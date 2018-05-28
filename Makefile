# Makefile for grub2-sign-extension
# Author: Bandie
# Licence: GNU-GPLv3

all: 
	@printf "Nothing to make. Run make install.\n"

install:
	install -D -m744 sbin/grub2-verify /usr/sbin/grub2-verify
	install -D -m744 sbin/grub2-sign /usr/sbin/grub2-sign
	install -D -m744 sbin/grub2-unsign /usr/sbin/grub2-unsign
	install -D -m744 sbin/grub2-update-kernel-signature /usr/sbin/grub2-update-kernel-signature
	@printf "Done.\n"

uninstall:
	rm /usr/sbin/grub2-{verify,sign,unsign,update-kernel-signature}
	@printf "Done.\n"
