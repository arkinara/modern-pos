$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$auditGh = (Get-Command gh.exe).Source
$auditDir = $PSScriptRoot
$auditSpecs = Get-Content -LiteralPath (Join-Path $auditDir 'audit-ticket-specs.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$auditManifestPath = Join-Path $auditDir 'audit-tickets-published.json'
$auditPublished = @()
if (Test-Path -LiteralPath $auditManifestPath) {
  $auditLoaded = Get-Content -LiteralPath $auditManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($auditLoadedEntry in $auditLoaded) {
    if ($auditLoadedEntry.key) { $auditPublished += $auditLoadedEntry }
  }
}
function Invoke-AuditGh {
  param([string[]]$Arguments)
  $auditResult = & $auditGh @Arguments
  if ($LASTEXITCODE -ne 0) { throw ('GitHub command failed: ' + ($Arguments[0..([Math]::Min(2, $Arguments.Length - 1))] -join ' ')) }
  return ($auditResult -join "`n")
}
function Save-AuditManifest {
  [System.IO.File]::WriteAllText($auditManifestPath, (ConvertTo-Json -InputObject @($script:auditPublished) -Depth 10), [System.Text.UTF8Encoding]::new($false))
}
$auditProject = Invoke-AuditGh @('project','view','19','--owner','arkinara','--format','json') | ConvertFrom-Json
$auditFields = Invoke-AuditGh @('project','field-list','19','--owner','arkinara','--format','json') | ConvertFrom-Json
$auditStatus = $auditFields.fields | Where-Object name -eq 'Status'
$auditTodo = $auditStatus.options | Where-Object name -eq 'Todo'
if (-not $auditProject.id -or -not $auditStatus.id -or -not $auditTodo.id) { throw 'Project or Todo status not found' }
$auditExisting = Invoke-AuditGh @('issue','list','--repo','arkinara/modern-pos','--state','all','--limit','200','--json','number,title,url') | ConvertFrom-Json

foreach ($auditSpec in $auditSpecs) {
  $auditEntry = $auditPublished | Where-Object key -eq $auditSpec.key | Select-Object -First 1
  $auditTitle = '[' + $auditSpec.priority + '] ' + $auditSpec.title
  if (-not $auditEntry) {
    $auditDependencyLines = @()
    foreach ($auditDependencyKey in $auditSpec.depends) {
      $auditDependency = $auditPublished | Where-Object key -eq $auditDependencyKey | Select-Object -First 1
      if (-not $auditDependency) { throw ('Dependency not published: ' + $auditDependencyKey) }
      $auditDependencyLines += '- [ ] #' + $auditDependency.number + ' - ' + $auditDependency.title
    }
    $auditDependencyText = if ($auditDependencyLines.Count) { $auditDependencyLines -join "`n" } else { 'None. Can start independently.' }
    $auditBody = $auditSpec.body + "`n## Dependencies`n" + $auditDependencyText + "`n"
    $auditBodyPath = Join-Path $auditDir ('ticket-' + $auditSpec.key + '.md')
    [System.IO.File]::WriteAllText($auditBodyPath, $auditBody, [System.Text.UTF8Encoding]::new($false))
    $auditMatch = $auditExisting | Where-Object title -eq $auditTitle | Select-Object -First 1
    if ($auditMatch) {
      $auditUrl = $auditMatch.url
      $auditNumber = $auditMatch.number
    } else {
      $auditUrl = (Invoke-AuditGh @('issue','create','--repo','arkinara/modern-pos','--title',$auditTitle,'--label',$auditSpec.label,'--body-file',$auditBodyPath)).Trim()
      if ($auditUrl -notmatch '^https://github\.com/arkinara/modern-pos/issues/(\d+)$') { throw ('Unexpected create result: ' + $auditUrl) }
      $auditNumber = [int]$Matches[1]
    }
    $auditEntry = [pscustomobject]@{ key=$auditSpec.key; number=$auditNumber; title=$auditTitle; url=$auditUrl; itemId=$null; status=$null; dependencies=@($auditSpec.depends) }
    $auditPublished += $auditEntry
    Save-AuditManifest
  }
  if (-not $auditEntry.itemId) {
    $auditCurrentBoard = Invoke-AuditGh @('project','item-list','19','--owner','arkinara','--format','json','--limit','200') | ConvertFrom-Json
    $auditItem = $auditCurrentBoard.items | Where-Object { $_.content.url -eq $auditEntry.url } | Select-Object -First 1
    if (-not $auditItem) {
      try {
        $auditItem = Invoke-AuditGh @('project','item-add','19','--owner','arkinara','--url',$auditEntry.url,'--format','json') | ConvertFrom-Json
      } catch {
        # Project automation may attach the new issue between lookup and add.
        $auditCurrentBoard = Invoke-AuditGh @('project','item-list','19','--owner','arkinara','--format','json','--limit','200') | ConvertFrom-Json
        $auditItem = $auditCurrentBoard.items | Where-Object { $_.content.url -eq $auditEntry.url } | Select-Object -First 1
        if (-not $auditItem) { throw }
      }
    }
    if (-not $auditItem.id) { throw 'Project item id missing' }
    $auditEntry.itemId = $auditItem.id
    Save-AuditManifest
  }
  if ($auditEntry.status -ne 'Todo') {
    $null = Invoke-AuditGh @('project','item-edit','--id',$auditEntry.itemId,'--project-id',$auditProject.id,'--field-id',$auditStatus.id,'--single-select-option-id',$auditTodo.id)
    $auditEntry.status = 'Todo'
    Save-AuditManifest
  }
  Write-Output ('ADDED #' + $auditEntry.number + ' Todo: ' + $auditEntry.title)
}

$auditBoard = Invoke-AuditGh @('project','item-list','19','--owner','arkinara','--format','json','--limit','200') | ConvertFrom-Json
foreach ($auditEntry in $auditPublished) {
  $auditVerified = $auditBoard.items | Where-Object { $_.content.url -eq $auditEntry.url } | Select-Object -First 1
  if (-not $auditVerified -or $auditVerified.status -ne 'Todo') { throw ('Board verification failed for #' + $auditEntry.number) }
}
Write-Output ('VERIFIED: ' + $auditPublished.Count + ' audit issues in Project 19, all Todo.')
