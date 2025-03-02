import 'package:flutter/foundation.dart';
import 'package:pienews/models/service_type.dart';
import 'package:pienews/models/user.dart';
import 'package:pienews/services/api/api_client.dart';
import 'package:pienews/services/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  ApiClient? _apiClient;
  User? _user;
  String? _error;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  ServiceType _currentService = ServiceType.theOldReader;
  final List<Function(ApiClient)> _apiClientListeners = [];

  // Constructor: immediate synchronous initialization
  AuthProvider({ApiClient? apiClient}) : _apiClient = apiClient {
    // Immediately sync login status from ApiClient
    if (_apiClient != null) {
      _isAuthenticated = _apiClient!.isLoggedIn;
      _user = _apiClient!.user;
      _currentService = _apiClient!.serviceType;

      debugPrint(
          'AuthProvider constructor: sync state _isAuthenticated=$_isAuthenticated');
    }

    // Start complete async initialization
    _init();
  }

  void addApiClientListener(Function(ApiClient) listener) {
    _apiClientListeners.add(listener);
  }

  void removeApiClientListener(Function(ApiClient) listener) {
    _apiClientListeners.remove(listener);
  }

  void _notifyApiClientListeners() {
    if (_apiClient != null) {
      for (var listener in _apiClientListeners) {
        listener(_apiClient!);
      }
    }
  }

  Future<void> _init() async {
    if (_apiClient != null) {
      try {
        // Execute complete initialization process
        await _apiClient!.init();

        // Get latest status from ApiClient again
        final wasAuthenticated = _isAuthenticated;
        _isAuthenticated = _apiClient!.isLoggedIn;
        _user = _apiClient!.user;
        _currentService = _apiClient!.serviceType;

        debugPrint(
            'AuthProvider async initialization: auth status=$_isAuthenticated, user=${_user?.email}');

        // Only notify UI updates when status changes
        if (wasAuthenticated != _isAuthenticated) {
          notifyListeners();
        }
      } catch (e) {
        debugPrint('AuthProvider initialization error: $e');
      }
    }
  }

  ApiClient? get apiClient => _apiClient;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  ServiceType get currentService => _currentService;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create new API client
      final newApiClient = await ApiClient.createClient(
        _currentService.serviceId,
        email: email,
        password: password,
      );

      // Execute login
      await newApiClient.login(email, password);

      // Verify login status
      if (!newApiClient.isLoggedIn || newApiClient.token == null) {
        throw Exception(
            'Login failed: Unable to get authentication information');
      }

      // Update state
      _apiClient = newApiClient;
      _isAuthenticated = true;
      _user = newApiClient.user;

      // Make sure to save user email for restoration on next startup
      await newApiClient.saveUserEmail(email);

      // Notify other Provider API clients have been updated
      _notifyApiClientListeners();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient?.clearToken();
      _apiClient = await ApiClient.createClient(_currentService.serviceId);
      _isAuthenticated = false;
      _user = null;

      // Notify other Provider API clients have been updated
      _notifyApiClientListeners();

      // Clean local database
      await DatabaseHelper.instance.clearAllData();

      // Clear all SharedPreferences data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> switchService(ServiceType service) async {
    if (_currentService == service) return;

    try {
      // Save new service type
      await ApiClient.saveServiceType(service);

      // Create new API client
      final newApiClient = await ApiClient.createClient(service.serviceId);

      // Update state
      _currentService = service;
      _apiClient = newApiClient;
      _isAuthenticated = false;
      _user = null;

      // Clean local data
      await DatabaseHelper.instance.clearAllData();

      // Notify other Provider API clients have been updated
      _notifyApiClientListeners();

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
