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
* When you create a new ArchivesSpace server, check this code out into the `/home/ubuntu` on our ArchivesSpace server: `/home/ubuntu/archivesspace_scripts`.
* Make sure the directory is owned by the `ubuntu:ubuntu` user.
* This code is eventually meant to *replace* the entire contents of the home directory of the `ubuntu` user.

### Usernames and passwords
To allow the code to talk to the ArchivesSpace, you will want to put usernames and passwords will go into two files.
* local_settings.cfg
* script_settings.sh
Run `cp script_settings_sample.sh script_settings.sh` and `cp local_settings_sample.cfg local_settings.cfg`, then edit the new files so they contain the right credentials.

## Export instructions
* To run a complete export, just run `./complete_export.sh`. This shields you from a number of steps that were previously run manually, to get around the fact that:
    - the server has yet to be fully set up in Ansible
    - the software used ( a variation on a past version of https://github.com/RockefellerArchiveCenter/as_export/blob/base/as_export.py ) and/or ArchivesSpace itself, was buggy, and would run into trouble.

## Next Steps
- Eliminate `setup.sh`. The commands in that script should be moved to the Ansible configuration.
- Use the latest version of https://github.com/RockefellerArchiveCenter/as_export/blob/base/as_export.py . Eddie Rubeiz did some work on this in July 2020, but was never able to get the `asnake` wrapper to correctly authenticate against ArchivesSpace.
- Figure out why it isn't possible to comment out the `python as_export.py --prefix 2012` line in  ./complete_export.sh. (Is it a memory leak? A bug of some sort in as_export.py itself?)
- Make it possible for the code to be checked out in an arbitrary location. (Currently, the directory `/home/ubuntu/archivesspace_scripts` is hardcoded in various places.)
- Consider running `./complete_export.sh` on a cron job, and setting up Ansible to run that cron job.
- Eliminate a considerable amount of duplication in the code between the two directories `fa-files` and `finding-aid-files`.
- When building a new ArchivesSpace server, automate the checkout of this code into the `/home/ubuntu` directory.
- Remove the two backup scripts (`s3-backup.sh` `mysql-backup.sh`) and place them in the Ansible code. They don't really belong in this code.
- Get rid of script_settings.sh and script_settings_sample.sh too. Their only function is to serve as a bandaid so we can make sure the export scripts are checked into Github without any passwords in it.

