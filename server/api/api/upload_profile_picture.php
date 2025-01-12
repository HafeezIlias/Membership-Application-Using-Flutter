<?php
if (!isset($_POST['user_id']) || !isset($_POST['image']) || !isset($_POST['filename'])) {
    $response = array('status' => 'failed', 'message' => 'Missing required parameters.');
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$user_id = $_POST['user_id'];
$image = $_POST['image'];
$filename = "profile-" . $user_id . "-" . randomfilename(10) . ".jpg";
$decoded_image = base64_decode($image);
$path = "../assets/profileImage/" . $filename;

// Save the image
if (file_put_contents($path, $decoded_image)) {
    // Update user's profile picture in the database
    $sql = "UPDATE tbl_user SET user_profile_image = '$filename' WHERE user_id = '$user_id'";
    if ($conn->query($sql) === TRUE) {
        $response = array('status' => 'success', 'image_path' => $filename);
    } else {
        $response = array('status' => 'failed', 'message' => 'Failed to update database.');
    }
} else {
    $response = array('status' => 'failed', 'message' => 'Failed to save the image.');
}

sendJsonResponse($response);

function randomfilename($length)
{
    $key = '';
    $keys = array_merge(range(0, 9), range('a', 'z'));

    for ($i = 0; $i < $length; $i++) {
        $key .= $keys[array_rand($keys)];
    }
    return $key;
}

function sendJsonResponse($response)
{
    header('Content-Type: application/json');
    echo json_encode($response);
}
?>
