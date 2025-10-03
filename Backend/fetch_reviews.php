<?php
header("Content-Type: application/json");
require 'config.php';

function timeAgo($datetime) {
    date_default_timezone_set("Asia/Kolkata");
    $now = new DateTime();
    $created = new DateTime($datetime);
    $diff = $now->diff($created);

    if ($diff->y > 0) return $created->format("F j, Y");
    elseif ($diff->m > 0) return $diff->m . " months ago";
    elseif ($diff->d > 2) return $diff->d . " days ago";
    elseif ($diff->h > 0) return $diff->h . " hours ago";
    elseif ($diff->i > 0) return $diff->i . " minutes ago";
    else return "Just now";
}

// The logged-in viewer (needed to compute "user_liked")
$viewer_id = isset($_GET['viewer_id']) ? intval($_GET['viewer_id']) : 0;

// Optional: filter reviews by author
$filter_user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

$whereClause = "r.status = 'Approved'";
if ($filter_user_id > 0) {
    $whereClause .= " AND r.user_id = $filter_user_id";
}

$sql = "
    SELECT 
        r.id AS review_id,
        r.user_id AS review_user_id,
        u2.username AS author_username,
        r.bus_operator,
        r.bus_number,  -- ✅ pulled from buses table
        r.review_text,
        r.overall_rating,
        r.punctuality_rating,
        r.cleanliness_rating,
        r.comfort_rating,
        r.staff_behaviour_rating,
        r.date_of_travel,
        r.boarding_point,
        r.dropping_point,
        r.created_at,

        i.image_path,

        (SELECT COUNT(*) FROM review_likes rl WHERE rl.review_id = r.id) AS like_count,

        EXISTS (
            SELECT 1 FROM review_likes rl2 
            WHERE rl2.review_id = r.id AND rl2.user_id = $viewer_id
        ) AS user_liked,

        (SELECT COUNT(*) FROM review_comments rc WHERE rc.review_id = r.id) AS comment_count,

        c.id AS comment_id,
        c.user_id AS comment_user_id,
        u.username AS comment_username,
        c.comment_text,
        c.created_at AS comment_created_at

    FROM bus_reviews r
    LEFT JOIN buses b ON r.bus_id = b.bus_id   -- ✅ join to get bus_number
    LEFT JOIN review_images i ON r.id = i.review_id
    LEFT JOIN review_comments c ON r.id = c.review_id
    LEFT JOIN users u ON c.user_id = u.id
    LEFT JOIN users u2 ON r.user_id = u2.id
    WHERE $whereClause
    ORDER BY r.created_at DESC
";


$result = mysqli_query($conn, $sql);

$reviews = [];
$commentTracker = [];

while ($row = mysqli_fetch_assoc($result)) {
    $id = $row['review_id'];

    if (!isset($reviews[$id])) {
        $reviews[$id] = [
            "review_id" => (int)$id,
            "review_user_id" => (int)$row['review_user_id'], // author
            "username" => $row['username'], // you might want author’s name instead
            "bus_operator" => $row['bus_operator'],
            "bus_number" => $row['bus_number'],
            "review_text" => $row['review_text'],
            "overall_rating" => (int)$row['overall_rating'],
            "punctuality_rating" => (int)$row['punctuality_rating'],
            "cleanliness_rating" => (int)$row['cleanliness_rating'],
            "comfort_rating" => (int)$row['comfort_rating'],
            "staff_behaviour_rating" => (int)$row['staff_behaviour_rating'],
            "date_of_travel" => $row['date_of_travel'],
            "boarding_point" => $row['boarding_point'],
            "dropping_point" => $row['dropping_point'],
            "created_at_formatted" => timeAgo($row['created_at']),
            "like_count" => (int)$row['like_count'],
            "user_liked" => (bool)$row['user_liked'],
            "comment_count" => (int)$row['comment_count'],
            "images" => [],
            "comments" => []
        ];
        $commentTracker[$id] = [];
    }

    if (!empty($row['image_path']) && !in_array($row['image_path'], $reviews[$id]['images'])) {
        $reviews[$id]['images'][] = $row['image_path'];
    }

    if (!empty($row['comment_text']) && $row['comment_id'] !== null) {
        if (!in_array($row['comment_id'], $commentTracker[$id])) {
            $reviews[$id]['comments'][] = [
                "comment_id" => (int)$row['comment_id'],
                "user_id" => (int)$row['comment_user_id'],
                "comment_text" => $row['comment_text'],
                "commented_at" => timeAgo($row['comment_created_at'])
            ];
            $commentTracker[$id][] = $row['comment_id'];
        }
    }
}

echo json_encode(array_values($reviews));
?>
