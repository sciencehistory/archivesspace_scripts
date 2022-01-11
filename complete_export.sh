DIRECTORY_INSTALLED=/home/ubuntu/archivesspace_scripts

cd $DIRECTORY_INSTALLED

echo "Starting complete export on `date`"

echo "Checking that ubuntu is part of group www-data..."
if groups | grep -q '\bwww-data\b'; then
    echo "ubuntu is part of www-data."
else
    echo "User ubuntu is not part of group www-data. This script will not be able to write to the web directories."
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

echo "Doanloading EADs and converting to HTML:"
./create_html_files.sh
sudo chown -R www-data:www-data /var/www/
sudo chmod -R g+rwx /var/www
