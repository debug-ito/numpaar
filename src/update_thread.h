#ifndef __UPDATE_THREAD_H_
#define __UPDATE_THREAD_H_

#include <X11/Xlib.h>
#include <xdo.h>

// void updateActiveWindows(xdo_t *xdoobj);
// void getActiveWindows(Window *cur, Window *last);
// void initActiveWindowManager(xdo_t *xdoobj, void (*callback)(xdo_t *, Window));
void initUpdateThread(xdo_t *xdoobj);
void notifyUpdateDefault();
void notifyUpdate(long update_defer_time_msec);
// ** Xサーバーに触れる処理全体は、以下の関数でロックしなければいけない。
void xserverLock();
void xserverUnlock();

#endif // __UPDATE_THREAD_H_


