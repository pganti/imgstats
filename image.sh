#uniquely identify the image through a uuid handle
UUID=$(cat /proc/sys/kernel/random/uuid)
SRC=/tmp/$UUID
#get the image
curl  -o $SRC.jpg $1
original_size=$(stat -c %s $SRC.jpg)
#get the lossless equivalent for the image
convert $SRC.jpg $SRC.png
png_size=$(stat -c %s $SRC.png)
# remove exif and convert to progressive
jpegtran -copy none -optimize -progressive $SRC.jpg  > $SRC.pro
progressive_size=$(stat -c %s $SRC.pro)
# lossless webp
cwebp -quiet -q 100 $SRC.png -o $SRC.webp
webp_size=$(stat -c %s $SRC.webp)
#Check Size Difference
echo "<style type="text/css">
.tftable {font-size:12px;color:#333333;width:100%;border-width: 1px;border-color: #729ea5;border-collapse: collapse;}
.tftable th {font-size:12px;background-color:#acc8cc;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:left;}
.tftable tr {background-color:#d4e3e5;}
.tftable td {font-size:12px;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;}
.tftable tr:hover {background-color:#ffffff;}
</style>"
echo "<h1>Lossless Transforms</h1>"
# start tabulating the results
echo "<table class="tftable" border="1">"
echo "<tr><th> Flavor</th><th> ByteCount</th><th> Image</th></tr>"

echo "<tr>"
echo "<td>PNG(no loss)</td>"
echo "<td>$png_size<td>"
echo '<img src="data:image/png;base64,';
		echo "$(cat $SRC.png| base64)"
echo '"><tr>';

echo "<tr>"
echo "<td>Original Image</td>"
echo "<td>$original_size<td>"
echo '<img src="data:image/jpeg;base64,';
		echo "$(cat $SRC.jpg| base64)"
echo '"><tr>';


echo "<tr>"
echo "<td>Progressive(No Exif)</td>"
echo "<td>$progressive_size<td>"
echo '<img src="data:image/jpeg;base64,';
		echo "$(cat $SRC.pro| base64)"
echo '"><tr>';

echo "<tr>"
echo "<td>Webp</td>"
echo "<td>$webp_size<td>"
echo '<img src="data:image/webp;base64,';
		echo "$(cat $SRC.webp| base64)"
echo '"><tr>';
echo "</table>";

# for a list of quality values generate different files
for q in 10 20 30 40 50 60 70 80 90 
do
	convert -strip -quality $q $SRC.pro $SRC.$q.jpg
	cwebp -quiet -q $q $SRC.png -o $SRC.$q.webp
	compare -metric PSNR $SRC.pro $SRC.$q.jpg $SRC.$q.diff
done

echo "<h1>Lossy Transforms</h1>"
echo "<h2>Visual Compare of jpg vs webp</h2>"
echo "<table class="tftable" border="1">"
echo "<tr>"
echo "<td></td>"
echo "<th scope="col">10</th> <th scope="col">20</th> <th scope="col">30</th> <th scope="col">40</th> <th scope="col">50</th> <th scope="col">60</th> <th scope="col">70</th> <th scope="col">80</th> <th scope="col">90</th>"
	echo "<tr>"
	echo "<td>JPG</td>"
	for q in 10 20 30 40 50 60 70 80 90 
	do
	echo '<td><img src="data:image/jpeg;base64,';
		echo "$(cat $SRC.$q.jpg| base64)"
	echo '"></td>';
	done
	echo "</tr>"

	echo "<tr>"
	echo "<td>WEB</td>"
	for q in 10 20 30 40 50 60 70 80 90 
	do
	echo '<td><img src="data:image/webp;base64,';
		echo "$(cat $SRC.$q.webp| base64)"
	echo '"></td>';
	done
	echo "</tr>"
echo "</table>";

echo "<h2>Compare ByteSizes of jpg vs webp</h2>"
echo "<table class="tftable" border="1">"
echo "<tr>"
echo "<td></td>"
echo "<th scope="col">10</th> <th scope="col">20</th> <th scope="col">30</th> <th scope="col">40</th> <th scope="col">50</th> <th scope="col">60</th> <th scope="col">70</th> <th scope="col">80</th> <th scope="col">90</th>"
	echo "<tr>"
	echo "<td>JPG</td>"
	for q in 10 20 30 40 50 60 70 80 90 
	do
		 echo "<td>$(stat -c %s $SRC.$q.jpg)</td>"
	done
	echo "</tr>"

	echo "<tr>"
	echo "<td>WEBP</td>"
	for q in 10 20 30 40 50 60 70 80 90 
	do
		echo "<td>$(stat -c %s $SRC.$q.webp)</td>"
	done
	echo "</tr>"
echo "</table>";

echo "<h2>PSNR</h2>"
echo "<table class="tftable" border="1">"
echo "<tr>"
echo "<td></td>"
echo "<th scope="col">10</th> <th scope="col">20</th> <th scope="col">30</th> <th scope="col">40</th> <th scope="col">50</th> <th scope="col">60</th> <th scope="col">70</th> <th scope="col">80</th> <th scope="col">90</th>"
	echo "<tr>"
	echo "<td>JPG</td>"
	for q in 10 20 30 40 50 60 70 80 90 
	do
		 echo "<td>$(compare -metric PSNR $SRC.pro $SRC.$q.jpg $SRC.$q.jdiff 2>&1)</td>"
	done
	echo "</tr>"

	echo "<tr>"
	echo "<td>Diff</td>"
	for q in 10 20 30 40 50 60 70 80 90 
	do
	echo '<td><img src="data:image/jpeg;base64,';
		echo "$(cat $SRC.$q.jdiff| base64)"
	echo '"></td>';
	done
	echo "</tr>"

echo "</table>";



# get the gory details
echo "<h1>Diagnostic Info</h1>"
identify -verbose /tmp/$UUID.jpg
rm /tmp/$UUID*
