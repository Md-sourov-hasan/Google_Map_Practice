# API Key Security Setup Guide

## Problem
Your Google Maps API key is exposed in source code:
```
lib/const/google_map_key.dart
```

Anyone can extract it from APK/GitHub and drain your quota.

---

## Immediate Action: Restrict Your Current Key

### Step 1: Go to GCP Console
1. Open https://console.cloud.google.com
2. Go to **APIs & Services** → **Credentials**
3. Find key: `AIzaSyBv5ZleG1nnsiUn-YSSXeZ9MFzFYztimug`

### Step 2: Set Application Restrictions

#### For Android:
1. Click the key
2. Go to **Application restrictions**
3. Select **Android apps**
4. Click **ADD AN ITEM**
5. Enter your package name (in `android/app/build.gradle`)
   - Example: `com.your_company.app`
6. Enter your **SHA-1 certificate fingerprint**

**Get SHA-1:**
```bash
cd android
./gradlew signingReport
```

#### For iOS:
1. Go to **Application restrictions**
2. Select **iOS apps**
3. Enter your **Bundle ID** (in `ios/Runner/Info.plist`)

#### For Web:
1. Go to **API restrictions**
2. Select **Maps SDK**
3. Add your domain:
   - Example: `yourdomain.com`
   - Development: `localhost`

### Step 3: Remove from Source Code

**Before committing, delete:**
```dart
// lib/const/google_map_key.dart - DELETE THIS FILE
```

---

## Recommended: Use Firebase for API Key Management

### Option A: Firebase Remote Config (Best)

1. Go to Firebase Console → Remote Config
2. Create parameter: `google_maps_api_key`
3. Set value to your API key
4. Update app to fetch from Firebase:

```dart
// lib/const/google_map_key.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';

class GoogleMapKey {
  static Future<String> getGmaKey() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getString('google_maps_api_key');
  }
}
```

### Option B: Backend Server (Most Secure)

Create endpoint on your backend:
```
GET /api/maps-key
Returns: { "key": "AIzaSy..." }
```

Then fetch in app:
```dart
class GoogleMapKey {
  static Future<String> getGmaKey() async {
    final response = await http.get(Uri.parse('YOUR_BACKEND/api/maps-key'));
    return jsonDecode(response.body)['key'];
  }
}
```

---

## Quick Checklist

- [ ] Restricted API key to Android app only
- [ ] Added SHA-1 certificate fingerprint
- [ ] Removed key from source code
- [ ] Set up billing alerts ($100 limit)
- [ ] Deleted `google_map_key.dart` from repository
- [ ] Added file to `.gitignore`:
  ```
  lib/const/google_map_key.dart
  ```

---

## Estimated Time per User

| Action | Time |
|--------|------|
| Set API restrictions | 5 min |
| Get SHA-1 fingerprint | 2 min |
| Remove from code | 2 min |
| Set up billing alerts | 3 min |
| **Total** | **12 min** |

---

## Verify It Works

1. Run app: `flutter run`
2. Open Google Maps screen
3. Check map loads normally
4. Go to GCP Console → Maps API usage
5. Verify calls are being counted

---

## Reference Links

- **Secure Keys**: https://cloud.google.com/docs/authentication/api-keys
- **API Restrictions**: https://cloud.google.com/docs/authentication/restrict-public-api-key
- **Android SHA-1**: https://developers.google.com/android/guides/client-auth
- **Firebase Remote Config**: https://firebase.google.com/docs/remote-config

*Recommended Action: Complete all steps within 24 hours*
