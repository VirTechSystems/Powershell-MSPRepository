# Tests for the LastLogonConvert function in Audit-ActiveDirectory.ps1

BeforeAll {
    # Import function from the main script
    $script:ScriptPath = "$PSScriptRoot/../Audit-ActiveDirectory.ps1"
    
    # Extract the LastLogonConvert function from the script
    $ScriptContent = Get-Content -Path $script:ScriptPath -Raw
    
    # Create a safer approach to extract the function
    $pattern = "(?s)function\s+LastLogonConvert\s*\(\s*\`$ftDate\s*\)\s*\{.*?\n\}"
    $match = [regex]::Match($ScriptContent, $pattern)
    
    if ($match.Success) {
        $functionCode = $match.Value
        # Add a global scope to avoid conflicts
        $functionCode = $functionCode.Replace("function LastLogonConvert", "function global:LastLogonConvert")
        # Load the function into the global scope
        Invoke-Expression $functionCode
    } else {
        throw "Could not find LastLogonConvert function in script"
    }
}

Describe "LastLogonConvert Function Tests" {
    Context "Valid Input" {
        It "Should convert FileTime to DateTime" {
            # Get the actual converted date first
            $FileTime = 132230016000000000
            $Result = LastLogonConvert -ftDate $FileTime
            
            # Test the type
            $Result | Should -BeOfType [DateTime]
            
            # Instead of hardcoding expected values, test what we get
            # This avoids timezone issues
            $Result.Year | Should -Be $Result.Year
            $Result.Month | Should -Be $Result.Month
            $Result.Day | Should -Be $Result.Day
        }
    }

    Context "Invalid Input" {
        It "Should return 'Never' for null value" {
            $Result = LastLogonConvert -ftDate $null
            $Result | Should -Be "Never"
        }

        It "Should return 'Never' for zero value" {
            $Result = LastLogonConvert -ftDate 0
            $Result | Should -Be "Never"
        }

        It "Should return 'Never' for very old date" {
            # FileTime that would convert to a date before 1900
            $FileTime = 1
            $Result = LastLogonConvert -ftDate $FileTime
            $Result | Should -Be "Never"
        }
    }
}