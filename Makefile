# Makefile for grub2-sign-extension
# Author: Bandie Kojote (MeikoDis)
# Licence: GNU-GPLv3

all: 
	@printf "Nothing to make. Run make install.\n"

install:
	cp ./sbin/grub2-verify /usr/sbin/
	cp ./sbin/grub2-sign /usr/sbin/
	cp ./sbin/grub2-unsign /usr/sbin/
	chown root:root /usr/sbin/grub2-{verify,sign,unsign}
	chmod 700 /usr/sbin/grub2-{verify,sign,unsign}
	@printf "Done.\n"

uninstall:
	rm /usr/sbin/grub2-{verify,sign,unsign}
	@printf "Done.\n"
