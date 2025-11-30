<?php
require_once 'db.php';
require_once 'config.php';
$api = "https://api.telegram.org/bot{$telegram_bot_token}/";

function req($m, $d = []) {
    global $api;
    $opts = [
        'http' => [
            'method' => 'POST',
            'header' => 'Content-Type: application/x-www-form-urlencoded',
            'content' => http_build_query($d)
        ]
    ];
    $ctx = stream_context_create($opts);
    $res = file_get_contents($api . $m, false, $ctx);
    return json_decode($res, true);
}

function getUpd($off = 0) {
    return req('getUpdates', ['offset' => $off, 'timeout' => 30]);
}

function send($cid, $txt, $kb = null) {
    $d = ['chat_id' => $cid, 'text' => $txt];
    if ($kb) $d['reply_markup'] = json_encode($kb);
    req('sendMessage', $d);
}

function getUser($tid) {
    global $pdo;
    try {
        $q = $pdo->prepare("SELECT * FROM users WHERE telegram_id = ?");
        $q->execute([$tid]);
        return $q->fetch();
    } catch (PDOException $e) {
        reconnectDB();
        try {
            $q = $pdo->prepare("SELECT * FROM users WHERE telegram_id = ?");
            $q->execute([$tid]);
            return $q->fetch();
        } catch (PDOException $e2) {
            return false;
        }
    }
}

function linkUser($tid, $tun, $uid) {
    global $pdo;
    try {
        $q = $pdo->prepare("UPDATE users SET telegram_id = ?, telegram_username = ? WHERE id = ?");
        return $q->execute([$tid, $tun, $uid]);
    } catch (PDOException $e) {
        reconnectDB();
        $q = $pdo->prepare("UPDATE users SET telegram_id = ?, telegram_username = ? WHERE id = ?");
        return $q->execute([$tid, $tun, $uid]);
    }
}

function reconnectDB() {
    global $pdo;
    $pdo = null;
    require 'db.php';
}

function showMenu($cid, $withPromo = true) {
    $menu = "Главное меню Aqmola Hub\n\n";
    $menu .= "ИИ Инструменты:\n";
    $menu .= "/pitch - Анализ питча (текст/голос)\n";
    $menu .= "/idea - Генератор идей для вашего стартапа\n";
    $menu .= "/analyze [текст] - Анализ бизнес-идеи\n\n";
    $menu .= "Профиль:\n";
    $menu .= "/profile - Мой профиль\n";
    $menu .= "/stats - Моя статистика\n\n";
    $menu .= "Помощь:\n";
    $menu .= "/help - Список всех команд\n";
    $menu .= "/start - Главное меню\n\n";
    
    if ($withPromo) {
        $menu .= "Хотите больше возможностей?\n";
        $menu .= "Напишите /download и скачайте наше приложение!";
    }
    
    send($cid, $menu);
}

function analyzePitch($text) {
    $ch = curl_init('https://aqmolarp.kz/backendapplication/pitch_analyze.php');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['text' => $text]));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    $res = curl_exec($ch);
    curl_close($ch);
    $data = json_decode($res, true);
    return $data['eval'] ?? 'Ошибка анализа';
}

function analyzeIdea($desc) {
    $ch = curl_init('https://aqmolarp.kz/backendapplication/ai_evaluate.php');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['idea' => $desc]));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    $res = curl_exec($ch);
    curl_close($ch);
    $data = json_decode($res, true);
    return $data['evaluation'] ?? 'Ошибка анализа';
}

function generateIdeas($industry) {
    $ch = curl_init('https://aqmolarp.kz/backendapplication/ai_generator.php');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['industry' => $industry, 'budget' => 'средний', 'team' => '2-3', 'region' => 'Казахстан', 'experience' => 'начинающий', 'goal' => 'создать MVP']));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    $res = curl_exec($ch);
    curl_close($ch);
    $data = json_decode($res, true);
    return $data['ideas'] ?? [];
}

function transcribeVoice($fileId) {
    global $api, $groq_key;
    require_once 'config.php';
    
    $fileInfo = req('getFile', ['file_id' => $fileId]);
    if (!isset($fileInfo['result']['file_path'])) return false;
    
    $filePath = $fileInfo['result']['file_path'];
    $fileUrl = str_replace('/bot', '/file/bot', $api) . $filePath;
    
    $voiceFile = file_get_contents($fileUrl);
    $tmpFile = sys_get_temp_dir() . '/' . uniqid() . '.ogg';
    file_put_contents($tmpFile, $voiceFile);
    
    $ch = curl_init('https://api.groq.com/openai/v1/audio/transcriptions');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, [
        'file' => new CURLFile($tmpFile, 'audio/ogg', 'voice.ogg'),
        'model' => 'whisper-large-v3',
        'language' => 'ru'
    ]);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $groq_key
    ]);
    
    $res = curl_exec($ch);
    curl_close($ch);
    unlink($tmpFile);
    
    $data = json_decode($res, true);
    return $data['text'] ?? false;
}

set_time_limit(0);
ignore_user_abort(true);

$sess = [];
$off = 0;
$iter = 0;

while (true) {
    $iter++;
    if ($iter % 10 == 0) {
        reconnectDB();
    }
    
    $upd = getUpd($off);
    
    if (isset($upd['result']) && count($upd['result']) > 0) {
        foreach ($upd['result'] as $u) {
            $off = $u['update_id'] + 1;
            
            if (isset($u['message'])) {
                $cid = $u['message']['chat']['id'];
                $txt = $u['message']['text'] ?? '';
                $tid = $u['message']['from']['id'];
                $tun = $u['message']['from']['username'] ?? '';
                
                if (isset($u['message']['voice']) && isset($sess[$cid]['step']) && $sess[$cid]['step'] == 'pitch_wait') {
                    $fileId = $u['message']['voice']['file_id'];
                    $voiceText = transcribeVoice($fileId);
                    if ($voiceText) {
                        send($cid, "Анализирую питч бро 1 second");
                        $result = analyzePitch($voiceText);
                        send($cid, $result, ['remove_keyboard' => true]);
                        unset($sess[$cid]);
                    } else {
                        send($cid, "тебя чет не слышно или я тупой просто");
                    }
                    continue;
                }
                
                if (strpos($txt, '/code ') === 0) {
                    $code = trim(substr($txt, 6));
                    
                    $file = __DIR__ . '/login_codes.json';
                    clearstatcache();
                    if (file_exists($file)) {
                        $codes = json_decode(file_get_contents($file), true);
                        
                        if (isset($codes[$code]) && !$codes[$code]['used']) {
                            $usr = getUser($tid);
                            if ($usr) {
                                $codes[$code]['user_data'] = [
                                    'user_id' => $usr['id'],
                                    't' => bin2hex(random_bytes(16)),
                                    'r' => $usr['role'],
                                    'name' => $usr['name'],
                                    'email' => $usr['email'],
                                    'avatar' => $usr['avatar']
                                ];
                                $codes[$code]['used'] = true;
                                file_put_contents($file, json_encode($codes));
                                $msg = "Код подтвержден!\n\n";
                                $msg .= "Вы успешно авторизованы в приложении.\n\n";
                                $msg .= "Хотите больше возможностей?\nНапишите /download и скачайте наше приложение!";
                                send($cid, $msg);
                            } else {
                                send($cid, "Сначала привяжите аккаунт. Нажмите /start");
                            }
                        } else {
                            send($cid, "Неверный или устаревший код.");
                        }
                    } else {
                        send($cid, "Неверный код.");
                    }
                } elseif (strpos($txt, '/pitch') === 0) {
                    send($cid, "Отправь мне свой питч текстом или голосовым сообщением, и я дам фидбек!");
                    $sess[$cid] = ['step' => 'pitch_wait'];
                } elseif (strpos($txt, '/idea') === 0) {
                    $kb = [
                        'keyboard' => [
                            [['text' => 'IT/Tech'], ['text' => 'E-commerce']],
                            [['text' => 'Образование'], ['text' => 'Здоровье']],
                            [['text' => 'Финтех'], ['text' => 'Другое']]
                        ],
                        'resize_keyboard' => true
                    ];
                    send($cid, "Выбери индустрию для генерации идеи:", $kb);
                    $sess[$cid] = ['step' => 'idea_industry'];
                } elseif (strpos($txt, '/analyze ') === 0) {
                    $desc = trim(substr($txt, 9));
                    if ($desc) {
                        send($cid, "Анализирую идею...");
                        $result = analyzeIdea($desc);
                        send($cid, $result);
                    } else {
                        send($cid, "Использование: /analyze [описание идеи]");
                    }
                } elseif (isset($sess[$cid]['step']) && $sess[$cid]['step'] == 'pitch_wait') {
                    send($cid, "Анализирую питч...");
                    $result = analyzePitch($txt);
                    $result .= "\n\n💎 Хотите больше возможностей?\nНапишите /download и скачайте наше приложение!";
                    send($cid, $result, ['remove_keyboard' => true]);
                    unset($sess[$cid]);
                } elseif (isset($sess[$cid]['step']) && $sess[$cid]['step'] == 'idea_industry') {
                    send($cid, "Генерирую идеи для индустрии: $txt...");
                    $ideas = generateIdeas($txt);
                    foreach ($ideas as $idx => $idea) {
                        $msg = "Идея " . ($idx + 1) . ": {$idea['name']}\n\n";
                        $msg .= "Проблема: {$idea['problem']}\n\n";
                        $msg .= "Решение: {$idea['solution']}\n\n";
                        $msg .= "Аудитория: {$idea['audience']}\n";
                        $msg .= "Модель: {$idea['model']}\n";
                        $msg .= "MVP: {$idea['mvp']}\n";
                        $msg .= "Риск: {$idea['risk']}\n";
                        $msg .= "Рынок: {$idea['market']}";
                        send($cid, $msg);
                    }
                    $final = "Выбери идею и начни работать!\n\n";
                    $final .= "Хотите больше возможностей?\nНапишите /download и скачайте наше приложение!";
                    send($cid, $final, ['remove_keyboard' => true]);
                    unset($sess[$cid]);
                } elseif (strpos($txt, '/start') === 0) {
                    $usr = getUser($tid);
                    if ($usr) {
                        $welcome = "Whatsapp my boy, {$usr['name']}!\n\n";
                        $welcome .= "Ты уже авторизован в Aqmola Hub.\n\n";
                        send($cid, $welcome);
                        showMenu($cid);
                    } else {
                        $kb = [
                            'keyboard' => [
                                [['text' => 'Привязать аккаунт']]
                            ],
                            'resize_keyboard' => true
                        ];
                        send($cid, "Привет! Для входа нужно привязать аккаунт.", $kb);
                        $sess[$cid] = ['step' => 'menu'];
                    }
                } elseif ($txt == '/help') {
                    showMenu($cid);
                } elseif ($txt == '/download') {
                    $apkPath = __DIR__ . '/app/app.apk';
                    if (file_exists($apkPath)) {
                        $ch = curl_init();
                        curl_setopt($ch, CURLOPT_URL, $api . 'sendDocument');
                        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                        curl_setopt($ch, CURLOPT_POST, true);
                        curl_setopt($ch, CURLOPT_POSTFIELDS, [
                            'chat_id' => $cid,
                            'document' => new CURLFile($apkPath, 'application/vnd.android.package-archive', 'AqmolaHub.apk'),
                            'caption' => "📱 Aqmola Hub для Android\n\nУстанови и получи полный доступ к функциям!"
                        ]);
                        curl_exec($ch);
                        curl_close($ch);
                    } else {
                        $msg = "Скачать Aqmola Hub\n\n";
                        $msg .= "Полный функционал доступен в приложении!";
                        send($cid, $msg);
                    }
                } elseif ($txt == '/profile') {
                    $usr = getUser($tid);
                    if ($usr) {
                        $msg = "твой профиль\n\n";
                        $msg .= "имя: {$usr['name']}\n";
                        $msg .= "email: {$usr['email']}\n";
                        $msg .= "роль: {$usr['role']}\n\n";
                        $msg .= "хотите больше возможностей?\n";
                        $msg .= "напишите /download и скачайте наше приложение!";
                        send($cid, $msg);
                    } else {
                        send($cid, "Сначала привяжите аккаунт. Нажмите /start");
                    }
                } elseif ($txt == '/stats') {
                    $usr = getUser($tid);
                    if ($usr) {
                        $msg = "твоя статистика\n\n";
                        $msg .= "ID: {$usr['id']}\n";
                        $msg .= "Дата регистрации: " . date('d.m.Y', strtotime($usr['created_at'] ?? 'now')) . "\n\n";
                        $msg .= "больше статистики доступно в приложении!\n\n";
                        $msg .= "хотите больше возможностей?\n";
                        $msg .= "напишите /download и скачайте наше приложение!";
                        send($cid, $msg);
                    } else {
                        send($cid, "Сначала привяжите аккаунт. Нажмите /start");
                    }
                } elseif ($txt == 'Привязать аккаунт') {
                    send($cid, "Введи свой email (логин):");
                    $sess[$cid] = ['step' => 'link_email', 'tid' => $tid, 'tun' => $tun];
                } elseif (isset($sess[$cid]['step']) && $sess[$cid]['step'] == 'link_email') {
                    $sess[$cid]['email'] = $txt;
                    send($cid, "Введи пароль от аккаунта:");
                    $sess[$cid]['step'] = 'link_pass';
                } elseif (isset($sess[$cid]['step']) && $sess[$cid]['step'] == 'link_pass') {
                    global $pdo;
                    $pass = $txt;
                    $email = $sess[$cid]['email'];
                    
                    try {
                        $q = $pdo->prepare("SELECT * FROM users WHERE email = ?");
                        $q->execute([$email]);
                        $usr = $q->fetch();
                        
                        if ($usr && password_verify($pass, $usr['pass'])) {
                            linkUser($sess[$cid]['tid'], $sess[$cid]['tun'], $usr['id']);
                            $msg = "Аккаунт успешно привязан!\n\n";
                            $msg .= "Теперь можешь войти через Telegram.\n\n";
                            send($cid, $msg, ['remove_keyboard' => true]);
                            showMenu($cid);
                        } else {
                            send($cid, "Неверный email или пароль. Попробуй снова /start", ['remove_keyboard' => true]);
                        }
                    } catch (PDOException $e) {
                        reconnectDB();
                        send($cid, "Ошибка соединения. Попробуй снова /start", ['remove_keyboard' => true]);
                    }
                    unset($sess[$cid]);
                }
            }
        }
    }
    
    sleep(1);
}
