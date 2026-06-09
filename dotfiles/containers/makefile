.PHONY: all fedora-dev ubuntu-server fedora-server

.DEFAULT_GOAL := help

ACTION := $(word 1, $(MAKECMDGOALS))
TARGET := $(word 2, $(MAKECMDGOALS))

VALID_TARGETS := fedora-dev fedora-server ubuntu-server ubuntu-storage
VALID_ACTIONS := $(VALID_TARGETS) build run exec

# dispatcher
ifeq ($(MAKELEVEL),0)

ifneq ($(filter $(ACTION),$(VALID_ACTIONS)),)
$(ACTION): $(ACTION)-$(TARGET)
	@:
ifeq ($(TARGET),)
TARGET := $(ACTION)
endif

else
$(if $(MAKECMDGOALS),$(error invalid action '$(ACTION)', valid actions are '$(VALID_ACTIONS)'),)
endif

endif

## Enviornment variables
USER := $(shell id -nu "$${SUDO_USER:-$$USER}")
UID := $(shell id -u "$${SUDO_USER:-$$USER}")
XDG_RUNTIME_DIR := $(shell printf '%s' $${XDG_RUNTIME_DIR:-/run/user/$(UID)})
WAYLAND_DISPLAY := $(shell find $(XDG_RUNTIME_DIR) -type s -name 'wayland-[0-9]' -printf "%P" 2>/dev/null)

%-: build-% run-% exec-%
	@:

# Dev Enviornment Testing and Production
build-fedora-dev:
	podman build -t $(TARGET):latest -f dockerfiles/$(TARGET).dockerfile ./
run-fedora-dev:
	runuser -u $(USER) -- ln -snf ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY} ${XDG_RUNTIME_DIR}/wayland-0
	podman run -dt \
		--name $(TARGET) \
		--hostname $(TARGET)-container \
		-e DISPLAY=${DISPLAY} \
		-e WAYLAND_DISPLAY=wayland-0 \
		-v $(TARGET):/persistant_volume \
		-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
		-v ${XDG_RUNTIME_DIR}/wayland-0:${XDG_RUNTIME_DIR}/wayland-0:ro \
		-v ${XDG_RUNTIME_DIR}/bus:${XDG_RUNTIME_DIR}/bus:ro \
		-p 8026:22 -p 6084:80 -p 6447:443 \
		localhost/$(TARGET):latest \
		/usr/bin/tini -- /usr/bin/bash
exec-fedora-dev:
	podman exec -it \
		-e DISPLAY=${DISPLAY} \
		$(TARGET) bash -c ' \
			ln -snf  ${XDG_RUNTIME_DIR}:${WAYLAND_DISPLAY} ${XDG_RUNTIME_DIR}:wayland-0; \
			mkdir -p /persistant_volume/share/dev; \
			ln -snf /persistant_volume/share/dev/ ~/dev; \
			ln -snf /persistant_volume/share/ ~/share; \
			exec bash; \
		'

# General Purpose Fedora Server
build-fedora-server:
	podman build -t $(TARGET):latest -f dockerfiles/$(TARGET).dockerfile ./
run-fedora-server:
	podman run -dt \
		--name $(TARGET) \
		--hostname $(TARGET)-container \
		-p 8022:22 -p 6080:80 -p 6443:443 -p 3306:3306 -p 5432:5432 -p 6379:6379 \
		localhost/$(TARGET):latest \
		/usr/bin/tini -- /usr/bin/bash
exec-fedora-server:
	podman exec -it $(TARGET) bash

# General Purpose Ubuntu Server
build-ubuntu-server:
	podman build -t $(TARGET):latest -f dockerfiles/$(TARGET).dockerfile ./
run-ubuntu-server:
	podman run -dt \
		--name $(TARGET) \
		--hostname $(TARGET)-container \
		-p 8022:22 -p 6080:80 -p 6443:443 -p 3306:3306 -p 5432:5432 -p 6379:6379 \
		localhost/$(TARGET):latest \
		/usr/bin/tini -- /usr/bin/bash
exec-ubuntu-server:
	podman exec -it $(TARGET) bash

# Ubuntu Storage Server
build-ubuntu-storage:
	podman build -t $(TARGET):latest -f dockerfiles/$(TARGET).dockerfile ./
run-ubuntu-storage:
	podman run -dt \
		--init \
		--name $(TARGET) \
		--hostname $(TARGET)-container \
		-p 8028:22 -p 6088:80 -p 6449:443 \
		localhost/$(TARGET):latest \
		/usr/bin/tini -- /usr/bin/bash
exec-ubuntu-storage:
	podman exec -it $(TARGET) bash

# Usage section
help:
	@printf '%s\n' \
		"usage: make [action|target] [target]" \
		"action:" \
		"    build  # build an image from dockerfile" \
		"    run    # create the container from generated image" \
		"    exec   # exec into container" \
		"examples:" \
		"    make fedora-dev       # build image -> create container -> attach to container" \
		"    make exec fedora-dev  # attach a session to running container"

