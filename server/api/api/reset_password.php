<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}
include_once("dbconnect.php");


    // Get the email and new password from POST data
    $email = $_POST['email'];
    $new_password = sha1($_POST['new_password']);

    // Check if the user exists
    $query = "SELECT * FROM tbl_user WHERE user_email = '$email'";
    $result = $conn->query($query);

    if ($result->num_rows > 0) {
        // Update the password in the database
        $update_query = "UPDATE tbl_user SET user_pass = '$new_password' WHERE user_email = '$email'";
        if ($conn->query($update_query) === TRUE) {
            echo json_encode(["status" => "success", "message" => "Password updated successfully."]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update the password."]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "User not found."]);
    }


// Close the database connection
$conn->close();
?>
