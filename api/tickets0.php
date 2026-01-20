<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/conexion.php';

// Obtener user_id desde los parámetros (para simplicidad en clase)
$user_id = $_GET['user_id'] ?? null;
if (!$user_id) {
    http_response_code(400);
    echo json_encode(['error' => 'user_id es requerido']);
    exit();
}

try {
    // Primero, obtener el rol del usuario
    $stmt = $pdo->prepare("SELECT role FROM profiles WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(404);
        echo json_encode(['error' => 'Usuario no encontrado']);
        exit();
    }

    $role = $user['role'];

    // Consulta base
    $sql = "
        SELECT 
            t.id,
            t.title,
            t.description,
            t.status,
            t.priority,
            t.module,
            t.created_at,
            t.updated_at,
            t.due_date,
            t.completed_at,
            c.name AS category_name,
            c.color AS category_color,
            creator.full_name AS created_by_name,
            assigned.full_name AS assigned_to_name
        FROM tickets t
        LEFT JOIN categories c ON t.category_id = c.id
        LEFT JOIN profiles creator ON t.created_by = creator.id
        LEFT JOIN profiles assigned ON t.assigned_to = assigned.id
    ";

    // Filtrar según rol
    if ($role === 'admin') {
        // Admin ve todos
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
    } else {
        // Usuario común ve solo sus tickets
        $sql .= " WHERE t.created_by = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$user_id]);
    }

    $tickets = $stmt->fetchAll();

    echo json_encode(['tickets' => $tickets]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Error al obtener los tickets']);
}
?>