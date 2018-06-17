#! /usr/bin/env bash
# Info: 
# Download: 
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SOURCE_DIR" || exit
source "./config.sh"

set -euo pipefail
#set -x

LOG_INFO=1
LOG_VERB=1

function def_ex {
  GZ_FILE="${1:-}"
  MCN_TOOLS="${3:-}"
  GZ_HASH="$(md5sum "$GZ_FILE" | cut -d' ' -f 1)"
  CACHE_FOLDER="${2:-}/${GZ_HASH:0:1}"  
  CACHE_FILE="$CACHE_FOLDER/$GZ_HASH";
  JOD_ID="${4:-}"
  if [ ! -f "$CACHE_FILE.xz" ]; then
    INFO "Extracting domains from $GZ_FILE to $CACHE_FILE.xz"
    mkdir -p "$CACHE_FOLDER"
    # We do some hacks to remove the number of false positive domains
    # urldecode: 20finn.no -> 
    #     http://blogg.no/share?url=http://pitoresk.blogg.no/1297370777_10feb2011.html&title=Antikviteter%20fra%20finn.no
    # sed: 300367.no -> 
    #     http://www.tromso.kommune.no/skriftlige-spoersmaal.300367.no.html
    zcat "$GZ_FILE" | sed -e 's/\.no\.html/.html/g' | \
      "$MCN_TOOLS/urldecode" 3 | \
      "$MCN_TOOLS/default_extract" | \
      sort | uniq | \
      xz --compress --stdout > "$CACHE_FILE.tmp" && \
      mv "$CACHE_FILE.tmp" "$CACHE_FILE.xz"
  else
    VERB "Found $CACHE_FILE.xz, not extracting domains from $GZ_FILE"
  fi
}

export -f def_ex
export LOG_INFO
export LOG_VERB

COUNT="$(find . -name "*$DOMAINS" 2>/dev/null | wc -l)";
if [ "$COUNT" -eq "0" ] || [ "x${1:-}" = "x--update-list" ]; then
  INFO "$DOMAINS not found, extracting ..."

  TIMESTAMP="$(date +%F-%T | tr ':' '-')"
  EXTRACT_CACHE="$STORAGE_PATH/ext-cache"
  mkdir -p "$EXTRACT_CACHE"
  GZ_FILES="$(mktemp "$PWD/$TIMESTAMP-XXXXXXXXXX")"
  find "$STORAGE_PATH/" -type f -name '*.gz' > "$GZ_FILES"
  cat "$GZ_FILES" | parallel def_ex '{}' "$EXTRACT_CACHE" "$MCN_TOOLS" '{#}'
  echo "$GZ_FILES"
  rm "$GZ_FILES"
  #find "$STORAGE_PATH/no-cache" -name '*.xz' | \
  #sort | uniq | parallel -P "$(echo "$(nproc --all) * 2" | bc)" def_ex '{#}' '{}'
  #exit 
  #  cat ./*"$DOMAINS" > "_tmp.list"
  #  find "$STORAGE_PATH/no-cache" -name '*.no' > "_tmp.list"
  #  cat "_tmp.list" | sort | uniq > "_tmp.list2" && mv "_tmp.list2" "$TIMESTAMP-$DOMAINS"
  #  rm "_tmp.list"
else
    INFO "$DOMAINS found. Use '$0 --update-list' create a new extract."
fi
