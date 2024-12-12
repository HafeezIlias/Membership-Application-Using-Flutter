<?php
if (!isset($_POST['user_id']) || !isset($_POST['product_id']) || !isset($_POST['quantity'])) {
    $response = array('status' => 'failed', 'message' => 'Missing required parameters');
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");
$user_id = $_POST['user_id'];
$product_id = $_POST['product_id'];
$quantity = $_POST['quantity'];

$sql = "UPDATE tbl_cart SET quantity = ? WHERE user_id = ? AND product_id = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    $response = array('status' => 'failed', 'message' => 'SQL preparation failed: ' . $conn->error);
    sendJsonResponse($response);
    die();
}

$stmt->bind_param("iii", $quantity, $user_id, $product_id);
$stmt->execute();

if ($stmt->affected_rows > 0) {
    $response = array('status' => 'success', 'message' => 'Quantity updated successfully');
} else {
    $response = array('status' => 'failed', 'message' => 'Failed to update quantity');
}

sendJsonResponse($response);

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>