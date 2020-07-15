#! /bin/bash
#
# Takes the content of /exports/data/ead/, runs them through the finding aid stylesheet
# and places the resulting items in /var/www/html and /var/www/html/ead
#


EXPORTLOCATION=/exports/data/ead/
EAD=$(find $EXPORTLOCATION -type f)
WEBDIR=/var/www/html
STYLESHEET=/home/ubuntu/bin/fa-files/findingaid.xsl
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
  chown www-data:www-data $WEBDIR/$FILENAME.html
  cp $e $WEBDIR/ead/scihist-$FILENAME.xml
  chown www-data:www-data $WEBDIR/ead/scihist-$FILENAME.xml
done
