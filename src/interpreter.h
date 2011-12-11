#ifndef __INTERPRETER_H_
#define __INTERPRETER_H_

typedef enum {
  INTERPRET_OK,
  INTERPRET_END,
  INTERPRET_NO_COMMAND,
  INTERPRET_OUT_OF_MEMORY,
  INTERPRET_UNKNOWN_COMMAND,
  INTERPRET_INVALID_KEYSTR,
} interpret_result_t;

void initInterpreter(xdo_t *xdoptr);
interpret_result_t interpret(char *command_str);

#endif //__INTERPRETER_H_

