buildscript {
    val kotlin_version = "1.9.0"
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
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

// الكود السحري بلغة كوتلين لإجبار مكتبات أندرويد الداخلية على التوافق مع إصدار 34
subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.browser" && requested.name == "browser") {
                useVersion("1.8.0")
            }
            if (requested.group == "androidx.activity") {
                useVersion("1.8.2")
            }
            if (requested.group == "androidx.core") {
                useVersion("1.12.0")
            }
        }
    }
}
