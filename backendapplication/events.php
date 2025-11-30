<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$act = $_GET['act'] ?? '';

if ($act == 'list') {
    $stmt = $pdo->query("
        SELECT e.*, COUNT(er.id) as registration_count 
        FROM events e 
        LEFT JOIN event_registrations er ON e.id = er.event_id 
        GROUP BY e.id 
        ORDER BY e.id DESC
    ");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
} elseif ($act == 'create') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("INSERT INTO events (title, descr, date, time, location, image) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data['title'], $data['descr'], $data['date'], $data['time'], $data['location'], $data['image']]);
    echo json_encode(['success' => true]);
} elseif ($act == 'delete') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("DELETE FROM events WHERE id = ?");
    $stmt->execute([$data['id']]);
    echo json_encode(['success' => true]);
} elseif ($act == 'register') {
    $data = json_decode(file_get_contents('php://input'), true);
    try {
        $stmt = $pdo->prepare("INSERT INTO event_registrations (user_id, event_id) VALUES (?, ?)");
        $stmt->execute([$data['user_id'], $data['event_id']]);
        echo json_encode(['success' => true]);
    } catch (PDOException $e) {
        echo json_encode(['success' => false, 'error' => 'Already registered or error']);
    }
} elseif ($act == 'get_registrations') {
    $eventId = $_GET['event_id'];
    $stmt = $pdo->prepare("
        SELECT u.name, u.email, u.avatar 
        FROM users u 
        JOIN event_registrations er ON u.id = er.user_id 
        WHERE er.event_id = ?
    ");
    $stmt->execute([$eventId]);
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
}
?>
