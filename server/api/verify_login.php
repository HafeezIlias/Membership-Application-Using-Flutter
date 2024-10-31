<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

// Get the email and username from the POST request, if they exist
$email = isset($_POST['email']) ? $_POST['email'] : null;
$username = isset($_POST['username']) ? $_POST['username'] : null;

$response = array();

// Check if email exists
if ($email) {
    $sqlCheckEmail = "SELECT `user_email` FROM `tbl_user` WHERE `user_email` = '$email'";
    $resultEmail = $conn->query($sqlCheckEmail);
    if ($resultEmail->num_rows > 0) {
        $response['email'] = array('status' => 'success', 'message' => 'Email exists');
    } else {
        $response['email'] = array('status' => 'failed', 'message' => 'Email not exists');
    }
}

// Check if username exists
if ($username) {
    $sqlCheckUsername = "SELECT `user_username` FROM `tbl_user` WHERE `user_username` = '$username'";
    $resultUsername = $conn->query($sqlCheckUsername);
    if ($resultUsername->num_rows > 0) {
        $response['username'] = array('status' => 'success', 'message' => 'Username exists');
    } else {
        $response['username'] = array('status' => 'failed', 'message' => 'Username not exists');
    }
}

// Send the JSON response
sendJsonResponse($response);

// Function to send a JSON response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

// Close the database connection
$conn->close();
?>
