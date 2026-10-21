// AGP 9-д Kotlin суурилагдсан (built-in Kotlin) тул kotlin-android plugin шаардлагагүй.
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.compose) apply false
    alias(libs.plugins.ksp) apply false
}
