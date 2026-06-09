.PHONY: switch test update clean install

.DEFAULT_GOAL := help

TARGET_HOST ?= $(shell cat /etc/hostname)
MAIN_ACTION :=
MAKE := make --no-print-directory MAKELEVEL=$(shell echo $$(( $(MAKELEVEL) + 1 )))

SWITCH_ARGS := --flake ./\#$(TARGET_HOST)
TEST_ARGS := --flake ./\#$(TARGET_HOST)
FLAKE_INPUT_NAME := nixpkgs
CLEAN_ARGS := -d
OPTIMISE_ARGS :=
UPDATE_ARGS :=
MAKE := make --no-print-directory


ENCRYPTED_LUKS_PARTITION :=
DECRYPTED_LUKS_PARTITION_NAME := cryptpart
DECRYPTED_LUKS_PARTITION := /dev/mapper/$(DECRYPTED_LUKS_PARTITION_NAME)
RSA_PRIVATE_KEY := $(shell grep -Eo "~/.ssh/.*|$(shell printf ~)/.ssh/.*" ./.git/config)
RSA_PUBLIC_KEY := $(RSA_PRIVATE_KEY).pub
KEYFILE := ./passphrase

MAIN_ACTION := $(word 1, $(MAKECMDGOALS))
MAIN_ACTION_ARGS := $(filter-out $(MAIN_ACTION),$(MAKECMDGOALS))

ifneq ($(MAIN_ACTION_ARGS),)
ACTION_ARGS := $(MAIN_ACTION_ARGS)
$(ACTION_ARGS):
	@:
endif

ifeq ($(MAKELEVEL),0)

ifneq ($(MAIN_ACTION),)

ifeq ($(MAIN_ACTION),switch)
SWITCH_ARGS := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(SWITCH_ARGS))
else ifeq ($(MAIN_ACTION),test)
TEST_ARGS := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(TEST_ARGS))
else ifeq ($(MAIN_ACTION),clean)
CLEAN_ARGS := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(CLEAN_ARGS))
else ifeq ($(MAIN_ACTION),optimise)
OPTIMISE_ARGS := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(OPTIMISE_ARGS))
else ifeq ($(MAIN_ACTION),update)
UPDATE_ARGS := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(UPDATE_ARGS))
else ifeq ($(MAIN_ACTION),install)
ENCRYPTED_LUKS_PARTITION := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(ENCRYPTED_LUKS_PARTITION))
else ifeq ($(MAIN_ACTION),show-source)
FLAKE_INPUT_NAME := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(FLAKE_INPUT_NAME))
else ifeq ($(MAIN_ACTION),get-pkg-function)
$(if $(ACTION_ARGS),,$(error no pkg.* function given))
GET_PKG_FUNCTION := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(GET_PKG_FUNCTION))
endif

endif # if MAIN_ACTION

endif # MAKELEVEL 0

ifeq ($(MAKELEVEL),2)

ifeq ($(MAIN_ACTION),__decrypt_luks)
DECRYPT_THIS_PARTITION := $(ACTION_ARGS)
$(if $(ACTION_ARGS),,$(error no partition to decrypt))
else ifeq ($(MAIN_ACTION),encrypt_keyfile)
KEYFILE := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(KEYFILE))
$(if $(shell [ -r $(RSA_PRIVATE_KEY) ]),,$(error no rsa key found for encryption))
else ifeq ($(MAIN_ACTION),decrypt_keyfile)
KEYFILE := $(if $(ACTION_ARGS),$(ACTION_ARGS),$(KEYFILE))
$(if $(shell [ -r $(RSA_PRIVATE_KEY) ]),,$(error no rsa key found for decryption))
endif

endif # MAKELEVEL 2

switch: __check_root # switch generation
	@printf '%s' \
		"run: " 1>&2
	nixos-rebuild $(@) $(SWITCH_ARGS)
	@printf '\n' 1>&2

test: __check_root # test instead of 'switch'
	@printf '%s' \
		"run: " 1>&2
	nixos-rebuild $(@) $(TEST_ARGS)
	@printf '\n' 1>&2

clean: __check_root # garbage collect the unused stuff from /nix/store/
	@printf '%s' \
		"run: " 1>&2
	nix-collect-garbage $(CLEAN_ARGS)
	@printf '\n' 1>&2

optimise: __check_root # optimise /nix/store/ path
	@printf '%s' \
		"run: " 1>&2
	nix store $(@) $(OPTIMISE_ARGS)
	@printf '\n' 1>&2

update: __check_root # update the flake inputs
	@printf '%s' \
		"run: " 1>&2
	nix flake $(@) $(UPDATE_ARGS)
	@printf '\n' 1>&2

list-generations: __check_root # list nixos generations
	@printf '%s' \
		"run: " 1>&2
	nix-env -p /nix/var/nix/profiles/system/ --list-generations
	@printf '\n' 1>&2

show-source: # show current system source
	@printf '%s' \
		"run: " 1>&2
	nix eval --impure --expr '(builtins.getFlake (builtins.toString ./.)).inputs.$(FLAKE_INPUT_NAME).outPath'
	@printf '\n' 1>&2


get-pkg-function: # query functions from pkg.*
	@printf '%s' \
		"run: " 1>&2
	nix eval --impure --expr '(builtins.unsafeGetAttrPos "$(GET_PKG_FUNCTION)" (import <nixpkgs> {})).file'
	@printf '\n' 1>&2

current-kernel-log: # show upstream kernel log and build flags
	@printf '%s' \
		"run: " 1>&2
	nix log ./#nixosConfigurations.$(TARGET_HOST).config.boot.kernelPackages.kernel
	@printf '\n' 1>&2

fetch: __check_root # fetch nixos flake inputs
	@printf '%s' \
		"run: " 1>&2
	nix flake prefetch-inputs $(UPDATE_ARGS)
	@printf '\n' 1>&2

encrypt_keyfile: # encrypt keyfile
	@printf '[*]: %s\n' \
		"encrypting keyfile '$(KEYFILE)' -> '$(KEYFILE).enc', using rsa private key: $(RSA_PRIVATE_KEY)" 1>&2
	@grep -qw "$(KEYFILE)" ./gitignore || printf '%s\n' "$(KEYFILE)" >> ./.gitignore
	ssh-keygen -e -m PEM -f $(RSA_PRIVATE_KEY) | \
		openssl pkeyutl -encrypt -pubin -inkey /dev/stdin -in $(KEYFILE) -out $(KEYFILE).enc
	@printf '[*] %s\n' \
		"do not remove the *.enc extension or change filename" 1>&2

decrypt_keyfile: # decrypte keyfile
	@printf '[*]: %s\n' \
		"decrypting keyfile '$(KEYFILE).enc' -> '$(KEYFILE)', using rsa private key: $(RSA_PRIVATE_KEY)" 1>&2
	@cp $(RSA_PRIVATE_KEY) /dev/shm/secret.privatekey && \
		ssh-keygen -p -P "" -N "" -m PEM -f /dev/shm/secret.privatekey
	openssl pkeyutl -decrypt -inkey /dev/shm/secret.privatekey -in $(KEYFILE).enc -out $(KEYFILE)
	@rm /dev/shm/secret.privatekey

generate_passphrase: # generate random passphrase
	@printf '[*]: %s\n' \
		"generating passphrase..." 1>&2
	@(for i in {0..1}; do \
		tr -cd 'bcdfghjklmnpqrstvwxyz' < <(openssl rand -base64 16) | fold -w4 | tr '\n' '-' && \
		tr -cd 'aeiou' < <(openssl rand -base64 64) | fold -w4 | tr '\n' '-' ; \
	done | sed -e 's/-$$//g')

deploy-dotfiles: __deploy_dotfiles_mapping # deploy dotfiles repo for current user

deploy_dotfiles: __deploy_dotfiles_mapping # deploy dotfiles repo for current user

symlink-dotfiles: __deploy_dotfiles_mapping

symlink_dotfiles: __deploy_dotfiles_mapping

dry-run-deploy-dotfiles: __dry_run_deploy_dotfiles_mapping

dry_run_deploy_dotfiles: __dry_run_deploy_dotfiles_mapping

dry-run-symlink-dotfiles: __dry_run_deploy_dotfiles_mapping

dry_run_symlink_dotfiles: __dry_run_deploy_dotfiles_mapping


install: __check_root __dependency_cmd_check # Initial bootstrap nixos system (TODO)
	@echo TODO

__check_root:
	@if [ $(shell id -u) != 0 ]; then \
		printf '[error]: %s\n' \
			"please run with root privileges" 1>&2; \
		exit 1; \
	fi

__install_interactive: __check_root __check_luks __check_lvm __dependency_cmd_check
	@echo TODO

__install_automated: __check_root __check_luks __check_lvm __dependency_cmd_check
	@echo TODO

__check_luks:
	@cryptsetup isLuks $(LUKS_PARTITION) && $(MAKE) --no-print-directory __decrypt_luks $(LUKS_PARTITION)

__check_lvm:
	@pvs $(DECRYPTED_LUKS_PARTITION)

__dependency_cmd_check:
	@COMMANDS="nixos-install cryptsetup openssl ssh-keygen"; \
		for cmd in $${COMMANDS}; do \
			command -v $${cmd} 2>&1 1>/dev/null || \
				{ printf '[error]: %s\n' "command '$${cmd}' not found, aborting" 1>&2; exit 1; }; \
		done

__decrypt_luks:
	@printf '[*]: %s\n' \
		"decrypting luks '$(DECRYPT_THIS_PARTITION)' -> '$(DECRYPTED_LUKS_PARTITION)'" 1>&2
	cryptsetup luksOpen $(DECRYPT_THIS_PARTITION) $(DECRYPTED_LUKS_PARTITION_NAME)

__dry_run_deploy_dotfiles_mapping:
	@$(MAKE) --no-print-directory __deploy_dotfiles_mapping DRY_RUN=1

__deploy_dotfiles_mapping: ./dotfiles/dotsync.conf
	@awk -F'[[:space:]]*->[[:space:]]*' ' \
		/^$$/ || /^[[:space:]]*$$/ || /^#/ { next } \
		{ src[$$1] = $$2 } \
		END { \
			for (s in src) { \
				config_dir = "$(dir $(<))" ; \
				cmd = "readlink -f \x27" config_dir s "\x27"; \
				dest_path = src[s]; \
				gsub("~","$$HOME",dest_path); \
				gsub(".*","\x22"dest_path"\x22",dest_path); \
				if ((cmd | getline src_abs_path) > 0) { \
					gsub(".*","\x22"src_abs_path"\x22",src_abs_path); \
					cmd = $(if $(DRY_RUN),"echo ",)"ln -snf " src_abs_path " " dest_path; \
					if (system(cmd) == 0) { \
						printf "success symlink: %s -> %s\n", src_abs_path, dest_path; \
					} else { \
						printf "failed to symlink: %s -> %s\n", src_abs_path, dest_path; \
					} \
				}; \
				close(cmd) \
			} \
		} \
	' $(<)

help: # print this this help menu
	@printf '%s\n' \
		"usage: make [action] VAR=override" \
		"actions"
	@awk -F':[[:space:]]*([^#]*)[[:space:]]*#' \
		'/^[a-zA-Z0-9_-]+:[^#]*#/ { print "    ", $$1, "->", $$2 }' makefile 1>&2

