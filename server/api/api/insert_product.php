<?php
if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$title = addslashes($_POST['title']);
$description = addslashes($_POST['description']);
// $location = addslashes($_POST['location']);
$productype = addslashes($_POST['producttype']);
// $startdate = ($_POST['start']);
// $enddate = ($_POST['end']);
$price = addslashes($_POST['price']);
$stock = addslashes($_POST['stock']);
$image = ($_POST['image']);
$decoded_image = base64_decode($image);

$filename = "product-".randomfilename(10).".jpg"; // where we are custom the filename

 $sqlinsertproduct="INSERT INTO `tbl_products`(`product_title`, `product_description`, `product_type`, `product_filename`, `product_price`, `product_stock`) VALUES ('$title','$description','$productype','$filename','$price','$stock')";

if ($conn->query($sqlinsertproduct) === TRUE) {
    $path = "../assets/products/". $filename;
    file_put_contents($path, $decoded_image);
	$response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
}else{
	$response = array('status' => 'failed', 'data' => null);
	sendJsonResponse($response);
}

function randomfilename($length) {
    $key = '';
    $keys = array_merge(range(0, 9), range('a', 'z'));

    for ($i = 0; $i < $length; $i++) {
        $key .= $keys[array_rand($keys)];
    }
    return $key;
}
	

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>