import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class SessionManager {
  static const _sessionKey = 'session';
  static const _sessionTimeKey = 'sessionTime';
  static const _sessionDuration = Duration(minutes: 5);

  Future<void> saveSession(String sessionData) async {
    final sessionTime = DateTime.now().toIso8601String();

    if (kIsWeb) {
      html.window.sessionStorage[_sessionKey] = sessionData; // Use sessionStorage instead of localStorage
      html.window.sessionStorage[_sessionTimeKey] = sessionTime; // Use sessionStorage instead of localStorage
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, sessionData);
      await prefs.setString(_sessionTimeKey, sessionTime);
    }
  }

  Future<String?> retrieveSession() async {
    String? sessionData;
    String? sessionTime;

    if (kIsWeb) {
      sessionData = html.window.sessionStorage[_sessionKey]; // Use sessionStorage instead of localStorage
      sessionTime = html.window.sessionStorage[_sessionTimeKey]; // Use sessionStorage instead of localStorage
    } else {
      final prefs = await SharedPreferences.getInstance();
      sessionData = prefs.getString(_sessionKey);
      sessionTime = prefs.getString(_sessionTimeKey);
    }

    if (sessionData != null && sessionTime != null) {
      final sessionDateTime = DateTime.parse(sessionTime);
      final currentTime = DateTime.now();

      if (currentTime.difference(sessionDateTime) <= _sessionDuration) {
        return sessionData;
      } else {
        // The session has expired
        if (kIsWeb) {
          html.window.sessionStorage.remove(_sessionKey); // Use sessionStorage instead of localStorage
          html.window.sessionStorage.remove(_sessionTimeKey); // Use sessionStorage instead of localStorage
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_sessionKey);
          await prefs.remove(_sessionTimeKey);
        }
      }
    }

    return null;
  }
}