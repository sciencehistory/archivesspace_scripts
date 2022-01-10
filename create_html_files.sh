DOWNLOAD_DIR=/tmp/eads
WEBDIR=/var/www/html
STYLESHEET=finding-aid-files/findingaid.xsl
rm $DOWNLOAD_DIR/*.ead.xml
wget -r -nH -np http://ead.sciencehistory.org/ -A *.ead.xml -P $DOWNLOAD_DIR
for XML_FILENAME in `ls $DOWNLOAD_DIR/*ead.xml`; do
    HTML_FILENAME=/var/www/html/$(xmlstarlet sel -t -v "(//_:unitid)[1]" $XML_FILENAME | sed 's/\./-/').html
    saxonb-xslt -o $HTML_FILENAME $XML_FILENAME $STYLESHEET
done

