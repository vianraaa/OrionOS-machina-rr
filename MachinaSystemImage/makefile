KERNEL_BIN := linux-kernel.bin

IMAGE := MachinaSystemImage.img
IMAGE_SIZE := 64M

MOUNT_DIR := /mnt/machina-boot
LOOPDEV := $(shell sudo losetup --find)

.PHONY: all clean

all: $(IMAGE)

$(KERNEL_BIN):
	@if [ ! -d ../linux ]; then \
		echo ">>> cloning linux kernel"; \
		cd .. && git clone https://github.com/torvalds/linux.git; \
	fi
	@echo ">>> building linux kernel"
	cd ../linux && \
		make defconfig && \
		make -j$$(nproc) bzImage
	cp ../linux/arch/x86/boot/bzImage $(KERNEL_BIN)

LimineTarget:
	if [ ! -d ../limine ]; then \
		cd .. && git clone --branch v9.x-binary --single-branch https://github.com/limine-bootloader/limine.git; \
	fi

$(IMAGE): LimineTarget $(KERNEL_BIN)
	@echo ">>> creating MachinaSystemImage: $(IMAGE)"
	@rm -f $(IMAGE)
	@dd if=/dev/zero of=$(IMAGE) bs=1 count=0 seek=$(IMAGE_SIZE)
	@parted $(IMAGE) --script \
		mklabel gpt \
		mkpart ESP fat32 1MiB 100% \
		set 1 boot on

	@echo ">>> setting up loop device"
	sudo losetup --partscan --find --show $(IMAGE) > .loopdev
	@LOOP=`cat .loopdev`; \
		sleep 0.5; \
		sudo mkfs.vfat $${LOOP}p1; \
		sudo mkdir -p $(MOUNT_DIR); \
		sudo mount $${LOOP}p1 $(MOUNT_DIR); \
		sudo cp $(KERNEL_BIN) $(LIMINE_FILES) $(MOUNT_DIR)/; \
		sudo umount $(MOUNT_DIR); \
		sudo limine-install $(IMAGE); \
		sudo losetup -d $${LOOP}; \
		rm -f .loopdev

	@echo ">>> done."

clean:
	rm -f $(IMAGE)
