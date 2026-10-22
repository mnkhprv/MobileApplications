# Unit Converter

Android (Kotlin/XML) unit converter with a splash screen, searchable two-column category grid, and real-time converter screen.

## Features

- 12 measurement categories: Length, Area, Volume, Mass, Time, Speed, Temperature, Density, Energy, Angle, Weight, and Fuel
- Six or more units per category, except Temperature with Celsius, Fahrenheit, and Kelvin
- Case-insensitive real-time category search
- Live conversion when the value or either unit changes
- Source/target swap action
- Input validation for empty, malformed, negative, extreme, and undefined values
- Pure Kotlin conversion engine using a base-unit model, with affine temperature and reciprocal fuel-economy support
- Local unit tests for every category and unit

## Build and test

1. Open the project in Android Studio with JDK 17 or newer.
2. Let Gradle sync.
3. Run the `app` configuration on an Android 7.0 (API 24) or newer device/emulator.

From the project directory on Windows:

```powershell
.\gradlew.bat testDebugUnitTest assembleDebug
```

The debug APK is generated under `app/build/outputs/apk/debug/`.
