plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // معرّف التطبيق الفريد
    namespace = "com.example.chatapp"

    // إصدار تجميع الأندرويد المطلوب من قبل الحزم الحديثة
    compileSdk = 36 

    // إصدار أدوات التطوير المحددة والمطلوبة في سجل البناء
    ndkVersion = "28.2.13676358"

    defaultConfig {
        // معرّف الحزمة للتطبيق
        applicationId = "com.example.chatapp"
        
        // الحد الأدنى لدعم نظام أندرويد (Android 5.0)
        minSdk = 23
        
        // الإصدار المستهدف للتوافق مع الأنظمة الحديثة
        targetSdk = 36
        
        // يمكنك إبقاء أرقام الإصدارات الافتراضية الخاصة بك هنا إذا رغبت
        versionCode = 1
        versionName = "1.0.0"
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
    // مكتبة دعم الميزات الحديثة على إصدارات أندرويد القديمة
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
