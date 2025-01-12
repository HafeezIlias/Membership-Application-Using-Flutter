<?php
include_once("dbconnect.php");
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Fetch and validate user_id
$user_id = isset($_POST['user_id']) ? $_POST['user_id'] : null;

if (!$user_id) {
    echo json_encode(["status" => "error", "message" => "Missing user_id"]);
    exit();
}

// Query to get the current membership status for the user
$sql = "SELECT 
            u.user_membership_id, 
            u.membership_id, 
            u.start_date, 
            u.end_date, 
            u.status, 
            m.name AS membership_name 
        FROM 
            tbl_user_membership_status u 
        JOIN 
            tbl_memberships m 
        ON 
            u.membership_id = m.membership_id 
        WHERE 
            u.user_id = '$user_id' 
        AND 
            u.status = 'Active' 
        ORDER BY 
            u.end_date DESC 
        LIMIT 1";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $membership = $result->fetch_assoc();
    echo json_encode(["status" => "success", "data" => $membership]);
} else {
    echo json_encode(["status" => "error", "message" => "No active membership found."]);
}

$conn->close();
?>
