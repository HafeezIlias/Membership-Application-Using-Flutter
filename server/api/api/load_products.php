<?php

include_once("dbconnect.php");

// Get page number and limit from query parameters
$pageno = isset($_GET['pageno']) ? intval($_GET['pageno']) : 1;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;

// Ensure valid values for pageno and limit
if ($pageno < 1) $pageno = 1;
if ($limit < 1) $limit = 10;

// Calculate offset
$offset = ($pageno - 1) * $limit;

// Count total products
$sqlCount = "SELECT COUNT(*) AS total FROM tbl_products";
$resultCount = $conn->query($sqlCount);

$totalProducts = 0;
$numofpage = 0;

if ($resultCount && $resultCount->num_rows > 0) {
    $totalProducts = intval($resultCount->fetch_assoc()['total']);
    $numofpage = ceil($totalProducts / $limit); // Calculate the number of pages
}

// Load products with limit and offset
$sqlloadproduct = "SELECT * FROM `tbl_products` ORDER BY `product_date` DESC LIMIT $limit OFFSET $offset";
$result = $conn->query($sqlloadproduct);

// Check for results and prepare response
if ($result && $result->num_rows > 0) {
    $productArray = [];
    while ($row = $result->fetch_assoc()) {
        $product = [
            'product_id' => $row['product_id'],
            'product_title' => $row['product_title'],
            'product_description' => $row['product_description'],
            'product_type' => $row['product_type'],
            'product_filename' => $row['product_filename'],
            'product_date' => $row['product_date'],
            'product_price' => $row['product_price'],
            'product_stock' => $row['product_stock'],
            'product_rating' => $row['product_rating'],
            'product_sold' => $row['product_sold'],
        ];
        array_push($productArray, $product);
    }

    $response = [
        'status' => 'success',
        'numofpage' => $numofpage,
        'numberofresult' => $totalProducts,
        'data' => $productArray,
    ];
} else {
    // No results
    $response = [
        'status' => 'failed',
        'numofpage' => $numofpage,
        'numberofresult' => $totalProducts,
        'data' => null,
    ];
}

// Send JSON response
sendJsonResponse($response);

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
