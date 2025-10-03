<?php
session_start();
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
require 'config.php';

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $user_input = trim($_POST['username'] ?? '');
    $password   = trim($_POST['password'] ?? '');

    if (empty($user_input) || empty($password)) {
        echo json_encode(["status" => "error", "message" => "Missing fields"]);
        exit;
    }

    // 1️⃣ Check in admins table first
    $stmt = $conn->prepare("SELECT id, password, name FROM adminUser WHERE (username = ? OR mail_id = ?)");
    $stmt->bind_param("ss", $user_input, $user_input);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        $stmt->bind_result($admin_id, $password, $name);
        $stmt->fetch();
        if ($password!= $password) {
            echo json_encode(["status" => "error", "message" => "incorrect_password"]);
        } else {
            $_SESSION['admin_id'] = $admin_id;
            echo json_encode([
                "status" => "success",
                "message" => "Admin login successful",
                "role" => "admin",
                "user_id" => $admin_id,
                "name" => $name
            ]);
        }
        $stmt->close();
        $conn->close();
        exit;
    }
    $stmt->close();

    $stmt = $conn->prepare("SELECT id, password, name FROM users WHERE (username = ? OR mail_id = ?) AND is_deleted = 0");
    $stmt->bind_param("ss", $user_input, $user_input);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows === 0) {
        echo json_encode(["status" => "error", "message" => "user_not_found"]);
        $stmt->close();
        $conn->close();
        exit;
    }

    $stmt->bind_result($user_id, $hashed_password, $name);
    $stmt->fetch();

    if (!password_verify($password, $hashed_password)) {
        echo json_encode(["status" => "error", "message" => "incorrect_password"]);
    } else {
        $_SESSION['user_id'] = $user_id;
        echo json_encode([
            "status" => "success",
            "message" => "User login successful",
            "role" => "user",
            "user_id" => $user_id,
            "name" => $name
        ]);
    }
    $stmt->close();
    $conn->close();
    exit;
} else {
    echo json_encode(["status" => "error", "message" => "Only POST requests are allowed"]);
    exit;
}
?>
