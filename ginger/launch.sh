#!/bin/sh

IMAGE_DISK=../target/disk_image.raw
DEPLOYMENT_DISK=../target/disk_deployment.raw
DATA_DISK=../target/disk_data.raw
OVMF_CODE=/usr/share/ovmf/OVMF.fd
OVMF_VARS=UEFI_VARS.fd

qemu-system-x86_64 \
  -m 256 \
  -nographic \
  -netdev tap,id=ginger,ifname=tap2,script=no,downscript=no \
  -device virtio-net-pci,netdev=ginger,mac=50:54:00:00:00:66 \
  -drive if=virtio,format=raw,file="${IMAGE_DISK}" \
  -drive if=virtio,format=raw,file="${DEPLOYMENT_DISK}" \
  -drive if=virtio,format=raw,file="${DATA_DISK}" \
  -drive if=pflash,format=raw,unit=0,file="${OVMF_CODE}",readonly=on
