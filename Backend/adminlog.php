<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'config.php';

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $user_input = $_POST['username/mail_id'] ?? '';
    $password = $_POST['password'] ?? '';

    if (empty($user_input) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Username/Email and password are required"]);
        exit;
    }

    // Fetch user where username or mail_id matches
    $stmt = $conn->prepare("SELECT password FROM adminUser WHERE username = ? OR mail_id = ?");
    $stmt->bind_param("ss", $user_input, $user_input);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows === 0) {
        echo json_encode(["status" => "error", "message" => "Invalid username/email or password"]);
        $stmt->close();
        $conn->close();
        exit;
    }

    $stmt->bind_result($stored_password);
    $stmt->fetch();

    // Plain text password check
    if ($password === $stored_password) {
        echo json_encode(["status" => "success", "message" => "Admin login successful"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid username/email or password"]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Only POST requests are allowed"]);
}
?>
