echo "Checking that ArchivesSpace is running..."
if [[ $(service archivesspace status | grep '\sactive') ]]; then
    echo "ArchivesSpace is running."
else
    echo "ArchivesSpace is not running."
    echo "Please run sudo systemctl start archivesspace until it is running."
    exit
fi

echo "Checking that ubuntu is part of group www-data..."
if [[ $( groups | grep www-data ) ]]; then
    echo "ubuntu is part of www-data."
else
    echo "User ubuntu is not part of group www-data. This script will not be able to write to the web directories."
    exit
fi

echo "Creating directories and installng software, if needed:"
./setup.sh

echo "Exporitng just 2012:"
python as_export.py --prefix 2012

echo "Complete export:"
python as_export.py

echo "Converting to HTML:"
sudo ./generate.sh


echo "Checking that all xml is valid:"
./xml-validator.sh
echo "Files are now available for harvest at https://archives.sciencehistory.org/ead/".

echo "Logs are at:"
echo "/home/ubuntu/archivesspace_scripts/log.txt"
echo "/var/log/findingaid/findingaid.log"
