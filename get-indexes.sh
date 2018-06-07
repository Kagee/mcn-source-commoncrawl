#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"

source "config.sh"
CLIENT="cdx-index-client/cdx-index-client.py"
WD="$PWD"

#echo -e "CC-MAIN-2013-20\nCC-MAIN-2013-48" | \
curl -s http://index.commoncrawl.org/ | grep -o -P 'CC-MAIN-....-..' | sort | uniq | \
while read API_ENDPOINT;
do
  FOLDER="${STORAGE_PATH}/$API_ENDPOINT"
  METADATA="$FOLDER/metadata"
  mkdir -p "$FOLDER";
  PAGES="$(cat ${FOLDER}/metadata | jq -r .pages)" 2>/dev/null
  if [ ! -f "${METADATA}" ] || [ "x$PAGES" = "x" ]; then
    curl -s "http://index.commoncrawl.org/${API_ENDPOINT}-index?url=*.no&output=json&showNumPages=true" > "$METADATA"
    PAGES="$(cat ${FOLDER}/metadata | jq -r .pages)"
  fi
  FILES="$(ls $FOLDER | grep -v metadata | wc -l)"
  #echo "Pages: $PAGES, Files: $FILES"

  if [ $PAGES -eq $FILES ]; then
    echo "Found $(find $FOLDER -type f ! -name metadata | wc -l) of $(cat ${FOLDER}/metadata| jq -r .pages) expected files for $API_ENDPOINT, assuming complete"
  else
    echo -n "$API_ENDPOINT ";
    cat "${STORAGE_PATH}/${API_ENDPOINT}/metadata";
    cd "${FOLDER}";
    # Defaults to Commoncrawer, so we don't supply a server URL
    ${WD}/${CLIENT} --processes ${THREADS} --coll "${API_ENDPOINT}" '*.no' --fl url -z;
    cd "$WD";
  fi
  #sleep 5;
done;
