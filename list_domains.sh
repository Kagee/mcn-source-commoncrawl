#! /usr/bin/env bash
# Info: http://data.norge.no/data/registerenheten-i-br%C3%B8nn%C3%B8ysund/enhetsregisteret
# Download: http://hotell.difi.no/download/brreg/enhetsregisteret?download
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"
source "config.sh" # MCN_TOOLS, DOMAINS

if [ ! -e "${DOMAINS}" ] || [ "x$1" = "x--update-list" ]; then
    echo "INFO: ${DOMAINS} not found, extracting ..." 1>&2
    # We do some hacks to remove the number of false positive domains
    # urldecode: 20finn.no -> 
    #     http://blogg.no/share?url=http://pitoresk.blogg.no/1297370777_10feb2011.html&title=Antikviteter%20fra%20finn.no
    # sed: 300367.no -> 
    #     http://www.tromso.kommune.no/skriftlige-spoersmaal.300367.no.html
    find "${STORAGE_PATH}/" -type f -name '*.gz' -exec zcat '{}' \; | \
        sed -e 's/\.no\.html/.html/g' | \
        ${MCN_TOOLS}/urldecode | ${MCN_TOOLS}/urldecode | ${MCN_TOOLS}/urldecode | \
        ${MCN_TOOLS}/default_extract > "${DOMAINS}"
else
    echo "INFO: ${DOMAINS} found. Use '$0 --update-list' to force new extraction." 1>&2
fi
#cat "${DOMAINS}"
