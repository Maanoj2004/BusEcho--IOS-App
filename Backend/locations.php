<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$query = '[out:json][timeout:60];
area["name"="Tamil Nadu"]->.a;
(
  node["place"~"city|town|village|hamlet|suburb|neighbourhood"](area.a);
);
out body;';

$url = "https://overpass-api.de/api/interpreter?data=" . urlencode($query);

$response = file_get_contents($url);

if ($response === FALSE) {
    http_response_code(500);
    echo json_encode(["error" => "Failed to fetch from Overpass API"]);
    exit();
}

$data = json_decode($response, true);

// Extract places
$places = [];
foreach ($data['elements'] as $element) {
    if (isset($element['tags']['name']) && isset($element['tags']['place'])) {
        $places[] = [
            "name" => $element['tags']['name'],
            "type" => $element['tags']['place'],
            "lat" => $element['lat'],
            "lon" => $element['lon']
        ];
    }
}

// Sort alphabetically by name
usort($places, fn($a, $b) => strcmp($a['name'], $b['name']));

echo json_encode($places);
?>
