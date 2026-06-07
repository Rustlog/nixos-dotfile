.PHONY: run rm rmf edit purge help

PROJECT_DIR := .
SRC_DIR := $(PROJECT_DIR)/src
BIN_DIR := $(PROJECT_DIR)/bin
PREFIX := /usr/local
INSTALL_DIR := $(PREFIX)/bin

VALID_MODES := debug release
MODE ?= debug

CC := clang

C_FLAGS := -std=c23
RELEASE_C_FLAGS := -O3 -Wall -Wextra -Wpedantic \
                   -fstack-protector-strong -fno-common
DEBUG_C_FLAGS := -DDEBUG -O0 -Wall -Wextra -Wpedantic -Werror -Wshadow \
        -Wconversion -Wsign-conversion -Wundef -Wstrict-prototypes \
        -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls \
        -Wswitch-enum -Wswitch-default -Wformat=2 -Wformat-security \
        -Wformat-overflow -Wfloat-equal -Wcast-align -Wcast-qual \
        -Wdouble-promotion -Wvla -Wnull-dereference -Wunreachable-code \
        -fstack-protector-strong -fno-common -fstrict-aliasing \
        -fno-omit-frame-pointer -fsanitize=address,undefined \
        -fno-sanitize-recover=all -pedantic-errors -g

AUTO_MODE_ACTIONS := r run rm rmf e edit build

ifneq ($(filter $(word 1, $(MAKECMDGOALS)),$(AUTO_MODE_ACTIONS)),)
TARGET_PROGRAM_NAME := $(word 2, $(MAKECMDGOALS))
BINARY := $(BIN_DIR)/$(TARGET_PROGRAM_NAME)
$(TARGET_PROGRAM_NAME):
	@:
endif

ifeq ($(MODE),debug)
C_FLAGS += $(DEBUG_C_FLAGS)
else ifeq ($(MODE),release)
C_FLAGS += $(RELEASE_C_FLAGS)
endif

SRCS := $(wildcard $(SRC_DIR)/*.c)
TARGETS := $(patsubst %.c,$(BIN_DIR)/%,$(patsubst $(SRC_DIR)/%.c,%.c,$(SRCS)))

# $(info "SRCS: $(SRCS)")
# $(info "TARGETS: $(TARGETS)")
# $(info "BINARY: $(BINARY)")

default: $(TARGETS)
	@:

$(BIN_DIR)/%: $(SRC_DIR)/%.c
	@mkdir -p $(BIN_DIR)
	$(CC) $(C_FLAGS) -o $@ $<

run: $(BINARY)
	$(BINARY) $(CMD)

r: $(BINARY)
	$(BINARY) $(CMD)

rm:
	@mkdir -p $(BIN_DIR)
	rm $(BINARY)

rmf:
	@mkdir -p $(SRC_DIR)
	rm $(SRC_DIR)/$(TARGET_PROGRAM_NAME).c

edit:
	@mkdir -p $(SRC_DIR)
	@echo $${EDITOR:-vim} $(SRC_DIR)/$(TARGET_PROGRAM_NAME).c
	@$${EDITOR:-vim} $(SRC_DIR)/$(TARGET_PROGRAM_NAME).c

e:
	@mkdir -p $(SRC_DIR)
	@echo $${EDITOR:-vim} $(SRC_DIR)/$(TARGET_PROGRAM_NAME).c
	@$${EDITOR:-vim} $(SRC_DIR)/$(TARGET_PROGRAM_NAME).c

build: $(SRC_DIR)/$(TARGET_PROGRAM_NAME).c
	@mkdir -p $(BIN_DIR)
	$(CC) $(C_FLAGS) -o $(TARGET_PROGRAM_NAME) $<

list:
	@mkdir -p $(BIN_DIR)
	@find $(BIN_DIR)/ -type f -printf "%P\n"

clean:
	@mkdir -p $(BIN_DIR)
	find $(BIN_DIR)/ -type f -exec rm {} ';'

purge:
	$(RM) -r $(BIN_DIR)

help:
	@printf '%s\n' \
		"usage:" \
		"    make run [PROGRAM]   # run program, if not ready build it" \
		"    make rm [PROGRAM]    # remove program from '$(BIN_DIR)'" \
		"    make rmf [PROGRAM]   # remove program soruce from '$(SRC_DIR)'" \
		"    make edit [PROGRAM]  # edit program with $$EDITOR" \
		"    make build [PROGRAM] # build a program" \
		"    make list            # list ever program in '$(BIN_DIR)'" \
		"    make clean           # remove everything from '$(BIN_DIR)'" \
		"    make                 # build every program in '$(SRC_DIR)'"

