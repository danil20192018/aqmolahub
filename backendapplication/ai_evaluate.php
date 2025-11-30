<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require 'config.php';
$apiKey=$groq_key ;

$data = json_decode(file_get_contents('php://input'), true);
$idea = $data['idea'] ?? '';

if (empty($idea)) {
    echo json_encode(['error' => 'Idea is required']);
    exit;
}

$prompt = "Ты эксперт по стартапам и бизнесу. Оцени следующую стартап-идею и дай структурированный ответ на русском языке.

Идея: $idea

Дай оценку в следующем формате:
1. Сильные стороны (2-3 пункта)
2. Риски и слабые места (2-3 пункта)
3. Советы по улучшению (2-3 пункта)

Будь конкретным и практичным.";

$requestData = [
    'model' => 'llama-3.1-8b-instant',
    'messages' => [
        [
            'role' => 'user',
            'content' => $prompt
        ]
    ],
    'temperature' => 0.7,
    'max_tokens' => 1000
];

$ch = curl_init('https://api.groq.com/openai/v1/chat/completions');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($requestData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $apiKey,
    'Content-Type: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode !== 200) {
    echo json_encode(['error' => 'AI service error', 'details' => $response]);
    exit;
}

$result = json_decode($response, true);
$evaluation = $result['choices'][0]['message']['content'] ?? 'Не удалось получить оценку';

echo json_encode([
    'success' => true,
    'evaluation' => $evaluation
]);
?>
