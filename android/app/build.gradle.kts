plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // تثبيت البناء على الإصدار 34 الآمن والمتوافق تماماً مع حاوية GitHub الافتراضية
    compileSdk = 34 

    defaultConfig {
        // تحديد هدف النظام رقم 34 لضمان عمل التطبيق بكفاءة
        targetSdk = 34
        
        // هنا تترك الإعدادات الافتراضية الخاصة بك مثل applicationId و minSdkVersion و versionCode و versionName
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
