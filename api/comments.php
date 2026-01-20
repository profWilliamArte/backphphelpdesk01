<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/conexion.php';

$method = $_SERVER['REQUEST_METHOD'];

// ========================
// POST: Crear un comentario
// ========================
if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);

    $required = ['ticket_id', 'user_id', 'content'];
    foreach ($required as $field) {
        if (!isset($input[$field]) || trim($input[$field]) === '') {
            http_response_code(400);
            echo json_encode(['error' => "El campo '$field' es obligatorio"]);
            exit();
        }
    }

    // Validar que el ticket exista
    $stmt = $pdo->prepare("SELECT id FROM tickets WHERE id = ?");
    $stmt->execute([$input['ticket_id']]);
    if (!$stmt->fetch()) {
        http_response_code(404);
        echo json_encode(['error' => 'Ticket no encontrado']);
        exit();
    }

    // Validar que el usuario exista
    $stmt = $pdo->prepare("SELECT id FROM profiles WHERE id = ?");
    $stmt->execute([$input['user_id']]);
    if (!$stmt->fetch()) {
        http_response_code(404);
        echo json_encode(['error' => 'Usuario no encontrado']);
        exit();
    }

    $comment_id = 'comment-' . bin2hex(random_bytes(8));
    $is_internal = isset($input['is_internal']) && $input['is_internal'] === true;

    try {
        $stmt = $pdo->prepare("
            INSERT INTO comments (id, ticket_id, user_id, content, is_internal)
            VALUES (?, ?, ?, ?, ?)
        ");

        $stmt->execute([
            $comment_id,
            $input['ticket_id'],
            $input['user_id'],
            trim($input['content']),
            $is_internal ? 1 : 0
        ]);

        echo json_encode([
            'message' => 'Comentario agregado exitosamente',
            'comment_id' => $comment_id
        ]);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al guardar el comentario']);
    }
    exit();
}

// ========================
// GET: Listar comentarios de un ticket
// ========================
if ($method === 'GET') {
    $ticket_id = $_GET['ticket_id'] ?? null;
    if (!$ticket_id) {
        http_response_code(400);
        echo json_encode(['error' => 'ticket_id es requerido']);
        exit();
    }

    // Verificar que el ticket exista
    $stmt = $pdo->prepare("SELECT id FROM tickets WHERE id = ?");
    $stmt->execute([$ticket_id]);
    if (!$stmt->fetch()) {
        http_response_code(404);
        echo json_encode(['error' => 'Ticket no encontrado']);
        exit();
    }

    try {
        $sql = "
            SELECT 
                c.id,
                c.content,
                c.is_internal,
                c.created_at,
                p.full_name AS author_name,
                p.role AS author_role,
                p.email AS author_email
            FROM comments c
            JOIN profiles p ON c.user_id = p.id
            WHERE c.ticket_id = ?
            ORDER BY c.created_at ASC
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([$ticket_id]);
        $comments = $stmt->fetchAll();

        echo json_encode(['comments' => $comments]);

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al obtener los comentarios']);
    }
    exit();
}

http_response_code(405);
echo json_encode(['error' => 'Método no permitido']);
?>