plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.edobashiri"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.edobashiri"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.activity:activity-ktx:1.9.3")

    // ===== AdMob（今後導入予定）=====
    // 下記1行のコメントを外し、AndroidManifest と MainActivity の AdMob 節を有効化するだけで
    // バナー／インタースティシャルが使えます。手順は android/ADMOB_SETUP.md 参照。
    // implementation("com.google.android.gms:play-services-ads:23.6.0")
}
