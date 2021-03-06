#region HEADER
# Integration Test Config Template Version: 1.2.0
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    <#
        Allows reading the configuration data from a JSON file,
        for real testing scenarios outside of the CI.
    #>
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName            = 'localhost'

                UserName            = "$env:COMPUTERNAME\SqlInstall"
                Password            = 'P@ssw0rd1'

                ServerName          = $env:COMPUTERNAME
                InstanceName        = 'DSCSQLTEST'

                Name                = 'FailsafeOp'
                NotificationMethod  = 'NotifyEmail'

                CertificateFile     = $env:DscPublicCertificatePath
            }
        )
    }
}

<#
    .SYNOPSIS
        Adds a SQL Agent Failsafe Operator.
#>
Configuration DSC_SqlAgentFailsafe_Add_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlAgentFailsafe 'Integration_Test'
        {
            Ensure               = 'Present'
            ServerName           = $Node.ServerName
            InstanceName         = $Node.InstanceName
            Name                 = $Node.Name
            NotificationMethod   = $Node.NotificationMethod

            PsDscRunAsCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.Username, (ConvertTo-SecureString -String $Node.Password -AsPlainText -Force))
        }
    }
}

<#
    .SYNOPSIS
        Removes a SQL Agent Failsafe Operator.
#>
Configuration DSC_SqlAgentFailsafe_Remove_Config
{
    Import-DscResource -ModuleName 'SqlServerDsc'

    node $AllNodes.NodeName
    {
        SqlAgentFailsafe 'Integration_Test'
        {
            Ensure               = 'Absent'
            ServerName           = $Node.ServerName
            InstanceName         = $Node.InstanceName
            Name                 = $Node.Name
            NotificationMethod   = $Node.NotificationMethod

            PsDscRunAsCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.Username, (ConvertTo-SecureString -String $Node.Password -AsPlainText -Force))
        }
    }
}


