<?php
function checkProfanityWithAI($text) {
    $apiKey = "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"; // ⚠️ Replace with your token
    $model = "unitary/toxic-bert"; // Toxicity model

    $url = "https://api-inference.huggingface.co/models/" . $model;

    $headers = [
        "Authorization: Bearer " . $apiKey,
        "Content-Type: application/json"
    ];

    $data = ["inputs" => $text];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

    $response = curl_exec($ch);

    if (curl_errno($ch)) {
        error_log("HuggingFace API error: " . curl_error($ch));
        curl_close($ch);
        return null;
    }

    curl_close($ch);

    $json = json_decode($response, true);

    // If response is invalid
    if (!is_array($json)) {
        return null;
    }

    // Extract toxicity score (higher = more toxic)
    // This model returns multiple labels, we just check "toxic"
    foreach ($json[0] as $labelData) {
        if ($labelData["label"] === "toxic" && $labelData["score"] > 0.7) {
            return true; // 🚨 Block toxic review
        }
    }

    return false; // ✅ Safe review
}

function containsBadWords($text) {
    $badWords = ["fuck", "shit", "bitch", "asshole", "chutiya", "mc", "bc"]; // expand this list
    foreach ($badWords as $word) {
        if (stripos($text, $word) !== false) {
            return true;
        }
    }
    return false;
}

