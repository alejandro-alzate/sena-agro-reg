# SENA Agro Reg - API Reference

Esta documentación describe todas las rutas de la API necesarias para el funcionamiento del dashboard del sistema SENA Agro Reg.

## Autenticación

Todas las rutas protegidas requieren un token de autenticación enviado en el header `Authorization: Bearer <token>`.

### POST /api/auth/login
Autentica un usuario y devuelve un token de sesión.

**Body:**
```json
{
  "username": "string",
  "password": "string",
  "remember": "boolean"
}
```

**Response (200):**
```json
{
  "success": true,
  "token": "string",
  "user": {
    "id": 1,
    "user": "root",
    "contact": "admin@sena.edu.co",
    "roles": 255
  }
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Credenciales incorrectas"
}
```

### POST /api/auth/verify
Verifica si un token es válido.

**Body:**
```json
{
  "token": "string"
}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "user": "root",
    "contact": "admin@sena.edu.co",
    "roles": 255
  }
}
```

### POST /api/auth/logout
Invalida el token actual del usuario.

**Response (200):**
```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente"
}
```

## Permisos

### GET /api/permissions/{module}
Obtiene los permisos del usuario actual para un módulo específico.

**Modules:** users, inventory, reminders, roles, sessions, events

**Response (200):**
```json
{
  "permission": "write" // "none", "read", "write"
}
```

## Gestión de Usuarios

### GET /api/users
Lista todos los usuarios del sistema.

**Response (200):**
```json
{
  "users": [
    {
      "id": 1,
      "user": "root",
      "contact": "admin@sena.edu.co",
      "roles": 255,
      "active": true
    }
  ]
}
```

### POST /api/users
Crea un nuevo usuario.

**Body:**
```json
{
  "user": "string",
  "contact": "string",
  "password": "string",
  "roles": 154
}
```

**Response (201):**
```json
{
  "success": true,
  "user": {
    "id": 2,
    "user": "newuser",
    "contact": "user@sena.edu.co",
    "roles": 154,
    "active": true
  }
}
```

### PUT /api/users/{id}
Actualiza un usuario existente.

**Body:**
```json
{
  "user": "string",
  "contact": "string",
  "password": "string", // opcional
  "roles": 154
}
```

### DELETE /api/users/{id}
Elimina un usuario.

**Response (200):**
```json
{
  "success": true,
  "message": "Usuario eliminado exitosamente"
}
```

### GET /api/users/stats
Obtiene estadísticas de usuarios.

**Response (200):**
```json
{
  "totalUsers": 10,
  "activeUsers": 8,
  "newUsersThisMonth": 2
}
```

## Gestión de Inventario

### GET /api/inventory
Lista todos los productos del inventario.

**Response (200):**
```json
{
  "items": [
    {
      "id": 1,
      "name": "Fertilizante NPK",
      "category": "Fertilizantes",
      "stock": 50,
      "price": 25000.00,
      "description": "Fertilizante completo",
      "active": true
    }
  ]
}
```

### POST /api/inventory
Crea un nuevo producto.

**Body:**
```json
{
  "name": "string",
  "category": "string",
  "stock": 0,
  "price": 0.00,
  "description": "string"
}
```

### PUT /api/inventory/{id}
Actualiza un producto existente.

### DELETE /api/inventory/{id}
Elimina un producto.

### GET /api/inventory/stats
Obtiene estadísticas del inventario.

**Response (200):**
```json
{
  "totalItems": 50,
  "lowStockItems": 5,
  "totalValue": 1250000.00,
  "categories": 8
}
```

## Gestión de Recordatorios

### GET /api/reminders
Lista todos los recordatorios.

**Response (200):**
```json
{
  "reminders": [
    {
      "id": 1,
      "owner": 1,
      "subject": "Riego diario",
      "message": "Recordatorio para regar las plantas",
      "cron": "0 8 * * *",
      "notifyRoles": "15",
      "status": 1
    }
  ]
}
```

### POST /api/reminders
Crea un nuevo recordatorio.

**Body:**
```json
{
  "subject": "string",
  "message": "string",
  "cron": "string",
  "notifyRoles": "string"
}
```

### PUT /api/reminders/{id}
Actualiza un recordatorio.

### DELETE /api/reminders/{id}
Elimina un recordatorio.

### POST /api/reminders/{id}/toggle
Activa/desactiva un recordatorio.

### GET /api/reminders/stats
Obtiene estadísticas de recordatorios.

**Response (200):**
```json
{
  "totalReminders": 10,
  "activeReminders": 7,
  "scheduledToday": 3
}
```

## Gestión de Roles

### GET /api/roles
Lista todos los roles definidos.

**Response (200):**
```json
{
  "roles": [
    {
      "position": 1,
      "name": "Administrador",
      "description": "Acceso completo al sistema",
      "userCount": 2
    },
    {
      "position": 2,
      "name": "Usuario",
      "description": "Acceso básico",
      "userCount": 5
    }
  ]
}
```

### POST /api/roles
Crea un nuevo rol.

**Body:**
```json
{
  "position": 8,
  "name": "string",
  "description": "string"
}
```

### PUT /api/roles/{position}
Actualiza un rol existente.

### DELETE /api/roles/{position}
Elimina un rol.

### GET /api/roles/{position}/users
Lista usuarios que tienen un rol específico.

## Gestión de Sesiones

### GET /api/sessions
Lista todas las sesiones activas.

**Response (200):**
```json
{
  "sessions": [
    {
      "id": 1,
      "owner": 1,
      "username": "root",
      "token": "abc123...",
      "expires": 1703980800,
      "active": true
    }
  ]
}
```

### DELETE /api/sessions/{id}
Elimina (expulsa) una sesión específica.

### POST /api/sessions/clear-expired
Elimina todas las sesiones expiradas.

### GET /api/sessions/stats
Obtiene estadísticas de sesiones.

**Response (200):**
```json
{
  "totalSessions": 15,
  "activeSessions": 8,
  "expiredSessions": 7
}
```

## Gestión de Eventos

### GET /api/events
Lista eventos del sistema con filtros opcionales.

**Query Parameters:**
- `type`: Filtra por tipo de evento (login, logout, create, update, delete)
- `limit`: Número de eventos a devolver (default: 50)
- `offset`: Offset para paginación (default: 0)

**Response (200):**
```json
{
  "events": [
    {
      "id": 1,
      "issuer": 1,
      "username": "root",
      "date": 1703980800,
      "name": "user_login",
      "description": "Usuario root inició sesión"
    }
  ]
}
```

### POST /api/events
Crea un nuevo evento de auditoría.

**Body:**
```json
{
  "name": "string",
  "description": "string"
}
```

### GET /api/events/stats
Obtiene estadísticas de eventos.

**Response (200):**
```json
{
  "totalEvents": 1500,
  "todayEvents": 25,
  "eventTypes": {
    "login": 300,
    "logout": 280,
    "create": 200,
    "update": 450,
    "delete": 50
  }
}
```

## Códigos de Estado HTTP

- **200**: OK - Operación exitosa
- **201**: Created - Recurso creado exitosamente
- **400**: Bad Request - Datos inválidos
- **401**: Unauthorized - Token inválido o faltante
- **403**: Forbidden - Sin permisos para la operación
- **404**: Not Found - Recurso no encontrado
- **500**: Internal Server Error - Error del servidor

## Manejo de Roles (Bitmask)

Los roles se manejan usando un sistema de bitmask donde cada bit representa un rol específico:

```
Posición 1 (bit 0): Administrador
Posición 2 (bit 1): Usuario Básico
Posición 3 (bit 2): Gestor de Inventario
Posición 4 (bit 3): Supervisor
...hasta la posición 64
```

Ejemplo: Un usuario con roles = 154 (binario: 10011010) tiene los roles en las posiciones 2, 4, 5 y 8.

## Algoritmo de Autenticación

1. **Entrada**: Contraseña en texto plano
2. **Sal**: Primeros 8 dígitos del SHA1 de la hora de creación
3. **Hash**: SHA1(Contraseña + Sal)
4. **Verificación**: Comparar hash almacenado con hash calculado

## Base de Datos (SQLite)

**Ubicación**: `recursos/db/MAIN.sqlite`

### Tabla USERS
```sql
CREATE TABLE USERS (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
    user TEXT NOT NULL UNIQUE,
    contact TEXT NOT NULL,
    roles INTEGER NOT NULL,
    salt TEXT NOT NULL,
    hash TEXT NOT NULL
);
```

### Tabla TOKENS
```sql
CREATE TABLE TOKENS (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
    owner INTEGER NOT NULL,
    token TEXT NOT NULL UNIQUE,
    expires INTEGER,
    FOREIGN KEY(owner) REFERENCES USERS(id)
);
```

### Tabla REMINDERS
```sql
CREATE TABLE REMINDERS (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
    owner INTEGER NOT NULL,
    subject TEXT NOT NULL,
    message TEXT,
    cron TEXT NOT NULL,
    notifyRoles TEXT,
    status INTEGER NOT NULL,
    FOREIGN KEY(owner) REFERENCES USERS(id)
);
```

### Tabla EVENTS
```sql
CREATE TABLE EVENTS (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
    issuer INTEGER NOT NULL,
    date INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    FOREIGN KEY(issuer) REFERENCES USERS(id)
);
```

## Notas de Implementación

1. **Fechas**: Todas las fechas se almacenan en formato epoch (tiempo Unix)
2. **Tokens**: Vulnerables a replay attacks - se requiere rotación frecuente
3. **Usuario Root**: ID = 1, acceso completo al sistema
4. **Permisos**: Se verifican en cada request mediante el bitmask de roles
5. **Logging**: Todos los eventos importantes deben registrarse en la tabla EVENTS

## Ejemplo de Implementación (Pseudocódigo)

```python
# Verificación de permisos
def check_permission(user_roles, required_permission, module):
    # Mapeo de módulos a posiciones de roles
    module_permissions = {
        'users': 1,      # Posición 1
        'inventory': 2,  # Posición 2
        'reminders': 3,  # Posición 3
        # etc...
    }

    role_position = module_permissions.get(module)
    if not role_position:
        return 'none'

    # Verificar si el usuario tiene el rol
    has_role = bool(user_roles & (1 << (role_position - 1)))

    if not has_role:
        return 'none'

    # Determinar nivel de permiso (lógica específica del negocio)
    if user_roles & 1:  # Usuario root (posición 1)
        return 'write'
    else:
        return 'read'  # O 'write' según reglas de negocio
```
