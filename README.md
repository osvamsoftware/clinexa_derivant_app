# Clinexa — App del médico derivante

Flutter. Consume la API de `clinexa_backend`.

## Configuración

La app **no lleva ningún archivo de configuración empaquetado**. Todos los
valores se inyectan al compilar con `--dart-define`.

> El `.env` anterior se declaraba como asset en `pubspec.yaml`: viajaba dentro
> del APK/IPA y se podía extraer con `unzip`. La clave de Google Maps que
> contenía debe considerarse comprometida y rotarse, además de restringirse
> por bundle ID / SHA-1 en Google Cloud Console.

### Desarrollo

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=GOOGLE_MAPS_API_KEY=...
```

### Release

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.clinexapp.com \
  --dart-define=GOOGLE_MAPS_API_KEY=...
```

`AppConfig.assertValid()` corta el arranque si un build de release sale sin
configurar o apuntando a una URL sin HTTPS.

## Firma de release

El APK/AAB de release necesita `android/key.properties` (ignorado por git):

```bash
cp android/key.properties.example android/key.properties
keytool -genkey -v -keystore ~/clinexa-derivant-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

⚠️ Guarda el `.jks` en un lugar seguro y respaldado: si se pierde, no se
puede volver a publicar una actualización de la app en Play Store.

## Seguridad

- **Tokens de sesión** en Keychain (iOS) / Keystore (Android) vía
  `SecureTokenStorage`. Los tokens de versiones anteriores se migran
  automáticamente al arrancar.
- **Tráfico en claro prohibido**. `usesCleartextTraffic` estaba en `true`,
  lo que habilitaba HTTP para toda la app y facilitaba interceptarla con un
  proxy. Ahora hay un `network_security_config.xml` que solo permite HTTP
  contra `10.0.2.2` y `localhost` para desarrollo.
- **El código de verificación ya no se consulta al servidor.** La pantalla lo
  mostraba "para pruebas" leyéndolo de un endpoint que devolvía el OTP de
  cualquier teléfono sin autenticación. Ese endpoint se eliminó del backend.
- **Sin logs de datos sensibles**: los `print` se ejecutan también en release.
