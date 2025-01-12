<?php
$servername = "localhost";
$username   = "feeyamnw_memberlinkadmin";
$password   = "NazuASN8BZXW";
$dbname     = "feeyamnw_memberlinkdb";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>