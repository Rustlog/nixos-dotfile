.PHONY: all fedora-dev ubuntu-server fedora-server

all:
	fedora-dev ubuntu-server fedora-server

fedora-dev:
	podman build -t $(@):latest -f dockerfiles/$(@).dockerfile ./
	podman run -dt \
		--name $(@) \
		--hostname $(@)-container \
		-v $(@):/persistant_volume \
		-p 8026:22 -p 6084:80 -p 6447:443 \
		localhost/$(@):latest \
		/usr/bin/tini -- /usr/bin/bash
	podman exec -it $(@) bash

fedora-server:
	podman build -t $(@):latest -f dockerfiles/$(@).dockerfile ./
	podman run -dt \
		--name $(@) \
		--hostname $(@)-container \
		-p 8022:22 -p 6080:80 -p 6443:443 -p 3306:3306 -p 5432:5432 -p 6379:6379 \
		localhost/$(@):latest \
		/usr/bin/tini -- /usr/bin/bash
	podman exec -it $(@) bash

ubuntu-server:
	podman build -t $(@):latest -f dockerfiles/$(@).dockerfile ./
	podman run -dt \
		--name $(@) \
		--hostname $(@)-container \
		-p 8022:22 -p 6080:80 -p 6443:443 -p 3306:3306 -p 5432:5432 -p 6379:6379 \
		localhost/$(@):latest \
		/usr/bin/tini -- /usr/bin/bash
	podman exec -it $(@) bash

ubuntu-storage:
	podman build -t $(@):latest -f dockerfiles/$(@).dockerfile ./
	podman run -dt \
		--init \
		--name $(@) \
		--hostname $(@)-container \
		-p 8028:22 -p 6088:80 -p 6449:443 \
		localhost/$(@):latest \
		/usr/bin/tini -- /usr/bin/bash
	podman exec -it $(@) bash

