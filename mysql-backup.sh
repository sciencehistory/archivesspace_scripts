#! /bin/bash

# This script, called regularly by the ubuntu user's crontab,
# dumps the ArchivesSpace database to a location where it can be harvested by the
# backup scripts on Dubnium.
cd /home/ubuntu/archivesspace_scripts

# get the passwords:
source ./script_settings.sh
OUTPUT_PATH=/backup/aspace-backup.sql

# dump:
mysqldump \
    archivesspace -C \
    --no-tablespaces \
    --password=$DATABASE_BACKUP_PASSWORD \
    --user=$DATABASE_BACKUP_USER \
    > $OUTPUT_PATH
