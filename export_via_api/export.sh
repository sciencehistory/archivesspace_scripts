source ../script_settings.sh
OUTPUT_DIR=eads
SESSION=`curl -s  -F password="$EXPORT_PASSWORD" archives.sciencehistory.org:8089/users/$EXPORT_USER/login |  jq -r '.session'`
IDS=`curl -s -H "X-ArchivesSpace-Session: $SESSION" archives.sciencehistory.org:8089/repositories/$REPOSITORY_ID/resources?all_ids=true |  jq -c '.[] ' `
for ID in $IDS; do
	echo "Exporting $ID."
	curl -s -H "X-ArchivesSpace-Session: $SESSION" archives.sciencehistory.org:8089/repositories/$REPOSITORY_ID/resource_descriptions/$ID.xml > $OUTPUT_DIR/$ID.ead
done