#! /usr/bin/env bash
# Info: 
# Download: 
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SOURCE_DIR" || exit
source "./config.sh"

set -euo pipefail
#set -x


COUNT="$(find . -name "*$DOMAINS" 2>/dev/null | wc -l)";
if [ "$COUNT" -eq "0" ] || [ "x${1:-}" = "x--update-list" ]; then
    echo >&2 "[INFO] $DOMAINS not found, extracting ..."
    # We do some hacks to remove the number of false positive domains
    # urldecode: 20finn.no -> 
    #     http://blogg.no/share?url=http://pitoresk.blogg.no/1297370777_10feb2011.html&title=Antikviteter%20fra%20finn.no
    # sed: 300367.no -> 
    #     http://www.tromso.kommune.no/skriftlige-spoersmaal.300367.no.html
    TIMESTAMP="$(date +%F%T | tr ':' '-')"
    mkdir -p "$STORAGE_PATH/no-cache"

    find "$STORAGE_PATH/" -type f -name '*.gz' | \
      ( while read -r FILE; do
          MD="$STORAGE_PATH/no-cache/$(md5sum "$FILE" | cut -d' ' -f 1).xz";
          if [ ! -f "$MD" ]; then
            echo >&2 "[INFO] Processing $FILE into $MD";
            zcat "$FILE" | sed -e 's/\.no\.html/.html/g' | \
            "$MCN_TOOLS/urldecode" 3 | \
            "$MCN_TOOLS/default_extract" | \
            xz --compress --stdout > "$MD.tmp" && mv "$MD.tmp" "$MD"
          else
            echo >&2 "[INFO] Found $MD, not processing $FILE"
          fi
        done
    ) && \
      find "$STORAGE_PATH/no-cache" -name '*.xz' -exec xzcat '{}' \;| \
      "$MCN_TOOLS/default_extract" | \
      cat - ./*"$DOMAINS" 2>/dev/null | sort | uniq > "_tmp.list" && \
      mv "_tmp.list" "$TIMESTAMP-$DOMAINS"
else
    echo >&2 "[INFO] $DOMAINS found. Use '$0 --update-list' to force new extraction."
fi
