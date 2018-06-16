#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"

source "config.sh"

find "${STORAGE_PATH}/" -type f -name '*.gz' | \
  parallel gzip --test {} 2>&1 | O="$(cat -)"

echo -n "Number of files with errors: "; echo "$O" | grep -c 'gzip:'
echo "$O"
