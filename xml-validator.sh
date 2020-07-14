#XMLFILES=$(find /exports/data/ead/ -type f)
XMLFILES=$(find /var/www/html/ead/ -type f)

for x in $XMLFILES;
  do
  echo "checking $x"
  xmlstarlet val -b $x
done
