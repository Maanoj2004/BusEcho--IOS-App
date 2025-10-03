<?php
include "config.php"; // your DB connection
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$user_id = $_GET['user_id']; // the profile owner who should receive notifications

// Likes (exclude if liker is the same as owner)
$queryLikes = "
    SELECT l.created_at, 'like' AS type, u.username, r.id AS review_id, u.id AS actor_id
    FROM review_likes l
    JOIN bus_reviews r ON l.review_id = r.id
    JOIN users u ON l.user_id = u.id
    WHERE r.user_id = ? AND u.id != ?
";

// Comments (exclude if commenter is the same as owner)
$queryComments = "
    SELECT c.created_at, 'comment' AS type, u.username, r.id AS review_id, u.id AS actor_id
    FROM review_comments c
    JOIN bus_reviews r ON c.review_id = r.id
    JOIN users u ON c.user_id = u.id
    WHERE r.user_id = ? AND u.id != ?
";

// Combine with UNION
$sql = "($queryLikes) UNION ALL ($queryComments) ORDER BY created_at DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("iiii", $user_id, $user_id, $user_id, $user_id);
$stmt->execute();
$result = $stmt->get_result();

$notifications = [];
while ($row = $result->fetch_assoc()) {
    if ($row['type'] === 'like') {
        $row['message'] = $row['username'] . " liked your review";
    } else {
        $row['message'] = $row['username'] . " commented on your review";
    }
    $notifications[] = $row;
}

echo json_encode($notifications);
?>
