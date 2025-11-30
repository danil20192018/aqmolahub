<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'config.php';
$apiKey=$groq_key ;

$d = json_decode(file_get_contents('php://input'), true);
$history = $d['history'] ?? [];

if (empty($history)) {
    echo json_encode(['err' => 'история пустая']);
    exit;
}

$messages = [
    [
        'role' => 'system',
        'content' => "Ты симулятор Совета Директоров. Твоя задача - разыграть диалог между тремя персонажами, которые обсуждают идею стартапа пользователя.

Персонажи:
1. Илон (Elon): Визионер, любит масштаб, ракеты, Марс. Ищет инновации. Говорит кратко.
2. Стив (Steve): Перфекционист, одержим дизайном и простотой. Ругает за сложность.
3. Скептик (Skeptic): Финансовый директор. Считает деньги, видит риски, задает неудобные вопросы.

Твоя задача:
1. Проанализировать последнее сообщение пользователя.
2. Сгенерировать диалог между персонажами (2-4 реплики), где они обсуждают это, спорят, выделяют плюсы и минусы.
3. В конце ОБЯЗАТЕЛЬНО один из персонажей должен задать конкретный вопрос пользователю, чтобы продолжить обсуждение.

Формат ответа СТРОГО JSON массив объектов:
[
  {\"speaker\": \"Elon\", \"text\": \"...\"},
  {\"speaker\": \"Skeptic\", \"text\": \"...\"},
  {\"speaker\": \"Steve\", \"text\": \"... (вопрос пользователю)\"}
]

Язык: Русский. Не пиши ничего кроме JSON."
    ]
];

foreach ($history as $msg) {
    $role = $msg['isUser'] ? 'user' : 'assistant';
    $content = $msg['text'];
    if (!$msg['isUser'] && isset($msg['speaker'])) {
        $content = $msg['speaker'] . ": " . $msg['text'];
    }
    $messages[] = ['role' => $role, 'content' => $content];
}

$req = [
    'model' => 'llama-3.1-8b-instant',
    'messages' => $messages,
    'temperature' => 0.8,
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
$content = $result['choices'][0]['message']['content'] ?? '[]';

if (preg_match('/\[.*\]/s', $content, $matches)) {
    $jsonStr = $matches[0];
} else {
    $jsonStr = '[]';
}

$dialog = json_decode($jsonStr, true);

if (!$dialog) {
    $dialog = [
        ['speaker' => 'System', 'text' => 'AI сломался, попробуй еще раз.']
    ];
}

echo json_encode([
    'res' => true,
    'dialog' => $dialog
]);
?>
