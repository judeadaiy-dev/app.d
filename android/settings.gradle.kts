pluginManagement {
    val flutterSdkPath = rootProject.projectDir.absolutePath + "/flutter" // مسار افتراضي
    
    // محاولة قراءة مسار فلاتر من ملف local.properties
    val properties = java.util.Properties()
    val localProperties = file("local.properties")
    if (localProperties.exists()) {
        localProperties.inputStream().use { properties.load(it) }
    }
    val flutterSdk = properties.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
    
    if (flutterSdk != null) {
        includeBuild("$flutterSdk/packages/flutter_tools/gradle")
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}
include(":app")
