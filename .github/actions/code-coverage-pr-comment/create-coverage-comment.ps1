param (
    [Parameter(Mandatory = $true)]
    [string]$CoverageReportPath
)

$coverageReport = Get-Content -Path $CoverageReportPath -Raw | ConvertFrom-Json
$coverageMarkdown = Get-content -Path "$PSScriptRoot/comment-template.md" -Raw

$totals = $coverageReport.totals

# Get the values for each metric
$lines = $totals.lines
$statements = $totals.statements
$functions = $totals.functions
$branches = $totals.branches
$branchesTrue = $totals.branchesTrue

# Replace the placeholders in the markdown template with the actual values
$lines.PSObject.Properties | ForEach-Object {
    $key = "lines" + $_.Name
    $coverageMarkdown = $coverageMarkdown -replace $key, $_.Value
}

$statements.PSObject.Properties | ForEach-Object {
    $key = "statements" + $_.Name
    $coverageMarkdown = $coverageMarkdown -replace $key, $_.Value
}

$functions.PSObject.Properties | ForEach-Object {
    $key = "functions" + $_.Name
    $coverageMarkdown = $coverageMarkdown -replace $key, $_.Value
}

$branches.PSObject.Properties | ForEach-Object {
    $key = "branches" + $_.Name
    $coverageMarkdown = $coverageMarkdown -replace $key, $_.Value
}

$branchesTrue.PSObject.Properties | ForEach-Object {
    $key = "branchesTrue" + $_.Name
    $coverageMarkdown = $coverageMarkdown -replace $key, $_.Value
}

# Output the final markdown content
Write-Host $coverageMarkdown

$coverageMarkdown | Set-Content -Path "$PSScriptRoot/coverage-comment.md"