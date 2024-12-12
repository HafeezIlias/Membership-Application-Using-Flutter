<?php
if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$newsid = $_POST['newsid'];
$title = addslashes($_POST['title']);
$details =addslashes( $_POST['details']);

$sqlupdatenews="UPDATE `tbl_news` SET `news_title`='$title',`news_details`='$details' WHERE `news_id` = '$newsid'";

if ($conn->query($sqlupdatenews) === TRUE) {
	$response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
}else{
	$response = array('status' => 'failed', 'data' => null);
	sendJsonResponse($response);
}
	
	

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>