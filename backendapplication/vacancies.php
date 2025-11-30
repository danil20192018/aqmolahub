<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$act = $_GET['act'] ?? '';

if ($act == 'list') {
    $stmt = $pdo->query("SELECT * FROM vacancies ORDER BY id DESC");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
} elseif ($act == 'create') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("INSERT INTO vacancies (title, company, salary, descr) VALUES (?, ?, ?, ?)");
    $stmt->execute([$data['title'], $data['company'], $data['salary'], $data['descr']]);
    echo json_encode(['success' => true]);
} elseif ($act == 'delete') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("DELETE FROM vacancies WHERE id = ?");
    $stmt->execute([$data['id']]);
    echo json_encode(['success' => true]);
} elseif ($act == 'respond') {
    $data = json_decode(file_get_contents('php://input'), true);
    try {
        $stmt = $pdo->prepare("INSERT INTO vacancy_responses (user_id, vacancy_id) VALUES (?, ?)");
        $stmt->execute([$data['user_id'], $data['vacancy_id']]);
        echo json_encode(['success' => true]);
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'error' => 'Already responded']);
    }
} elseif ($act == 'get_responses') {
    $vacancyId = $_GET['vacancy_id'];
    $stmt = $pdo->prepare("
        SELECT u.id, u.name, u.email, u.avatar 
        FROM users u 
        JOIN vacancy_responses vr ON u.id = vr.user_id 
        WHERE vr.vacancy_id = ?
    ");
    $stmt->execute([$vacancyId]);
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
} elseif ($act == 'delete_response') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("DELETE FROM vacancy_responses WHERE user_id = ? AND vacancy_id = ?");
    $stmt->execute([$data['user_id'], $data['vacancy_id']]);
    echo json_encode(['success' => true]);
}
?>
