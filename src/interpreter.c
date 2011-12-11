#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xdo.h>
#include <unistd.h>
#include "interpreter.h"
#include "keygrab_manager.h"
#include "update_thread.h"
#include "socket_manager.h"
#include "window_utils.h"

// ** Recommended delay for xdo_type
#define XDO_TYPE_DELAY 12000

typedef struct {
  const char *command_name;
  int num_of_argument;
  interpret_result_t (*command_handler)(int token_num);
} CommandCatalogue;

#define COMMAND_NUM 11

static CommandCatalogue com_catalogue[COMMAND_NUM];

#define TOKEN_MAX_NUM 32
#define TOKEN_DELIM_STR ",\n\r"

static char *command_tokens[TOKEN_MAX_NUM];

static xdo_t *xdo_obj;

//////////////////////

interpret_result_t comEnd(int token_numn) {
  return INTERPRET_END;
}

interpret_result_t comKeyGrab(int token_num) {
  int target_key = getNumpaarKeyFromString(command_tokens[1]);
  if(target_key < 0) return INTERPRET_INVALID_KEYSTR;
  unsigned char want_grab = (strcmp(command_tokens[2], "on") == 0 ? 1 : 0);
  setGrabState((numpaar_key_t)target_key, want_grab);
  return INTERPRET_OK;
}

interpret_result_t comKeyRelease(int token_num) {
  releaseAllGrab();
  return INTERPRET_OK;
}

interpret_result_t comXdoKey(int token_num) {
  xdo_keysequence(xdo_obj, CURRENTWINDOW, command_tokens[1], 0);
  return INTERPRET_OK;
}

int convertHexToInt(char hex_four_bit) {
  if(hex_four_bit >= '0' && hex_four_bit <= '9') {
    return hex_four_bit - '0';
  }else if(hex_four_bit >= 'A' && hex_four_bit <= 'F') {
    return hex_four_bit - 'A' + 10;
  }else if(hex_four_bit >= 'a' && hex_four_bit <= 'f') {
    return hex_four_bit - 'a' + 10;
  }else {
    return -1;
  }
}

interpret_result_t comXdoType(int token_num) {
  char *encoded_arg = command_tokens[1];
  int size = strlen(encoded_arg) / 2;
  char *arg = (char *)malloc(size + 1);
  if(!arg) {
    return INTERPRET_OUT_OF_MEMORY;
  }
  memset(arg, 0, size + 1);
  for(int i = 0 ; i < size ; i++) {
    arg[i] = (convertHexToInt(encoded_arg[i*2]) << 4) + convertHexToInt(encoded_arg[i*2+1]);
  }
  xdo_type(xdo_obj, CURRENTWINDOW, arg, XDO_TYPE_DELAY);
  free(arg);
  return INTERPRET_OK;
}


interpret_result_t comKeyGrabSetOn(int token_num) {
  setAllGrabStates(&command_tokens[1], token_num - 1);
  return INTERPRET_OK;
}

interpret_result_t comWaitMsec(int token_num) {
  int wait_msec = atoi(command_tokens[1]);
  fprintf(stderr, "Wait for %dmsec...\n", wait_msec);
  usleep(wait_msec * 1000);
  return INTERPRET_OK;
}

interpret_result_t comUpdateActive(int token_num) {
  long defer_time = atol(command_tokens[1]);
  fprintf(stderr, "Deferred update in %ldmsec...\n", defer_time);
  notifyUpdate(defer_time);
  return INTERPRET_OK;
}

interpret_result_t comMouseClick(int token_num) {
  int button = atoi(command_tokens[1]);
  int x = atoi(command_tokens[2]);
  int y = atoi(command_tokens[3]);
  long screen = 0;
  // xdo_get_current_desktop(xdo_obj, &screen);
  xdo_mousemove(xdo_obj, x, y, (int)screen);
  xdo_click(xdo_obj, CURRENTWINDOW, button);
  return INTERPRET_OK;
}

interpret_result_t comXdoKeyChange(int token_num) {
  char *key = command_tokens[1];
  int is_keydown = (command_tokens[2][0] == '0' ? 0 : 1);
  if(is_keydown) {
    xdo_keysequence_down(xdo_obj, CURRENTWINDOW, key, 0);
  }else {
    xdo_keysequence_up(xdo_obj, CURRENTWINDOW, key, 0);
  }
  return INTERPRET_OK;
}

void outputWindowToBack(Window win, char *buffer, int buf_size) {
  int ret = snprintf(buffer, buf_size, "%u %s\n", (unsigned int)win, getWindowName(xdo_obj, win));
    if(ret >= buf_size) {
      fprintf(stderr, "outputWindowToBack: Buffer too short.\n");
      return;
    }
    writeToEngine(buffer);
}

int isWindowForPager(Window win) {
  long nitems;
  Atom type;
  int size;
  Atom *state_list = (Atom *)xdo_getwinprop(xdo_obj, win, XInternAtom(xdo_obj->xdpy, "_NET_WM_STATE", False), &nitems, &type, &size);
  // fprintf(stderr, "isWindowForPager:\n  IN: WID=%d\n", (int)win);
  if(!state_list) {
    // fprintf(stderr, "  FAILED.\n");
    return 1;
  }
  Atom pager_atom = XInternAtom(xdo_obj->xdpy, "_NET_WM_STATE_SKIP_PAGER", False);
  int ret = 1;
  for(int i = 0 ; i < nitems ; i++) {
    if(state_list[i] == pager_atom) {
      ret = 0;
      break;
    }
  }
  XFree(state_list);
  return ret;
}

interpret_result_t comWinList(int token_num) {
  const int WINLIST_BUFSIZE = 2048;
  int winnum = 0;
  char buffer[WINLIST_BUFSIZE];
  Window *winlist = getWindowList(xdo_obj, &winnum);
  for(int i = winnum-1 ; i >= 0 ; i--) {
    if(isWindowForPager(winlist[i])) {
      outputWindowToBack(winlist[i], buffer, WINLIST_BUFSIZE);
    }
  }
  snprintf(buffer, WINLIST_BUFSIZE, "endlist\n");
  writeToEngine(buffer);
  XFree(winlist);
  return INTERPRET_OK;
}

//////////////////////

int tokenizeCommandLine(char *command_line) {
  int token_num = 0;
  command_tokens[0] = strtok(command_line, TOKEN_DELIM_STR);
  if(command_tokens[0] == NULL) {
    return token_num;
  }
  token_num++;
  while( (command_tokens[token_num] = strtok(NULL, TOKEN_DELIM_STR)) ) {
    token_num++;
  }
  return token_num;
}

void initInterpreter(xdo_t *xdoptr) {
  int i = 0;
  xdo_obj = xdoptr;
  com_catalogue[i].command_name = "end";
  com_catalogue[i].num_of_argument = 0;
  com_catalogue[i].command_handler = comEnd;
  i++;
  com_catalogue[i].command_name = "keygrab";
  com_catalogue[i].num_of_argument = 2;
  com_catalogue[i].command_handler = comKeyGrab;
  i++;
  com_catalogue[i].command_name = "keyrelease";
  com_catalogue[i].num_of_argument = 0;
  com_catalogue[i].command_handler = comKeyRelease;
  i++;
  com_catalogue[i].command_name = "xdokey";
  com_catalogue[i].num_of_argument = 1;
  com_catalogue[i].command_handler = comXdoKey;
  i++;
  com_catalogue[i].command_name = "keygrabseton";
  com_catalogue[i].num_of_argument = 1;
  com_catalogue[i].command_handler = comKeyGrabSetOn;
  i++;
  com_catalogue[i].command_name = "waitmsec";
  com_catalogue[i].num_of_argument = 1;
  com_catalogue[i].command_handler = comWaitMsec;
  i++;
  com_catalogue[i].command_name = "updateactive";
  com_catalogue[i].num_of_argument = 1;
  com_catalogue[i].command_handler = comUpdateActive;
  i++;
  com_catalogue[i].command_name = "mouseclick";
  com_catalogue[i].num_of_argument = 3;
  com_catalogue[i].command_handler = comMouseClick;
  i++;
  com_catalogue[i].command_name = "xdotype";
  com_catalogue[i].num_of_argument = 1;
  com_catalogue[i].command_handler = comXdoType;
  i++;
  com_catalogue[i].command_name = "xdokeychange";
  com_catalogue[i].num_of_argument = 2;
  com_catalogue[i].command_handler = comXdoKeyChange;
  i++;
  com_catalogue[i].command_name = "winlist";
  com_catalogue[i].num_of_argument = 0;
  com_catalogue[i].command_handler = comWinList;
  i++;
}

interpret_result_t interpret(char *command_str) {
  int token_num = tokenizeCommandLine(command_str);
  int i;
  if(token_num <= 0) return INTERPRET_NO_COMMAND;

  // ** TODO: ハッシュ的な連想配列を使って効率よくやる。
  for(i = 0 ; i < COMMAND_NUM ; i++) {
    if(com_catalogue[i].num_of_argument <= token_num-1
       && strcmp(com_catalogue[i].command_name, command_tokens[0]) == 0) {
      
      fprintf(stderr, "Accept command line: %s", command_tokens[0]);
      for(int j = 1 ; j < token_num ; j++) {
        fprintf(stderr, ",%s", command_tokens[j]);
      }
      fprintf(stderr, "\n");
      
      return (com_catalogue[i].command_handler)(token_num);
    }
  }
  return INTERPRET_UNKNOWN_COMMAND;
}



