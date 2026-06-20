import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.dsl.LibraryExtension
import com.android.build.gradle.BaseExtension

plugins {
    id("com.google.gms.google-services") version "4.5.0" apply false
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.5.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { androidExt ->
            when (androidExt) {
                is ApplicationExtension -> androidExt.compileSdk = 36
                is LibraryExtension -> androidExt.compileSdk = 36
                is BaseExtension -> androidExt.compileSdkVersion = "android-36"
            }
        }
    }
}
