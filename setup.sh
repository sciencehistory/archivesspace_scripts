# These commands can be removed from here and
# added to the Ansible script for aspace.
#
pip install requests  psutil requests_toolbelt

sudo mkdir -p /exports/data/ead  /var/www/html/ead/ /var/log/findingaid/
sudo chown -R ubuntu:ubuntu /exports/data/ead
sudo chown -R ubuntu:ubuntu /var/log/findingaid/

sudo touch /var/log/findingaid/findingaid.log
sudo chown ubuntu:ubuntu /var/log/findingaid/findingaid.log

sudo chown -R www-data:www-data /var/www/
sudo chmod -R g+rwx /var/www
# Note: It's assumed ubuntu is part of group wwww-data and can thus write to these directories.
# If it's not, the export script will simply not run.
