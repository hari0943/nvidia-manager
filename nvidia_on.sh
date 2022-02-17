#!/usr/bin/env bash
REMOVE_DEVICE=1
DEVICE_BUS_ID=0000:01:00.0
CONTROLLER_BUS_ID=0000:00:01.0
MODULES_LOAD=(nvidia nvidia_uvm nvidia_modeset "nvidia_drm modeset=1")
BUS_RESCAN_WAIT_SEC=1
REMOVE_DEVICE=1
function turn_on_gpu {
  echo 'Turning the PCIe controller on to allow card rescan'
  sudo tee /sys/bus/pci/devices/${CONTROLLER_BUS_ID}/power/control <<<on

  echo 'Waiting 1 second'
  sleep 1

  if [[ ! -d /sys/bus/pci/devices/${DEVICE_BUS_ID} ]]; then
    echo 'Rescanning PCI devices'
    sudo tee /sys/bus/pci/rescan <<<1
    echo "Waiting ${BUS_RESCAN_WAIT_SEC} second for rescan"
    sleep ${BUS_RESCAN_WAIT_SEC}
  fi

  echo 'Turning the card on'
  sudo tee /sys/bus/pci/devices/${DEVICE_BUS_ID}/power/control <<<on
}
function load_modules {
  for module in "${MODULES_LOAD[@]}"
  do
    echo "Loading module ${module}"
    sudo modprobe ${module}
  done
}
function enable_gpu {
	if lsmod | grep -q acpi_call; then
		echo 'acpi_call found'
	else
		echo 'acpi_call found, importing it'
		sudo modprobe acpi_call
	fi
    	echo '\_SB.PCI0.PEG0.PEGP._ON'> /proc/acpi/call
    	echo 'Discrete graphic card ENABLED !'
}
enable_gpu
turn_on_gpu
load_modules
