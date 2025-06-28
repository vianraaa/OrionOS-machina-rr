IMAGE := MachinaSystemImage.img
IMAGE_SIZE := 512M
EFI_SIZE := 100M
ROOT_UUID := 8af49127-2f93-4ec3-aff7-485208f56036
MOUNT_EFI := /mnt/machina-efi
MOUNT_ROOT := /mnt/machina-root
KERNEL_BIN := linux

.PHONY: all clean

all: $(IMAGE)

$(IMAGE): $(KERNEL_BIN)
	fallocate -l $(IMAGE_SIZE) $(IMAGE)
	parted --script $(IMAGE) \
		mklabel gpt \
		mkpart ESP fat32 1MiB $(EFI_SIZE) \
		set 1 boot on \
		mkpart primary ext4 $(EFI_SIZE) 100% \
		name 1 EFI \
		name 2 root
	sudo bash -c "\
		set -e; \
		LOOPDEV=$$(sudo losetup --show -fP $(IMAGE)); \
		mkfs.vfat $${LOOPDEV}p1; \
		mkfs.ext4 -U $(ROOT_UUID) $${LOOPDEV}p2; \
		mkdir -p $(MOUNT_EFI) $(MOUNT_ROOT); \
		mount $${LOOPDEV}p1 $(MOUNT_EFI); \
		mount $${LOOPDEV}p2 $(MOUNT_ROOT); \
		mkdir -p $(MOUNT_EFI)/EFI/BOOT; \
		cp ../limine/BOOTX64.EFI $(MOUNT_EFI)/EFI/BOOT/BOOTX64.EFI; \
		cp ../limine/BOOTIA32.EFI $(MOUNT_EFI)/EFI/BOOT/BOOTIA32.EFI; \
		mkdir -p $(MOUNT_EFI)/boot; \
		cp ../limine/limine-uefi-cd.bin $(MOUNT_EFI)/boot/limine-uefi-cd.bin; \
		mkdir -p $(MOUNT_ROOT)/boot; \
		cp $(KERNEL_BIN) $(MOUNT_ROOT)/boot/$(KERNEL_BIN); \
		cp limine.conf $(MOUNT_ROOT)/boot/limine.conf; \
		umount $(MOUNT_EFI); \
		umount $(MOUNT_ROOT); \
		losetup -d $${LOOPDEV}; \
		rmdir $(MOUNT_EFI) $(MOUNT_ROOT); \
		"
	../limine/limine bios-install $(IMAGE)

$(KERNEL_BIN):
	@if [ ! -d ../linux ]; then \
		echo ">>> cloning linux kernel"; \
		cd .. && git clone --depth=1 https://github.com/torvalds/linux.git; \
	fi
	@echo ">>> configuring linux kernel"
	cd ../linux && \
		make ARCH=x86_64 defconfig && \
		scripts/config --enable EARLY_PRINTK && \
		scripts/config --enable EARLY_PRINTK_SERIAL && \
		scripts/config --enable SERIAL_8250 && \
		scripts/config --enable SERIAL_8250_CONSOLE && \
		scripts/config --enable VGA_CONSOLE && \
		scripts/config --enable FRAMEBUFFER_CONSOLE && \
		scripts/config --enable DRM && \
		scripts/config --set-val CONSOLE_LOGLEVEL_DEFAULT 7 && \
		make olddefconfig && \
		make -j$(nproc) ARCH=x86_64 bzImage
	cp ../linux/arch/x86/boot/bzImage $(KERNEL_BIN)

clean:
	rm -rf $(MOUNT_EFI) $(MOUNT_ROOT)
	rm -f $(IMAGE)