<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

// Retrieve identifier and password from the POST request
$identifier = $_POST['identifier']; // Can be email or username
$password = sha1($_POST['password']); // Hash the password

// SQL query to check for either email or username match
$sqllogin = "SELECT * FROM `tbl_user` 
             WHERE (`user_email` = '$identifier' OR `user_username` = '$identifier') 
             AND `user_pass` = '$password'";
$result = $conn->query($sqllogin);

// Send response based on the query result
if ($result->num_rows > 0) {
    $userlist = array();
    while ($row = $result->fetch_assoc()) {
        $userlist['userid'] = $row['user_id'];
        $userlist['useremail'] = $row['user_email'];
        $userlist['username'] = $row['user_username'];
        $userlist['userpassword'] = $row['user_pass'];
        $userlist['userphone'] = $row['user_phone'];
        $userlist['userdatereg'] = $row['user_date_register'];
        $userlist['useraddress'] = $row['user_address'];
        $userlist['userrole'] = $row['user_role'];
        $userlist['userprofileimage'] = $row['user_profile_image'];
        
        
    }
    $response = array('status' => 'success', 'data' => $userlist);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

$conn->close();
?>
