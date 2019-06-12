#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"

source "fr-config.sh"
CLIENT="cdx-index-client/cdx-index-client.py"
WD="$PWD"
mkdir -p "$STORAGE_PATH"

#echo -e "CC-MAIN-2013-20\nCC-MAIN-2013-48" | \
#curl -s http://index.commoncrawl.org/ | grep -o -P 'CC-MAIN-....-[0-9]*' | sort | uniq | \

curl -s http://index.commoncrawl.org/collinfo.json | jq -c '.[]' | sort | uniq | \
while read JSON;
do
  ID="$(echo "$JSON" | jq -r '.["id"]')"
  CDX="$(echo "$JSON" | jq -r '.["cdx-api"]')"
  FOLDER="${STORAGE_PATH}/${ID}"
  METADATA="$FOLDER/metadata"
  mkdir -p "$FOLDER";
  PAGES="$(cat ${FOLDER}/metadata | jq -r .pages 2>/dev/null)" 2>/dev/null
  if [ ! -f "${METADATA}" ] || [ "x$PAGES" = "x" ]; then
    1>&2 echo "[INFO] Metadata was missing, downloading"
    curl -s "${CDX}?url=*.fr&output=json&showNumPages=true" > "$METADATA"
    PAGES="$(cat ${FOLDER}/metadata | jq -r .pages)"
  fi
  FILES="$(ls $FOLDER | grep -v metadata | wc -l)"
  1>&2 echo "[INFO] ID: $ID, PAGES: $PAGES, Files: $FILES"

  if [ $PAGES -eq $FILES ]; then
    echo "Found $(find $FOLDER -type f ! -name metadata | wc -l) of $(cat ${FOLDER}/metadata| jq -r .pages) expected files for ${ID}, assuming complete"
  else
    1>&2 echo "Found $(find $FOLDER -type f ! -name metadata | wc -l) of $(cat ${FOLDER}/metadata| jq -r .pages) expected files for ${ID}, downloading"
    1>&2 echo -n "Downloading pages for $ID ";
    1>&2 echo $JSON
    1>&2 cat "${METADATA}";
    cd "${FOLDER}";
    # Defaults to Commoncrawer, so we don't supply a server URL
    ${WD}/${CLIENT} --processes ${THREADS} --coll "${ID}" '*.fr' --fl url -z;
    cd "$WD";
  fi
  #sleep 5;
done;
