#!/usr/bin/env bash
#
# Arranca la app en desarrollo leyendo las claves del .env
#
#   ./run_dev.sh                 # dispositivo por defecto
#   ./run_dev.sh -d chrome       # cualquier argumento pasa a flutter run
#
# El .env se inyecta al COMPILAR: no se empaqueta dentro de la app.
# Si lo editas, hay que reiniciar (un hot reload no basta).

set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  echo "Falta el archivo .env. Créalo con:"
  echo "  cp .env.example .env"
  echo "y completa las claves."
  exit 1
fi

exec flutter run --dart-define-from-file=.env "$@"
