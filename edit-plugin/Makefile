# in clean remove all .so and .db files

# Variables
CC = gcc
CFLAGS = -shared -fPIC
LIB_NAME = libdatabase.so
SRC = database.c

# Targets
all: $(LIB_NAME)

$(LIB_NAME): $(SRC)
	$(CC) $(CFLAGS) -o $(LIB_NAME) $(SRC) -lsqlite3

clean:
	rm -f $(LIB_NAME) *.db test.db*

.PHONY: all clean

