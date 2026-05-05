# CI/local: analyzer treats warnings as non-fatal so the command exits 0 while still printing issues.
# Strict mode (warnings fail the job): run `dart analyze` without this script.
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..
dart analyze --no-fatal-warnings @args
