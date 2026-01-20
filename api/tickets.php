<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/conexion.php';

$method = $_SERVER['REQUEST_METHOD'];



// ========================
// GET: Obtener un ticket POR ID (si hay parámetro 'id')
// ========================
if ($method === 'GET' && isset($_GET['id'])) {
    $ticket_id = $_GET['id'];

    try {
        $sql = "
            SELECT 
                t.id, t.title, t.description, t.status, t.priority, t.module,
                t.created_at, t.updated_at, t.due_date, t.completed_at,
                c.name AS category_name, c.color AS category_color,
                creator.full_name AS created_by_name, creator.email AS created_by_email,
                assigned.full_name AS assigned_to_name, assigned.email AS assigned_to_email
            FROM tickets t
            LEFT JOIN categories c ON t.category_id = c.id
            LEFT JOIN profiles creator ON t.created_by = creator.id
            LEFT JOIN profiles assigned ON t.assigned_to = assigned.id
            WHERE t.id = ?
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([$ticket_id]);
        $ticket = $stmt->fetch();

        if (!$ticket) {
            http_response_code(404);
            echo json_encode(['error' => 'Ticket no encontrado']);
            exit();
        }

        echo json_encode(['ticket' => $ticket]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Error al obtener el ticket']);
    }
    exit();
}





// ========================
// GET: Listar tickets
// ========================
if ($method === 'GET') {
    $user_id = $_GET['user_id'] ?? null;
    if (!$user_id) {
        http_response_code(400);
        echo json_encode(['error' => 'user_id es requerido']);
        exit();
    }

    try {
        $stmt = $pdo->prepare("SELECT role FROM profiles WHERE id = ?");
        $stmt->execute([$user_id]);
        $user = $stmt->fetch();

        if (!$user) {
            http_response_code(404);
            echo json_encode(['error' => 'Usuario no encontrado']);
            exit();
        }

        $role = $user['role'];

        $sql = "
            SELECT 
                t.id, t.title, t.description, t.status, t.priority, t.module,
                t.created_at, t.updated_at, t.due_date, t.completed_at,
                c.name AS category_name, c.color AS category_color,
                creator.full_name AS created_by_name,
                assigned.full_name AS assigned_to_name
            FROM tickets t
            LEFT JOIN categories c ON t.category_id = c.id
            LEFT JOIN profiles creator ON t.created_by = creator.id
            LEFT JOIN profiles assigned ON t.assigned_to = assigned.id
        ";

        if ($role === 'admin') {
            $stmt = $pdo->prepare($sql);
            $stmt->execute();
        } else {
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
    exit();
}

// ========================
// POST: Crear nuevo ticket
// ========================
if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);

    // Validar campos obligatorios
    $required = ['title', 'description', 'created_by', 'category_id'];
    foreach ($required as $field) {
        if (!isset($input[$field]) || trim($input[$field]) === '') {
            http_response_code(400);
            echo json_encode(['error' => "El campo '$field' es obligatorio"]);
            exit();
        }
    }

    // Generar UUID simple (puedes mejorar esto después)
    $ticket_id = 'ticket-' . bin2hex(random_bytes(8));

    try {
        $pdo->beginTransaction();

        $stmt = $pdo->prepare("
            INSERT INTO tickets (
                id, title, description, status, priority, module,
                created_by, category_id, due_date
            ) VALUES (
                ?, ?, ?, ?, ?, ?,
                ?, ?, ?
            )
        ");

        $status = $input['status'] ?? 'open';
        $priority = $input['priority'] ?? 'medium';
        $module = $input['module'] ?? 'support';
        $due_date = $input['due_date'] ?? null;

        $stmt->execute([
            $ticket_id,
            trim($input['title']),
            trim($input['description']),
            $status,
            $priority,
            $module,
            $input['created_by'],
            $input['category_id'],
            $due_date
        ]);

        $pdo->commit();

        // Devolver el ticket recién creado (básico)
        echo json_encode([
            'message' => 'Ticket creado exitosamente',
            'ticket_id' => $ticket_id
        ]);
    } catch (Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'Error al crear el ticket']);
    }
    exit();
}


// ========================
// PUT: Actualizar un ticket por ID + registrar historial
// ========================
if ($method === 'PUT') {
    $ticket_id = $_GET['id'] ?? null;
    if (!$ticket_id) {
        http_response_code(400);
        echo json_encode(['error' => 'ID del ticket es requerido']);
        exit();
    }

    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input || !is_array($input)) {
        http_response_code(400);
        echo json_encode(['error' => 'Datos inválidos o cuerpo vacío']);
        exit();
    }

    // Asegurarse de que changed_by esté presente
    $changed_by = $input['changed_by'] ?? null;
    if (!$changed_by) {
        http_response_code(400);
        echo json_encode(['error' => 'El campo "changed_by" es obligatorio']);
        exit();
    }

    // Validar que el ticket exista
    $stmt = $pdo->prepare("SELECT * FROM tickets WHERE id = ?");
    $stmt->execute([$ticket_id]);
    $current_ticket = $stmt->fetch();

    if (!$current_ticket) {
        http_response_code(404);
        echo json_encode(['error' => 'Ticket no encontrado']);
        exit();
    }

    // Validar que changed_by sea un usuario válido
    $stmt = $pdo->prepare("SELECT id FROM profiles WHERE id = ?");
    $stmt->execute([$changed_by]);
    if (!$stmt->fetch()) {
        http_response_code(400);
        echo json_encode(['error' => 'Usuario que realiza el cambio no válido']);
        exit();
    }

    // Campos permitidos para actualizar
    $allowed_fields = ['status', 'priority', 'category_id', 'assigned_to', 'due_date', 'completed_at'];
    $updates = [];
    $params = [];
    $changes_to_log = [];

    foreach ($allowed_fields as $field) {
        if (array_key_exists($field, $input)) {
            $new_value = $input[$field];
            $old_value = $current_ticket[$field];

            // Normalizar valores nulos
            if ($new_value === null || strtolower((string)$new_value) === 'null') {
                $new_value = null;
                $updates[] = "$field = NULL";
            } else {
                $updates[] = "$field = ?";
                $params[] = $new_value;
            }

            // Registrar cambio solo si hay diferencia
            if ($old_value != $new_value) {
                $changes_to_log[] = [
                    'field' => $field,
                    'old' => $old_value,
                    'new' => $new_value
                ];
            }
        }
    }

    if (empty($updates)) {
        http_response_code(400);
        echo json_encode(['error' => 'No se proporcionaron campos para actualizar']);
        exit();
    }

    // Agregar updated_at
    $updates[] = "updated_at = CURRENT_TIMESTAMP";

    try {
        $pdo->beginTransaction();

        // Actualizar el ticket
        $sql = "UPDATE tickets SET " . implode(', ', $updates) . " WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(array_merge($params, [$ticket_id]));

        // Registrar cada cambio en el historial
        foreach ($changes_to_log as $change) {
            $history_id = 'hist-' . bin2hex(random_bytes(8));
            $stmt_hist = $pdo->prepare("
                INSERT INTO ticket_history (id, ticket_id, changed_by, field_changed, old_value, new_value)
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            $stmt_hist->execute([
                $history_id,
                $ticket_id,
                $changed_by,
                $change['field'],
                $change['old'],
                $change['new']
            ]);
        }

        $pdo->commit();

        echo json_encode([
            'message' => 'Ticket actualizado exitosamente',
            'ticket_id' => $ticket_id,
            'changes_logged' => count($changes_to_log)
        ]);
    } catch (Exception $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo json_encode(['error' => 'Error al actualizar el ticket']);
    }
    exit();
}

// Método no permitido
http_response_code(405);
echo json_encode(['error' => 'Método no permitido']);
