# Flutter Authentication Flow Documentation  

This documentation explains how to implement the **authentication flow** in a Flutter mobile application, including sending OTP, validating OTP, signing up, logging in, and managing JWT tokens using **Secure Storage**.

---

## **Folder Structure**  

```
lib/
├── components/
│   ├── auth/
│   │   ├── login.dart         // Login screen
│   │   ├── signup.dart        // Signup screen
│   │   ├── otp_validation.dart // OTP validation screen
├── services/
│   ├── auth_service.dart      // API services for authentication
│   └── secure_storage.dart    // Secure storage utility for JWT
├── models/
│   └── user_model.dart        // User data model
├── stores/
│   └── auth_store.dart        // State management for authentication
```

---

## **Authentication Flow Overview**

### **1. Signup Process**
- **File**: `lib/components/auth/signup.dart`  
- **Flow**:  
  1. Collect `username`, `email`, `password`, and `confirmPassword` from the user.  
  2. Call the `signup` function from `auth_service.dart`.  
  3. On success:  
     - Send OTP to the user's email.  
     - Navigate to the OTP validation screen.

---

### **2. Sending OTP**
- **File**: `lib/services/auth_service.dart`  
- **Flow**:  
  1. Trigger the `/api/auth/send-otp` endpoint with the user's email.  
  2. Display a toast or snackbar notifying the user that the OTP was sent.

---

### **3. OTP Validation**
- **File**: `lib/components/auth/otp_validation.dart`  
- **Flow**:  
  1. Collect the OTP input from the user.  
  2. Call the `validateOtp` function from `auth_service.dart`, passing the OTP and associated user email.  
  3. If valid, complete the signup process and store the JWT.

---

### **4. Login Process**
- **File**: `lib/components/auth/login.dart`  
- **Flow**:  
  1. Collect `email/username` and `password` from the user.  
  2. Call the `login` function from `auth_service.dart`.  
  3. On success:  
     - Store the JWT in **Secure Storage**.  
     - Navigate to the app's dashboard or home screen.  

---

## **Services**

### **1. Authentication Service** (`auth_service.dart`)  
Handles API requests for signup, login, OTP sending, and validation.

- **Signup**:
  ```dart
  Future<void> signup(String username, String email, String password) async {
    final response = await postRequest('/api/auth/signup', {
      "username": username,
      "email": email,
      "password": password,
    });
    if (response.isSuccess) {
      // Send OTP or handle post-signup flow
    } else {
      throw Exception(response.errorMessage);
    }
  }
  ```

- **Login**:
  ```dart
  Future<void> login(String identifier, String password) async {
    final response = await postRequest('/api/auth/login', {
      "identifier": identifier,
      "password": password,
    });
    if (response.isSuccess) {
      // Save JWT securely
    } else {
      throw Exception(response.errorMessage);
    }
  }
  ```

- **Send OTP**:
  ```dart
  Future<void> sendOtp(String email) async {
    final response = await postRequest('/api/auth/send-otp', {"email": email});
    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }
  }
  ```

- **Validate OTP**:
  ```dart
  Future<void> validateOtp(String email, String otp) async {
    final response = await postRequest('/api/auth/validate-otp', {
      "email": email,
      "otp": otp,
    });
    if (!response.isSuccess) {
      throw Exception(response.errorMessage);
    }
  }
  ```

---

### **2. Secure Storage Utility** (`secure_storage.dart`)  
Utility for securely storing JWT tokens using **Flutter Secure Storage**.

- **Save JWT**:
  ```dart
  Future<void> saveJwt(String jwt) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'jwt', value: jwt);
  }
  ```

- **Retrieve JWT**:
  ```dart
  Future<String?> getJwt() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'jwt');
  }
  ```

- **Delete JWT**:
  ```dart
  Future<void> deleteJwt() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt');
  }
  ```

---

## **Screens Workflow**

### **Signup Screen**
- Collect `username`, `email`, and `password`.
- Call `signup`:
  ```dart
  await AuthService().signup(username, email, password);
  Navigator.push(context, MaterialPageRoute(builder: (_) => OtpValidationScreen()));
  ```
- Handle success or error responses.

---

### **OTP Validation Screen**
- Collect `otp` from the user.
- Call `validateOtp`:
  ```dart
  await AuthService().validateOtp(email, otp);
  Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
  ```
- Handle validation success or retry limit errors.

---

### **Login Screen**
- Collect `identifier` and `password`.
- Call `login`:
  ```dart
  await AuthService().login(identifier, password);
  Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
  ```
- Handle authentication success or error responses.

---

## **State Management** (`auth_store.dart`)  
Use a state management solution like **Provider**, **Riverpod**, or **GetX** to manage user and authentication states across the app.

### **User Model** (`user_model.dart`)  
Define a `User` class to store user details:  
```dart
class User {
  final String id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}
```

---

## **Final Notes**  
1. Ensure API communication uses HTTPS for secure data transmission.  
2. Use **Flutter Secure Storage** for securely managing sensitive data.  
3. Add error handling for API requests to provide a better user experience.  
4. Implement retry logic for OTP validation with a backend-enforced retry limit.