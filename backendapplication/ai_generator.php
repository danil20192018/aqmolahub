<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'config.php';
$apiKey=$groq_key ;


$d = json_decode(file_get_contents('php://input'), true);
$industry = $d['industry'] ?? '';
$budget = $d['budget'] ?? '';
$team = $d['team'] ?? '';
$region = $d['region'] ?? '';
$experience = $d['experience'] ?? '';
$goal = $d['goal'] ?? '';

if (empty($industry)) {
    echo json_encode(['err' => 'индустрия пустая']);
    exit;
}

$prompt = "Ты эксперт по стартапам. Сгенерируй 3 уникальные идеи стартапа на основе:

Индустрия: $industry
Бюджет: $budget
Размер команды: $team
Регион: $region
Опыт: $experience
Цель: $goal

Для каждой идеи создай:
1. name - креативное название (на русском)
2. problem - какую проблему решаем (1-2 предложения)
3. solution - как решаем (2-3 предложения)
4. audience - целевая аудитория
5. model - бизнес-модель (как зарабатываем)
6. mvp - что сделать для MVP за 2 недели
7. risk - главный риск
8. market - размер рынка (примерная оценка)

ВАЖНО: Ответ СТРОГО в формате JSON массива, без лишнего текста:
[
  {\"name\": \"...\", \"problem\": \"...\", \"solution\": \"...\", \"audience\": \"...\", \"model\": \"...\", \"mvp\": \"...\", \"risk\": \"...\", \"market\": \"...\"},
  {\"name\": \"...\", \"problem\": \"...\", \"solution\": \"...\", \"audience\": \"...\", \"model\": \"...\", \"mvp\": \"...\", \"risk\": \"...\", \"market\": \"...\"},
  {\"name\": \"...\", \"problem\": \"...\", \"solution\": \"...\", \"audience\": \"...\", \"model\": \"...\", \"mvp\": \"...\", \"risk\": \"...\", \"market\": \"...\"}
]

Язык: Русский.";

$req = [
    'model' => 'llama-3.1-8b-instant',
    'messages' => [
        ['role' => 'user', 'content' => $prompt]
    ],
    'temperature' => 0.9,
    'max_tokens' => 2500
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

$ideas = json_decode($jsonStr, true);

if (!$ideas || count($ideas) < 3) {
    $ideas = [
        ['name' => 'Ошибка', 'problem' => 'AI не смог сгенерировать идеи', 'solution' => 'Попробуй еще раз', 'audience' => '-', 'model' => '-', 'mvp' => '-', 'risk' => '-', 'market' => '-']
    ];
}

echo json_encode([
    'res' => true,
    'ideas' => $ideas
]);
?>
