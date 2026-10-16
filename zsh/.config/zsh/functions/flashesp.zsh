flashesp() {
    local port="${1:-/dev/ttyUSB0}"
    local baud=115200

    if ! command -v idf.py &>/dev/null; then
        source "$HOME/esp/esp-idf/export.sh" || return 1
    fi

    echo "Building ESP32 firmware..."
    idf.py build || return 1

    echo "Flashing ESP32 on $port..."
    idf.py -p "$port" -b "$baud" flash || return 1

    echo "ESP32 flashed successfully!"
}
