# GALA Mobile application

Generic mobile application for a social media platform.

## Technologies
Flutter for cross-platform mobile development (iOS and Android)

## APIs
API specifications are found in the API folder. They are a Postman export file.
Analyze this in detail to undestand the API structure, endpoints and the response logic

## Features

### User registration and authentication with OPT on email

On the first page of the application, the user is asked to register or login with OPT.
Two options: create account or login

#### User clicks on "Create account"
Show a input field for email and a button "Send OPT"
User enters email and clicks on "Send OPT"
Show a message "OPT sent to your email" 
Show a 6 digits OPT code
It must expire in 60 seconds

The api contains a userStatus field that can be used to check if the user is already registered. 1 is registered, 0 is not registered
If the user is already registered, show a message "Email already registered, please login" and show the login page


#### User clicks on "Login"
Show a input field for email and a button "Send OPT"
User enters email and clicks on "Send OPT"
Show a message "OPT sent to your email" 
Show a 6 digits OPT code

If the user is not registered, show a message "Email not registered, please register" and show the registration page

### User profile management
After successful login, the user can access his profile page which will show the email and the fullname.
