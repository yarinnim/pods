# Keycloak
Keycloak is an open-source identity and access management solution.
It helps applications and services handle authentication and
authorization without writing your own login system.

## To access to keycloak 
 - http://localhost:8080/admin
 - Login with the credentials from .env:
      Username: KEYCLOAK_ADMIN
      Password: KEYCLOAK_ADMIN_PASSWORD

## Creating a Realm

A realm is an isolated domain that contains users, applications, roles, and groups.
  -  Steps to create a new realm:
       1. In the admin console, click “Add Realm”
       2. Provide a name for the realm (e.g., myrealm)
       3. Configure basic options like tokens, sessions, and themes
       4. Save the realm

## Registering Clients (Applications)

Clients are applications that Keycloak protects.

## Defining Roles and Permissions

Roles define permissions for users.

## User Management

Keycloak allows you to manage users:
    - Create users manually:
        1. Navigate to Users → Add User
        2. Fill in details (username, email, etc.)
        3. Set a password under Credentials
