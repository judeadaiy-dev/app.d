pluginManagement {
    val flutterSdkPath = provider {
        val properties = java.util.Properties()
        val localPropertiesFile = settingsDir.resolve("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { properties.load(it) }
        }
        val settingsSdkPath = properties.getProperty("flutter.sdk")
        if (settingsSdkPath != null) return@provider settingsSdkPath
        val environmentSdkPath = System.getenv("FLUTTER_ROOT")
        if (environmentSdkPath != null) return@provider environmentSdkPath
        throw GradleException("Flutter SDK not found. Define flutter.sdk in local.properties or FLUTTER_ROOT env variable.")
    }

    includeBuild("${flutterSdkPath.get()}/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // 💡 تثبيت إصدار التجميع المستقر 8.2.1 المتوافق 100% لضمان إخراج ملف الـ APK
    id("com.android.application") version "8.2.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

include(":app")
