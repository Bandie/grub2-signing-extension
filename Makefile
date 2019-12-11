# Makefile for grub2-sign-extension
# Author: Bandie
# Licence: GNU-GPLv3

all: 
	@printf "Nothing to make. Run make install.\n"

install:
	@printf "Check for old scripts and remove them...\n"
	rm -f /usr/sbin/grub2-{verify,sign,unsign,update-kernel-signature}
	install -D -m744 sbin/grub-verify /usr/sbin/grub-verify
	install -D -m744 sbin/grub-sign /usr/sbin/grub-sign
	install -D -m744 sbin/grub-unsign /usr/sbin/grub-unsign
	install -D -m744 sbin/grub-update-kernel-signature /usr/sbin/grub-update-kernel-signature
	@printf "Done.\n"

uninstall:
	rm -f /usr/sbin/grub-{verify,sign,unsign,update-kernel-signature}
	@printf "Done.\n"
