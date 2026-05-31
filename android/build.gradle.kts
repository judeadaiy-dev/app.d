buildscript {
    ext.kotlin_version = '1.9.0' // تأكدي من توافق هذا الإصدار
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // هذا السطر هو الذي كان مفقوداً!
        classpath 'com.android.tools.build:gradle:8.1.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
