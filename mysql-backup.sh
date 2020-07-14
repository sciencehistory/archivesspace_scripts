#! /bin/bash

# This script, called regularly by the ubuntu user's crontab,
# dumps the ArchivesSpace database to a location where it can be harvested by the
# backup scripts on Dubnium.


source ./script_settings.sh
#TODO: investigate what the deal is with this:
OUTPUT_PATH=/backup/aspace-backup.sql
OUTPUT_PATH=/backups/mysql-backup/archivesspace_backup.sql
mysqldump \
    archivesspace -C \
    --password=$DATABASE_BACKUP_PASSWORD \
    --user=$DATABASE_BACKUP_USER \
    > /backups/mysql-backup/archivesspace_backup.sql
