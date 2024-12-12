<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

// Get the email from the POST request
$email = $_POST['email'];
// Query to check if the email exists in the database
$sqlCheckEmail = "SELECT `user_email` FROM `tbl_user` WHERE `user_email` = '$email'";
$result = $conn->query($sqlCheckEmail);

// Prepare the response based on whether the email exists or not
if ($result->num_rows > 0) {
    $response = array('status' => 'success', 'message' => 'Email exists');
} else {
    $response = array('status' => 'failed', 'message' => 'Email does not exist');
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
