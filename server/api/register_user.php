<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$email = $_POST['email'];
$password = sha1($_POST['password']); // Hash the password$_POST['password'];
$phonenumber = $_POST['phoneNum'];
$username = $_POST['username'];

// Check for duplicate email or username
$sqlcheck = "SELECT * FROM `tbl_user` WHERE `user_email` = '$email' OR `user_username` = '$username'";
$result = $conn->query($sqlcheck);

if ($result->num_rows > 0) {
    // Duplicate found
    $response = array('status' => 'failed', 'message' => 'Username or email already exists');
    sendJsonResponse($response);
} else {
    // Proceed with insertion if no duplicates are found
    $sqlinsert = "INSERT INTO `tbl_user`(`user_email`, `user_pass`, `user_phone`, `user_username`) VALUES ('$email', '$password', '$phonenumber', '$username')";
    
    if ($conn->query($sqlinsert) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
    } else {
        $response = array('status' => 'failed', 'message' => 'Registration failed');
    }
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
