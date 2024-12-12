<?php

// Check if the required parameters are present in the POST request
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'message' => 'Missing user ID');
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");
$user_id = $_POST['user_id'];

// Get page number and limit from query parameters
$pageno = isset($_GET['pageno']) ? intval($_GET['pageno']) : 1;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;

// Ensure valid values for pageno and limit
if ($pageno < 1) $pageno = 1;
if ($limit < 1) $limit = 10;

// Calculate offset
$offset = ($pageno - 1) * $limit;

// SQL query to count total cart items for the user
$sqlCount = "SELECT COUNT(*) AS total FROM tbl_cart WHERE user_id = ?";
$stmtCount = $conn->prepare($sqlCount);
$stmtCount->bind_param("i", $user_id);
$stmtCount->execute();
$resultCount = $stmtCount->get_result();
$totalCartItems = 0;

if ($resultCount && $resultCount->num_rows > 0) {
    $totalCartItems = intval($resultCount->fetch_assoc()['total']);
}

$numofpage = ceil($totalCartItems / $limit); // Calculate the number of pages

// SQL query to fetch cart items and product details with pagination
$sql = "SELECT c.cart_id, c.product_id, c.quantity, p.product_title, p.product_price, p.product_filename 
        FROM tbl_cart c 
        INNER JOIN tbl_products p ON c.product_id = p.product_id 
        WHERE c.user_id = ? 
        LIMIT $limit OFFSET $offset";

// Prepare and execute the query
$stmt = $conn->prepare($sql);
if (!$stmt) {
    // Check if the query was prepared successfully
    $response['status'] = 'failed';
    $response['message'] = 'SQL preparation failed: ' . $conn->error;
    sendJsonResponse($response);
    die();
}

$stmt->bind_param("i", $user_id);
$stmt->execute();

// Check for errors in execution
if ($stmt->error) {
    $response['status'] = 'failed';
    $response['message'] = 'SQL execution failed: ' . $stmt->error;
    sendJsonResponse($response);
    die();
}

$result = $stmt->get_result();

// Check if there are any cart items for the user
$cartItems = array();
while ($row = $result->fetch_assoc()) {
    $cartItems[] = $row;
}

// Prepare the response with pagination details
if (empty($cartItems)) {
    $response['status'] = 'success';
    $response['message'] = 'No items found in the cart';
    $response['cart_items'] = [];
    $response['cart_item_count'] = 0;
    $response['numofpage'] = $numofpage;
    $response['numberofresult'] = $totalCartItems;
} else {
    // Return the cart items and pagination info
    $response['status'] = 'success';
    $response['cart_items'] = $cartItems;
    $response['cart_item_count'] = count($cartItems);
    $response['numofpage'] = $numofpage;
    $response['numberofresult'] = $totalCartItems;
}

sendJsonResponse($response);

function sendJsonResponse($response) {
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>
