# Clinexa — App del médico derivante

Flutter. Consume la API de `clinexa_backend`.

## Configuración

Los valores salen de dos sitios, en este orden de prioridad:

1. **`--dart-define`**, si se pasa al compilar.
2. **`.env`**, que se carga al arrancar (`flutter_dotenv`).

### Desarrollo

Copia la plantilla una vez y ya puedes arrancar sin argumentos:

```bash
cp .env.example .env    # y completa las claves
flutter run
```

El `.env` es **obligatorio**: está declarado como asset en `pubspec.yaml`, así
que sin él la compilación falla con `No file or variants found for asset:
.env`. No se versiona (está en `.gitignore`); `.env.example` sí.

> ⚠️ **El `.env` viaja dentro del APK y del IPA** y se puede extraer con
> `unzip`. Ahí solo pueden ir claves públicas. La de Google Maps lo es: lo que
> la protege es restringirla por bundle ID / SHA-1 en Google Cloud Console, no
> esconderla. Aun así, la que había en el `.env` de una versión anterior
> quedó publicada en el repositorio y conviene rotarla.

Para un paquete de producción sin claves dentro, deja el `.env` vacío y pasa
los valores por `--dart-define`, que tienen prioridad:

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
