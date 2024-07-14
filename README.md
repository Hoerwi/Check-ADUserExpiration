# Active Directory User Expiration Check Script

This PowerShell script automates the management of Active Directory user accounts based on expiration dates. It checks for users whose expiration dates have passed and disables their accounts. Additionally, it removes users from specified groups related to Microsoft licenses.

## Prerequisites

- Windows PowerShell (Version 5.1 or higher)
- Active Directory PowerShell Module (Import-Module ActiveDirectory)

## How to Use

1. **Download** or **clone** the repository to your local machine.

2. **Modify Script Variables**:
   - Adjust the `$logFile` variable to specify the path for the log file.
   - Customize the `$disabledOU` variable to specify the target OU where disabled accounts should be moved.

3. **Run the Script**:
   - Open PowerShell with Administrator privileges.
   - Navigate to the directory containing the script (`cd path\to\script`).
   - Execute the script: `.\Check-ADUserExpiration.ps1`.

4. **Review Logs**:
   - Check the specified log file (`$logFile`) for detailed execution logs and errors.

## Script Details

- **Functionality**:
  - Queries AD for users with expiration dates set and are enabled.
  - Disables accounts of users whose expiration dates have passed.
  - Removes users from groups whose names start with "MS-LIC".
  - Moves disabled users to a specified OU (`$disabledOU`).

- **Error Handling**:
  - Logs errors encountered during account disabling and group removal to the log file.
  - Displays error messages in the PowerShell console for immediate feedback.

## Notes

- **Security**: Ensure the script is run by an Administrator with appropriate permissions.
- **Testing**: Test thoroughly in a non-production environment before deploying to production.

## License

This project is licensed under the [MIT License](LICENSE).
