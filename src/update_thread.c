#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>
#include <xdo.h>
#include <pthread.h>
#include <errno.h>
#include "update_thread.h"

// static pthread_mutex_t active_win_mutex; // ** To protect the active window handlers
// static Window cur_active_window;
// static Window last_active_window;

#define DEFAULT_UPDATE_DEFER_TIME_MSEC 200

static pthread_cond_t wakeup_cond;
static pthread_mutex_t wakeup_mutex; // ** To protect wakeup_time
static struct timespec wakeup_time_absolute;

static pthread_mutex_t xserver_mutex; // ** To protect X server

// static void (*winchange_callback)(xdo_t *, Window) = NULL;

#define isWakeupTimeSet() (wakeup_time_absolute.tv_sec != 0)

static Window root_win;
static XClientMessageEvent awin_update_msg;

//// int my_is_success(const char *funcname, int code) {
////   /* Nonzero is failure. */
////   if (code != 0)
////     fprintf(stderr, "CUSTOMIZED XDO: %s failed (code=%d)\n", funcname, code);
////   return code;
//// }
//// 
//// unsigned char *my_xdo_getwinprop(const xdo_t *xdo, Window window, Atom atom,
////                               long *nitems, Atom *type, int *size) {
////   Atom actual_type;
////   int actual_format;
////   unsigned long _nitems;
////   unsigned long nbytes;
////   unsigned long bytes_after; /* unused */
////   unsigned char *prop;
////   int status;
//// 
////   fprintf(stderr, "  my_xdo_getwinprop: before XGet\n");
////   status = XGetWindowProperty(xdo->xdpy, window, atom, 0, (~0L),
////                               False, AnyPropertyType, &actual_type,
////                               &actual_format, &_nitems, &bytes_after,
////                               &prop);
////   fprintf(stderr, "  my_xdo_getwinprop: after XGet\n");
////   if (status == BadWindow) {
////     fprintf(stderr, "window id # 0x%lx does not exists!", window);
////     return NULL;
////   } if (status != Success) {
////     fprintf(stderr, "XGetWindowProperty failed!");
////     return NULL;
////   }
//// 
////   if (actual_format == 32)
////     nbytes = sizeof(long);
////   else if (actual_format == 16)
////     nbytes = sizeof(short);
////   else if (actual_format == 8)
////     nbytes = 1;
////   else if (actual_format == 0)
////     nbytes = 0;
//// 
////   if (nitems != NULL) {
////     *nitems = _nitems;
////   }
//// 
////   if (type != NULL) {
////     *type = actual_type;
////   }
//// 
////   if (size != NULL) {
////     *size = actual_format;
////   }
////   return prop;
//// }
//// 
//// // ** ライブラリのxdo_window_get_active関数は、dataをfreeしていた。
//// // ** これがまずいのではと思い、ちゃんとXFreeするバージョンを独自に用意してみた。
//// int my_xdo_window_get_active(const xdo_t *xdo, Window *window_ret) {
////   Atom type;
////   int size;
////   long nitems = 0;
////   unsigned char *data;
////   Atom request;
////   Window root;
//// 
////   // if (_xdo_ewmh_is_supported(xdo, "_NET_ACTIVE_WINDOW") == False) {
////   //   fprintf(stderr,
////   //           "Your windowmanager claims not to support _NET_ACTIVE_WINDOW, "
////   //           "so the attempt to query the active window aborted.\n");
////   //   return XDO_ERROR;
////   // }
//// 
////   request = XInternAtom(xdo->xdpy, "_NET_ACTIVE_WINDOW", False);
////   root = XDefaultRootWindow(xdo->xdpy);
////   fprintf(stderr, "  Before xdo_getwinprop\n");
////   data = my_xdo_getwinprop(xdo, root, request, &nitems, &type, &size);
////   fprintf(stderr, "  After  xdo_getwinprop\n");
//// 
////   if (nitems > 0) {
////     *window_ret = *((Window*)data);
////   } else {
////     *window_ret = 0;
////   }
////   XFree(data);
//// 
////   return my_is_success("XGetWindowProperty[_NET_ACTIVE_WINDOW]",
////                      *window_ret == 0);
//// }
//// 
//// 
//// void getActiveWindows(Window *cur, Window *last) {
////   pthread_mutex_lock(&active_win_mutex);
////   *cur = cur_active_window;
////   *last = last_active_window;
////   pthread_mutex_unlock(&active_win_mutex);
//// }

void notifyUpdateDefault() {
  notifyUpdate(DEFAULT_UPDATE_DEFER_TIME_MSEC);
}

void notifyUpdate(long update_defer_time_msec) {
  struct timespec temp_time;
  // ** 現在時刻に一定時間を加え、遅延更新の実行時刻を作成する。
  // ** オーバーフローがコワいのでちょっと防衛的な演算をしてます。
  clock_gettime(CLOCK_REALTIME, &temp_time);
  long tv_nsec_msec = temp_time.tv_nsec / 1000000;
  long nsecpart     = temp_time.tv_nsec % 1000000;
  long ret_msec = tv_nsec_msec + update_defer_time_msec;
  long secpart  = ret_msec / 1000;
  long msecpart = ret_msec % 1000;
  temp_time.tv_sec  += secpart;
  temp_time.tv_nsec = msecpart * 1000000 + nsecpart;

  pthread_mutex_lock(&wakeup_mutex);
  wakeup_time_absolute = temp_time;
  pthread_mutex_unlock(&wakeup_mutex);

  pthread_cond_broadcast(&wakeup_cond);
  fprintf(stderr, "Notify update done.\n");
}

void sendDummyEvent(xdo_t *xdoobj) {
  fprintf(stderr, "sendDummyEvent..\n");
  XSendEvent(xdoobj->xdpy, root_win, False, SubstructureNotifyMask, (XEvent*)&awin_update_msg);
  XFlush(xdoobj->xdpy);
}

void *deferredUpdateThread(void *_xdoobj) {
  // ** active windowsの遅延更新のためのスレッド
  xdo_t *xdoobj = (xdo_t *)_xdoobj;
  struct timespec copied_wakeup_time;
  int retcode = 0;

  while(1) {
    pthread_mutex_lock(&wakeup_mutex);
    while(!isWakeupTimeSet()) {
      // ** 最初の遅延更新指示を待つ。
      pthread_cond_wait(&wakeup_cond, &wakeup_mutex);
    }
    while(retcode != ETIMEDOUT) {
      // ** 遅延更新のタイミングまで待つ。
      // ** 待機中にwakeup_time_absoluteの更新があった場合、待機目標時刻を修正してまた待機。
      copied_wakeup_time = wakeup_time_absolute;
      retcode = pthread_cond_timedwait(&wakeup_cond, &wakeup_mutex, &copied_wakeup_time);
    }
    fprintf(stderr, "Deferred update: START...\n");
    memset(&wakeup_time_absolute, 0, sizeof(wakeup_time_absolute));
    retcode = 0;
    pthread_mutex_unlock(&wakeup_mutex);
    xserverLock();
    fprintf(stderr, "Deferred update: ENTER X LOCK.\n");
    /// updateActiveWindows(xdoobj);
    sendDummyEvent(xdoobj);
    xserverUnlock();
    fprintf(stderr, "Deferred update: DONE...\n");
  }
}

void initUpdateThread(xdo_t *xdoobj) {
  // pthread_mutex_init(&active_win_mutex, NULL);
  pthread_mutex_init(&wakeup_mutex, NULL);
  pthread_mutex_init(&xserver_mutex, NULL);
  pthread_cond_init(&wakeup_cond, NULL);
  memset(&wakeup_time_absolute, 0, sizeof(wakeup_time_absolute));
  // cur_active_window = last_active_window = getActiveWindowHandler(xdoobj);
  // winchange_callback = callback;
  root_win = DefaultRootWindow(xdoobj->xdpy);

  memset(&awin_update_msg, 0, sizeof(awin_update_msg));
  awin_update_msg.type = ClientMessage;
  awin_update_msg.send_event = True;
  awin_update_msg.window = root_win;
  awin_update_msg.display = xdoobj->xdpy;
  awin_update_msg.format = 8;
  strcpy(awin_update_msg.data.b, "awin");

  pthread_t updater_thread;
  pthread_create(&updater_thread, NULL, deferredUpdateThread, xdoobj);
}

void xserverLock() {
  pthread_mutex_lock(&xserver_mutex);
}

void xserverUnlock() {
  pthread_mutex_unlock(&xserver_mutex);
}

