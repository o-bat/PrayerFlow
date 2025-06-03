import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Requests location permission with proper error handling and user guidance
  static Future<LocationPermissionResult> requestLocationPermissionSafely(
    BuildContext context, {
    String? customTitle,
    String? customMessage,
  }) async {
    try {
      // Check current permission status
      final status = await Permission.location.status;

      if (status.isGranted) {
        return LocationPermissionResult.granted;
      }

      // If permission was previously denied permanently
      if (status.isPermanentlyDenied) {
        if (!context.mounted) return LocationPermissionResult.error;
        return await _handlePermanentlyDenied(context);
      }

      // Show explanation dialog first (following Android/iOS guidelines)
      if (!context.mounted) return LocationPermissionResult.error;

      // Add small delay to ensure dialog is fully dismissed
      await Future.delayed(const Duration(milliseconds: 300));

      // Request the permission
      final result = await Permission.location.request();

      return _mapPermissionStatus(result);
    } catch (e) {
      log('Error requesting location permission: $e');
      return LocationPermissionResult.error;
    }
  }

  /// Check if location services are enabled on the device
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Permission.location.serviceStatus.isEnabled;
    } catch (e) {
      log('Error checking location service status: $e');
      return false;
    }
  }

  /// Get current location permission status
  static Future<LocationPermissionResult> getPermissionStatus() async {
    try {
      final status = await Permission.location.status;
      return _mapPermissionStatus(status);
    } catch (e) {
      log('Error getting permission status: $e');
      return LocationPermissionResult.error;
    }
  }

  /// Handle the case when permission is permanently denied
  static Future<LocationPermissionResult> _handlePermanentlyDenied(
    BuildContext context,
  ) async {
    if (!context.mounted) return LocationPermissionResult.error;

    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission has been permanently denied. '
          'Please enable it in Settings to use location-based features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      final opened = await openAppSettings();
      if (opened) {
        return LocationPermissionResult.openedSettings;
      }
    }

    return LocationPermissionResult.permanentlyDenied;
  }

  /// Map PermissionStatus to our custom result enum
  static LocationPermissionResult _mapPermissionStatus(
    PermissionStatus status,
  ) {
    switch (status) {
      case PermissionStatus.granted:
        return LocationPermissionResult.granted;
      case PermissionStatus.denied:
        return LocationPermissionResult.denied;
      case PermissionStatus.restricted:
        return LocationPermissionResult.restricted;
      case PermissionStatus.limited:
        return LocationPermissionResult.limited;
      case PermissionStatus.permanentlyDenied:
        return LocationPermissionResult.permanentlyDenied;
      case PermissionStatus.provisional:
        return LocationPermissionResult.provisional;
    }
  }
}

/// Enum for location permission results
enum LocationPermissionResult {
  granted,
  denied,
  restricted,
  limited,
  permanentlyDenied,
  provisional,
  openedSettings,
  error,
}

/// Extension to make working with results easier
extension LocationPermissionResultExtension on LocationPermissionResult {
  bool get isGranted => this == LocationPermissionResult.granted;
  bool get isDenied => this == LocationPermissionResult.denied;
  bool get isPermanentlyDenied =>
      this == LocationPermissionResult.permanentlyDenied;
  bool get canRequestAgain => this == LocationPermissionResult.denied;
}
