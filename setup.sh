# These commands can be removed from here and
# added to the Ansible script for aspace.
#
pip install requests  psutil requests_toolbelt

sudo mkdir -p /exports/data/ead  /var/www/html/ead/ /var/log/findingaid/
sudo chown -R ubuntu:ubuntu /exports/data/ead
sudo chown -R ubuntu:ubuntu /var/www/html/ead/
sudo chown -R ubuntu:ubuntu /var/log/findingaid/

sudo touch /var/log/findingaid/findingaid.log
sudo chown ubuntu:ubuntu /var/log/findingaid/findingaid.log
