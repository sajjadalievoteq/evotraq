param(
    [string]$SourceRoot = "lib",
    [int]$MaxFileLines = 500,
    [int]$MaxPathDepth = 8,
    [switch]$FailOnViolations
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "Source root '$SourceRoot' does not exist."
}

$dartFiles = @(Get-ChildItem -LiteralPath $SourceRoot -Recurse -Filter *.dart -File)
$findings = [System.Collections.Generic.List[object]]::new()
$resolvedSourceRoot = (Resolve-Path $SourceRoot).Path.TrimEnd('\', '/')

foreach ($file in $dartFiles) {
    $relativePath = $file.FullName.Substring($resolvedSourceRoot.Length).TrimStart('\', '/')
    $content = Get-Content -LiteralPath $file.FullName
    $text = $content -join "`n"
    $lineCount = $content.Count
    $pathDepth = ($relativePath -split '[\\/]').Count

    $widgetMatches = [regex]::Matches(
        $text,
        '(?m)^\s*(?:final\s+|base\s+)?class\s+(?<name>\w+)\s+extends\s+(?:StatelessWidget|StatefulWidget)\b'
    )
    $buildHelperMatches = [regex]::Matches(
        $text,
        '(?m)^\s*(?:static\s+)?(?:Widget|List<Widget>|Iterable<Widget>)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\('
    ) | Where-Object { $_.Groups['name'].Value -ne 'build' }
    $forbiddenDirectiveMatches = [regex]::Matches(
        $text,
        '(?m)^\s*(?<directive>part of|part|export)\s+'
    )
    $passThroughWidgetLocalMatches = [regex]::Matches(
        $text,
        '(?m)^\s*(?:final|Widget)\s+(?<name>[A-Za-z_][A-Za-z0-9_]*(?:body|content|child|widget|card|row|column|list|sheet|chart|legend|panel|view|section|tile|scaffold|layout|skeleton)[A-Za-z0-9_]*)\s*=\s*(?:const\s+)?[A-Z][A-Za-z0-9_<>]*\s*\('
    ) | Where-Object {
        $_.Groups['name'].Value -notmatch '(Controller|Key|Node|Model|Request|Response|Service|Cubit|Bloc)$'
    }

    if ($widgetMatches.Count -gt 1) {
        $widgetNames = @($widgetMatches | ForEach-Object { $_.Groups['name'].Value }) -join ', '
        $findings.Add([pscustomobject]@{
            Rule = 'one-widget-per-file'
            Path = $relativePath
            Detail = "$($widgetMatches.Count) widget classes: $widgetNames"
        })
    }

    foreach ($match in $buildHelperMatches) {
        $findings.Add([pscustomobject]@{
            Rule = 'no-widget-build-helpers'
            Path = $relativePath
            Detail = "Extract widget-returning function $($match.Groups['name'].Value) into an independent widget"
        })
    }

    foreach ($match in $forbiddenDirectiveMatches) {
        $findings.Add([pscustomobject]@{
            Rule = 'no-part-or-export-directives'
            Path = $relativePath
            Detail = "Replace $($match.Groups['directive'].Value) with direct imports and standalone files"
        })
    }

    foreach ($match in $passThroughWidgetLocalMatches) {
        $findings.Add([pscustomobject]@{
            Rule = 'no-pass-through-widget-locals'
            Path = $relativePath
            Detail = "Inline or extract intermediate widget local $($match.Groups['name'].Value)"
        })
    }

    if ($lineCount -gt $MaxFileLines) {
        $findings.Add([pscustomobject]@{
            Rule = 'max-file-lines'
            Path = $relativePath
            Detail = "$lineCount lines (limit: $MaxFileLines)"
        })
    }

    if ($pathDepth -gt $MaxPathDepth) {
        $findings.Add([pscustomobject]@{
            Rule = 'max-path-depth'
            Path = $relativePath
            Detail = "depth $pathDepth (limit: $MaxPathDepth)"
        })
    }
}

$summary = [pscustomobject]@{
    DartFiles = $dartFiles.Count
    Findings = $findings.Count
    MultiWidgetFiles = @($findings | Where-Object Rule -eq 'one-widget-per-file').Count
    WidgetBuildHelpers = @($findings | Where-Object Rule -eq 'no-widget-build-helpers').Count
    OversizedFiles = @($findings | Where-Object Rule -eq 'max-file-lines').Count
    OverNestedFiles = @($findings | Where-Object Rule -eq 'max-path-depth').Count
    ForbiddenDirectives = @($findings | Where-Object Rule -eq 'no-part-or-export-directives').Count
    PassThroughWidgetLocals = @($findings | Where-Object Rule -eq 'no-pass-through-widget-locals').Count
}

$summary | Format-List
$findings | Sort-Object Rule, Path | Format-Table -AutoSize -Wrap

if ($FailOnViolations -and $findings.Count -gt 0) {
    exit 1
}
