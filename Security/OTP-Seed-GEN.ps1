# Generate 20 random bytes (160 bits)
$randomBytes = New-Object byte[] 20
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($randomBytes)

# Convert to Base32
function Convert-ToBase32 {
    param ([byte[]]$bytes)

    $base32Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    $output = [System.Text.StringBuilder]::new()
    $bitBuffer = 0
    $bitCount = 0

    foreach ($byte in $bytes) {
        $bitBuffer = ($bitBuffer -shl 8) -bor $byte
        $bitCount += 8

        while ($bitCount -ge 5) {
            $index = ($bitBuffer -shr ($bitCount - 5)) -band 0x1F
            $output.Append($base32Chars[$index]) | Out-Null
            $bitCount -= 5
        }
    }

    if ($bitCount -gt 0) {
        $index = ($bitBuffer -shl (5 - $bitCount)) -band 0x1F
        $output.Append($base32Chars[$index]) | Out-Null
    }

    return $output.ToString()
}

# Generate OTP Seed
$otpSeed = Convert-ToBase32 -bytes $randomBytes
Write-Output "OTP Seed (Base32, Google Authenticator Compatible): $otpSeed"
