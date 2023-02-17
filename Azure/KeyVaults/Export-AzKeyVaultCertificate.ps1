function Export-AzKeyVaultCertificate
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $VaultName,

        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter()]
        [Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer] $DefaultProfile
    )

    $Certificate = Get-AzKeyVaultCertificate -VaultName $VaultName -Name $Name -DefaultProfile $DefaultProfile
    $Secret      = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Certificate.Name -AsPlainText
    $SecretByte  = [Convert]::FromBase64String($Secret)

    $x509Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SecretByte, "", "Exportable,PersistKeySet") 
    [System.IO.File]::WriteAllBytes(
        $Path, 
        $x509Cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $password)
    )
}