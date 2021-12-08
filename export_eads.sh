# requires xmlstarlet to parse xml
# requires jq to parse json

source script_settings.sh
OUTPUT_DIR=/exports/data/ead
API_URL=archives.sciencehistory.org:8089
#API_URL=localhost:8089

SESSION=`curl -s  -F password="$EXPORT_PASSWORD" $API_URL/users/$EXPORT_USER/login |  jq -r '.session'`
IDS=`curl -s -H "X-ArchivesSpace-Session: $SESSION" $API_URL/repositories/$REPOSITORY_ID/resources?all_ids=true |  jq -c '.[] ' `
MANIFEST_FILE=$OUTPUT_DIR/manifest.txt

echo "Manifest:" > $MANIFEST_FILE
echo "" 		>> $MANIFEST_FILE

for ID in $IDS; do
	echo "Exporting $ID."
	NEW_FILENAME="$ID.ead.xml"

	# Retrieve the EAD and save it at the new filename:
	curl -s -H "X-ArchivesSpace-Session: $SESSION" \
		$API_URL/repositories/$REPOSITORY_ID/resource_descriptions/$ID.xml?include_daos=true \
		> $OUTPUT_DIR/$NEW_FILENAME

	# Get the title out of the EAD
	TITLE=`xmlstarlet sel -t -v "//_:titleproper/text()" $OUTPUT_DIR/$NEW_FILENAME`

	# This part should soon be obsolete, but we need to keep it in here for a bit.
	# Also make a copy of the EAD file at the old filename:
	ACCESSION_NUMBER=`xmlstarlet sel -t -v "(//_:unitid)[1]" $OUTPUT_DIR/$NEW_FILENAME | sed 's/\./-/'`
	OLD_FILENAME="scihist-$ACCESSION_NUMBER.xml"
	cp $OUTPUT_DIR/$NEW_FILENAME $OUTPUT_DIR/$OLD_FILENAME


	# Write out the details to the manifest file:
	echo $TITLE              >>     $MANIFEST_FILE
	echo "    $NEW_FILENAME" >>     $MANIFEST_FILE
	echo "    $OLD_FILENAME" >>     $MANIFEST_FILE

done
