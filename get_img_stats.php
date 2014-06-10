<?php
echo "<html> <body>";
$url=$_POST["url"];
$cmd = dirname(__FILE__).'/image.sh "'.$url.'"';
$output=shell_exec($cmd);
echo "<pre>$output</pre>";
echo "</body> </html>"
?>
