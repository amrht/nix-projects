# Frontend Authentication Flow Documentation (Web - Next.js)

This documentation explains how to implement the **authentication flow** in a Next.js application using your `user-store` for state management and utility functions for signup, login, OTP validation, and JWT storage.

---

## **Folder Structure**

```
src/
├── components/
│   ├── auth/
│   │   ├── Login.js        // Login form component
│   │   ├── Signup.js       // Signup form component
│   │   ├── OtpValidation.js // OTP validation component
├── store/
│   ├── user-store.js       // Zustand store for user management
├── utils/
│   └── requests.js         // API request utility functions
```

---

## **Authentication Flow Overview**

### **1. Signup Process**
- **File**: `src/components/auth/Signup.js`  
- **Flow**:
  1. Collect user details: `username`, `email`, `password`, and `confirmPassword`.
  2. Call `signup` from the `user-store`:
     - If successful, store the JWT in cookies and set the user state.
     - If it fails, display an error message using `react-hot-toast`.

### **2. Sending OTP**
- **File**: `src/components/auth/Signup.js`  
- **Flow**:
  1. After user details are submitted, call the OTP endpoint to send the OTP.
  2. Notify the user that an OTP has been sent to their email.

### **3. OTP Validation**
- **File**: `src/components/auth/OtpValidation.js`  
- **Flow**:
  1. Accept OTP input from the user.
  2. Call the `validateOtp` API with the OTP and associated user details.
  3. If valid, allow the user to complete signup.
  4. Limit retries by managing `trialNumber` on the backend.

### **4. Login Process**
- **File**: `src/components/auth/Login.js`  
- **Flow**:
  1. Collect user credentials: `identifier` (email/username) and `password`.
  2. Call `login` from the `user-store`:
     - If successful, store the JWT in cookies and set the user state.
     - If it fails, display an error message using `react-hot-toast`.

---

## **User Store Functions**

### **1. Signup Function**
- Located in `user-store.js`.  
- Handles:
  - Sending signup data to `/auth/local/register`.
  - Storing the JWT in cookies with a 30-day validity.
  - Updating the Zustand store with user data and login state.

---

### **2. Login Function**
- Located in `user-store.js`.  
- Handles:
  - Authenticating user via `/auth/local`.
  - Storing the JWT in cookies with a 30-day validity.
  - Updating the Zustand store with user data and login state.

---

### **3. OTP Validation**
- Add a new function in `utils/requests.js`:

```js
export const validateOtpRequest = async (email, otp) => {
  return postRequest('/auth/validate-otp', { email, otp });
};
```

- Use this function in the `OtpValidation` component to validate the OTP.

---

## **Components Workflow**

### **Signup Component**
1. Collect `username`, `email`, `password`, and `confirmPassword`.
2. Call `signup`:
   ```js
   useUserStore.getState().signup(data, () => {
     // Redirect to OTP validation screen
   });
   ```
3. On success, send the OTP to the user's email.

---

### **OTP Validation Component**
1. Collect `otp` from the user.
2. Call `validateOtpRequest`:
   ```js
   validateOtpRequest(email, otp).then((res) => {
     if (res.success) {
       toast.success('OTP validated');
       // Redirect to dashboard or further steps
     } else {
       toast.error('Invalid OTP');
     }
   });
   ```
3. Handle retry limits on the backend using `trialNumber`.

---

### **Login Component**
1. Collect `identifier` (email/username) and `password`.
2. Call `login`:
   ```js
   useUserStore.getState().login(data, () => {
     // Redirect to dashboard
   });
   ```
3. Handle success and error states with `react-hot-toast`.

---

## **JWT Token Management**

- JWT tokens are stored using **JS Cookies** with a validity of 30 days:
  ```js
  Cookies.set('jwt', res.data.jwt, { expires: 30, domain: DOMAIN });
  ```
- Remove JWT on logout:
  ```js
  Cookies.remove('jwt', { domain: DOMAIN });
  ```

---

## **Final Notes**
- Use the `user-store` functions directly in your components to manage signup, login, and OTP validation.
- For security:
  - Always validate JWT on the backend.
  - Use HTTPS and secure cookie attributes (`secure: true`, `httpOnly: false`).