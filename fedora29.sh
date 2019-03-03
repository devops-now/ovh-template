#!/bin/bash

dnf upgrade -y
dnf install -y langpacks-fr policycoreutils-python-utils lvm2 binutils

# Enable root ssh
sed -i 's/,command.*ssh-rsa/ ssh-rsa/' /root/.ssh/authorized_keys
sed -i 's/#\?\s*Port\s\+.*/Port 225/' /etc/ssh/sshd_config

semanage port -a -t ssh_port_t -p tcp 225
systemctl restart sshd

# Use LVM
umount /home
pvcreate -y /dev/md3
vgcreate lvm /dev/md3
lvcreate -L 1G -n home lvm
mkfs.ext4 /dev/lvm/home

sed -i 's/LABEL="\/home" \/home xfs/\/dev\/mapper\/lvm-home \/home ext4/' /etc/fstab

# Fix boot LV on MDRaid
rm -f /etc/dracut.conf.d/98-ovh.conf
dracut --regenerate-all -f -q

# Manage users
userdel -r fedora

# Use selinux
sed -i "s/#\?\s*SELINUX\s*=.*/SELINUX=permissive/" /etc/selinux/config
touch /.autorelabel

# Disable cloud-init
touch /etc/cloud/cloud-init.disabled

# Fix boot of mdmonitor
sed -i '1i MAILADDR root' /etc/mdadm.conf

exit 0
