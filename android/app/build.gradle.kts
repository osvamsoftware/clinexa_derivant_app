import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Configuración de firma de release.
// El keystore y sus contraseñas viven FUERA del repositorio: en
// android/key.properties (ignorado por git) o en los secrets del CI.
// Firmar con la clave de debug —como se hacía antes— significa que
// cualquiera puede publicar un APK modificado que el sistema considera
// "la misma app", y además bloquea la publicación en Play Store.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.clinexapp.derivante"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.clinexapp.derivante"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Explícito y no heredado: flutter_secure_storage usa
        // EncryptedSharedPreferences, que requiere API 23+. Si el minSdk
        // bajara al cambiar de versión de Flutter, el almacenamiento seguro
        // de los tokens fallaría en tiempo de ejecución.
        minSdk = maxOf(flutter.minSdkVersion, 24) // Recommendation for some Firebase/Notification features
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // Sin keystore solo se puede probar en local. Un build así
                // NO es publicable: el pipeline de release debe fallar si
                // falta key.properties.
                logger.warn(
                    "AVISO: no se encontró android/key.properties. " +
                    "El build de release se firmará con la clave de debug " +
                    "y NO es publicable."
                )
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
