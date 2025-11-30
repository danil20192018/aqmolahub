<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
require 'db.php';

$method = $_SERVER['REQUEST_METHOD'];
$act = $_GET['act'] ?? '';

if ($method == 'GET') {
    if ($act == 'list') {
        $type = $_GET['type'] ?? 'offer';
        $stmt = $pdo->prepare("
            SELECT m.*, u.name as author_name, u.avatar as author_avatar 
            FROM market_listings m 
            JOIN users u ON m.user_id = u.id 
            WHERE m.type = ? AND m.status = 'active' 
            ORDER BY m.created_at DESC
        ");
        $stmt->execute([$type]);
        echo json_encode(['res' => true, 'data' => $stmt->fetchAll()]);
    }
} elseif ($method == 'POST') {
    $d = json_decode(file_get_contents('php://input'), true);

    if ($act == 'create') {
        $uid = $d['user_id'];
        $type = $d['type'];
        $title = $d['title'];
        $desc = $d['desc'] ?? '';
        $price = (int)$d['price'];

        if ($price < 0) {
            echo json_encode(['res' => false, 'err' => 'Цена не может быть отрицательной']);
            exit;
        }

        $stmt = $pdo->prepare("INSERT INTO market_listings (user_id, type, title, description, price) VALUES (?, ?, ?, ?, ?)");
        if ($stmt->execute([$uid, $type, $title, $desc, $price])) {
            echo json_encode(['res' => true]);
        } else {
            echo json_encode(['res' => false, 'err' => 'Ошибка БД']);
        }
    } elseif ($act == 'buy') {
        $buyerId = $d['buyer_id'];
        $listingId = $d['listing_id'];

        $pdo->beginTransaction();

        try {
            $stmt = $pdo->prepare("SELECT * FROM market_listings WHERE id = ? AND status = 'active' FOR UPDATE");
            $stmt->execute([$listingId]);
            $listing = $stmt->fetch();

            if (!$listing) {
                throw new Exception('Объявление не найдено или уже закрыто');
            }

            $price = (int)$listing['price'];
            $sellerId = (int)$listing['user_id'];

            if ($buyerId == $sellerId) {
                throw new Exception('Нельзя купить у самого себя');
            }
            $stmt = $pdo->prepare("SELECT coins FROM users WHERE id = ?");
            $stmt->execute([$buyerId]);
            $buyer = $stmt->fetch();

            if ($buyer['coins'] < $price) {
                throw new Exception('Недостаточно HubCoins');
            }

            $commission = ceil($price * 0.05);
            $sellerAmount = $price - $commission;

            $stmt = $pdo->prepare("UPDATE users SET coins = coins - ? WHERE id = ?");
            $stmt->execute([$price, $buyerId]);
            $stmt = $pdo->prepare("UPDATE users SET coins = coins + ? WHERE id = ?");
            $stmt->execute([$sellerAmount, $sellerId]);

            $stmt = $pdo->prepare("UPDATE market_listings SET status = 'completed' WHERE id = ?");
            $stmt->execute([$listingId]);

            $stmt = $pdo->prepare("INSERT INTO market_transactions (buyer_id, seller_id, listing_id, amount, commission) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([$buyerId, $sellerId, $listingId, $price, $commission]);

            $pdo->commit();
            echo json_encode(['res' => true, 'msg' => "Успешно! Комиссия системы: $commission HC"]);

        } catch (Exception $e) {
            $pdo->rollBack();
            echo json_encode(['res' => false, 'err' => $e->getMessage()]);
        }
    } elseif ($act == 'delete') {
        $uid = $d['user_id'];
        $lid = $d['listing_id'];

        $stmt = $pdo->prepare("UPDATE market_listings SET status = 'deleted' WHERE id = ? AND user_id = ?");
        if ($stmt->execute([$lid, $uid])) {
            echo json_encode(['res' => true]);
        } else {
            echo json_encode(['res' => false, 'err' => 'Ошибка удаления']);
        }
    }
}
?>
