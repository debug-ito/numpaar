#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "window_utils.h"

char *getWindowName(xdo_t *xdoobj, Window window) {
  static char window_name[WINDOW_NAME_BUFFER_SIZE] = "";
  unsigned char *xdo_buff;
  int name_len  = 0;
  int name_type = 0;
  if(!window) {
    strcpy(window_name, "[NULL]");
    return window_name;
  }
  xdo_get_window_name(xdoobj, window, &xdo_buff, &name_len, &name_type);
  if(!xdo_buff) {
    strcpy(window_name, "[NULL]");
    return window_name;
  }
  strncpy(window_name, (char *)xdo_buff, WINDOW_NAME_BUFFER_SIZE);
  window_name[WINDOW_NAME_BUFFER_SIZE-1] = '\0';
  XFree(xdo_buff);
  return window_name;
}

Window getActiveWindowHandler(xdo_t *xdoobj) {
  Window active_w = 0;
  // my_xdo_window_get_active(xdoobj, &active_w);
  xdo_window_get_active(xdoobj, &active_w);
  if(!active_w) {
    fprintf(stderr, "Fail: xdo_window_get_active\n");
    return 0;
  }
  return active_w;
}

// ** wmctrlとxdoのソースコードを参考にした
Window *getWindowList(xdo_t *xdoobj, int *num_windows) {
  long nitems;
  Atom type;
  int  size;
  unsigned char *prop = NULL;
  prop = xdo_getwinprop(xdoobj, DefaultRootWindow(xdoobj->xdpy),
                        XInternAtom(xdoobj->xdpy, "_NET_CLIENT_LIST_STACKING", False), &nitems, &type, &size);
  if(!prop) {
    prop = xdo_getwinprop(xdoobj, DefaultRootWindow(xdoobj->xdpy),
                          XInternAtom(xdoobj->xdpy, "_NET_CLIENT_LIST", False), &nitems, &type, &size);
  }
  if(!prop) {
    prop = xdo_getwinprop(xdoobj, DefaultRootWindow(xdoobj->xdpy),
                          XInternAtom(xdoobj->xdpy, "_WIN_CLIENT_LIST", False), &nitems, &type, &size);
  }
  if(!prop) {
      fprintf(stderr, "Cannot obtain X client list.\n");
      return NULL;
  }
  *num_windows = (int)nitems;
  return (Window *)prop;
}

char *getWindowClassAndName(xdo_t *xdoobj, Window window) {
  static char class_str[WINDOW_CLASSNAME_BUFFER_SIZE];
  XClassHint class_info;
  memset(&class_info, 0, sizeof(class_info));
  class_str[0] = '\0';
  if(XGetClassHint(xdoobj->xdpy, window, &class_info)) {
    if(snprintf(class_str, WINDOW_CLASSNAME_BUFFER_SIZE, "%s.%s %s",
                class_info.res_name, class_info.res_class, getWindowName(xdoobj, window)) >= WINDOW_CLASSNAME_BUFFER_SIZE) {
      fprintf(stderr, "getWindowClassAndName: buffer too short.\n");
    }
  }else {
    class_str[0] = '\0';
  }
  class_str[WINDOW_CLASSNAME_BUFFER_SIZE-1] = '\0';
  if(class_info.res_name) XFree(class_info.res_name);
  if(class_info.res_class) XFree(class_info.res_class);
  return class_str;
}
