<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

// Retrieve identifier and password from the POST request
$identifier = $_POST['identifier']; // Can be email or username
$password = $_POST['password'];

// SQL query to check for either email or username match
$sqllogin = "SELECT `user_email`, `user_username`, `user_pass` FROM `tbl_user` 
             WHERE (`user_email` = '$identifier' OR `user_username` = '$identifier') 
             AND `user_pass` = '$password'";
$result = $conn->query($sqllogin);

// Send response based on the query result
if ($result->num_rows > 0) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

$conn->close();
?>
