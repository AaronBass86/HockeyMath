# Hockey Math - Store Deployment Checklist

## Google Maps API Setup
- [ ] Configure Google Cloud Console project
  - [ ] Enable required APIs:
    - [ ] Distance Matrix API
    - [ ] Geocoding API
    - [ ] Maps SDK for iOS
    - [ ] Maps SDK for Android
  - [ ] Set up billing account
  - [ ] Configure API quotas and alerts
  - [ ] Create production API key
  - [ ] Set up API key restrictions:
    - [ ] iOS bundle ID
    - [ ] Android package name
    - [ ] Limit to required APIs only

## iOS Deployment
### API Integration
- [ ] Replace simulated Maps service with real API calls in `maps_service.dart`
- [ ] Add Google Maps SDK to iOS project
- [ ] Configure API key in AppDelegate.swift/AppDelegate.m

### Location Services
- [ ] Add location permissions to Info.plist:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Hockey Math needs your location to calculate accurate travel times to the rink.</string>
  ```
- [ ] Configure background location capabilities (if needed)
- [ ] Implement location permission request handling

### App Store Preparation
- [ ] Update app icons
- [ ] Create app privacy policy
- [ ] Complete App Store privacy questionnaire
- [ ] Prepare App Store screenshots
- [ ] Write App Store description
- [ ] Configure TestFlight for beta testing

## Android Deployment
### API Integration
- [ ] Add Google Maps SDK to build.gradle
- [ ] Configure API key in AndroidManifest.xml:
  ```xml
  <meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR-API-KEY"/>
  ```

### Location Services
- [ ] Add location permissions to AndroidManifest.xml:
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  ```
- [ ] Implement runtime permission handling
- [ ] Handle location services enabled/disabled states

### Play Store Preparation
- [ ] Generate release keystore
- [ ] Configure app signing
- [ ] Create feature graphic
- [ ] Prepare Play Store screenshots
- [ ] Write Play Store description
- [ ] Complete Play Store privacy questionnaire
- [ ] Set up internal testing track

## Code Updates
### Maps Service
- [ ] Update `lib/services/maps_service.dart`:
  - [ ] Implement real API calls
  - [ ] Add error handling
  - [ ] Add retry logic
  - [ ] Implement request caching
  - [ ] Add API response validation

### Location Service
- [ ] Create `lib/services/location_service.dart`:
  - [ ] Implement device location access
  - [ ] Handle permission states
  - [ ] Add location error handling
  - [ ] Implement location updates (if needed)

### General
- [ ] Remove all hardcoded values
- [ ] Implement proper error UI
- [ ] Add loading states
- [ ] Add offline support
- [ ] Implement analytics tracking
- [ ] Add crash reporting

## Testing
- [ ] Test with real API integration
- [ ] Test location permissions flow
- [ ] Test offline behavior
- [ ] Test error scenarios
- [ ] Perform battery usage testing
- [ ] Test on multiple iOS devices/versions
- [ ] Test on multiple Android devices/versions
- [ ] Beta test with real users

## Documentation
- [ ] Update README with API setup instructions
- [ ] Document build process
- [ ] Create privacy policy
- [ ] Create terms of service
- [ ] Document known limitations
- [ ] Create support documentation

## Post-Launch
- [ ] Monitor API usage
- [ ] Set up API usage alerts
- [ ] Monitor crash reports
- [ ] Monitor user feedback
- [ ] Plan for updates based on feedback

## Notes
- Keep API key secure and never commit to source control
- Consider implementing API key rotation system
- Monitor battery usage with location services
- Consider implementing caching to reduce API calls
- Plan for API fallback/offline scenarios 