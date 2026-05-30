plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.judeadaiy.chat_app"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.judeadaiy.chat_app"
        minSdk = 23
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }// احذف هذا الجزء تماماً من ملف build.gradle.kts
/*
applicationVariants.all {
    val variant = this
    variant.outputs.all {
        val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
        output.outputFileName = "MyFinalApp.apk"
    }
}
*/


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
