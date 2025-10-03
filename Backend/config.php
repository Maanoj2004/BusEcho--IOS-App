<?php
$host = "localhost"; // or your server host
$dbname = "busreview"; // replace with your DB name
$dbuser = "root";       // e.g., root
$dbpass = "";   // e.g., "" for empty

// Create connection
$conn = new mysqli($host, $dbuser, $dbpass, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
