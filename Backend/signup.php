<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'config.php';

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $name       = $_POST['name'] ?? '';
    $username   = $_POST['username'] ?? '';
    $mail_id    = $_POST['mail_id'] ?? '';
    $password   = $_POST['password'] ?? '';
    $phone_num  = $_POST['phone_num'] ?? '';
    $bio        = $_POST['bio'] ?? null;  // ✅ Optional bio field

    // Basic validation
    if (empty($name) || empty($username) || empty($mail_id) || empty($password) || empty($phone_num)) {
        echo json_encode(["status" => "error", "message" => "All fields are required"]);
        exit;
    }

    if (!filter_var($mail_id, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(["status" => "error", "message" => "Invalid email format"]);
        exit;
    }

    if (
        strlen($password) < 8 ||
        !preg_match("/[A-Z]/", $password) ||
        !preg_match("/[a-z]/", $password) ||
        !preg_match("/[0-9]/", $password) ||
        !preg_match("/[\W]/", $password)
    ) {
        echo json_encode([
            "status" => "error",
            "message" => "Password must be at least 8 characters long and include uppercase, lowercase, number, and special character"
        ]);
        exit;
    }

    // Check if username exists
    $checkUsername = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $checkUsername->bind_param("s", $username);
    $checkUsername->execute();
    $checkUsername->store_result();
    if ($checkUsername->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "Username already exists"]);
        $checkUsername->close();
        $conn->close();
        exit;
    }
    $checkUsername->close();

    // Check if email exists
    $checkEmail = $conn->prepare("SELECT id FROM users WHERE mail_id = ?");
    $checkEmail->bind_param("s", $mail_id);
    $checkEmail->execute();
    $checkEmail->store_result();
    if ($checkEmail->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "Email already exists"]);
        $checkEmail->close();
        $conn->close();
        exit;
    }
    $checkEmail->close();

    // Check if phone number exists
    $checkPhone = $conn->prepare("SELECT id FROM users WHERE phone_num = ?");
    $checkPhone->bind_param("s", $phone_num);
    $checkPhone->execute();
    $checkPhone->store_result();
    if ($checkPhone->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "Phone number already exists"]);
        $checkPhone->close();
        $conn->close();
        exit;
    }
    $checkPhone->close();

    // Optional bio length check (optional)
    if (!empty($bio) && strlen($bio) > 200) {
        echo json_encode(["status" => "error", "message" => "Bio must be under 200 characters"]);
        exit;
    }

    // Hash the password
    $password_hashed = password_hash($password, PASSWORD_DEFAULT);

    // Insert user into the database
    $stmt = $conn->prepare("INSERT INTO users (name, username, mail_id, password, phone_num, bio) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssss", $name, $username, $mail_id, $password_hashed, $phone_num, $bio);

    if ($stmt->execute()) {
        echo json_encode([
            "status" => "success",
            "message" => "User registered successfully",
            "name" => $name
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Error occurred during registration"
        ]);
    }

    $stmt->close();
    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Only POST requests are allowed"]);
}
?>
