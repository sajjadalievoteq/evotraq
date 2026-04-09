import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traqtrace_app/features/user_management/cubit/profile_cubit.dart';
import 'package:http/http.dart' as http;


// Constants for storage keys
const String DARK_MODE_KEY = 'dark_mode_preference';
const String API_ENDPOINT_STATUS_KEY = 'api_endpoint_status';

/// ThemeProvider manages the application's theme state
/// 
/// This provider listens to changes in the ProfileCubit to update
/// the theme across the entire application when the user toggles dark mode
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  late ProfileCubit _profileCubit;
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    // Constructor - sets up listeners for theme changes in ProfileCubit
  ThemeProvider({required ProfileCubit profileCubit}) {
    _profileCubit = profileCubit;
    
    // Initialize theme from ProfileCubit state and fallback to local storage
    _initThemePreference();
    
    // Add subscription to ProfileCubit state changes
    profileCubit.stream.listen((state) {
      if (state.darkMode != _isDarkMode) {
        _isDarkMode = state.darkMode;
        _saveLocalThemePreference(_isDarkMode); // Save to local storage
        notifyListeners();
      }
    });
  }
    // Initialize theme from ProfileCubit and local storage
  Future<void> _initThemePreference() async {
    // First check local storage (that's our source of truth now)
    _isDarkMode = await _getLocalThemePreference();
    
    // If ProfileCubit has a different value and we're connected, sync with it
    try {
      final cubitDarkMode = _profileCubit.state.darkMode;
      if (_isDarkMode != cubitDarkMode) {
        print('Theme sync: Local($_isDarkMode) -> ProfileCubit($cubitDarkMode)');
        _isDarkMode = cubitDarkMode;
        await _saveLocalThemePreference(_isDarkMode);
      }
    } catch (e) {
      print('Using local theme preference due to ProfileCubit error: $e');
      // Already using local preference, so no action needed
    }
    
    // Notify listeners with initial theme
    notifyListeners();
  }
  
  // Get theme preference from local storage
  Future<bool> _getLocalThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(DARK_MODE_KEY) ?? false; // Default to light theme
    } catch (e) {
      print('Error reading theme preference from local storage: $e');
      return false; // Default to light theme if there's an error
    }
  }
  
  // Save theme preference to local storage
  Future<void> _saveLocalThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(DARK_MODE_KEY, isDark);
    } catch (e) {
      print('Error saving theme preference to local storage: $e');
    }
  }  /// Toggle theme method - updates locally first, then tries to sync with server
  Future<void> toggleTheme() async {
    // Toggle the theme
    _isDarkMode = !_isDarkMode;
    
    // Apply changes immediately in this order:
    // 1. Save to local storage
    await _saveLocalThemePreference(_isDarkMode);
    
    // 2. Update the UI
    notifyListeners();
    
    // 3. Try to sync with server in the background (non-blocking)
    // We're intentionally not awaiting this to avoid UI delays
    Future(() async {
      final success = await _syncThemeWithServer();
      if (!success) {
        print('Theme saved locally but server sync failed or was skipped');
      }
    });
  }
    /// Set theme directly
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      // Set the new value
      _isDarkMode = isDark;
      
      // Apply changes immediately in this order:
      // 1. Save to local storage
      await _saveLocalThemePreference(_isDarkMode);
      
      // 2. Update the UI
      notifyListeners();
      
      // 3. Try to sync with server in the background (non-blocking)
      // We're intentionally not awaiting this to avoid UI delays
      Future(() async {
        final success = await _syncThemeWithServer();
        if (!success) {
          print('Theme saved locally but server sync failed or was skipped');
        }
      });
    }
  }
  /// Check if the API endpoint is available
  Future<bool> _isApiEndpointAvailable() async {
    try {
      // Check if we already know the endpoint is unavailable
      final prefs = await SharedPreferences.getInstance();
      // We're not checking the previous status anymore, always assuming it's available
      
      // This bypasses the check for now, so we'll always try to update
      // the theme on the server. Later, implement proper connectivity checks.
      
      // Mark this endpoint as available
      await prefs.setBool(API_ENDPOINT_STATUS_KEY, true);
      
      // Always return true to attempt the API call
      return true;
      
    } catch (e) {
      print('Error checking API endpoint: $e');
      return true; // Still try to make the call
    }
  }
    /// Improved method to sync with server 
  Future<bool> _syncThemeWithServer() async {
    try {
      // Check if API is available before attempting to sync
      if (!(await _isApiEndpointAvailable())) {
        print('API endpoint is unavailable, skipping theme sync');
        return false;
      }
      
      // Attempt to update server via ProfileCubit
      _profileCubit.updateAppPreferences(
        darkMode: _isDarkMode,
        language: _profileCubit.state.language,
      );
      
      print('Sent theme preference update to server: darkMode=$_isDarkMode');
      
      // Listen for the response (scheduled for the next event loop cycle)
      await Future.delayed(const Duration(milliseconds: 50));
      
      // This is a best-effort attempt - we don't actually know if the API call succeeded
      // But the user's theme preference is already applied locally, so it's not critical
      return true;
    } catch (e) {
      print('Error syncing theme with server: $e');
      return false;
    }
  }
  
  /// Refresh theme from current profile state or local storage
  /// Useful when profile is loaded after initial setup
  Future<void> refreshFromProfile() async {
    // First get the local preference as the baseline
    final localPreference = await _getLocalThemePreference();
    
    bool shouldUpdate = false;
    
    try {
      // Try to get from ProfileCubit
      final profileState = _profileCubit.state;
      
      // If server and local disagree, prefer local but log the difference
      if (profileState.darkMode != localPreference) {
        print('Theme mismatch: Server(${profileState.darkMode}) vs Local($localPreference)');
        print('Using local preference as source of truth');
      }
      
      // Only update if our current state differs from the local preference
      if (_isDarkMode != localPreference) {
        _isDarkMode = localPreference;
        shouldUpdate = true;
      }
    } catch (e) {
      print('ProfileCubit error during theme refresh: $e');
      
      // If local differs from current, update to local
      if (_isDarkMode != localPreference) {
        _isDarkMode = localPreference;
        shouldUpdate = true;
      }
    }
    
    // Notify listeners if there was a change
    if (shouldUpdate) {
      notifyListeners();
    }
  }
  
  /// Get the current theme preference - can be called from outside
  /// Returns the current theme mode synchronously
  bool getCurrentThemePreference() {
    return _isDarkMode;
  }
  
  /// Load theme preference from shared preferences
  static Future<bool> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(DARK_MODE_KEY) ?? false;
  }

  /// Save theme preference to shared preferences
  static Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DARK_MODE_KEY, isDarkMode);
  }
  /// Check API availability by sending a request to the server
  /// Returns true if the API is reachable, false otherwise
  static Future<bool> checkApiAvailability(String apiBaseUrl) async {
    try {
      // Use the /health endpoint if it exists, or just use a simple GET to the base URL
      final healthEndpoint = '$apiBaseUrl/health';
      
      final response = await http.get(Uri.parse(healthEndpoint));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // API is reachable
        return true;
      } else {
        // API responded with an error status
        print('API returned status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error checking API availability: $e');
      return false; // Assume API is not available on error
    }
  }
}
