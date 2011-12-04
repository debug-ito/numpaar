#include <string.h>
#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/keysym.h>
#include "keygrab_manager.h"

#define NUMPAAR_KEY_STR_SIZE 32

typedef struct {
  KeySym xkeysym;
  char numpaar_key_str[NUMPAAR_KEY_STR_SIZE];
  unsigned char is_grabbed;
} NumpaarKeyInfo;

static NumpaarKeyInfo keyinfo[NUMPAAR_KEY_NUM];
static Display *display_ptr;
static Window root_window;
static unsigned int numlock_mask = 0;

void setGrabXKeyRaw(int keycode, int is_numlocked, unsigned char want_grab) {
  unsigned int modifier = (is_numlocked ? numlock_mask : 0);
  if(want_grab) {
    XGrabKey(display_ptr, keycode, modifier, root_window, False, GrabModeAsync, GrabModeAsync);
    // XGrabKey(display_ptr, keycode, modifier | Mod1Mask, root_window, False, GrabModeAsync, GrabModeAsync); // ** ALTキー押してる状態でもグラブする
  }else {
    XUngrabKey(display_ptr, keycode, modifier, root_window);
    // XUngrabKey(display_ptr, keycode, modifier | Mod1Mask, root_window);
  }
}

void setGrabXKey(KeySym xkey, unsigned char want_grab) {
  int numlocked = 0;
  int keycode = XKeysymToKeycode(display_ptr, xkey);
  // ** numlock状態でもgrabしたいならここを有効にする。
  // if(xkey == XK_KP_Divide || xkey == XK_KP_Multiply
  //    || xkey == XK_KP_Subtract || xkey == XK_KP_Add ||
  //    xkey == XK_KP_Enter) {
  //   setGrabXKeyRaw(keycode, 0, want_grab);
  //   setGrabXKeyRaw(keycode, 1, want_grab);
  //   return;
  // }
  if(xkey >= XK_KP_0 && xkey <= XK_KP_9) {
    numlocked = 1;
  }
  if(xkey == XK_KP_Decimal) {
    // ** XK_KP_DecimalをXKeysymToKeycodeにつっこむと、なぜか正しいkeycodeを返さない。
    numlocked = 1;
    xkey = XK_KP_Delete;
  }
  setGrabXKeyRaw(keycode, numlocked, want_grab);
}

// ** Reference: grab_key.c of xbindkey package
void setNumlockMask() {
  int i;
  XModifierKeymap *modmap;
  KeyCode nlock;
  static int mask_table[8] = {
    ShiftMask, LockMask, ControlMask, Mod1Mask,
    Mod2Mask, Mod3Mask, Mod4Mask, Mod5Mask
  };
  nlock = XKeysymToKeycode (display_ptr, XK_Num_Lock);
  modmap = XGetModifierMapping (display_ptr);

  if (modmap != NULL && modmap->max_keypermod > 0) {
    for (i = 0; i < 8 * modmap->max_keypermod; i++) {
      if (modmap->modifiermap[i] == nlock && nlock != 0) {
        numlock_mask = mask_table[i / modmap->max_keypermod];
      }
    }
  }

  if(modmap) {
    XFreeModifiermap (modmap);
  }
}

void initNumpaarKeys(Display *dsp, Window root_w) {
  display_ptr = dsp;
  root_window = root_w;
  setNumlockMask();
  memset(keyinfo, 0, sizeof(keyinfo));
  
  keyinfo[NUMPAAR_UP].xkeysym = XK_KP_Up;
  keyinfo[NUMPAAR_DOWN].xkeysym = XK_KP_Down;
  keyinfo[NUMPAAR_LEFT].xkeysym = XK_KP_Left;
  keyinfo[NUMPAAR_RIGHT].xkeysym = XK_KP_Right;
  keyinfo[NUMPAAR_HOME].xkeysym = XK_KP_Home;
  keyinfo[NUMPAAR_PAGEUP].xkeysym = XK_KP_Page_Up;
  keyinfo[NUMPAAR_PAGEDOWN].xkeysym = XK_KP_Page_Down;
  keyinfo[NUMPAAR_END].xkeysym = XK_KP_End;
  keyinfo[NUMPAAR_CENTER].xkeysym = XK_KP_Begin;
  keyinfo[NUMPAAR_INSERT].xkeysym = XK_KP_Insert;
  keyinfo[NUMPAAR_DELETE].xkeysym = XK_KP_Delete;
  keyinfo[NUMPAAR_ENTER].xkeysym = XK_KP_Enter;
  keyinfo[NUMPAAR_DIVIDE].xkeysym = XK_KP_Divide;
  keyinfo[NUMPAAR_MULTIPLY].xkeysym = XK_KP_Multiply;
  keyinfo[NUMPAAR_MINUS].xkeysym = XK_KP_Subtract;
  keyinfo[NUMPAAR_PLUS].xkeysym = XK_KP_Add;
  // keyinfo[NUMPAAR_PERIOD].xkeysym = XK_KP_Decimal;

  strcpy(keyinfo[NUMPAAR_UP].numpaar_key_str, "up");
  strcpy(keyinfo[NUMPAAR_DOWN].numpaar_key_str, "down");
  strcpy(keyinfo[NUMPAAR_LEFT].numpaar_key_str, "left");
  strcpy(keyinfo[NUMPAAR_RIGHT].numpaar_key_str, "right");
  strcpy(keyinfo[NUMPAAR_HOME].numpaar_key_str, "home");
  strcpy(keyinfo[NUMPAAR_PAGEUP].numpaar_key_str, "page_up");
  strcpy(keyinfo[NUMPAAR_PAGEDOWN].numpaar_key_str, "page_down");
  strcpy(keyinfo[NUMPAAR_END].numpaar_key_str, "end");
  strcpy(keyinfo[NUMPAAR_CENTER].numpaar_key_str, "center");
  strcpy(keyinfo[NUMPAAR_INSERT].numpaar_key_str, "insert");
  strcpy(keyinfo[NUMPAAR_DELETE].numpaar_key_str, "delete");
  strcpy(keyinfo[NUMPAAR_ENTER].numpaar_key_str, "enter");
  strcpy(keyinfo[NUMPAAR_DIVIDE].numpaar_key_str, "divide");
  strcpy(keyinfo[NUMPAAR_MULTIPLY].numpaar_key_str, "multiply");
  strcpy(keyinfo[NUMPAAR_MINUS].numpaar_key_str, "minus");
  strcpy(keyinfo[NUMPAAR_PLUS].numpaar_key_str, "plus");
  // strcpy(keyinfo[NUMPAAR_PERIOD].numpaar_key_str, "period");
  // 
  // int i;
  // for(i = 0 ; i < NUMPAAR_KEY_NUM - NUMPAAR_00 ; i++) {
  //   if(i < 10) {
  //     keyinfo[NUMPAAR_00 + i].xkeysym = XK_KP_0 + i;
  //   }
  //   sprintf(keyinfo[NUMPAAR_00 + i].numpaar_key_str, "chan_%02d", i);
  // }
}

KeySym mapNumpaarKeyToXKey(numpaar_key_t key) {
  return keyinfo[key].xkeysym;
  // switch(key) {
  // case NUMPAAR_UP: return XK_KP_Up;
  // case NUMPAAR_DOWN: return XK_KP_Down;
  // case NUMPAAR_LEFT: return XK_KP_Left;
  // case NUMPAAR_RIGHT: return XK_KP_Right;
  // case NUMPAAR_HOME: return XK_KP_Home;
  // case NUMPAAR_PAGEUP: return XK_KP_Page_Up;
  // case NUMPAAR_PAGEDOWN: return XK_KP_Page_Down;
  // case NUMPAAR_END: return XK_KP_End;
  // case NUMPAAR_CENTER: return XK_KP_Begin;
  // case NUMPAAR_INSERT: return XK_KP_Insert;
  // case NUMPAAR_DELETE: return XK_KP_Delete;
  // case NUMPAAR_ENTER: return XK_KP_Enter;
  // case NUMPAAR_DEVIDE: return XK_KP_Divide;
  // case NUMPAAR_MULTIPLY: return XK_KP_Multiply;
  // case NUMPAAR_MINUS: return XK_KP_Subtract;
  // case NUMPAAR_PLUS: return XK_KP_Add;
  // case NUMPAAR_PERIOD: return XK_KP_Decimal;
  // default:
  //   if(key <= NUMPAAR_09) {
  //     return XK_KP_0 + key - NUMPAAR_00;
  //   }
  // }
  // return 0;
}

// void setGrabChannelKeys(unsigned char want_grab) {
//   int i;
//   for(i = 0 ; i <= 9 ; i++) {
//     setGrabXKey(XK_KP_0 + i, want_grab);
//   }
// }

void setGrabPeriodKey(unsigned char want_grab) {
  setGrabXKey(XK_KP_Decimal, want_grab);
  // setGrabXKey(XK_period, want_grab);
}

int setGrabState(numpaar_key_t key, unsigned char want_grab) {
  if((keyinfo[key].is_grabbed && want_grab) || (!keyinfo[key].is_grabbed && !want_grab)) {
    return 0;
  }
  keyinfo[key].is_grabbed = want_grab;
  KeySym xkey = mapNumpaarKeyToXKey(key);
  if(!xkey) return 0;
  setGrabXKey(xkey, want_grab);
  return 1;
}

void setAllGrabStates(char **keystrings, int num_of_keystrings) {
  unsigned char desired_states[NUMPAAR_KEY_NUM];
  memset(desired_states, 0, sizeof(desired_states));
  for(int i = 0 ; i < num_of_keystrings ; i++) {
    int keyid = getNumpaarKeyFromString(keystrings[i]);
    if(keyid < 0) continue;
    desired_states[keyid] = 1;
  }
  int grab_count = 0;
  for(int i = 0 ; i < NUMPAAR_KEY_NUM ; i++) {
    grab_count += setGrabState(i, desired_states[i]);
  }
  // if(grab_count > 0) {
  //   // ** send a dummy event to unblock XNextEvent,
  //   // ** so that the change of grabs becomes in effect immediately.
  //   sendDummyEvent();
  // }
}

void releaseAllGrab() {
  numpaar_key_t i;
  for(i = 0 ; i < NUMPAAR_KEY_NUM ; i++) {
    setGrabState(i, 0);
  }
}

const char *getNumpaarKeyStringFromXKey(KeySym xkey) {
  int i;
  for(i = 0 ; i < NUMPAAR_KEY_NUM ; i++) {
    if(keyinfo[i].xkeysym == xkey && keyinfo[i].is_grabbed) {
      return keyinfo[i].numpaar_key_str;
    }
  }
  return NULL;
}

int getNumpaarKeyFromString(const char *keystring) {
  // ** TODO: ハッシュ的な連想配列で効率よく実装する。
  int i;
  for(i = 0 ; i < NUMPAAR_KEY_NUM ; i++) {
    if(strcmp(keystring, keyinfo[i].numpaar_key_str) == 0) {
      return i;
    }
  }
  return -1;
}
