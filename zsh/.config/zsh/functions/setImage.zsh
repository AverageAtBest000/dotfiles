setImage() {
    if [[ -z "$1" ]]; then
        echo "Usage: setImage <image>"
        return 1
    fi

    local imagePath="$1"

    awww img "$imagePath"
    matugen image "$imagePath"
}
