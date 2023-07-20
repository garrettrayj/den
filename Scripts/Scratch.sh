#!/bin/zsh

destination="Screenshots/iPhone 12 Pro Max"

for file ($destination/*.png(ND.)) {
    new_name="${file//-//}"
    mkdir -p "$(dirname "$new_name")"
    mv "${file}" "${new_name}"
}
