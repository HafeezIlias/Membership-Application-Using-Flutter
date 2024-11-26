<?php
include_once("dbconnect.php");

if (isset($_POST['news_id']) && isset($_POST['likes']) && isset($_POST['dislikes'])) {
    $news_id = $_POST['news_id'];
    $likes = intval($_POST['likes']);
    $dislikes = intval($_POST['dislikes']);

    $sql = "UPDATE tbl_news SET likes = ?, dislikes = ? WHERE news_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("iis", $likes, $dislikes, $news_id); //bind param is used to protect from sql injection
    //i is for integer  // s for string

    if ($stmt->execute()) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "fail", "error" => $stmt->error]);
    }
    $stmt->close();
} else {
    echo json_encode(["status" => "fail", "error" => "Invalid parameters"]);
}
$conn->close();
?>
