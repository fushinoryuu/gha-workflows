param (
    [Parameter(Mandatory = $true)]
    [string]$CoverageReportPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

# coverage.py writes an empty-string key (the module-level code) inside each file's "functions"
# and "classes" blocks. ConvertFrom-Json only accepts that with -AsHashtable.
$coverageReport = Get-Content -Path $CoverageReportPath -Raw | ConvertFrom-Json -AsHashtable
$totals = $coverageReport.totals

function New-Metric {
    param (
        [int]$Total,
        [int]$Covered,
        [int]$Skipped,
        $Pct
    )

    [ordered]@{
        total   = $Total
        covered = $Covered
        skipped = $Skipped
        pct     = $Pct
    }
}

function Get-Pct {
    param (
        [int]$Covered,
        [int]$Total
    )

    if ($Total -eq 0) { return 100 }
    [math]::Round(($Covered / $Total) * 100, 2)
}

# coverage.py has no separate "statements" metric, so lines and statements both use the
# statement counts. "skipped" is the lines excluded with `# pragma: no cover`.
$lines = New-Metric `
    -Total $totals.num_statements `
    -Covered $totals.covered_lines `
    -Skipped $totals.excluded_lines `
    -Pct ([math]::Round($totals.percent_statements_covered, 2))

# Branch data only exists when the tests ran with branch coverage (`--cov-branch`).
if ($totals.ContainsKey('num_branches')) {
    $branches = New-Metric `
        -Total $totals.num_branches `
        -Covered $totals.covered_branches `
        -Skipped 0 `
        -Pct ([math]::Round($totals.percent_branches_covered, 2))
}
else {
    $branches = New-Metric -Total 0 -Covered 0 -Skipped 0 -Pct 'n/a'
}

# coverage.py only reports functions per file (and only in version 7.6 and newer), so add them up.
$functionSummaries = @()
$hasFunctionData = $false
foreach ($file in $coverageReport.files.Values) {
    if (-not $file.ContainsKey('functions')) { continue }
    $hasFunctionData = $true

    foreach ($function in $file.functions.GetEnumerator()) {
        # The empty name is the file's module-level code, not a function
        if ($function.Key -ne '') { $functionSummaries += $function.Value.summary }
    }
}

if ($hasFunctionData) {
    # A function counts as covered if any of its statements ran. One with no statements to run
    # (for example excluded with a pragma) is skipped, and left out of the percentage.
    $functionsTotal = $functionSummaries.Count
    $functionsCovered = @($functionSummaries | Where-Object { $_.covered_lines -gt 0 }).Count
    $functionsSkipped = @($functionSummaries | Where-Object { $_.num_statements -eq 0 }).Count

    $functions = New-Metric `
        -Total $functionsTotal `
        -Covered $functionsCovered `
        -Skipped $functionsSkipped `
        -Pct (Get-Pct -Covered $functionsCovered -Total ($functionsTotal - $functionsSkipped))
}
else {
    $functions = New-Metric -Total 0 -Covered 0 -Skipped 0 -Pct 'n/a'
}

# Write the same shape that vitest's coverage-summary.json has, so the rest of the action
# doesn't need to know which framework produced the report.
[ordered]@{
    total = [ordered]@{
        lines      = $lines
        statements = $lines
        functions  = $functions
        branches   = $branches
    }
} | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath
