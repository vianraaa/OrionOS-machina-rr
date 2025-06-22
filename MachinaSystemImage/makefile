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
		cd .. && git clone --depth=1 https://github.com/torvalds/linux.git; \
	fi
	@echo ">>> building linux kernel"
	cd ../linux && \
		make defconfig && \
		make -j$$(nproc) bzImage
	cp ../linux/arch/x86/boot/bzImage $(KERNEL_BIN)

LimineTarget:
	if [ ! -d ../limine ]; then \
		cd .. && git clone --branch v9.x-binary --single-branch https://github.com/limine-bootloader/limine.git; \
		make -C limine; \
	fi

$(IMAGE): LimineTarget $(KERNEL_BIN)
	# .

clean:
	rm -f $(IMAGE)
