#! /bin/bash
CLIENT="../../submodules/cdx-index-client/cdx-index-client.py"
WD="$PWD"
#echo -e "CC-MAIN-2013-20\nCC-MAIN-2013-48" | \
curl -s http://index.commoncrawl.org/ | grep -o -P  "api endpoint:[^)]*" | grep -o -P 'CC-MAIN-....-..' | \
while read API_ENDPOINT;
do
  FOLDER="storage/$API_ENDPOINT"
  METADATA="$FOLDER/metadata"
  mkdir -p "$FOLDER";
  if [ ! -f "${METADATA}" ]; then
    curl -s "http://index.commoncrawl.org/${API_ENDPOINT}-index?url=*.no&output=json&showNumPages=true" > "$METADATA"
  fi
  if [ $(cat ${FOLDER}/metadata| jq -r .pages) -eq $(ls $FOLDER | grep -v metadata | wc -l) ]; then
    echo "Found $(ls $FOLDER | wc -l) of $(cat ${FOLDER}/metadata| jq -r .pages) expected files for $API_ENDPOINT, assuming complete"
  else
    echo -n "$API_ENDPOINT ";
    cat storage/$API_ENDPOINT/metadata;
    cd $FOLDER;
    # Defaults to Commoncrawer, so we don't supply a server URL
    ${WD}/${CLIENT} --processes 4 --coll "${API_ENDPOINT}" '*.no' --fl url -z;
    cd $WD;
  fi
  #sleep 5;
done;
