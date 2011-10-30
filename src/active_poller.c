#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <xdo.h>
#include <unistd.h>

#define WINDOW_NAME_BUFFER_SIZE 1024

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
    memset(window_name, 0, sizeof(window_name));
    return window_name;
  }
  strncpy(window_name, (char *)xdo_buff, WINDOW_NAME_BUFFER_SIZE);
  window_name[WINDOW_NAME_BUFFER_SIZE-1] = '\0';
  XFree(xdo_buff);
  return window_name;
}

Window getActiveWindowHandler(xdo_t *xdoobj) {
  Window active_w = 0;
  xdo_window_get_active(xdoobj, &active_w);
  if(!active_w) {
    fprintf(stderr, "Fail: xdo_window_get_active\n");
    return 0;
  }
  return active_w;
}

int main(int argc, char **argv) {
  xdo_t *xdoobj = xdo_new(NULL);
  if(argc < 2) {
    fprintf(stderr, "active_poller INTERVAL(in us)\n");
    return 1;
  }
  int interval = atoi(argv[1]);
  fprintf(stderr, "Interval: %d us\n", interval);

  if(!xdoobj) {
    fprintf(stderr, "Fail: xdo_new\n");
    return 1;
  }
  fprintf(stderr, "Success\n");
  // Display *dsp = xdoobj->xdpy;
  // Window root_w = DefaultRootWindow(dsp);

  while(1) {
    Window awin;
    xdo_keysequence(xdoobj, CURRENTWINDOW, "a", 0);
    awin = getActiveWindowHandler(xdoobj);
    fprintf(stderr, "Active: %d > %s\n", (int)awin,getWindowName(xdoobj, awin));
    usleep(interval);
  }
}
