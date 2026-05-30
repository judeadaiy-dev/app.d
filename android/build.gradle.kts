// إعدادات المستودعات الأساسية
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// مسح المجلدات القديمة عند إعادة البناء
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
