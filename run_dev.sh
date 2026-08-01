#!/usr/bin/env bash
#
# Arranca la app en desarrollo con la configuración local.
#
# Las claves NO se empaquetan en la app: se inyectan al compilar desde
# config/dev.json, que no está versionado.
#
#   ./run_dev.sh                 # dispositivo por defecto
#   ./run_dev.sh -d chrome       # cualquier argumento pasa a flutter run

set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f config/dev.json ]]; then
  echo "Falta config/dev.json. Créalo con:"
  echo "  cp config/dev.json.example config/dev.json"
  echo "y completa los valores."
  exit 1
fi

exec flutter run --dart-define-from-file=config/dev.json "$@"
