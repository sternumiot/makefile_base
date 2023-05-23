OUTPUT_FILE = libunitests.a
# Files that will be copied to the build dir
EXTERNAL_HEADERS_SRC = components/fff/fff.h $(HEADERS_DIR)/test.h

CC = gcc
FINAL_STAGE = @ar srv $@ $^

TESTS_SRC_DIR = tests
SRC_DIR = src
HEADERS_DIR = include
BUILD_DIR = build

C_INCLUDES = -I$(HEADERS_DIR)
C_DEFS =
CFLAGS = $(C_DEFS) $(C_INCLUDES) -Wa,-aln=$(@:.o=.s)  -g -O0
