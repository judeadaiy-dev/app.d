pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropertiesFile = settingsDir.resolve("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { properties.load(it) }
        }
        val settingsSdkPath = properties.getProperty("flutter.sdk")
        if (settingsSdkPath != null) return@run settingsSdkPath
        val environmentSdkPath = System.getenv("FLUTTER_ROOT")
        if (environmentSdkPath != null) return@run environmentSdkPath
        throw GradleException("Flutter SDK not found. Define flutter.sdk in local.properties or FLUTTER_ROOT env variable.")
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.1" apply false
    // تغيير إصدار كوتلين ليتوافق 100% مع 8.2.1
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}
include(":app")
