#!/usr/bin/env bash
REMOVE_DEVICE=1
DEVICE_BUS_ID=0000:01:00.0
CONTROLLER_BUS_ID=0000:00:01.0
MODULES_UNLOAD=(nvidia_drm nvidia_modeset nvidia_uvm nvidia)
BUS_RESCAN_WAIT_SEC=1
REMOVE_DEVICE=1
function turn_off_gpu {
  if [[ "$REMOVE_DEVICE" == '1' ]]; then
    echo 'Removing Nvidia bus from the kernel'
    sudo tee /sys/bus/pci/devices/${DEVICE_BUS_ID}/remove <<<1
  else
    echo 'Enabling powersave for the graphic card'
    sudo tee /sys/bus/pci/devices/${DEVICE_BUS_ID}/power/control <<<auto
  fi

  echo 'Enabling powersave for the PCIe controller'
  sudo tee /sys/bus/pci/devices/${CONTROLLER_BUS_ID}/power/control <<<auto
}
function unload_modules {
  for module in "${MODULES_UNLOAD[@]}"
  do
    echo "Unloading module ${module}"
    sudo modprobe -r ${module}
  done
}
function disable_gpu {
	if lsmod | grep -q acpi_call; then
		echo 'acpi_call found'
	else
		echo 'acpi_call found, importing it'
		sudo modprobe acpi_call
	fi
    	echo '\_SB.PCI0.PEG0.PEGP._OFF'> /proc/acpi/call
    	echo 'Discrete graphic card DISABLED !'
}
unload_modules
disable_gpu
turn_off_gpu
