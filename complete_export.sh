DIRECTORY_INSTALLED=/home/ubuntu/archivesspace_scripts

cd $DIRECTORY_INSTALLED

echo "Starting complete export on `date`"
echo "Checking that ArchivesSpace is running..."

if /opt/archivesspace/archivesspace.sh status | grep -q 'running'; then
    echo "ArchivesSpace is running."
else
    echo "ArchivesSpace is not running."
    echo "Please run sudo systemctl start archivesspace until it is running."
    exit
fi

echo "Checking that ubuntu is part of group www-data..."
if groups | grep -q '\bwww-data\b'; then
    echo "ubuntu is part of www-data."
else
    echo "User ubuntu is not part of group www-data. This script will not be able to write to the web directories."
    exit
fi

jq --version > /dev/null
if [ $? -eq 0 ]; then
    echo "jq is installed."
else
    echo "jq is not installed."
    exit
fi

xmlstarlet --version > /dev/null
if [ $? -eq 0 ]; then
    echo "xmlstarlet is installed."
else
    echo "xmlstarlet is not installed."
    exit
fi


echo "Creating directories and installng software, if needed:"
./setup.sh

echo "Exporting EADs."
./export_eads.sh

echo "Converting to HTML:"
sudo ./generate.sh

echo "Checking that all xml is valid:"
./xml-validator.sh
echo "Files are now available for harvest at https://archives.sciencehistory.org/ead/".

echo "Logs are at:"

echo "/var/log/findingaid/findingaid.log"
