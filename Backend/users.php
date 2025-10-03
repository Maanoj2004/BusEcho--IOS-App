<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'config.php';

// Fetch users from database
$sql = "SELECT id, name, username, mail_id, bio FROM users where is_deleted = 0 ORDER BY name ASC";
$result = mysqli_query($conn, $sql);

$users = [];
while ($row = mysqli_fetch_assoc($result)) {
    $users[] = [
    "id" => (int)$row['id'],
    "name" => $row['name'],
    "username" => $row['username'],
    "email" => $row['mail_id'],
    "bio" => $row['bio']
];
}

echo json_encode($users);
mysqli_close($conn);
?>
