#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <signal.h>
#include <xdo.h>

#include "keygrab_manager.h"
#include "socket_manager.h"
#include "interpreter.h"
#include "update_thread.h"
#include "window_utils.h"

#define DEBUG

#ifdef DEBUG
static char *event_names[LASTEvent+1];

void debugInitEventNames() {
  event_names[2] = "KeyPress";
  event_names[3] = "KeyRelease";
  event_names[4] = "ButtonPress";
  event_names[5] = "ButtonRelease";
  event_names[6] = "MotionNotify";
  event_names[7] = "EnterNotify";
  event_names[8] = "LeaveNotify";
  event_names[9] = "FocusIn";
  event_names[10] = "FocusOut";
  event_names[11] = "KeymapNotify";
  event_names[12] = "Expose";
  event_names[13] = "GraphicsExpose";
  event_names[14] = "NoExpose";
  event_names[15] = "VisibilityNotify";
  event_names[16] = "CreateNotify";
  event_names[17] = "DestroyNotify";
  event_names[18] = "UnmapNotify";
  event_names[19] = "MapNotify";
  event_names[20] = "MapRequest";
  event_names[21] = "ReparentNotify";
  event_names[22] = "ConfigureNotify";
  event_names[23] = "ConfigureRequest";
  event_names[24] = "GravityNotify";
  event_names[25] = "ResizeRequest";
  event_names[26] = "CirculateNotify";
  event_names[27] = "CirculateRequest";
  event_names[28] = "PropertyNotify";
  event_names[29] = "SelectionClear";
  event_names[30] = "SelectionRequest";
  event_names[31] = "SelectionNotify";
  event_names[32] = "ColormapNotify";
  event_names[33] = "ClientMessage";
  event_names[34] = "MappingNotify";
  event_names[35] = "GenericEvent";
  event_names[36] = "LASTEvent";
}
#endif //DEBUG

#define NOTIFY_BUFFER_SIZE 1024
#define RECEIVE_BUFFER_SIZE 2048

static char notify_buffer[NOTIFY_BUFFER_SIZE];
static char receive_buffer[RECEIVE_BUFFER_SIZE];

void finish() {
  releaseSocketFile();
  exit(0);
}

void setSignalHandlers() {
  signal(SIGHUP,  finish);
  signal(SIGTERM, finish);
  signal(SIGINT,  finish);
  signal(SIGQUIT, finish);
  signal(SIGPIPE, finish);
}

int getChannel(xdo_t *xdo) {
  long current_desktop;
  xdo_get_current_desktop(xdo, &current_desktop);
  return (int)current_desktop;
}

void setNotifyBuffer(xdo_t *xdo, const char *pushed_numpaar_key, Window active_window, char * active_name) {
  int written_num;
  written_num= snprintf(notify_buffer, NOTIFY_BUFFER_SIZE, "%s\n%d\n%s\n",
                         pushed_numpaar_key, getChannel(xdo), active_name == NULL ? getWindowClassAndName(xdo, active_window) : active_name);
  if(written_num >= NOTIFY_BUFFER_SIZE) {
    fprintf(stderr, "setNotifyBuffer: notify_buffer is too short.\n");
    notify_buffer[NOTIFY_BUFFER_SIZE-1] = '\0';
  }
}

void readCommands() {
  interpret_result_t ret = INTERPRET_OK;
  while(ret != INTERPRET_END) {
    readLineFromEngine(receive_buffer, RECEIVE_BUFFER_SIZE);
    ret = interpret(receive_buffer);
  }
}

void notifyAndProcessCommands(xdo_t *xdo, const char *pushed_numpaar_key, Window active_window, char *active_name) {
  setNotifyBuffer(xdo, pushed_numpaar_key, active_window, active_name);
  fprintf(stderr, "Event notify: %s\n", pushed_numpaar_key);
  writeToEngine(notify_buffer);
  readCommands();
}

// ** キー押しっぱなしによるオートリピートを検出しないといけない。
// ** オートリピートによって発生したKeyReleaseイベントではトリガーしない。
// ** http://stackoverflow.com/questions/2100654/ignore-auto-repeat-in-x11-applications
int isKeyTriggerred(XEvent *event, Display *disp) {
  if (event->type == KeyRelease) {
    if(XEventsQueued(disp, QueuedAfterReading)) {
      XEvent nev;
      XPeekEvent(disp, &nev);
      
      if(nev.type == KeyPress && nev.xkey.time == event->xkey.time &&
         nev.xkey.keycode == event->xkey.keycode) {
        /* Key wasn't actually released */
        return 0;
      }
    }
    return 1;
  }
  return 0;
}

void switchChannel(xdo_t *xdo, long new_channel, Window active_window) {
  xdo_set_current_desktop(xdo, new_channel);
  // notifyAndProcessCommands(xdo, "switch", active_window);
  notifyUpdateDefault();
}

void showEvent(FILE *out, xdo_t *xdo, XEvent *event) {
  XAnyEvent *anyevent = (XAnyEvent*)event;
  static unsigned char seq = 0;
  
#ifdef DEBUG
  fprintf(out, "%03d Event type: %d (%s)\n", seq, anyevent->type, event_names[anyevent->type]);
#else
  fprintf(out, "%03 Event type: %d\n", seq, anyevent->type);
#endif //DEBUG
  seq++;
}

// void listOfWindows(xdo_t *xdo) {
//   xdo_search_t query;
//   memset(&query, 0, sizeof(query));
//   query.max_depth = 2;
//   query.only_visible = 1;
//   query.require = SEARCH_ALL;
//   query.searchmask = SEARCH_ONLYVISIBLE;
// 
//   Window *window_list = NULL;
//   int num_windows = 0;
//   fprintf(stderr, "Active: %s\n", getWindowName(xdo, getActiveWindowHandler(xdo)));
//   fprintf(stderr, "List of windows\n");
//   xdo_window_search(xdo, &query, &window_list, &num_windows);
//   if(!window_list) {
//     fprintf(stderr, "  Failure.\n");
//     return;
//   }
//   for(int i = 0 ; i < num_windows ; i++) {
//     fprintf(stderr, "  > %s\n", getWindowName(xdo, window_list[i]));
//   }
//   free(window_list);
// }

int myXErrorHandler(Display *disp, XErrorEvent *xerror) {
  fprintf(stderr, "XError: type:%d  serial:%d  errorCode:%d  requestCode:%d  minorCode:%d\n",
          xerror->type, (int)xerror->serial, xerror->error_code, xerror->request_code, xerror->minor_code);
  return 0;
}

void updateActiveWindows(xdo_t *xdoobj, Window *cur_win, Window *last_win, char **cur_name_ptr, char **last_name_ptr) {
  // ** Swap window names
  char *temp_name_ptr = *last_name_ptr;
  *last_name_ptr = *cur_name_ptr;
  *cur_name_ptr = temp_name_ptr;
  
  *last_win = *cur_win;
  *cur_win = getActiveWindowHandler(xdoobj);
  if(*cur_win == 0) {
    *cur_win = getActiveWindowHandler(xdoobj); // retry
  }
  strcpy(*cur_name_ptr, getWindowClassAndName(xdoobj, *cur_win));
  fprintf(stderr, "  Last active: %d %s\n", (int)(*last_win), *last_name_ptr);
  fprintf(stderr, "  Curr active: %d %s\n", (int)(*cur_win),  *cur_name_ptr);
  if(*cur_win != *last_win || strcmp(*cur_name_ptr, *last_name_ptr) != 0) {
    notifyAndProcessCommands(xdoobj, "switch", *cur_win, *cur_name_ptr);
  }
}

void usage() {
  fprintf(stderr, "numpaar_x SOCKET_PATH\n");
}

int main(int argc, char **argv) {
  char *socket_pathname;
  if(argc < 2) {
    usage();
    return 1;
  }
  socket_pathname = argv[1];
  xdo_t *xdoobj = xdo_new(NULL);
  if(!xdoobj) {
    fprintf(stderr, "Fail: xdo_new\n");
    return 1;
  }
  Display *dsp = xdoobj->xdpy;
  Window root_w = DefaultRootWindow(dsp);

  debugInitEventNames();

  XSetErrorHandler(myXErrorHandler);
  initInterpreter(xdoobj);
  initNumpaarKeys(dsp, root_w);
  setGrabPeriodKey(1);
  initUpdateThread(xdoobj);
  setSignalHandlers();
  if(!initSocket(socket_pathname)) {
    return 1;
  }

  XSelectInput(dsp, root_w, SubstructureNotifyMask);
  
  XEvent event;
  int event_looped = 1;
  Window cur_active_win, last_active_win;
  // ** cur_active_name and last_active_name point to one of the two text buffers of window_names.
  static char window_names[2][WINDOW_NAME_BUFFER_SIZE];
  char *cur_active_name  = window_names[0];
  char *last_active_name = window_names[1];
  
  cur_active_win = last_active_win = 0;
  notifyAndProcessCommands(xdoobj, "switch", cur_active_win, NULL);
  updateActiveWindows(xdoobj, &cur_active_win, &last_active_win, &cur_active_name, &last_active_name);
  
  xserverLock();
  while(event_looped) {
  event_loop_head:
    xserverUnlock();
    XNextEvent(dsp, &event);
    xserverLock();
    showEvent(stderr, xdoobj, &event);

    KeySym s = 0;
    XClientMessageEvent *cme = (XClientMessageEvent*)(&event);
    switch(event.type) {
    case KeyRelease:
    case KeyPress:
      XLookupString(&event.xkey, NULL, 0, &s, NULL);
      fprintf(stderr, "  %s: %s\n", (event.type == KeyRelease) ? "RL" : "PS", XKeysymToString(s));
      if(isKeyTriggerred(&event, dsp)) {
        updateActiveWindows(xdoobj, &cur_active_win, &last_active_win, &cur_active_name, &last_active_name);
        const char *numpaar_key = getNumpaarKeyStringFromXKey(s);
        if(!numpaar_key) goto event_loop_head;
        notifyAndProcessCommands(xdoobj, numpaar_key, cur_active_win, cur_active_name);
      }
      break;
    case ConfigureNotify:
    case DestroyNotify:
      notifyUpdateDefault();
      break;
    case ClientMessage:
      if(strcmp(cme->data.b, "awin") == 0) {
        // ** a trigger to update active windows
        fprintf(stderr, "ClientMessage - awin received.\n");
        updateActiveWindows(xdoobj, &cur_active_win, &last_active_win, &cur_active_name, &last_active_name);
      }
      break;
    }
  }
  
  releaseAllGrab(dsp, &root_w);
  releaseSocketFile();
  xdo_free(xdoobj);
  return 0;
}


