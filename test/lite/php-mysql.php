<?php
    $connect=mysql_connect('192.168.101.89','php_user','mysql123');
    if($connect)
        echo "PHP connect Mysql Database sucess...";
    else
        echo "PHP connect Mysql Database failed...";
?>
