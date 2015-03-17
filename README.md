# grub2-signing-extension for GRUB2

GRUB2 has got a function called "check\_signatures" which automatically checks if your GRUB2 files are signed and have a good signature. If the files aren't signed or have a bad signature GRUB2 won't run them to prevent running malicious software.
The GRUB2 signing extension are some scripts which helps you to verify, sign and unsign your GRUB2 bootloader files using gpg. 



## Requirements

You need

* GRUB2 ( sys-boot/grub:2 )
* GNUpg ( app-crypt/gnupg )



## Preparation

Before you can use the signing and verification feature you need to generate a keypair as root. Please use a secure passphrase.

`# gpg --gen-key`


To make gpg able to sign and verify files in a `su` environment we need to activate the gpg-agent for root. 

Edit the file _/root/.gnupg/gpg.conf_ and add the line `use-agent`.

Save the file and create _/root/.gnupg/gpg-agent.conf_ with the following content

    pinentry-program /usr/bin/pinentry-curses
    no-grab
    default-cache-ttl 1800



## How to install the GRUB2 check\_signatures feature and using the grub2-signing-extension

First, export your public key.

`# gpg --export -o ~/pubkey`


Next step, `mount /boot` and (re)install GRUB2. You need to install the public key into the core and instruct to load the modules `gcry_sha256` `gcry_dsa` and `gcry_rsa` at start. So you need the following arguments to install it this way

`grub2-install /dev/sda -k /root/pubkey --modules="gcry_sha256 gcry_dsa gcry_rsa"`


Now download the grub2-signing-extension and run `make install` as root. You will now have `grub2-sign`, `grub2-unsign` and `grub2-verify` as runable scripts.


To _enable_ GRUB2's check\_signatures feature insert the following content at the end of the file of */etc/grub.d/00_header* 

    cat << EOF
    set check_signatures=enforce
    EOF


Run `grub2-mkconfig -o /boot/grub/grub.cfg` to make the new configuration valid.

Now the time is come to sign your GRUB2 bootloader. Just run `grub2-sign`, enter your passphrase and that's it.


**ATTENTION:** On every change you need to run `grub2-unsign` first before you make your changes. It's also recommended to install a password in GRUB2!






## Files

If you didn't read the instruction above here is what the scripts does:

* `grub2-sign` is signing the bootloader files with root's keypair.
* `grub2-unsign` is removing the signatures of the bootloader files.
* `grub2-verify` is checking if your signatures are good. If not, you will see which signature is bad.



## Troubleshooting

### I forgot to run grub2-unsign before I made changes. What now?

Run `grub2-verify` to see, which signature is bad. Remove the signature and run `grub2-unsign`, after this `grub2-sign`.


### How can I switch off GRUB2's check_signature feature?

Open */etc/grub.d/00_header* and remove the part 

    cat << EOF
    set check_signatures=enforce
    EOF

Run `grub2-unsign` and `grub2-mkconfig -o /boot/grub/grub.cfg`.


### Suddenly I can't boot! This is YOUR FAULT!

No. An important signature is bad. So GRUB2 didn't run this part of code/configuration/kernel/whatever.


### Okay, I really got some bad signatures. What do I do now?

Check your system thoroughly. Check it about malicious software. Check it about malicious connections. CHECK EVERYTHING.



# ADDENDUM

## How to install a GRUB2 password

Run `grub2-mkpasswd-pbkdf2` and type a password. Please take care because in the GRUB2 standard installation the keyboard layout is set to en\_US.
Copy the content of *grub.pbkdf2.[...]* to your clipboard. Open the file */etc/grub.d/00_header* and insert this at the end of the file

    cat << EOF
    set superusers="yourUsername"
    export superusers
    password_pbkdf2 yourUsername grub.pbkdf2.[...this string from the clipboard...]
    EOF

To boot GNU/Linux automatically and without authentication open */etc/grub.d/10_linux* and change the following lines like this

     echo "menuentry '$(echo "$title" | grub_quote)' ${CLASS} \$menuentry_id_option 'gnulinux-$version-$type-$boot_device_id' {" | sed "s/^/$submenu_indentation/"
    else
     echo "menuentry '$(echo "$os" | grub_quote)' ${CLASS} \$menuentry_id_option 'gnulinux-simple-$boot_device_id' {" | sed "s/^/$submenu_indentation/"
    fi

to

     echo "menuentry '$(echo "$title" | grub_quote)' --unrestricted ${CLASS} \$menuentry_id_option 'gnulinux-$version-$type-$boot_device_id' {" | sed "s/^/$submenu_indentation/"
    else
     echo "menuentry '$(echo "$os" | grub_quote)' --unrestricted ${CLASS} \$menuentry_id_option 'gnulinux-simple-$boot_device_id' {" | sed "s/^/$submenu_indentation/"
    fi

The important changing is the flag *--unrestricted*.


Run `grub2-unsign` to unsign the bootloader. 

Then run `grub2-mkconfig -o /boot/grub/grub.cfg` to write the new config. 

After this run `grub2-sign` again to sign the new changings.

