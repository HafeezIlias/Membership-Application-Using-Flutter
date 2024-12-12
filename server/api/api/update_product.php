<?php

// Include database connection
include_once("dbconnect.php");

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

$productid = $_POST['Productid'];
$title = $_POST['title'];
$description = addslashes($_POST['description']);
$producttype = $_POST['producttype'];
$price = $_POST['price'];
$image = $_POST['image'];
$stock = $_POST['stock'];
$filename = isset($_POST['filename']) ? $_POST['filename'] : ""; // Use the existing filename if provided

// Check if image is provided or "NA" (if no image)
if ($image != "NA") {
    // Generate a unique filename for the new image
    $filename = "product-" . randomfilename(10) . ".jpg";
    // Decode the base64 encoded image
    $decoded_image = base64_decode($image);
    // Set the file path to save the image
    $path = "../assets/products/" . $filename;

    // Check if the image was successfully saved
    if (!file_put_contents($path, $decoded_image)) {
        $response = array('status' => 'failed', 'data' => 'Failed to save image');
        sendJsonResponse($response);
        die;
    }
}

// Prepare SQL query using prepared statements to avoid SQL injection
$sqlupdateproduct = "UPDATE `tbl_products` SET 
    `product_title` = ?, 
    `product_description` = ?, 
    `product_type` = ?, 
    `product_price` = ?,
    `product_stock` = ?";

// Add the image filename conditionally
if ($image != "NA") {
    $sqlupdateproduct .= ", `product_filename` = ?";
}

$sqlupdateproduct .= " WHERE `product_id` = ?";

// Prepare the statement
$stmt = $conn->prepare($sqlupdateproduct);

// Bind parameters to the statement based on whether the image is provided
if ($image != "NA") {
    $stmt->bind_param("sssdsis", $title, $description, $producttype, $price, $stock, $filename, $productid);
} else {
    $stmt->bind_param("sssdis", $title, $description, $producttype, $price, $stock, $productid);
}

// Execute the statement
if ($stmt->execute()) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => 'Database update failed');
    sendJsonResponse($response);
}

// Function to send JSON response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

// Function to generate a random filename
function randomfilename($length)
{
    $key = '';
    $keys = array_merge(range(0, 9), range('a', 'z'));

    for ($i = 0; $i < $length; $i++) {
        $key .= $keys[array_rand($keys)];
    }
    return $key;
}
?>