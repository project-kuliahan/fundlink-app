# Fundlink API Documentation

## Production Usage Guide

### Base URL
**Production**: `https://bahamud.my.id/api`
**Development**: `http://127.0.0.1:8000/api`

### HTTPS Requirement
All API requests MUST use HTTPS in production. HTTP requests will be rejected.

### Authentication Flow

#### 1. Login
```http
POST https://bahamud.my.id/api/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password"
}
```

**Success Response (200)**:
```json
{
  "token": "1|abc123def456...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com",
    "role": "user",
    "unit_id": 1,
    "unit": {
      "id": 1,
      "name": "Unit A"
    }
  }
}
```

**Error Response (401)**:
```json
{
  "message": "The provided credentials are incorrect."
}
```

#### 2. Using Token for Authenticated Requests
Include the token in Authorization header for all subsequent requests:

```http
Authorization: Bearer 1|abc123def456...
```

#### 3. Logout
```http
POST https://bahamud.my.id/api/logout
Authorization: Bearer {token}
```

## API Endpoints

### Register
```http
POST https://bahamud.my.id/api/register
Content-Type: application/json

{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "password123"
}
```

**Response**:
```json
{
  "token": "2|xyz...",
  "user": {
    "id": 2,
    "name": "Jane Doe",
    "email": "jane@example.com",
    "role": "user",
    "unit_id": null
  }
}
```

### Dashboard
```http
GET https://bahamud.my.id/api/dashboard
Authorization: Bearer {token}
```

**Response**:
```json
{
  "saldo": 1500000,
  "total_pemasukan": 2000000,
  "total_pengeluaran": 500000,
  "unit": {
    "id": 1,
    "name": "Unit A"
  }
}
```

### Transactions
```http
GET https://bahamud.my.id/api/transactions?page=1
Authorization: Bearer {token}
```

**Response**:
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "type": "pemasukan",
      "amount": 100000,
      "category": "Donasi",
      "description": "Donasi bulan April",
      "transaction_date": "2024-04-01",
      "created_at": "2024-04-01T10:00:00Z"
    }
  ],
  "per_page": 15,
  "total": 50
}
```

### Create Transaction
```http
POST https://bahamud.my.id/api/transactions
Authorization: Bearer {token}
Content-Type: application/json

{
  "type": "pemasukan",
  "amount": 50000,
  "category": "Donasi",
  "description": "Donasi online",
  "transaction_date": "2024-04-15"
}
```

**Response**:
```json
{
  "message": "Transaction recorded successfully",
  "transaction": {
    "id": 2,
    "type": "pemasukan",
    "amount": 50000,
    "category": "Donasi",
    "description": "Donasi online",
    "transaction_date": "2024-04-15",
    "user_id": 1,
    "unit_id": 1
  }
}
```

> [!IMPORTANT]
> **Image Upload in Mobile (Flutter/React Native/Android)**:
> When uploading images (such as `attachment` for transactions, or `photo` for profile updates), you **MUST** use `multipart/form-data` instead of `application/json`.
> Do not send base64 encoded strings for file fields. Send the actual file stream.

### User Profile
```http
GET https://bahamud.my.id/api/user
Authorization: Bearer {token}
```

### Update Profile
```http
POST https://bahamud.my.id/api/user/profile
Authorization: Bearer {token}
Content-Type: multipart/form-data

name=Jane Doe
email=jane@example.com
photo=[FILE_STREAM]
```

### Units (Admin Only)
```http
GET https://bahamud.my.id/api/units
Authorization: Bearer {token}
```

### Users (Admin Only)
```http
GET https://bahamud.my.id/api/users
Authorization: Bearer {token}
```

### Notifications
```http
GET https://bahamud.my.id/api/notifications?page=1
Authorization: Bearer {token}
```

### Mark Notification as Read
```http
POST https://bahamud.my.id/api/notifications/{id}/read
Authorization: Bearer {token}
```

## Mobile App Integration Examples

### Flutter/Dart Example

> [!TIP]
> **Uploading Files with Flutter (MultipartRequest)**
> To upload images to Fundlink APIs, use `http.MultipartRequest` instead of `http.post`.

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  final String baseUrl = 'https://bahamud.my.id/api';
  String? _token;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, redirect to login
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load dashboard');
    }
  }

  // Example: Uploading Transaction with Image
  Future<Map<String, dynamic>> createTransaction({
    required String type,
    required String amount,
    required String category,
    required String description,
    required String transactionDate,
    File? attachment,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('\$baseUrl/transactions'));
    
    // Add Headers
    request.headers.addAll({
      'Authorization': 'Bearer \$_token',
      'Accept': 'application/json',
    });

    // Add Fields
    request.fields['type'] = type;
    request.fields['amount'] = amount;
    request.fields['category'] = category;
    request.fields['description'] = description;
    request.fields['transaction_date'] = transactionDate;

    // Add File
    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath('attachment', attachment.path)
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create transaction: \${response.body}');
    }
  }
}
```

### React Native/JavaScript Example
```javascript
const API_BASE_URL = 'https://bahamud.my.id/api';

class ApiService {
  constructor() {
    this.token = null;
  }

  async login(email, password) {
    try {
      const response = await fetch(`${API_BASE_URL}/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          password,
        }),
      });

      const data = await response.json();

      if (response.ok) {
        this.token = data.token;
        return data;
      } else {
        throw new Error(data.message || 'Login failed');
      }
    } catch (error) {
      throw error;
    }
  }

  async getDashboard() {
    try {
      const response = await fetch(`${API_BASE_URL}/dashboard`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Content-Type': 'application/json',
        },
      });

      if (response.statusCode === 401) {
        // Token expired
        this.token = null;
        throw new Error('Unauthorized');
      }

      return await response.json();
    } catch (error) {
      throw error;
    }
  }
}
```

### Android/Kotlin Example
```kotlin
class ApiService(private val context: Context) {
    private val baseUrl = "https://bahamud.my.id/api"
    private var token: String? = null

    suspend fun login(email: String, password: String, deviceName: String): Result<LoginResponse> {
        return try {
            val requestBody = JSONObject().apply {
                put("email", email)
                put("password", password)
            }

            val response = makeRequest("$baseUrl/login", "POST", requestBody.toString())
            val jsonResponse = JSONObject(response)

            token = jsonResponse.getString("token")
            Result.success(parseLoginResponse(jsonResponse))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getDashboard(): Result<DashboardResponse> {
        return try {
            val response = makeRequest("$baseUrl/dashboard", "GET")
            val jsonResponse = JSONObject(response)
            Result.success(parseDashboardResponse(jsonResponse))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private suspend fun makeRequest(url: String, method: String, body: String? = null): String {
        return withContext(Dispatchers.IO) {
            val connection = URL(url).openConnection() as HttpURLConnection
            connection.requestMethod = method
            connection.setRequestProperty("Content-Type", "application/json")

            token?.let {
                connection.setRequestProperty("Authorization", "Bearer $it")
            }

            body?.let {
                connection.doOutput = true
                connection.outputStream.use { os ->
                    os.write(it.toByteArray())
                }
            }

            val responseCode = connection.responseCode
            if (responseCode == 401) {
                token = null // Clear expired token
            }

            connection.inputStream.bufferedReader().use { it.readText() }
        }
    }
}
```

## Error Handling

### Common HTTP Status Codes
- **200**: Success
- **201**: Created (for POST requests)
- **401**: Unauthorized (invalid/expired token)
- **422**: Validation error
- **429**: Too many requests (rate limited)
- **500**: Server error

### Rate Limiting
- **Limit**: 60 requests per minute per user
- **Headers**: Check `X-RateLimit-Remaining` in response

### Token Expiration
- Tokens are long-lived but can expire
- Handle 401 responses by redirecting to login
- Implement token refresh if needed

## Security Best Practices

1. **Always use HTTPS**
2. **Store tokens securely** (Keychain on iOS, EncryptedSharedPreferences on Android)
3. **Validate SSL certificates**
4. **Handle token expiration gracefully**
5. **Implement proper error handling**
6. **Use certificate pinning** for additional security
7. **Validate all input data**
8. **Log out users on sensitive operations**

## Testing Production API

### Using cURL
```bash
# Login
curl -X POST https://bahamud.my.id/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Get dashboard
curl -X GET https://bahamud.my.id/api/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Using Postman/Thunder Client
1. Set base URL to `https://bahamud.my.id/api`
2. For authenticated requests, add header: `Authorization: Bearer {token}`
3. Test all endpoints before releasing mobile app
