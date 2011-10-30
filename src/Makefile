PROJ=numpaar_x
OBJ=numpaar_x.o keygrab_manager.o socket_manager.o interpreter.o update_thread.o window_utils.o
CC=gcc
CPP=g++
CFLAGS=-Wall -std=gnu99 -g -O2
LDFLAGS=`pkg-config --libs x11` -lxdo -lpthread -lrt

all: tag $(PROJ)

$(PROJ): $(OBJ)
	$(CC) $(LDFLAGS) $^ -o $@

active_poller: active_poller.o
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	rm -f $(PROJ) $(OBJ) active_poller.o active_poller TAGS

tag:
	etags *.c

