<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$method = $_SERVER['REQUEST_METHOD'];
$act = $_GET['act'] ?? '';

if ($method == 'POST') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    
    if ($act == 'update') {
        $userId = $data['user_id'];
        $name = $data['name'];
        $avatar = $data['avatar'] ?? null;
        
        if ($avatar) {
            $stmt = $pdo->prepare("UPDATE users SET name = ?, avatar = ? WHERE id = ?");
            $stmt->execute([$name, $avatar, $userId]);
        } else {
            $stmt = $pdo->prepare("UPDATE users SET name = ? WHERE id = ?");
            $stmt->execute([$name, $userId]);
        }
        
        echo json_encode(['success' => true]);
    } elseif ($act == 'changepass') {
        $userId = $data['user_id'];
        $oldPass = $data['old_pass'];
        $newPass = $data['new_pass'];
        
        $stmt = $pdo->prepare("SELECT pass FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $user = $stmt->fetch();
        
        if ($user && password_verify($oldPass, $user['pass'])) {
            $hashedPass = password_hash($newPass, PASSWORD_DEFAULT);
            $stmt = $pdo->prepare("UPDATE users SET pass = ? WHERE id = ?");
            $stmt->execute([$hashedPass, $userId]);
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Invalid password']);
        }
    }
}
