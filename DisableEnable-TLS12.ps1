function Enable-TLS12 {
    # Define the base registry path for the protocols
    $registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'

    # List of protocols to disable
    $protocolsToDisable = @('SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1')

    # Disable insecure protocols and ensure they are not enabled
    foreach ($protocol in $protocolsToDisable) {
        $clientPath = "$registryPath\$protocol\Client"
        $serverPath = "$registryPath\$protocol\Server"

        # Set the registry values for Client and Server
        Set-ItemProperty -Path $clientPath -Name 'DisabledByDefault' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $clientPath -Name 'Enabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $serverPath -Name 'DisabledByDefault' -Value 1 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $serverPath -Name 'Enabled' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }

    # Enable TLS 1.2
    $tls12ClientPath = "$registryPath\TLS 1.2\Client"
    $tls12ServerPath = "$registryPath\TLS 1.2\Server"

    # Ensure the TLS 1.2 is enabled and not disabled by default
    Set-ItemProperty -Path $tls12ClientPath -Name 'DisabledByDefault' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $tls12ClientPath -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $tls12ServerPath -Name 'DisabledByDefault' -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $tls12ServerPath -Name 'Enabled' -Value 1 -Type DWord -ErrorAction SilentlyContinue

    Write-Output "TLS 1.2 has been enabled and insecure protocols have been disabled."
}


function Revert-TLS12 {
    # Define the base registry path for the protocols
    $registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'

    # Protocol settings to revert to
    $protocolsSettings = @{
        'SSL 2.0' = @{
            'Client' = @{ 'DisabledByDefault' = 0; 'Enabled' = 0 }
            'Server' = @{ 'DisabledByDefault' = 0; 'Enabled' = 1 }
        }
        'SSL 3.0' = @{
            'Client' = @{ 'DisabledByDefault' = 0; 'Enabled' = 1 }
            'Server' = @{ 'DisabledByDefault' = 0; 'Enabled' = 1 }
        }
        'TLS 1.0' = @{
            'Client' = @{ 'DisabledByDefault' = 0; 'Enabled' = 1 }
            'Server' = @{ 'DisabledByDefault' = 0; 'Enabled' = 1 }
        }
        'TLS 1.1' = @{
            'Client' = @{ 'DisabledByDefault' = 0; 'Enabled' = 1 }
            'Server' = @{ 'DisabledByDefault' = 0; 'Enabled' = 1 }
        }
    }

    foreach ($protocol in $protocolsSettings.Keys) {
        foreach ($key in $protocolsSettings[$protocol].Keys) {
            $path = "$registryPath\$protocol\$key"
            $settings = $protocolsSettings[$protocol][$key]
            Set-ItemProperty -Path $path -Name 'DisabledByDefault' -Value $settings['DisabledByDefault'] -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $path -Name 'Enabled' -Value $settings['Enabled'] -Type DWord -ErrorAction SilentlyContinue
        }
    }

    Write-Output "TLS and SSL protocol settings have been reverted."
}
