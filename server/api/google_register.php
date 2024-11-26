<?php
require 'vendor/autoload.php';
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

function verifyGoogleToken($idToken) {
    $client = new Google_Client(['client_id' => 'YOUR_CLIENT_ID.apps.googleusercontent.com']);
    $payload = $client->verifyIdToken($idToken);

    return $payload ? $payload : false;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $idToken = $_POST['id_token'];
    $userData = verifyGoogleToken($idToken);

    if ($userData) {
        $email = $userData['email'];
        $name = $userData['name'];
        $googleId = $userData['sub']; // Google User ID

        // Database connection
        $conn = new mysqli('localhost', 'your_username', 'your_password', 'your_database');

        if ($conn->connect_error) {
            die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
        }

        // Check if the user already exists
        $stmt = $conn->prepare('SELECT * FROM users WHERE email = ?');
        $stmt->bind_param('s', $email);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            echo json_encode(['status' => 'error', 'message' => 'User already registered']);
        } else {
            // Insert new user
            $stmt = $conn->prepare('INSERT INTO users (google_id, name, email) VALUES (?, ?, ?)');
            $stmt->bind_param('sss', $googleId, $name, $email);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Registration successful']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to register user']);
            }
        }

        $stmt->close();
        $conn->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid Google token']);
    }
}
?>
