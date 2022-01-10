#! /bin/bash
#
# Takes the content of /exports/data/new_ead/, runs them through the finding aid stylesheet
# and places the resulting items in /var/www/html.
#

EXPORTLOCATION=/var/www/html/new_ead
EAD=$(ls $EXPORTLOCATION/*.xml )
WEBDIR=/var/www/html
STYLESHEET=finding-aid-files/findingaid.xsl
DATE=$(date +%Y-%m-%d-%H:%M)

for e in $EAD;
  do
  FILENAME=$(xmlstarlet sel -t -v "(//_:unitid)[1]" $e | sed 's/\./-/')
  echo "$DATE Generating html for $e" &>> /var/log/findingaid/findingaid.log
  saxonb-xslt \
      -o $WEBDIR/$FILENAME.html \
      $e $STYLESHEET \
      &>> /var/log/findingaid/findingaid.log \
      && echo "Successful generation of $e" >> /var/log/findingaid/findingaid.log \
	  || echo "Generation for $e failed" >> /var/log/findingaid/findingaid.log

done

sudo chmod -R 775 $WEBDIR
sudo chown -R  www-data:www-data $WEBDIR
