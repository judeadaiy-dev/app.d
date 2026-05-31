plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // 💡 هذا هو السطر السحري المطلوب لحل مشكلة الـ Namespace
    // استبدل com.example.chatapp بمعرّف تطبيقك الفعلي إذا كان مختلفاً
    namespace = "com.judeadaiy.chat_app"

    compileSdk = 34 

    defaultConfig {
        // تأكد من وجود نفس المعرّف هنا أيضاً
        applicationId = "com.example.chatapp"
        
        targetSdk = 34
        minSdk = 23
        
        // ... يمكنك ترك الـ versionCode والـ versionName كما هي لديك
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
