<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$uuid = $_GET['uuid'] ?? '';

if (!$uuid) {
    echo json_encode(['res' => false]);
    exit;
}

$file = 'login_requests.json';
if (!file_exists($file)) {
    echo json_encode(['res' => false]);
    exit;
}

$reqs = json_decode(file_get_contents($file), true);

if (isset($reqs[$uuid])) {
    $data = $reqs[$uuid];
    
    if (time() - $data['ts'] > 300) {
        unset($reqs[$uuid]);
        file_put_contents($file, json_encode($reqs));
        echo json_encode(['res' => false, 'err' => 'expired']);
        exit;
    }
    
    echo json_encode([
        'res' => true,
        't' => $data['t'],
        'r' => $data['r'],
        'name' => $data['name'],
        'email' => $data['email'],
        'user_id' => $data['user_id'],
        'avatar' => $data['avatar']
    ]);
    
    unset($reqs[$uuid]);
    file_put_contents($file, json_encode($reqs));
} else {
    echo json_encode(['res' => false]);
}
