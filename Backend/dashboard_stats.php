<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

require 'config.php'; // make sure this has your $conn connection

// Queries for each stat
$queries = [
    "users" => "SELECT COUNT(*) as count FROM users where is_deleted = 0",
    "buses" => "SELECT COUNT(*) as count FROM buses",
    "reviews" => "SELECT COUNT(*) as count FROM bus_reviews",
    "comments" => "SELECT COUNT(*) as count FROM review_comments",
    "likes" => "SELECT COUNT(*) as count FROM review_likes"
];

$response = [];

foreach ($queries as $key => $sql) {
    $result = mysqli_query($conn, $sql);
    if ($result) {
        $row = mysqli_fetch_assoc($result);
        $response[$key] = intval($row['count']);
    } else {
        $response[$key] = 0; // fallback in case of query error
    }
}

// Output JSON
echo json_encode($response);
?>

