<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $code = $data['code'] ?? '';
    file_put_contents(__DIR__ . '/debug_codes.log', date('Y-m-d H:i:s') . " - POST code: $code\n", FILE_APPEND);
    if ($code) {
        $file = __DIR__ . '/login_codes.json';
        $codes = file_exists($file) ? json_decode(file_get_contents($file), true) : [];
        $codes[$code] = ['ts' => time(), 'used' => false];
        file_put_contents($file, json_encode($codes));
        file_put_contents(__DIR__ . '/debug_codes.log', date('Y-m-d H:i:s') . " - Saved code: $code\n", FILE_APPEND);
        echo json_encode(['res' => true]);
    } else {
        echo json_encode(['res' => false]);
    }
} else {
    $code = $_GET['code'] ?? '';
    if (!$code) {
        echo json_encode(['res' => false]);
        exit;
    }
    
    $file = __DIR__ . '/login_codes.json';
    clearstatcache();
    if (!file_exists($file)) {
        echo json_encode(['res' => false]);
        exit;
    }
    
    $codes = json_decode(file_get_contents($file), true);
    
    if (isset($codes[$code]) && isset($codes[$code]['user_data'])) {
        $data = $codes[$code]['user_data'];
        
        echo json_encode([
            'res' => true,
            't' => $data['t'],
            'r' => $data['r'],
            'name' => $data['name'],
            'email' => $data['email'],
            'user_id' => $data['user_id'],
            'avatar' => $data['avatar']
        ]);
        
        unset($codes[$code]);
        file_put_contents($file, json_encode($codes));
    } else {
        echo json_encode(['res' => false]);
    }
}
