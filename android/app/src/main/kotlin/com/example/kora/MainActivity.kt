// MainActivity.kt

package com.example.kora // adjust to your actual package

import io.flutter.embedding.android.FlutterFragmentActivity
// NOT: import io.flutter.embedding.android.FlutterActivity

// FIX: must extend FlutterFragmentActivity, not FlutterActivity.
// The health package's Health Connect permission launcher registration
// (PermissionController.createRequestPermissionResultContract()) requires
// FragmentActivity-specific APIs that plain FlutterActivity/ComponentActivity
// doesn't expose. This is almost certainly why "Permission launcher not
// found" persists even with correct configure() timing.
class MainActivity : FlutterFragmentActivity()