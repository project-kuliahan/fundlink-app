# Fundlink Mobile App Integration Guide

## Authentication Flow Implementation

### 1. Token Management Class

```dart
// Flutter/Dart
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Save token securely
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user data
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // Get stored user
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    return userJson != null ? jsonDecode(userJson) : null;
  }

  // Clear all auth data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
```

### 2. HTTP Client with Automatic Token Handling

```dart
class ApiClient {
  static const String baseUrl = 'https://bahamud.my.id/api';
  final AuthService _authService = AuthService();

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 401:
        // Token expired or invalid
        _authService.logout();
        throw UnauthorizedException('Session expired. Please login again.');
      case 422:
        final errors = jsonDecode(response.body);
        throw ValidationException(errors['errors'] ?? errors['message']);
      case 429:
        throw RateLimitException('Too many requests. Please try again later.');
      case 500:
        throw ServerException('Server error. Please try again later.');
      default:
        throw ApiException('Something went wrong. Status: ${response.statusCode}');
    }
  }
}
```

### 3. Login Implementation

```dart
class LoginViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.post('/login', {
        'email': email,
        'password': password,
      });

      // Save token and user data
      await _authService.saveToken(response['token']);
      await _authService.saveUser(response['user']);

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
```

### 4. Dashboard Data Fetching

```dart
class DashboardViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiClient.get('/dashboard');
      _dashboardData = data;
    } catch (e) {
      _error = e.toString();
      if (e is UnauthorizedException) {
        // Handle token expiration - redirect to login
        // Navigation logic here
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 5. Transaction Management

```dart
class TransactionViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  bool _hasMorePages = true;
  int _currentPage = 1;
  String? _error;

  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _hasMorePages;
  String? get error => _error;

  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _transactions.clear();
      _hasMorePages = true;
    }

    if (!_hasMorePages || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/transactions?page=$_currentPage');

      final newTransactions = List<Map<String, dynamic>>.from(response['data']);
      _transactions.addAll(newTransactions);

      _currentPage++;
      _hasMorePages = response['current_page'] < response['last_page'];

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction({
    required Map<String, String> data,
    File? attachment,
  }) async {
    try {
      final token = await _authService.getToken();
      var request = http.MultipartRequest('POST', Uri.parse('${ApiClient.baseUrl}/transactions'));
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields.addAll(data);

      if (attachment != null) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment', attachment.path)
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Refresh transactions after creating new one
        await loadTransactions(refresh: true);
        return true;
      } else {
        _error = 'Failed to create transaction: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
```

## Error Handling Classes

```dart
// Custom Exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;
  ValidationException(this.errors) : super('Validation failed');

  @override
  String toString() {
    return errors.values.expand((e) => e).join('\n');
  }
}

class RateLimitException extends ApiException {
  RateLimitException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}
```

## Network Connectivity Handling

```dart
class NetworkService {
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<T> executeWithRetry<T>(
    Future<T> Function() operation,
    int maxRetries = 3,
  ) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= maxRetries) {
          rethrow;
        }

        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }

    throw Exception('Max retries exceeded');
  }
}
```

## App Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final authService = AuthService();
  final apiClient = ApiClient();

  // Check if user is already logged in
  final isAuthenticated = await authService.isAuthenticated();

  runApp(MyApp(
    isAuthenticated: isAuthenticated,
    authService: authService,
    apiClient: apiClient,
  ));
}
```

## Production Considerations

### 1. Environment Configuration
```dart
class Config {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    return isProduction
        ? 'https://bahamud.my.id/api'
        : 'http://10.0.2.2:8000/api'; // Android emulator
  }
}
```

### 2. SSL Certificate Handling
```dart
class HttpOverridesService {
  static void setup() {
    HttpOverrides.global = MyHttpOverrides();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow only specific certificates in production
        return Config.isProduction ? false : true;
      };
  }
}
```

### 3. Logging and Monitoring
```dart
class Logger {
  static void logApiCall(String endpoint, int statusCode, [String? error]) {
    if (Config.isProduction) {
      // Send to monitoring service (Firebase Crashlytics, Sentry, etc.)
      FirebaseCrashlytics.instance.recordError(
        error ?? 'API Error',
        null,
        information: [endpoint, statusCode.toString()],
      );
    } else {
      print('API Call: $endpoint - Status: $statusCode - Error: $error');
    }
  }
}
```

## Testing Production API

### Unit Tests
```dart
void main() {
  group('API Integration Tests', () {
    late ApiClient apiClient;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiClient = ApiClient()..client = mockClient; // Inject mock client
    });

    test('Login success', () async {
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
                '{"token": "test_token", "user": {"id": 1}}',
                200,
              ));

      final result = await apiClient.post('/login', {
        'email': 'test@example.com',
        'password': 'password',
      });

      expect(result['token'], 'test_token');
    });
  });
}
```

This implementation provides a robust foundation for mobile app integration with proper error handling, token management, and production-ready features.
