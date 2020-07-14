source ./script_settings.sh
/opt/archivesspace/scripts/ead_export.sh $EXPORT_USER $EXPORT_PASSWORD $REPOSITORY_ID
echo "New zipped file is at: /opt/archivesspace/data/export-repo-3.zip"
echo "List of created items:"
unzip -vl  /opt/archivesspace/data/export-repo-3.zip
