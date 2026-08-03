/// Rol reservado a la app receptora, para bloquear el login cruzado.
///
/// El backend usa el literal `receptor` — ver `app/models/users.py` en el
/// backend.
const String kOtherAppRole = 'receptor';

/// Código de error interno para el estado del cubit de login. No es un
/// mensaje para el usuario: la pantalla lo traduce a la [WrongRoleScreen].
const String kWrongRoleErrorCode = 'wrong_role_$kOtherAppRole';

/// True si el rol del usuario que acaba de iniciar sesión pertenece a la
/// otra app (la receptora), no a esta.
bool isWrongApp(String userRole) => userRole == kOtherAppRole;
