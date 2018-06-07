#! /usr/bin/env bash
# Info: 
# Download: 
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SOURCE_DIR" || exit
source "./config.sh"

if [ ! -e "$DOMAINS" ] || [ "x$1" = "x--update-list" ]; then
    echo >&2 "[INFO] $DOMAINS not found, extracting ..."
    # We do some hacks to remove the number of false positive domains
    # urldecode: 20finn.no -> 
    #     http://blogg.no/share?url=http://pitoresk.blogg.no/1297370777_10feb2011.html&title=Antikviteter%20fra%20finn.no
    # sed: 300367.no -> 
    #     http://www.tromso.kommune.no/skriftlige-spoersmaal.300367.no.html
    # TODO: rewrite to work on one and one fiel, and to skip a file of a precessed file exsists
    find "$STORAGE_PATH/" -type f -name '*.gz' -exec zcat '{}' \; | \
        sed -e 's/\.no\.html/.html/g' | \
        "$MCN_TOOLS/urldecode" 3 | \
        "$MCN_TOOLS/default_extract" | cat - "$DOMAINS" 2>/dev/null > "_tmp.list"
    mv "_tmp.list" "$DOMAINS"
else
    echo >&2 "[INFO] $DOMAINS found. Use '$0 --update-list' to force new extraction."
fi
#cat "${DOMAINS}"
