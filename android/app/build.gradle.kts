import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // Kotlin comes from AGP 9's built-in Kotlin (android.builtInKotlin=true).
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.grs.kuber"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.grs.kuber"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Optimization: Include only required locales to save space in the App Bundle.
        // This removes translations from various libraries that the app doesn't use.
        resConfigs("en")

        // Package only the ABIs Flutter is building (`--target-platform`).
        // Flutter's own filter always allows all three, and plugins with native
        // code (isar_flutter_libs) ship every ABI, so an arm64-only APK carried
        // ~1.2 MB of unused 32-bit / x86_64 libraries. Needs
        // `disable-abi-filtering=true` (gradle.properties) so Flutter does not
        // reset this. No target platform: Flutter's default three, no x86.
        val abiFor = mapOf(
            "android-arm" to "armeabi-v7a",
            "android-arm64" to "arm64-v8a",
            "android-x64" to "x86_64",
        )
        val abis = (project.findProperty("target-platform") as String?)
            ?.split(",")
            ?.mapNotNull { abiFor[it.trim()] }
            ?.takeIf { it.isNotEmpty() }
            ?: abiFor.values.toList()
        ndk {
            abiFilters.clear()
            abiFilters += abis
        }
    }

    buildTypes {
        release {
            // Enable code shrinking, obfuscation, and optimization for the release build.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            signingConfig = signingConfigs.getByName("release")
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // flutter_local_notifications 21.x requires desugar_jdk_libs >= 2.1.4.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // flutter_local_notifications transitively pulls com.google.android.material
    // 1.7.0, whose date picker calls the deprecated Window.setStatusBarColor /
    // setNavigationBarColor (Android 15 edge-to-edge flag). Pin a current
    // Material that migrated its date picker to the inset-compat APIs.
    implementation("com.google.android.material:material:1.13.0")

    // vNext: launch task queue as expedited background work
    // (BackgroundTasksWorker.kt).
    implementation("androidx.work:work-runtime-ktx:2.10.5")
}
