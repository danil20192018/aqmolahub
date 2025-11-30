<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

require 'config.php';
$apiKey=$groq_key ;

$d = json_decode(file_get_contents('php://input'), true);
$msgs = $d['messages'] ?? [];

if (empty($msgs)) {
    echo json_encode(['err' => 'нет сообщений']);
    exit;
}

$sysPrompt = [
    'role' => 'system',
    'content' => "Ты - опытный ментор стартапов и бизнес-консультант в Aqmola Hub. 
    Твоя цель - помогать стартаперам развивать их идеи, находить бизнес-модели и решать проблемы.
    
    Твой стиль:
    - Профессиональный, но дружелюбный
    - Практичный (давай конкретные советы, а не общие фразы)
    - Краткий (не пиши огромные тексты, если не просят)
    - Используй форматирование (списки, жирный текст) для удобства чтения
    
    Если тебя просят создать Business Model Canvas, Roadmap или анализ конкурентов - делай это структурировано."
];

array_unshift($msgs, $sysPrompt);

$req = [
    'model' => 'llama-3.1-8b-instant',
    'messages' => $msgs,
    'temperature' => 0.7,
    'max_tokens' => 1500
];

$ch = curl_init('https://api.groq.com/openai/v1/chat/completions');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($req));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $apiKey,
    'Content-Type: application/json'
]);

$res = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($code !== 200) {
    echo json_encode(['err' => 'AI ошибка']);
    exit;
}

$result = json_decode($res, true);
$reply = $result['choices'][0]['message']['content'] ?? 'не удалось';

echo json_encode([
    'res' => true,
    'reply' => $reply
]);
?>
