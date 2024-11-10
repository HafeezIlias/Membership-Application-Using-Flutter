<?php
// Include database connection
include_once("dbconnect.php");

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve the email and new password from the request
    $email = $_POST['email'];
    $new_password = $_POST['new_password'];

    // Sanitize inputs
    $email = filter_var($email, FILTER_SANITIZE_EMAIL);
    $new_password = filter_var($new_password, FILTER_SANITIZE_STRING);

    // Check if the user exists
    $sql = "SELECT * FROM users WHERE email = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Hash the new password for security
        $hashed_password = password_hash($new_password, PASSWORD_BCRYPT);

        // Update the password in the database
        $update_sql = "UPDATE users SET password = ? WHERE email = ?";
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bind_param("ss", $hashed_password, $email);

        if ($update_stmt->execute()) {
            echo json_encode(array("success" => true, "message" => "Password reset successful."));
        } else {
            echo json_encode(array("success" => false, "message" => "Error updating password. Please try again."));
        }
    } else {
        echo json_encode(array("success" => false, "message" => "Email not found."));
    }

    $stmt->close();
    $update_stmt->close();
    $conn->close();
} else {
    echo json_encode(array("success" => false, "message" => "Invalid request method."));
}
?>
