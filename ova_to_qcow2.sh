#!/bin/bash
### Functional globals
qcow2_path="$1"
ova_file=$(find . -maxdepth 1 -type f -name '*.ova' -print -quit)
found_image=""

# Function to check if qemu-utils is installed
check_qemu_utils() {
    if ! command -v qemu-img >/dev/null; then
        echo "qemu-utils is not installed."
        read -p "Would you like to install qemu-utils? (y/N): " install_choice
        if [[ $install_choice == [Yy] ]]; then
            sudo apt-get update
            sudo apt-get install qemu-utils
        else
            echo "Please install qemu-utils manually to proceed."
            exit 1
        fi
    fi
}

# Function to Accept output VDI file path as script argument and check
qcow_path_check() {
    if [[ -z $qcow2_path ]]; then
        echo "Output QCOW2 file path not provided."
        exit 1
    fi
}

# function to Scan current directory for OVA file
ova_file_check() {
    if [[ -z $ova_file ]]; then
        echo "No OVA file found in the current directory."
        exit 1
    fi
}

# Function to extract OVA
extract_ova() {
    tar -xvf "$ova_file"
}

# Function to scan current directory for VDI or VMDK file
image_file_check() {
    image_file=$(find . -maxdepth 1 \( -name '*.vdi' -o -name '*.vmdk' \) -print -quit)    
    if [[ -z $image_file ]]; then
        echo "No VDI or VMDK file found in the current directory."
        exit 1
    else
        found_image=$image_file
    fi
}

convert_to_qcow2() {
    qemu-img convert "$found_image" -O qcow2 "$qcow2_path"
}

#======================================================================================================

main() {
    check_qemu_utils &&
    qcow_path_check &&
    ova_file_check &&
    extract_ova &&
    image_file_check &&
    convert_to_qcow2
}

main "$@"
