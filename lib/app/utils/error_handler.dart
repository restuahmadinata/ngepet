import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Global error handler and debugger utility
/// Provides centralized error logging and user feedback
class ErrorHandler {
  // Singleton pattern
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Log errors to console in debug mode
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔴 ERROR in $context');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack Trace:');
        print(stackTrace);
      }
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// Log info messages in debug mode
  static void logInfo(String context, String message) {
    if (kDebugMode) {
      print('ℹ️ [$context] $message');
    }
  }

  /// Log success messages in debug mode
  static void logSuccess(String context, String message) {
    if (kDebugMode) {
      print('✅ [$context] $message');
    }
  }

  /// Log warning messages in debug mode
  static void logWarning(String context, String message) {
    if (kDebugMode) {
      print('⚠️ [$context] $message');
    }
  }

  /// Show error snackbar to user
  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// Show success snackbar to user
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  /// Show info snackbar to user
  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  /// Show warning snackbar to user
  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.warning_outlined, color: Colors.white),
    );
  }

  /// Handle Firebase errors with user-friendly messages
  static void handleFirebaseError(String context, dynamic error) {
    logError(context, error);

    String userMessage = 'An error occurred. Please try again.';

    // Convert error to string for pattern matching
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network')) {
      userMessage = 'Network error. Please check your internet connection.';
    } else if (errorString.contains('permission')) {
      userMessage = 'Permission denied. You may not have access to this resource.';
    } else if (errorString.contains('not found') || errorString.contains('not-found')) {
      userMessage = 'Resource not found.';
    } else if (errorString.contains('already exists')) {
      userMessage = 'This item already exists.';
    } else if (errorString.contains('timeout')) {
      userMessage = 'Request timeout. Please try again.';
    } else if (errorString.contains('unauthorized') || errorString.contains('unauthenticated')) {
      userMessage = 'Please login to continue.';
    }

    showError(
      title: 'Error',
      message: userMessage,
    );
  }

  /// Show loading dialog
  static void showLoading({String message = 'Please wait...'}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dismissal by back button
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? Colors.blue,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Detailed error report for debugging
  static String generateErrorReport(String context, dynamic error, [StackTrace? stackTrace]) {
    final buffer = StringBuffer();
    buffer.writeln('ERROR REPORT');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Context: $context');
    buffer.writeln('Timestamp: ${DateTime.now()}');
    buffer.writeln('Error: $error');
    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace);
    }
    buffer.writeln('═══════════════════════════════════════');
    return buffer.toString();
  }

  /// Copy error report to clipboard (for user to share with developer)
  static void copyErrorReport(String context, dynamic error, [StackTrace? stackTrace]) {
    final report = generateErrorReport(context, error, stackTrace);
    
    // In a real app, you would copy to clipboard
    // For now, just log it
    if (kDebugMode) {
      print(report);
    }
    
    showInfo(
      title: 'Error Report',
      message: 'Error details have been logged. Please share console output with the developer.',
      duration: const Duration(seconds: 5),
    );
  }
}
