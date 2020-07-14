#! /bin/bash
PATH=/home/ubuntu/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
aws s3 sync /backup s3://chf-hydra-backup/Aspace --no-guess-mime-type --storage-class STANDARD_IA
