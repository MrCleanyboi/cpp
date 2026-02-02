# PowerShell script to fix record package namespace issue
$packagePath = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\record-4.4.4\android\build.gradle"

if (Test-Path $packagePath) {
    $content = Get-Content $packagePath -Raw
    
    # Check if namespace is already added
    if ($content -notmatch "namespace\s+") {
        # Add namespace after the first 'android {' block
        $content = $content -replace "(android\s*\{)", "`$1`n    namespace 'com.llfbandit.record'"
        Set-Content -Path $packagePath -Value $content
        Write-Host "✅ Namespace added to record package"
    } else {
        Write-Host "✅ Namespace already exists"
    }
} else {
    Write-Host "❌ Package not found at: $packagePath"
}
