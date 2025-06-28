#!/bin/sh
make -C MachinaSystemImage
qemu-system-x86_64 -hda MachinaSystemImage/MachinaSystemImage.iso -serial stdio