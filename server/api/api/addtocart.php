<?php


if (!isset($_POST)) {
    $response = array('status' => 'failed', 'message' => 'Missing parameters');
    sendJsonResponse($response);
    die();
}
include_once("dbconnect.php");

$user_id = $_POST['user_id'];
$product_id = $_POST['product_id'];
$quantity = $_POST['quantity'];

// Check if product exists in the cart
$sqlCheck = "SELECT * FROM tbl_cart WHERE user_id = ? AND product_id = ?";
$stmtCheck = $conn->prepare($sqlCheck);
$stmtCheck->bind_param("ii", $user_id, $product_id);
$stmtCheck->execute();
$result = $stmtCheck->get_result();

if ($result->num_rows > 0) {
    // Update quantity if product exists
    $sqlUpdate = "UPDATE tbl_cart SET quantity = quantity + ? WHERE user_id = ? AND product_id = ?";
    $stmtUpdate = $conn->prepare($sqlUpdate);
    $stmtUpdate->bind_param("iii", $quantity, $user_id, $product_id);
    $stmtUpdate->execute();
} else {
    // Insert new product into the cart
    $sqlInsert = "INSERT INTO tbl_cart (user_id, product_id, quantity) VALUES (?, ?, ?)";
    $stmtInsert = $conn->prepare($sqlInsert);
    $stmtInsert->bind_param("iii", $user_id, $product_id, $quantity);
    $stmtInsert->execute();
}

$response = array('status' => 'success', 'message' => 'Cart updated successfully');
sendJsonResponse($response);

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>
