# Seccion 1: _Principios de diseño_

## Frontend:

- El usuario accede atravéz de un portal web
- HTTP (dev: 8080, prod: 80)
- HTTPS sin implementar (dev: 8443, prod: 443)
- Los esqueletos van a estar guardados en recursos/server/
- Los portales web internamente usaran otro socket para comunicarse con las otras partes del sistema
- Para cada peticion se manda un token
    - Por el momento este es vulnerable a un replay attack, por el momento se fuerza al usuario a iniciar sesion seguido.

## Backend:

- Usuario maestro por defecto: Nombre → `root`, Contraseña → `toor`
- El usuario con id 1 tiene acceso indiscriminado a los datos (unix-like)
- Todos las fechas son serializadas a formato [epoch](https://es.wikipedia.org/wiki/Tiempo_Unix) por la simplicidad.
- Algoritmo de autenticacion:

    - Contraseña → String
    - Sal → String(8)
        - Primeros 8 digitos de un sha1sum de una fuente aleatoria como la hora de creacion de la cuenta.
    - Hash = sha1sum(Contraseña + Sal)

### Base de datos:

- recursos/db/MAIN.sqlite

    - USERS
        - Objecto Usuario (DB):
            - id(int)[nn, pk, ai, u]
            - user(str)[nn, u]
            - contact(str)[nn]
            - roles(int)[nn]
            - salt(str)[nn]
            - hash(str)[nn]
    - TOKENS

        - Objecto Token (DB):
            - id(int)[nn, pk, ai, u]
            - owner(int)[nn, fk(USERS.id)]
            - token(str)[nn, u]
            - expires(int)

    - REMINDERS
        - id(int)[nn, pk, ai, u]
        - owner(int)[nn, fk(USERS.id)]
        - subject(str)[nn]
        - message(str)[]
        - cron(str)[nn]
        - notifyRoles(str)[]
        - status(int)[nn]
    - EVENTS
        - id(int)[nn, pk, ai, u]
        - issuer(int)[nn, fk(USERS.id)]
        - date(int)[nn]
        - name(str)[nn]
        - description(str)[nn]

### Roles

- Un objectio usuario tiene un campo llamado roles el cual contiene un numero en entero el cual se expande a binario para representar si el usuario tiene ciertos roles
    - Ejemplo usuario bob tiene el campo rol establecido a 154
    - El numero 154 en binario es 01011001 (big endian)
        - Significa que tiene y no tiene acceso a los siguientes roles:
            - Rol1 → no
            - Rol2 → si
            - Rol3 → no
            - Rol4 → si
            - Rol5 → si
            - Rol6 → no
            - Rol7 → no
            - Rol8 → si
        - De esta manera se linealiza los roles del usuario en un solo campo en la base de datos
        - Debilidades:
            - remover o cambiar la posicion de los roles requiere que los roles de todos los usuarios sean recalculados.
