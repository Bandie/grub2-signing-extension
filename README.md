# grub2-signing-extension for GRUB2

GRUB2 has got a function called "check\_signatures" which automatically checks if your GRUB2 files are signed and have a good signature. If the files aren't signed or have a bad signature GRUB2 won't run them to prevent running malicious software.
The GRUB2 signing extension are some scripts which helps you to verify, sign and unsign your GRUB2 bootloader files using gpg. 



## Requirements

You need

* GRUB2 ( sys-boot/grub:2 )
* GNUpg >= 2.1 ( >= app-crypt/gnupg-2.1 )  



## Installation
### Arch Linux (AUR)
- Import [Bandie's GPG key](https://bandie.org/assets/bandie.pub.asc) through running `gpg --recv-keys E2D7876915312785DC086BFCC1E133BC65A822DD`.
- Use your favourite AUR helper to install [grub2-signing-extension](https://aur.archlinux.org/packages/grub2-signing-extension/).

### From github
- Import [Bandie's GPG key](https://bandie.org/assets/bandie.pub.asc) through running `gpg --recv-keys E2D7876915312785DC086BFCC1E133BC65A822DD`.
- Download the [grub2-signing-extension](https://github.com/Bandie/grub2-signing-extension/releases/download/0.1.2/grub2-signing-extension-0.1.2.tar.gz) and it's [signature](https://github.com/Bandie/grub2-signing-extension/releases/download/0.1.2/grub2-signing-extension-0.1.2.tar.gz.asc). 
- Run `gpg --verify grub2-signing-extension*.tar.gz.asc` to make sure that everything is alright.
- Unpack the tar archive. `tar xvf grub2-signing-extension*.tar.gz`
- Change into the grub2-signing-extension directory.
- Run `make install` as root. 

You will now have `grub-sign`, `grub-unsign`, `grub-verify` and `grub-update-kernel-signature` as runable scripts.


## Enabling GRUB2 check\_signatures feature

Before you can use the signing and verification feature you need to generate a keypair as root.

- Run `gpg --gen-key` as root. Please use a secure passphrase.
- Activate the `gpg-agent` for root so that you are able to sign and verify files in a `su` environment. To do that:
  - Edit the file _/root/.gnupg/gpg.conf_ and add the line `use-agent`. Save the file.
  - Create _/root/.gnupg/gpg-agent.conf_ with the following content
      ```
      pinentry-program /usr/bin/pinentry-curses
      no-grab
      default-cache-ttl 1800
      ```
- Export your public key through running `gpg --export -o ~/pubkey`.
- `mount /boot` (assuming your /boot partition is in your /etc/fstab)
- (Re)install GRUB2. The following command will install root's public key into the core and instruct to load the modules `gcry_sha256` `gcry_dsa` and `gcry_rsa` at start so that GRUB2 will be able to do verifications.
  - `grub-install /dev/sda -k /root/pubkey --modules="gcry_sha256 gcry_dsa gcry_rsa"`
- Enable GRUB2's check\_signatures feature:
  - Insert the following content at the end of the file of */etc/grub.d/00_header*
      ```
      cat << EOF
      set check_signatures=enforce
      EOF
      ```    
- Run`grub-mkconfig -o /boot/grub/grub.cfg` to make the new configuration valid.
- Sign your bootloader running `grub-sign` and enter your GPG passphrase. 

**It is also recommended to install a password in GRUB2! [See ADDENDUM]**


## How to update the signatures on changes

On every change at the GRUB2 core files you need to run `grub-unsign` first before you make your changes. Please notice, if you reinstall GRUB2, you should do it as it is said above. Otherwise the signature check won't work.

If you do some changes or updates for the kernel or initramfs, you may want to use `grub-update-kernel-signature` instead.




## Files

If you didn't read the instruction above here is what the scripts does:

* `grub-sign` is signing the bootloader files with root's keypair.
* `grub-unsign` is removing the signatures of the bootloader files.
* `grub-verify` is checking if your signatures are good. If not, you will see which signature is bad.
* `grub-update-kernel-signature` is renewing the signatures in /boot/ (without subdirs) and grub.cfg, regardless if grub-verify fails.


## Exit codes

You might be interested in the exit codes of `grub-verify` to use it in your monitoring tools:

```
0 - Everything is okay
1 - Found bad signatures
2 - No signatures found at all [GRUB2 is completely unsigned]
3 - Missing signatures [There are correct signatures but some files are unsigned]
```


## Troubleshooting

### I receive an error 
#### gpg: signing failed: Permission denied

Make sure that the tty you are in belongs to you (root). Do:

```
chown root:root $(tty)
```




### I forgot to run grub2-unsign before I made changes. What now?

Run `grub-verify` to see, which signature is bad. Remove the signature and run `grub-unsign`, after this `grub-sign`.
Alternatively, if you just updated your kernel/initramfs/grub.cfg, run `grub-update-kernel-signatures`.


### How can I switch off GRUB2's check\_signature feature?

Open */etc/grub.d/00_header* and remove the part 

    cat << EOF
    set check_signatures=enforce
    EOF

Run `grub-unsign` and `grub-mkconfig -o /boot/grub/grub.cfg`.

Also you should reinstall grub2, using something like `grub-install /dev/sda`.


### Suddenly I can't boot! This is YOUR FAULT!

No. An important signature is bad. So GRUB2 didn't run this part of code/configuration/kernel/whatever.
You could do a chroot using an USB dongle with a GNU/Linux distribution on it. If you're chrooted to your system run `grub-verify`. 
If you think this happened through an update shortly done by you, you may want to run `gpg-agent --daemon ; grub-update-kernel-signatures`.


### Okay, I really got some bad signatures not caused by me. What do I do now?

Check your system thoroughly. Check it about malicious software. Check it about malicious connections. CHECK EVERYTHING. 



# ADDENDUM

## How to install a GRUB2 password

- Generate a GRUB2 password string through running `grub-mkpasswd-pbkdf2`. Please take care because in the GRUB2 standard installation the keyboard layout is set to en\_US.
- Copy the generated *grub.pbkdf2.[...]* string to your clipboard.
- Open the file */etc/grub.d/00_header* and insert this at the end of the file
    ```
    cat << EOF
    set superusers="yourUsername"
    export superusers
    password_pbkdf2 yourUsername [...this grub.pbkdf2.* string from the clipboard...]
    EOF
    ```
- To boot GNU/Linux automatically and without authentication open */etc/grub.d/10_linux* and change the following lines from
  ```
      echo "menuentry '$(echo "$title" | grub_quote)' ${CLASS} \$menuentry_id_option 'gnulinux-$version-$type-$boot_device_id' {" | sed "s/^/$submenu_indentation/"
    else
      echo "menuentry '$(echo "$os" | grub_quote)' ${CLASS} \$menuentry_id_option 'gnulinux-simple-$boot_device_id' {" | sed "s/^/$submenu_indentation/"
    fi
  ```
  to

  ```
      echo "menuentry '$(echo "$title" | grub_quote)' --unrestricted ${CLASS} \$menuentry_id_option 'gnulinux-$version-$type-$boot_device_id' {" | sed "s/^/$submenu_indentation/"
    else
      echo "menuentry '$(echo "$os" | grub_quote)' --unrestricted ${CLASS} \$menuentry_id_option 'gnulinux-simple-$boot_device_id' {" | sed "s/^/$submenu_indentation/"
    fi
  ```
  The important changing is the flag *--unrestricted*.
  
- Run `grub-unsign` to unsign the bootloader.
- Run `grub-mkconfig -o /boot/grub/grub.cfg` to write the new config.
- Run `grub-sign` to sign the new changings.
