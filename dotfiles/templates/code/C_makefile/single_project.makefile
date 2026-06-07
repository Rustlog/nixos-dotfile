.PHONY: build install run default help
.DEFAULT_GOAL := build

PROJECT_NAME ?= main
PROJECT_DIR := .
SRC_DIR := $(PROJECT_DIR)/src
BUILD_DIR := $(PROJECT_DIR)/build
BIN_DIR := $(PROJECT_DIR)/bin
BINARY := $(BIN_DIR)/$(PROJECT_NAME)
PREFIX := /usr/local
INSTALL_DIR := $(PREFIX)/bin
C_FLAGS := -std=c23 -pedantic -Wall -Wpedantic -Wextra -Werror -Wconversion

SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRCS))

ifeq ($(SRCS),)
$(error no source files in src dir '$(SRC_DIR)')
endif

build: $(OBJS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(C_FLAGS) -o $(BINARY) $(OBJS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(C_FLAGS) -c -o $@ $<

$(BINARY):
	$(MAKE) --no-print-directory build

run: $(BINARY)
	$(BINARY) $(CMD)

install: $(BINARY)
	install -m755 -oroot -groot $(BINARY) $(INSTALL_DIR)/$(PROJECT_NAME)

uninstall:
	$(RM) $(INSTALL_DIR)/$(PROJECT_NAME)

clean:
	$(RM) $(OBJS)

purge:
	$(RM) -r $(BUILD_DIR) $(BIN_DIR)

help:
	@printf '%s\n' \
		"usage:" \
		"    make build     # build '$(BINARY)'" \
		"    make run       # test or run '$(BINARY)': e.g, make run CMD='--flag=value --boolean-flag'" \
		"    make install   # install project system-wide"

