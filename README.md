# Science History Institute ArchivesSpace Scripts

## About 

* This is a collection of scripts we use to manage and back up our ArchivesSpace instance.
* It does two main things:
1. Allow our EADs to be harvested over HTTP by peer institutions.
2. Provide scripts for a cronjob to back up our ArchivesSpace data.

## Credits
* Much of this work is due to Sarah Newhouse and Daniel Sanford.
* Eddie Rubeiz spent some time in summer 2020 cleaning it up, making it more reliable and documenting it.

## Installation
* This code is meant to be checked out in the `/home/ubuntu` on our ArchivesSpace server: `/home/ubuntu/archivesspace_scripts`.
* This code is meant to be owned by the `ubuntu:ubuntu` user.
* This code is meant to *replace* the entire contents of the home directory of the `ubuntu` user.

## Export details
* To run a complete export, just run `./complete_export.sh`. This shields you from a number of steps that were previously run manually, to get around the fact that:
    - the server has yet to be fully set up in Ansible
    - the software used ( a variation on a past version of https://github.com/RockefellerArchiveCenter/as_export/blob/base/as_export.py ) and/or ArchivesSpace itself, was buggy, and would run into trouble.

## Next Steps
- Eliminate `setup.sh`. The commands in that script should be moved to the Ansible configuration.
- Use the latest version of https://github.com/RockefellerArchiveCenter/as_export/blob/base/as_export.py . Eddie Rubeiz did some work on this in July 2020, but was never able to get the `asnake` wrapper to correctly authenticate against ArchivesSpace.
- Make it possible for the code to be checked out in an arbitrary location. (Currently, the directory `/home/ubuntu/archivesspace_scripts` is hardcoded in various places.)
- Consider running `./complete_export.sh` on a cron job, and setting up Ansible to run that cron job.
- Eliminate a considerable amount of duplication in the code between the two directories `fa-files` and `finding-aid-files`.
- When building a new ArchivesSpace server, automate the checkout of this code into the `/home/ubuntu` directory.
- Remove the two backup scripts (`s3-backup.sh` `mysql-backup.sh`) and place them in the Ansible code. They don't really belong in this code.
