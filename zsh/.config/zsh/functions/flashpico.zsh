flashpico() {
  local file="$1"
  local configure="$2"
  local pico_mount
 
  if [[ -z "$file" ]]; then
    echo "Usage: flashpico path/to/program.uf2 [true]"
    return 1
  fi

  if [[ "$configure" == "true" ]]; then
    cmake -S . -B build \
      -DPICO_SDK_PATH="$HOME/Code/CPP/pico/pico-sdk" \
      -DPICO_BOARD=pico || return 1
  fi

  cmake --build build -j "$(nproc)" || return 1

  if [[ ! -f "$file" ]]; then
    echo "UF2 not found: $file"
    return 1
  fi

  pico_mount=$(findmnt -rn -S LABEL=RPI-RP2 -o TARGET)

  if [[ -z "$pico_mount" ]]; then
    udisksctl mount -b /dev/disk/by-label/RPI-RP2 || return 1
    pico_mount=$(findmnt -rn -S LABEL=RPI-RP2 -o TARGET)
  fi

  if [[ -z "$pico_mount" ]]; then
    echo "Could not find the Pico mount point."
    return 1
  fi

  cp "$file" "$pico_mount/" || return 1
  sync
}
