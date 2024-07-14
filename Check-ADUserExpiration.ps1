<#
.SYNOPSIS
    Checks expiration dates of AD users and disables accounts automatically when expiration date is reached.

.DESCRIPTION
    This script queries all user accounts in Active Directory with an expiration date set and automatically disables
    accounts whose expiration date has passed. It also removes users from groups whose names start with "MS-LIC"
    (commonly used for Microsoft licenses like Office, Visio, PowerApps).

    The script must be run in Administrator mode due to its use of Active Directory cmdlets.

.NOTES
    File Name: Check-ADUserExpiration.ps1
    Date     : 2024-07.14
    Version  : 1.0

    Changelog:
    - 1.0: Initial script.

    WARNING:
    - This script will check ALL accounts in the Active Directory. Ensure proper testing and permissions before
      executing in a production environment.

#>

# Import the AD PowerShell module (Required for functionality)
Import-Module ActiveDirectory

# Path to the log file (ADJUST!!!)
$logFile = "\\your\log\path\AD_Disabled_$(Get-Date -Format 'yyyyMMdd').log"

# Function to write to the log file
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    $logMessage | Add-Content -Path $logFile
}

# Log start message
Write-Log "Script started."

# Query all users with an expiration date for their account and are not disabled
$usersWithExpiration = Get-ADUser -Filter {AccountExpirationDate -like "*" -and Enabled -eq $true} -Properties SamAccountName, AccountExpirationDate, MemberOf

# Array for deactivated users
$deactivatedUsers = @()

# Check and disable users with expiration dates
foreach ($user in $usersWithExpiration) {
    try {
        # Check if the expiration date has passed
        if ($user.AccountExpirationDate -lt (Get-Date)) {
            # Disable the user account
            Disable-ADAccount -Identity $user.SamAccountName
            Write-Log "User account $($user.SamAccountName) has been disabled."

            # Remove from all groups starting with "MS-LIC" (Microsoft licenses - Office/Visio/PowerApps)
            foreach ($group in $user.MemberOf) {
                $groupObject = Get-ADGroup -Identity $group
                if ($groupObject.Name -like "MS-LIC*") {
                    try {
                        Remove-ADGroupMember -Identity $groupObject.SamAccountName -Members $user.SamAccountName -Confirm:$false
                        Write-Log "User $($user.SamAccountName) has been removed from group $($groupObject.Name)."
                    } catch {
                        Write-Log "Error removing user $($user.SamAccountName) from group $($groupObject.Name): $_"
                    }
                }
            }

            Write-Host "User account $($user.SamAccountName) has been disabled due to expired expiration date."
            
            # Add user to deactivated list
            $deactivatedUsers += $user

            # Move to DISABLED-OU
            $disabledOU = "OU=Disabled Accounts,DC=domain,DC=com"  # Adjust this to your environment
            Move-ADObject -Identity $user.DistinguishedName -TargetPath $disabledOU -Confirm:$false
            Write-Log "User $($user.SamAccountName) has been moved to DISABLED-OU."

        }
    } catch {
        Write-Log "Error disabling user $($user.SamAccountName): $_"
        Write-Host "Error disabling user $($user.SamAccountName): $_"
    }
}

# Output the list of deactivated users
if ($deactivatedUsers.Count -gt 0) {
    Write-Log "The following users have been disabled:"
    $deactivatedUsers | Select-Object Name, SamAccountName, AccountExpirationDate | Format-Table -AutoSize
} else {
    Write-Log "No users with expired expiration date found."
}

# Log end message
Write-Log "Script ended."
