#uniquely identify the image through a uuid handle
UUID=$(cat /proc/sys/kernel/random/uuid)
SRC=/tmp/$UUID
#get the image
curl  -o $SRC.jpg $1
# remove exif and convert to progressive
jpegtran -copy none -optimize -progressive $SRC.jpg  > $SRC.pro
convert -strip -quality 80 $SRC.jpg $SRC.80
convert $SRC.jpg $SRC.png
cwebp -q 80 $SRC.jpg -o $SRC.webp
#Check Size Difference
png_size=$(stat -c %s $SRC.png)
original_size=$(stat -c %s $SRC.jpg)
progressive_size=$(stat -c %s $SRC.pro)
optimized_size=$(stat -c %s $SRC.80)
webp_size=$(stat -c %s $SRC.webp)
echo "<hr>"
echo "<div>"
echo "PNG(no loss) size	: $png_size bytes"
echo '<img class="jpeg" src="data:image/png;base64,';
		echo "$(cat $SRC.png| base64)"
echo '">';
echo "</div>"

echo "<div>"
echo "Original  size		: $original_size bytes"
echo '<img class="jpeg" src="data:image/jpeg;base64,';
		echo "$(cat $SRC.jpg| base64)"
echo '">';
echo "</div>"
echo "<div>"
echo "Prog+NoEXIF  size	: $progressive_size bytes"
echo '<img class="jpeg" src="data:image/jpeg;base64,';
		echo "$(cat $SRC.pro| base64)"
echo '">';
echo "</div>"
echo "<div>"
echo "JPG+NoExif at 80% 	: $optimized_size bytes"
echo '<img class="jpeg" src="data:image/jpeg;base64,';
		echo "$(cat $SRC.80| base64)"
echo '">';
echo "</div>"
echo "<div>"
echo "WEBP(at 80%) size	: $webp_size bytes"
echo '<img class="jpeg" src="data:image/jpeg;base64,';
		echo "$(cat $SRC.webp| base64)"
echo '">';
echo "</div>"
echo "<hr>"
# get the gory details
identify -verbose /tmp/$UUID.jpg
rm /tmp/$UUID*
