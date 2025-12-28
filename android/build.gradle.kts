plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.research_driven_time_scheduler_mobile_app"
    compileSdk = 34  // Updated to 34 for Android 13+
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.research_driven_time_scheduler_mobile_app"
        minSdk = 21  // Minimum for flutter_local_notifications
        targetSdk = 34  // Updated for Android 13+
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Required for notifications
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // No additional dependencies needed - flutter_local_notifications handles it
}