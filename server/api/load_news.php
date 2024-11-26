<?php

include_once("dbconnect.php");

// Get pagination parameters
$pageno = isset($_GET['pageno']) ? intval($_GET['pageno']) : 1;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 10;
$offset = ($pageno - 1) * $limit;

// Count total number of news
$sqlCount = "SELECT COUNT(*) AS total FROM tbl_news";
$resultCount = $conn->query($sqlCount);

if ($resultCount && $resultCount->num_rows > 0) {
    $totalNews = $resultCount->fetch_assoc()['total'];
    $numofpage = ceil($totalNews / $limit);
} else {
    $response = array('status' => 'fail', 'message' => 'Failed to count total news.');
    sendJsonResponse($response);
    die();
}

// Fetch paginated news
$sqlloadnews = "SELECT * FROM tbl_news ORDER BY news_date DESC LIMIT $limit OFFSET $offset";
$result = $conn->query($sqlloadnews);

if ($result && $result->num_rows > 0) {
    $newsarray = array();
    while ($row = $result->fetch_assoc()) {
        $news = array(
            'news_id' => $row['news_id'],
            'news_title' => $row['news_title'],
            'news_details' => $row['news_details'],
            'news_date' => $row['news_date'],
            'likes' => intval($row['likes']),
            'dislikes' => intval($row['dislikes']),
        );
        array_push($newsarray, $news);
    }

    $response = array(
        'status' => 'success',
        'numofpage' => $numofpage,
        'numberofresult' => $totalNews,
        'data' => array('news' => $newsarray),
    );
    sendJsonResponse($response);
} else {
    $response = array('status' => 'fail', 'message' => 'No news found.');
    sendJsonResponse($response);
}

// Function to send JSON response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
