# PowerShell script to fix speech_to_text package namespace issue
$packagePath = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\speech_to_text-6.6.2\android\build.gradle"

if (Test-Path $packagePath) {
    $content = Get-Content $packagePath -Raw
    
    # Check if namespace is already added
    if ($content -notmatch "namespace\s+'com\.csdcorp\.speech_to_text'") {
        # Add namespace after the first 'android {' block
        $content = $content -replace "(android\s*\{)", "`$1`n    namespace 'com.csdcorp.speech_to_text'"
        Set-Content -Path $packagePath -Value $content
        Write-Host "✅ Namespace added to speech_to_text package"
    } else {
        Write-Host "✅ Namespace already exists"
    }
} else {
    Write-Host "❌ Package not found at: $packagePath"
    Write-Host "Please run 'flutter pub get' first"
}
