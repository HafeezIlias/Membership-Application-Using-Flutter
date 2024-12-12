<?php

// Check if the required parameters are present in the POST request
if (!isset($_POST['user_id']) || !isset($_POST['product_id'])) {
    $response = array('status' => 'failed', 'message' => 'Missing user ID or product ID');
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");
$user_id = $_POST['user_id'];
$product_id = $_POST['product_id'];

// SQL query to remove the item from the cart
$sql = "DELETE FROM tbl_cart WHERE user_id = ? AND product_id = ?";

// Prepare and execute the query
$stmt = $conn->prepare($sql);
if (!$stmt) {
    // Check if the query was prepared successfully
    $response = array('status' => 'failed', 'message' => 'SQL preparation failed: ' . $conn->error);
    sendJsonResponse($response);
    die();
}

$stmt->bind_param("ii", $user_id, $product_id);
$stmt->execute();

// Check if any rows were affected (i.e., item was removed)
if ($stmt->affected_rows > 0) {
    // Return success if item was removed
    $response = array('status' => 'success', 'message' => 'Item removed from cart');
} else {
    // Return failure if no rows were affected
    $response = array('status' => 'failed', 'message' => 'Item not found in cart');
}

sendJsonResponse($response);

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>
