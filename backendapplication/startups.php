<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$act = $_GET['act'] ?? '';

if ($act == 'list') {
    $stmt = $pdo->query("SELECT * FROM startups ORDER BY created_at DESC");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
} elseif ($act == 'create') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("INSERT INTO startups (name, description, full_description, founder, website, stage, funding, team_size, contact_email, image) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([
        $data['name'], 
        $data['description'], 
        $data['full_description'] ?? null,
        $data['founder'] ?? null,
        $data['website'] ?? null,
        $data['stage'] ?? null,
        $data['funding'] ?? null,
        $data['team_size'] ?? null,
        $data['contact_email'] ?? null,
        $data['image'] ?? null
    ]);
    echo json_encode(['success' => true]);
} elseif ($act == 'delete') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("DELETE FROM startups WHERE id = ?");
    $stmt->execute([$data['id']]);
    echo json_encode(['success' => true]);
}
?>
