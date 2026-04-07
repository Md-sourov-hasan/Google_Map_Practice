# Google Maps API Cost Documentation

## Overview
This Flutter app uses Google Maps SDK to display current location on Android, iOS, and Web platforms.

---

## API Billing Breakdown

### Current Implementation
- **SKU**: Maps SDK (Dynamic Maps Loads)
- **Trigger**: Every time `GoogleMap` widget loads
- **Free Tier**: First 10,000 loads/month

### Pricing (Pay-as-you-go)
| Monthly Loads | Price per 1,000 | Cost per Load |
|--------------|-----------------|--------------|
| 1 - 10,000 | $0 | $0 (FREE) |
| 10,001 - 100,000 | $7.00 | $0.007 |
| 100,001 - 500,000 | $5.60 | $0.0056 |
| 500,001 - 5M | $4.20 | $0.0042 |
| 5M+ | $0.53 | $0.00053 |

---

## Cost Examples (20,000 Users)

### Scenario 1: Users open app 1x/day
```
Daily Loads: 20,000
Monthly Loads: 600,000
Monthly Cost: $3,290
Annual Cost: $39,480
```

### Scenario 2: Users open app 5x/day
```
Daily Loads: 100,000
Monthly Loads: 3,000,000
Monthly Cost: $13,370
Annual Cost: $160,440
```

### Scenario 3: Subscription Plan
| Plan | Monthly | Included Calls |
|------|---------|-----------------|
| Starter | $100 | 50,000 |
| Essentials | $275 | 100,000 |
| Pro | $1,200 | 250,000 |

---

## Current Files

### Core Implementation
- **Main Screen**: `lib/current_adress/google_maps_screen.dart`
- **API Key**: `lib/const/google_map_key.dart` ⚠️ **EXPOSED**
- **Dependencies**: `pubspec.yaml`

### Key Components
1. **GoogleMapController** - Controls map interactions
2. **LatLng** - Current user location
3. **Marker** - Shows current position
4. **Geolocator** - Gets device location (NO API COST)

---

## ⚠️ Security Issues

### Current Risk
```dart
// lib/const/google_map_key.dart
class GoogleMapKey {
  static const String gmaKey = 'AIzaSyBv5ZleG1nnsiUn-YSSXeZ9MFzFYztimug';
}
```

**Problem**: API key is visible in:
- Source code (GitHub)
- APK/IPA files
- Anyone can extract and misuse

### Solution
1. **Set API Key Restrictions** in Google Cloud Console:
   - Android apps only
   - iOS apps only
   - Web domains only

2. **Remove from code** (for production):
   - Use Firebase Remote Config
   - Backend server (recommended)
   - Environment variables

---

## Optimization Tips

### 1. Reduce API Calls
```dart
// ❌ Bad: Reloading map unnecessarily
void _loadCurrentLocation() {
  setState(() {
    _isFetchingLocation = true;
  });
  // Map reloads = API charge
}

// ✅ Good: Cache location, show cached map
void _loadCurrentLocationOnce() {
  if (_currentLatLng != null) return; // Skip if already loaded
  // Only load once
}
```

### 2. Disable Web/Desktop if not needed
In `pubspec.yaml`, comment out unnecessary platforms:
```yaml
# web/    # Disable if not using
# linux/  # Disable if not using
# windows/ # Disable if not using
```

### 3. Use Static Maps for simple cases
- Don't need interactive map?
- Use Static Maps API (cheaper)
- Cost: $2.00 per 1,000 loads (vs $7.00)

---

## Monthly Cost Estimates

| Users | Daily Opens | Monthly Cost | Annual |
|-------|------------|-------------|--------|
| 1,000 | 1x | $165 | $1,980 |
| 1,000 | 5x | $825 | $9,900 |
| 5,000 | 1x | $822 | $9,864 |
| 10,000 | 1x | $1,645 | $19,740 |
| **20,000** | **1x** | **$3,290** | **$39,480** |
| 20,000 | 5x | $13,370 | $160,440 |

---

## Next Steps

### Priority 1: Security
- [ ] Set API key restrictions in GCP
- [ ] Remove key from source code
- [ ] Use environment variables

### Priority 2: Cost Control
- [ ] Set up billing alerts in GCP
- [ ] Monitor usage in Cloud Console
- [ ] Consider subscription plan if >250K calls/month

### Priority 3: Optimization
- [ ] Implement map caching
- [ ] Reduce unnecessary reloads
- [ ] Use subscription plan for predictable costs

---

## GCP Console Links

1. **Check Usage**: https://console.cloud.google.com/billing/reports
2. **Set Alerts**: https://console.cloud.google.com/billing/alerting
3. **API Keys**: https://console.cloud.google.com/apis/credentials
4. **Maps Platform**: https://console.cloud.google.com/google/maps-apis

---

## Contact & Support

- **Pricing Questions**: https://mapsplatform.google.com/contact-us/
- **Billing Issues**: https://cloud.google.com/support
- **Quotas**: 100,000 requests/second from GCP

---

*Last Updated: April 7, 2026*  
*Documentation Version: 1.0*
