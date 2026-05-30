buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") } // إضافة ضرورية لحل نقص الملفات
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
