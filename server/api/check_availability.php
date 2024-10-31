<?php
include_once("dbconnect.php");

if (isset($_POST['email'])) {
    $email = $_POST['email'];
    $query = "SELECT * FROM tbl_user WHERE user_email = '$email'";
    $result = mysqli_query($conn, $query);

    if (mysqli_num_rows($result) > 0) {
        echo json_encode(["status" => "exists"]);
    } else {
        echo json_encode(["status" => "available"]);
    }
}

if (isset($_POST['username'])) {
    $username = $_POST['username'];
    $query = "SELECT * FROM tbl_user WHERE user_username = '$username'";
    $result = mysqli_query($conn, $query);

    if (mysqli_num_rows($result) > 0) {
        echo json_encode(["status" => "exists"]);
    } else {
        echo json_encode(["status" => "available"]);
    }
}
?>
