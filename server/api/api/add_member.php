<?php

include_once("dbconnect.php");
$name = $_POST['name'];
$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);
$role = $_POST['role'];

$sql = "INSERT INTO tbl_users (user_name, user_email, user_password, user_role) VALUES ('$name', '$email', '$password', '$role')";
$response = $conn->query($sql) ? ['status' => 'success'] : ['status' => 'failed'];
echo json_encode($response);

?>