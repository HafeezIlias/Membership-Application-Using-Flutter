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

// Count total memberships
$sqlCount = "SELECT COUNT(*) AS total FROM tbl_memberships";
$resultCount = $conn->query($sqlCount);

$totalMemberships = 0;
$numofpage = 0;

if ($resultCount && $resultCount->num_rows > 0) {
    $totalMemberships = intval($resultCount->fetch_assoc()['total']);
    $numofpage = ceil($totalMemberships / $limit); // Calculate the number of pages
}

// Load memberships with limit and offset
$sqlloadmembership = "SELECT * FROM `tbl_memberships` ORDER BY `membership_id` ASC LIMIT $limit OFFSET $offset";
$result = $conn->query($sqlloadmembership);

// Check for results and prepare response
if ($result && $result->num_rows > 0) {
    $membershipArray = [];
    while ($row = $result->fetch_assoc()) {
        $membership = [
            'membership_id' => $row['membership_id'],
            'name' => $row['name'],
            'description' => $row['description'],
            'price' => $row['price'],
            'duration' => $row['duration'],
            'benefits' => $row['benefits'],
            'terms' => $row['terms'],
            'membership_filename' => $row['membership_filename'], // Fixed field name
            'membership_sold' => $row['membership_sold'],
            'membership_rating' => $row['membership_rating'],
        ];
        array_push($membershipArray, $membership);
    }

    $response = [
        'status' => 'success',
        'numofpage' => $numofpage,
        'numberofresult' => $totalMemberships,
        'data' => $membershipArray,
    ];
} else {
    // No results
    $response = [
        'status' => 'failed',
        'numofpage' => $numofpage,
        'numberofresult' => $totalMemberships,
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
