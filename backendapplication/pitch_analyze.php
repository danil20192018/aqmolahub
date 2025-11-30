<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'config.php';
$apiKey=$groq_key ;

$d = json_decode(file_get_contents('php://input'), true);
$txt = $d['text'] ?? '';

if (empty($txt)) {
    echo json_encode(['err' => 'текст пустой']);
    exit;
}

$prompt = "Ты эксперт по питчингу стартапов. Проанализируй этот питч и дай оценку на русском языке.

Питч: $txt

Оцени по критериям:
1. Проблема - четко ли описана проблема? (да/нет + комментарий)
2. Решение - понятно ли решение? (да/нет + комментарий)
3. Целевая аудитория - упомянута ли ЦА? (да/нет + комментарий)
4. Бизнес-модель - как планируется зарабатывать? (да/нет + комментарий)
5. Уникальность - чем отличается от конкурентов? (да/нет + комментарий)

Дай итоговую оценку от 1 до 10 и 2-3 совета как улучшить питч.
Будь строгим но конструктивным.";

$req = [
    'model' => 'llama-3.1-8b-instant',
    'messages' => [
        ['role' => 'user', 'content' => $prompt]
    ],
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
$eval = $result['choices'][0]['message']['content'] ?? 'не удалось';

echo json_encode([
    'res' => true,
    'eval' => $eval
]);
?>
