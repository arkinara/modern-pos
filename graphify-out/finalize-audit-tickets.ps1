$ErrorActionPreference = 'Stop'
$auditGh = (Get-Command gh.exe).Source
$auditDir = $PSScriptRoot
function Invoke-AuditGh {
  param([string[]]$Arguments)
  $auditResponse = & $auditGh @Arguments
  if ($LASTEXITCODE -ne 0) { throw ('GitHub command failed: ' + $Arguments[0] + ' ' + $Arguments[1]) }
  return ($auditResponse -join "`n")
}
foreach ($auditPair in @(@(64,66),@(65,67))) {
  $auditOld = $auditPair[0]
  $auditNew = $auditPair[1]
  $auditDuplicateBody = 'Duplicate created during publication retry. The actionable finding, acceptance criteria and dependencies are tracked in #' + $auditNew + '.'
  $auditDuplicateFile = Join-Path $auditDir ('duplicate-' + $auditOld + '.md')
  [System.IO.File]::WriteAllText($auditDuplicateFile, $auditDuplicateBody, [System.Text.UTF8Encoding]::new($false))
  $null = Invoke-AuditGh @('issue','edit',[string]$auditOld,'--repo','arkinara/modern-pos','--add-label','duplicate','--body-file',$auditDuplicateFile)
  $auditIssue = Invoke-AuditGh @('issue','view',[string]$auditOld,'--repo','arkinara/modern-pos','--json','state') | ConvertFrom-Json
  if ($auditIssue.state -eq 'OPEN') {
    $null = Invoke-AuditGh @('issue','close',[string]$auditOld,'--repo','arkinara/modern-pos','--reason','not planned')
  }
  $auditBoard = Invoke-AuditGh @('project','item-list','19','--owner','arkinara','--format','json','--limit','200') | ConvertFrom-Json
  $auditDuplicateItem = $auditBoard.items | Where-Object { $_.content.number -eq $auditOld } | Select-Object -First 1
  if ($auditDuplicateItem) {
    $null = Invoke-AuditGh @('project','item-delete','19','--owner','arkinara','--id',$auditDuplicateItem.id)
  }
  Write-Output ('Removed duplicate #' + $auditOld + '; canonical #' + $auditNew)
}

$auditManifestPath = Join-Path $auditDir 'audit-tickets-published.json'
$auditLoaded = Get-Content -LiteralPath $auditManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$auditEntries = @()
foreach ($auditLoadedEntry in $auditLoaded) {
  if ($auditLoadedEntry.key) { $auditEntries += $auditLoadedEntry }
}
[System.IO.File]::WriteAllText($auditManifestPath, (ConvertTo-Json -InputObject $auditEntries -Depth 10), [System.Text.UTF8Encoding]::new($false))
$auditBoard = Invoke-AuditGh @('project','item-list','19','--owner','arkinara','--format','json','--limit','200') | ConvertFrom-Json
$auditOpen = Invoke-AuditGh @('issue','list','--repo','arkinara/modern-pos','--state','open','--limit','100','--json','number,title,url') | ConvertFrom-Json
if ($auditEntries.Count -ne 13) { throw 'Expected 13 canonical tickets' }
foreach ($auditEntry in $auditEntries) {
  $auditItem = $auditBoard.items | Where-Object { $_.content.url -eq $auditEntry.url } | Select-Object -First 1
  if (-not $auditItem -or $auditItem.status -ne 'Todo') { throw ('Todo board verification failed: #' + $auditEntry.number) }
  $auditMatch = $auditOpen | Where-Object number -eq $auditEntry.number | Select-Object -First 1
  if (-not $auditMatch) { throw ('Issue is not open: #' + $auditEntry.number) }
  foreach ($auditDependencyKey in $auditEntry.dependencies) {
    $auditDependency = $auditEntries | Where-Object key -eq $auditDependencyKey | Select-Object -First 1
    if (-not $auditDependency -or $auditItem.content.body -notmatch ('#' + $auditDependency.number + '\b')) { throw ('Dependency link missing: #' + $auditEntry.number) }
  }
}
[System.IO.File]::WriteAllText((Join-Path $auditDir 'project-19-after-publication.json'), (ConvertTo-Json -InputObject $auditBoard -Depth 30), [System.Text.UTF8Encoding]::new($false))
Write-Output ('VERIFIED: ' + $auditEntries.Count + ' open audit issues in Project 19, all Todo, dependency links present.')
$auditEntries | Select-Object number,title,url | Format-Table -AutoSize
