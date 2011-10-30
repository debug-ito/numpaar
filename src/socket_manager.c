#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <signal.h>
#include <sys/un.h>
#include <string.h>
#include "socket_manager.h"

#define SOCKET_PATH_MAX 256

static char numpaar_socket_path[SOCKET_PATH_MAX];
static int listening_socket = -1;
static int numpaar_socket = -1;
static FILE *read_stream = NULL;

void releaseSocketFile() {
  struct stat buf;
  // if(read_stream) {
  //   fclose(read_stream);
  //   read_stream = NULL;
  // }
  // if(numpaar_socket >= 0) {
  //   close(numpaar_socket);
  //   numpaar_socket = -1;
  // }
  // if(listening_socket >= 0) {
  //   close(listening_socket);
  //   listening_socket = -1;
  // }
  if(stat(numpaar_socket_path, &buf) < 0) return;
  unlink(numpaar_socket_path);
}

int initSocket(const char *socket_path) {
  struct sockaddr_un address;
  int addr_len;
  memset(numpaar_socket_path, 0, sizeof(numpaar_socket_path));
  if(listening_socket < 0) {
    listening_socket = socket(AF_UNIX, SOCK_STREAM, 0);
    if(listening_socket < 0) {
      perror("establishConnection: socket");
      fprintf(stderr, "cannot create listening socket.\n");
      return 0;
    }
  }
  memset(&address, 0, sizeof(address));
  address.sun_family = AF_UNIX;
  strcpy(address.sun_path, socket_path);
  addr_len = sizeof(address.sun_family) + strlen(address.sun_path);
  //
  if(bind(listening_socket, (struct sockaddr *)&address, addr_len) < 0) {
    perror("establishConnection: bind");
    fprintf(stderr, "Cannot bind the socket.\n");
    return 0;
  }
  strcpy(numpaar_socket_path, socket_path);
  if(listen(listening_socket, 1) < 0) {
    perror("establishConnection: listen");
    return 0;
  }
  numpaar_socket = accept(listening_socket, NULL, NULL);
  if(numpaar_socket < 0) {
    perror("establishConnection: accept");
    return 0;
  }
  read_stream = fdopen(numpaar_socket, "r");
  return 1;
}

int writeToEngine(const char *write_str) {
  if(numpaar_socket < 0) {
    fprintf(stderr, "ERROR: communication socket is uninitialized.\n");
    goto error_end;
  }
  if(write(numpaar_socket, write_str, strlen(write_str)) < 0) {
    fprintf(stderr, "ERROR: communication socket is broken. Unable to write.\n");
    goto error_end;
  }
  return 1;
 error_end:
  kill(getpid(), SIGTERM);
  return 0;
}

int readLineFromEngine(char *rx_buffer, int buffer_size) {
  if(!read_stream) {
    fprintf(stderr, "ERROR: communication socket is uninitialized.\n");
    goto error_end;
  }
  if(!fgets(rx_buffer, buffer_size, read_stream)) {
    fprintf(stderr, "ERROR: communication socket is broken. Unable to read.\n");
    goto error_end;
  }
  return 1;
 error_end:
  kill(getpid(), SIGTERM);
  return 0;
}

