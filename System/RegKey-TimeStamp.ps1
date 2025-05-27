Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public class RegKeyTime {
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern int RegOpenKeyEx(
        UIntPtr hKey,
        string subKey,
        uint options,
        int samDesired,
        out IntPtr phkResult);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern int RegQueryInfoKey(
        IntPtr hKey,
        StringBuilder lpClass,
        ref uint lpcClass,
        IntPtr lpReserved,
        IntPtr lpcSubKeys,
        IntPtr lpcMaxSubKeyLen,
        IntPtr lpcMaxClassLen,
        IntPtr lpcValues,
        IntPtr lpcMaxValueNameLen,
        IntPtr lpcMaxValueLen,
        IntPtr lpcbSecurityDescriptor,
        out long lpftLastWriteTime);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern int RegCloseKey(IntPtr hKey);

    public static readonly UIntPtr HKEY_LOCAL_MACHINE = new UIntPtr(0x80000002u);

    public static DateTime GetLastWriteTime(string subKey) {
        IntPtr phkResult = IntPtr.Zero;  // Initialize phkResult to IntPtr.Zero
        long filetime;
        DateTime lastWriteTime;

        int result = RegOpenKeyEx(HKEY_LOCAL_MACHINE, subKey, 0, 0x20019, out phkResult);
        if (result != 0) {
            throw new Exception(String.Format("Failed to open registry key. Error code: {0}", result));
        }

        try {
            uint lpcClass = 1024;
            StringBuilder classBuilder = new StringBuilder((int)lpcClass);

            result = RegQueryInfoKey(phkResult, classBuilder, ref lpcClass, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, out filetime);
            if (result != 0) {
                throw new Exception(String.Format("Failed to query registry key information. Error code: {0}", result));
            }

            lastWriteTime = DateTime.FromFileTime(filetime);
        } finally {
            if (phkResult != IntPtr.Zero) {
                RegCloseKey(phkResult);
            }
        }

        return lastWriteTime;
    }
}
"@

# Usage Example
try {
    $lastWriteTime = [RegKeyTime]::GetLastWriteTime("SOFTWARE\Microsoft\Windows\CurrentVersion\<some path>")
    Write-Output "Last Modified Time: $lastWriteTime"
} catch {
    Write-Error "An error occurred: $_"
}
