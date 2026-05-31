plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // تحديث رقم التجميع والتعرف إلى الإصدار 36 المتوافق مع حزمك الحالية
    compileSdk = 36 

    defaultConfig {
        // تحديد الإصدار المستهدف 36 ليتوافق مع تحديثات النظام ومكتبات أندرويد المستوردة
        targetSdk = 36
        
        // ... الإعدادات الافتراضية الخاصة بك تترك هنا مثل applicationId و minSdkVersion
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
} // تم إغلاق قوس الـ android هنا بشكل برمجي صحيح

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
