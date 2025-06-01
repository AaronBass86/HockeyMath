import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class MapsService {
  static const String _apiKey = 'AIzaSyDkzV3HRQAAOF0skWtB3qCDmw2JG0-7R2w';
  
  static Future<Map<String, dynamic>> getDirections(String destination, {List<String>? stops}) async {
    // TODO: Replace with actual Google Maps API call
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    if (stops == null || stops.isEmpty) {
      // Direct route without stops
      return {
        'distance': '7.8 miles',
        'duration': '16 minutes',
        'durationValue': 16 * 60, // in seconds
      };
    } else {
      // Simulate more realistic data for Chicago locations
      bool hasChicagoStop = stops.any((stop) => 
        stop.toLowerCase().contains('chicago') || 
        stop.toLowerCase().contains('dearborn')
      );

      if (hasChicagoStop) {
        // Approximate distance from Chicago to Willowbrook
        const baseDistance = 22.5; // miles
        const baseDuration = 45; // minutes (without traffic)

        // Add extra distance/time for each additional stop
        final extraDistance = (stops.length - 1) * 1.5;
        final extraDuration = (stops.length - 1) * 5;

        return {
          'distance': '${(baseDistance + extraDistance).toStringAsFixed(1)} miles',
          'duration': '${baseDuration + extraDuration} minutes',
          'durationValue': (baseDuration + extraDuration) * 60, // in seconds
        };
      } else {
        // Local stops (non-Chicago)
        final extraDistance = stops.length * 1.5;
        final extraDuration = stops.length * 5;

        return {
          'distance': '${(7.8 + extraDistance).toStringAsFixed(1)} miles',
          'duration': '${16 + extraDuration} minutes',
          'durationValue': (16 + extraDuration) * 60, // in seconds
        };
      }
    }
  }
} 