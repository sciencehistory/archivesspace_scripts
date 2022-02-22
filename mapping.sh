EXPORT_USER=joe
EXPORT_PASSWORD=shmo
REPOSITORY_ID=3
API_URL=localhost:8089
TMP_XML_FILES=tmp_xml_files

SESSION=`curl -s  -F password="$EXPORT_PASSWORD" $API_URL/users/$EXPORT_USER/login |  jq -r '.session'`
IDS=`curl -s -H "X-ArchivesSpace-Session: $SESSION" "$API_URL/repositories/$REPOSITORY_ID/resources?all_ids=true" |  jq -c '.[] ' `


mkdir -p $TMP_XML_FILES
rm -rf  $TMP_XML_FILES/*

for ID in $IDS; do
        XML_FILENAME="$TMP_XML_FILES/$ID.ead.xml"
        curl -s -H "X-ArchivesSpace-Session: $SESSION" \
                $API_URL/repositories/$REPOSITORY_ID/resource_descriptions/$ID.xml \
                > $XML_FILENAME
        HTML_FILENAME=$(xmlstarlet sel -t -v "(//_:unitid)[1]" $XML_FILENAME | sed 's/\./-/').html
        echo "'$HTML_FILENAME' : '/repositories/$REPOSITORY_ID/resources/$ID',"
done
