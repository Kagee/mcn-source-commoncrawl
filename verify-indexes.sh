#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"

source "config.sh"

find "${STORAGE_PATH}/" -type f -name '*.gz' | \
 parallel gzip --test {}
