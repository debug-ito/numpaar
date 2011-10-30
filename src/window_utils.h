#ifndef __WINDOW_UTILS_H_
#define __WINDOW_UTILS_H_

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <xdo.h>

char *getWindowName(xdo_t *xdoobj, Window window);
Window getActiveWindowHandler(xdo_t *xdoobj);
Window *getWindowList(xdo_t *xdoobj, int *num_windows);
char *getWindowClassAndName(xdo_t *xdoobj, Window window);

#define WINDOW_NAME_BUFFER_SIZE 1024
#define WINDOW_CLASSNAME_BUFFER_SIZE 2048

#endif //__WINDOW_UTILS_H_
