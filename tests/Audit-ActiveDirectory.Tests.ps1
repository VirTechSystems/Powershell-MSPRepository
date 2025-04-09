# Tests for Audit-ActiveDirectory.ps1
# These tests use Pester for PowerShell testing framework
# They mock all AD cmdlets to avoid actually connecting to AD

BeforeAll {
    # Import required modules
    $script:ModulePath = "$PSScriptRoot/.."
    $script:ScriptPath = "$ModulePath/Audit-ActiveDirectory.ps1"
    
    # Create mock functions for ReportHTML module
    # These functions will be used instead of the actual ReportHTML module
    function Mock-HTMLFunctions {
        # Create all the necessary HTML functions that would normally be in the ReportHTML module
        function global:Get-HTMLOpenPage { 
            param($TitleText, $LeftLogoString, $RightLogoString)
            "<html><head><title>$TitleText</title></head><body>"
        }
        
        function global:Get-HTMLTabHeader { 
            param($TabNames)
            "<div class='tabHeaders'>$($TabNames -join ', ')</div>"
        }
        
        function global:Get-HTMLTabContentOpen {
            param($TabName, $TabHeading)
            "<div class='tabContent' id='$TabName'><h2>$TabHeading</h2>"
        }
        
        function global:Get-HTMLContentOpen { 
            param($HeaderText, $BackgroundShade)
            "<div class='content'><h3>$HeaderText</h3>"
        }
        
        function global:Get-HTMLContentTable { 
            param($InputObject, $HideFooter)
            "<table>MockTable:$($InputObject.Count) rows</table>"
        }
        
        function global:Get-HTMLContentDataTable { 
            param($InputObject, $HideFooter) 
            "<table class='dataTable'>MockDataTable:$($InputObject.Count) rows</table>"
        }
        
        function global:Get-HTMLContentClose { "</div>" }
        
        function global:Get-HTMLColumn1of2 { "<div class='column1of2'>" }
        
        function global:Get-HTMLColumn2of2 { "<div class='column2of2'>" }
        
        function global:Get-HTMLColumnOpen { 
            param($ColumnNumber, $ColumnCount)
            "<div class='column$ColumnNumber'>"
        }
        
        function global:Get-HTMLColumnClose { "</div>" }
        
        function global:Get-HTMLTabContentClose { "</div>" }
        
        function global:Get-HTMLClosePage { "</body></html>" }
        
        function global:Get-HTMLPieChartObject { 
            [PSCustomObject]@{
                Title = ""
                Size = @{
                    Height = 250
                    Width = 250
                }
                ChartStyle = @{
                    ChartType = 'doughnut'
                    ColorSchemeName = "ColorScheme3"
                }
                DataDefinition = @{
                    DataNameColumnName = 'Name'
                    DataValueColumnName = 'Count'
                }
            }
        }
        
        function global:Get-HTMLPieChart { 
            param($ChartObject, $DataSet)
            "<div class='pieChart'>MockPieChart:$($DataSet.Count) items</div>"
        }
        
        function global:Save-HTMLReport { 
            param($ReportContent, $ShowReport, $ReportName, $ReportPath)
            # Create directory if it doesn't exist
            if ($ReportPath -and -not (Test-Path $ReportPath)) {
                New-Item -ItemType Directory -Path $ReportPath -Force | Out-Null
            }
            
            # Create a test report file
            $ReportFilePath = if ($ReportPath) { 
                "$ReportPath/$ReportName.html" 
            } else {
                "$TestDrive/Report.html"
            }
            
            Set-Content -Path $ReportFilePath -Value "<html><body>Mock Report</body></html>"
            $ReportFilePath
        }

        # Create mock for the original Get-Module function
        function global:Get-Module {
            param(
                [Parameter(Position=0)]
                [string]$Name,
                [switch]$ListAvailable
            )
            
            if ($Name -eq "ReportHTML" -and $ListAvailable) {
                [PSCustomObject]@{
                    Name = "ReportHTML"
                    Version = "1.4.1.1"
                }
            } else {
                # Return empty array for other module requests
                @()
            }
        }

        # Mock these additional functions that might be called
        function global:Install-Module { 
            param($Name, $Force)
            $true 
        }

        function global:Import-Module { 
            param($Name, $ErrorAction)
            $true 
        }
    }

    # Mock all AD cmdlets used in the script
    function Mock-ADCmdlets {
        # Core Get-AD cmdlets
        function global:Get-ADUser {
            param($Filter, $Properties, $SearchBase)
            # Return mock user objects
            @(
                [PSCustomObject]@{
                    Name = "Test User 1"
                    SamAccountName = "testuser1"
                    UserPrincipalName = "testuser1@domain.com"
                    Enabled = $true
                    PasswordExpired = $false
                    PasswordLastSet = (Get-Date).AddDays(-30)
                    PasswordNeverExpires = $false
                    PasswordNotRequired = $false
                    AccountExpirationDate = $null
                    lastlogon = 132245058964986350
                    DistinguishedName = "CN=Test User 1,OU=Users,DC=domain,DC=com"
                    EmailAddress = "testuser1@domain.com"
                    whenCreated = (Get-Date).AddDays(-60)
                    ProtectedFromAccidentalDeletion = $true
                },
                [PSCustomObject]@{
                    Name = "Test User 2"
                    SamAccountName = "testuser2"
                    UserPrincipalName = "testuser2@domain.com"
                    Enabled = $false
                    PasswordExpired = $true
                    PasswordLastSet = (Get-Date).AddDays(-100)
                    PasswordNeverExpires = $true
                    PasswordNotRequired = $false
                    AccountExpirationDate = (Get-Date).AddDays(30)
                    lastlogon = 132245058964986350
                    DistinguishedName = "CN=Test User 2,OU=Users,DC=domain,DC=com"
                    EmailAddress = "testuser2@domain.com"
                    whenCreated = (Get-Date).AddDays(-5)
                    ProtectedFromAccidentalDeletion = $false
                }
            )
        }

        function global:Get-ADOrganizationalUnit {
            param($Filter, $Properties)
            # Return mock OUs
            @(
                [PSCustomObject]@{
                    Name = "Test OU 1"
                    DistinguishedName = "OU=Test OU 1,DC=domain,DC=com"
                    ProtectedFromAccidentalDeletion = $true
                    linkedgrouppolicyobjects = @(
                        "CN={31B2F340-016D-11D2-945F-00C04FB984F9},CN=Policies,CN=System,DC=domain,DC=com"
                    )
                    WhenChanged = (Get-Date).AddDays(-10)
                },
                [PSCustomObject]@{
                    Name = "Test OU 2"
                    DistinguishedName = "OU=Test OU 2,DC=domain,DC=com"
                    ProtectedFromAccidentalDeletion = $false
                    linkedgrouppolicyobjects = @()
                    WhenChanged = (Get-Date).AddDays(-20)
                }
            )
        }

        function global:Get-ADGroup {
            param($Filter, $Properties, $Identity)
            # Handle the case where we're looking for a specific group by Identity
            if ($Identity) {
                if ($Identity -eq "Domain Admins") {
                    return [PSCustomObject]@{
                        Name = "Domain Admins"
                        GroupCategory = "Security"
                        ProtectedFromAccidentalDeletion = $true
                        managedBy = "CN=Admin User,OU=Users,DC=domain,DC=com"
                        mail = $null
                    }
                }
                
                # Return mock properties if mail property is requested
                if ($Properties -contains "mail") {
                    return [PSCustomObject]@{
                        mail = "group@domain.com"
                    }
                }
                
                return [PSCustomObject]@{
                    Name = $Identity
                    GroupCategory = "Security"
                }
            }
            
            # Return mock groups for Filter * call
            @(
                [PSCustomObject]@{
                    Name = "Domain Admins"
                    GroupCategory = "Security"
                    ProtectedFromAccidentalDeletion = $true
                    managedBy = "CN=Admin User,OU=Users,DC=domain,DC=com"
                    mail = $null
                },
                [PSCustomObject]@{
                    Name = "Test Group"
                    GroupCategory = "Distribution"
                    ProtectedFromAccidentalDeletion = $false
                    managedBy = $null
                    mail = "testgroup@domain.com"
                }
            )
        }

        function global:Get-ADGroupMember {
            param($Identity)
            # Return members based on group name
            if ($Identity -eq "Domain Admins") {
                return @(
                    [PSCustomObject]@{
                        Name = "Admin User"
                        ObjectClass = "user"
                    }
                )
            }
            elseif ($Identity -eq "Enterprise Admins") {
                return @(
                    [PSCustomObject]@{
                        Name = "Enterprise Admin"
                        ObjectClass = "user"
                    }
                )
            }
            else {
                return @(
                    [PSCustomObject]@{
                        Name = "Group Member"
                        ObjectClass = "user"
                    }
                )
            }
        }

        function global:Get-ADComputer {
            param($Filter, $Properties, $SearchBase)
            # Return mock computers
            @(
                [PSCustomObject]@{
                    Name = "PC1"
                    Enabled = $true
                    OperatingSystem = "Windows 10"
                    ProtectedFromAccidentalDeletion = $true
                    Modified = (Get-Date).AddDays(-5)
                    PasswordLastSet = (Get-Date).AddDays(-30)
                    DistinguishedName = "CN=PC1,OU=Computers,DC=domain,DC=com"
                },
                [PSCustomObject]@{
                    Name = "PC2"
                    Enabled = $false
                    OperatingSystem = "Windows Server 2019"
                    ProtectedFromAccidentalDeletion = $false
                    Modified = (Get-Date).AddDays(-10)
                    PasswordLastSet = (Get-Date).AddDays(-60)
                    DistinguishedName = "CN=PC2,CN=Computers,DC=domain,DC=com"
                }
            )
        }

        function global:Search-ADAccount {
            param($AccountExpiring, $UsersOnly)
            # Return mock expiring accounts
            @(
                [PSCustomObject]@{
                    Name = "Expiring User"
                    UserPrincipalName = "expiring@domain.com"
                    AccountExpirationDate = (Get-Date).AddDays(7)
                    Enabled = $true
                }
            )
        }

        function global:Get-ADObject {
            param($Filter, $Properties)
            # Return recently modified AD objects
            @(
                [PSCustomObject]@{
                    Name = "Modified Object"
                    ObjectClass = "user"
                    WhenChanged = (Get-Date).AddDays(-2)
                    DisplayName = "Modified User"
                },
                [PSCustomObject]@{
                    Name = "GPO-Policy"
                    ObjectClass = "GroupPolicyContainer"
                    WhenChanged = (Get-Date).AddDays(-1)
                    DisplayName = "Security Policy"
                }
            )
        }

        function global:Get-ADDomain {
            [PSCustomObject]@{
                Forest = "domain.com"
                InfrastructureMaster = "DC1.domain.com"
                RIDMaster = "DC1.domain.com"
                PDCEmulator = "DC1.domain.com"
                computerscontainer = "CN=Computers,DC=domain,DC=com"
                UsersContainer = "CN=Users,DC=domain,DC=com"
            }
        }

        function global:Get-ADForest {
            param($Server)
            [PSCustomObject]@{
                DomainNamingMaster = "DC1.domain.com"
                SchemaMaster = "DC1.domain.com"
                upnsuffixes = @("domain.com", "subdom.domain.com")
            }
        }

        function global:Get-ADOptionalFeature {
            param($Filter)
            [PSCustomObject]@{
                EnabledScopes = @("CN=Partitions,CN=Configuration,DC=domain,DC=com")
            }
        }

        function global:Get-ADUserResultantPasswordPolicy {
            param($Identity)
            [PSCustomObject]@{
                MaxPasswordAge = 90
            }
        }

        function global:Get-ADDefaultDomainPasswordPolicy {
            [PSCustomObject]@{
                MaxPasswordAge = [TimeSpan]::FromDays(90)
            }
        }

        function global:Get-GPO {
            param($All, $Guid)
            if ($Guid) {
                return [PSCustomObject]@{
                    DisplayName = "Test GPO for $Guid"
                }
            }
            
            @(
                [PSCustomObject]@{
                    DisplayName = "Test GPO"
                    Id = [guid]::NewGuid()
                    GPOStatus = "AllSettingsEnabled"
                    ModificationTime = (Get-Date).AddDays(-5)
                    computer = [PSCustomObject]@{
                        dsversion = 1
                    }
                    user = [PSCustomObject]@{
                        dsversion = 1
                    }
                }
            )
        }

        function global:Get-EventLog {
            param($Newest, $LogName)
            @(
                [PSCustomObject]@{
                    TimeGenerated = (Get-Date).AddDays(-1)
                    EntryType = "Information"
                    Message = "An account was successfully logged on"
                }
            )
        }

        # Mock additional functions that might be used
        function global:Write-Host {
            param($Object, $ForegroundColor, $NoNewline)
            # Do nothing
        }
        
        function global:Write-Error {
            param($Message)
            # Do nothing
        }
        
        function global:Get-Date {
            param($Format)
            
            if ($Format) {
                return (Get-Date).ToString($Format)
            }
            
            # Return the current date/time
            [datetime]::Now
        }
    }

    # Call our mock functions to set everything up
    Mock-HTMLFunctions
    Mock-ADCmdlets
}

Describe "Audit-ActiveDirectory" {
    Context "Basic Script Tests" {
        # Test that the script file exists
        It "Should have a valid script file" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        # Test for LastLogonConvert function
        It "Should contain LastLogonConvert function" {
            $scriptContent = Get-Content -Path $script:ScriptPath -Raw
            $scriptContent | Should -Match "function LastLogonConvert"
        }

        # Test that script has basic parameters
        It "Should contain basic parameters" {
            $scriptContent = Get-Content -Path $script:ScriptPath -Raw
            $scriptContent | Should -Match "param"
            $scriptContent | Should -Match "ReportTitle"
            $scriptContent | Should -Match "Days"
        }
    }
}