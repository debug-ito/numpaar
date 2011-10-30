#ifndef __SOCKET_MANAGER_H_
#define __SOCKET_MANAGER_H_

int initSocket(const char *socket_path);
int writeToEngine(const char *write_str);
int readLineFromEngine(char *rx_buffer, int buffer_size);
void releaseSocketFile();

#endif //__SOCKET_MANAGER_H_


