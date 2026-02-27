# Database Configuration Setup

## For New Developers

1. Copy the template file:
   ```bash
   cp src/main/resources/application.properties.template src/main/resources/application.properties
   ```

2. Update the database credentials in `application.properties`:
   ```properties
   spring.datasource.username=your_actual_username
   spring.datasource.password=your_actual_password
   ```

3. Make sure your PostgreSQL database is running and accessible

## Important Notes

- **Never commit `application.properties`** - it contains local database credentials
- The file is already in `.gitignore` to prevent accidental commits
- Use `application.properties.template` as a reference for required properties
- Each developer should have their own local database configuration

## Database Setup

1. Create PostgreSQL database:
   ```sql
   CREATE DATABASE "dsiApp";
   ```

2. Create user (optional):
   ```sql
   CREATE USER your_username WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE "dsiApp" TO your_username;
   ```

3. Update your local `application.properties` with the correct credentials

## Security

- Change the `jwt.secret` to a secure random string in production
- Use environment variables for sensitive configuration in production deployments