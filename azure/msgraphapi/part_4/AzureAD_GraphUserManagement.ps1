# Example file from www.debontonline.com
# Setup Microsoft 365 environment https://developer.microsoft.com/en-us/microsoft-365/dev-program
# Microsoft graph api documentation: https://docs.microsoft.com/en-us/graph/overview?view=graph-rest-1.0



# Minimum Required API permission for execution to create a new users
# User.Read.Write.All
# User.ManageIdentities.All


# Required Powershell Module for certificate authorisation
# Install-Module MSAL.PS 


# Connection information for Graph API connection - Certificate Based
$clientID = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx" #  App Id MS Graph API Connector SPN
$TenantName = "<<tenantname>>.onmicrosoft.com" # Example debontonlinedev.onmicrosoft.com
$TenantID = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx" # Tenant ID 
$CertificatePath = "Cert:\CurrentUser\my\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Add the Certificate Path Including Thumbprint here e.g. cert:\currentuser\my\6C1EE1A11F57F2495B57A567211220E0ADD72DC1 >#
##Import Certificate
$Certificate = Get-Item $certificatePath
##Request Token
$TokenResponse = Get-MsalToken -ClientId $ClientId -TenantId $TenantId -ClientCertificate $Certificate
$TokenAccess = $TokenResponse.accesstoken
 

# Create Single User Account
$CreateUserBody = @{
    "userPrincipalName"="John.Doe@$tenantname"
    "displayName"="John Do"
    "mailNickname"="John Doe"
    "accountEnabled"=$true
    "passwordProfile"= @{
        "forceChangePasswordNextSignIn" = $false
        "forceChangePasswordNextSignInWithMfa" = $false
        "password"="Welcome123456"
    }
 }

$CreateUserUrl = "https://graph.microsoft.com/v1.0/users"
$CreateUser = Invoke-RestMethod -Uri $CreateUserUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($CreateUserBody | convertto-json) -ContentType "application/json"


#Modify Single User Account
$ModifyUserUPN = "John.Doe@$tenantname"
$ModifyUserBody = @{
    "displayName"="John Doe"
}

$ModifyUserUrl = "https://graph.microsoft.com/v1.0/users/"
$ModifyUser = Invoke-RestMethod -Uri $CreateUserUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Patch -Body $($CreateUserBody | convertto-json) -ContentType "application/json"



#Delete Single User Account
$DeleteUserUPN = "John.Doe@$tenantname"
$DeleteUserUrl =  "https://graph.microsoft.com/v1.0/users/$DeleteUserUPN"
Invoke-RestMethod -Uri $DeleteUserUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Delete




# Create multiple users via CSV file
$ImportFile = "C:\Temp\Import\AzureADUsers.csv" #Location of *.csv file
$date=Get-Date -Format "yyyyMMdd_HHmm"
$logfile = "C:\Temp\Import\AzureADUsers_$date.log"

$Users = Import-Csv -Path $Importfile -Delimiter ";"

ForEach($User in $Users)  {

    $CreateUserBody = @{
        "userPrincipalName"= $UPN
        "displayName"= $DisplayName
        "mailNickname"= $MailNickName
        "accountEnabled"=$true
        "passwordProfile"= @{
            "forceChangePasswordNextSignIn" = $false
            "forceChangePasswordNextSignInWithMfa" = $false
            "password"= $password
        }
     }
   
     $CreateUserUrl = "https://graph.microsoft.com/v1.0/users"
    $UserLog = Invoke-RestMethod -Uri $CreateUserUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($CreateUserBody | convertto-json) -ContentType "application/json"
    Write-Output $UserLog | ft >> $logfile 
}   
    
 


    

