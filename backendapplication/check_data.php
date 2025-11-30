<?php
require 'db.php';

echo "Сейчас глянем что в базе\n\n";

echo "QR КОДЫ (ХабКоины)\n";

try {
    $stmt = $pdo->query("SELECT * FROM qr_codes LIMIT 5");
    $codes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!$codes) {
        echo "В таблице qr_codes вообще пусто\n";
    } else {
        foreach ($codes as $r) {
            echo "ID: {$r['id']} | Код: {$r['code']} | Монет: {$r['coins']} | Активен: {$r['active']}\n";
        }
    }
} catch (Exception $e) {
    echo "ошибка при просмотре qr_codes {$e->getMessage()}\n";
}

echo "\nQR КАРТЫ (AR)\n";

try {
    $stmt = $pdo->query("SELECT * FROM qr_cards LIMIT 5");
    $cards = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!$cards) {
        echo "В qr_cards тоже пусто... эх.\n";
    } else {
        foreach ($cards as $r) {
            echo "ID: {$r['id']} | Юзер: {$r['user_id']} | QR: {$r['qr_code']} | Имя: {$r['name']}\n";
        }
    }
} catch (Exception $e) {
    echo "Что-то сломалось при чтении qr_cards: {$e->getMessage()}\n";
}

echo "\nГотово вроде\n";
?>
