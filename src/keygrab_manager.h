
#ifndef __KEYGRAB_MANAGER_H_
#define __KEYGRAB_MANAGER_H_

#include <X11/Xlib.h>
#include <X11/keysym.h>

typedef enum {
  NUMPAAR_UP,
  NUMPAAR_DOWN,
  NUMPAAR_LEFT,
  NUMPAAR_RIGHT,
  NUMPAAR_HOME,
  NUMPAAR_PAGEUP,
  NUMPAAR_PAGEDOWN,
  NUMPAAR_END,
  NUMPAAR_CENTER,
  NUMPAAR_INSERT,
  NUMPAAR_DELETE,
  NUMPAAR_ENTER,
  NUMPAAR_DIVIDE,
  NUMPAAR_MULTIPLY,
  NUMPAAR_MINUS,
  NUMPAAR_PLUS,
  // NUMPAAR_NUMLOCK,
  // NUMPAAR_PERIOD,
  // NUMPAAR_00,
  // NUMPAAR_01,
  // NUMPAAR_02,
  // NUMPAAR_03,
  // NUMPAAR_04,
  // NUMPAAR_05,
  // NUMPAAR_06,
  // NUMPAAR_07,
  // NUMPAAR_08,
  // NUMPAAR_09,
  NUMPAAR_KEY_NUM, // must be last in enum
} numpaar_key_t;

void initNumpaarKeys(Display *dsp, Window root_w);
int setGrabState(numpaar_key_t key, unsigned char want_grab);
void setAllGrabStates(char **keystrings, int num_of_kenstrings);
void releaseAllGrab();
const char *getNumpaarKeyStringFromXKey(KeySym xkey);
int getNumpaarKeyFromString(const char *keystring);

#endif //__KEYGRAB_MANAGER_H_


