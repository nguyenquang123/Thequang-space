Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$KoreanProcessName = "NEW_LINE$([char]0xACF5)$([char]0xC815)"
$DefaultRoot = "Z:\1. HFSVINA Public\4. Production Engineering Team\$KoreanProcessName"
$AllowedExtensions = @(
  ".pdf",
  ".xlsx", ".xls", ".xlsm", ".xlsb", ".xltx", ".xltm", ".csv",
  ".docx", ".doc", ".docm", ".dotx", ".dotm", ".rtf",
  ".pptx", ".ppt", ".pptm", ".potx", ".potm", ".ppsx", ".ppsm",
  ".accdb", ".mdb",
  ".mpp",
  ".pub",
  ".one",
  ".mp4", ".mov", ".avi", ".wmv",
  ".dwg", ".dxf",
  ".vsd", ".vsdx",
  ".txt",
  ".jpg", ".jpeg", ".png"
)
$Script:AllRows = @()
$Script:FilteredRows = @()

function Get-Area {
  param([string[]]$Parts, [string]$FileName)

  foreach ($part in $Parts) {
    if ($part -match "(?i)UOT") { return "UOT" }
    if ($part -match "(?i)S2") { return "S2" }
  }

  if ($FileName -match "(?i)UOT") { return "UOT" }
  if ($FileName -match "(?i)S2") { return "S2" }
  return "OTHER"
}

function Get-DocumentType {
  param(
    [string]$FileName,
    [string[]]$Parts
  )

  $text = "$FileName $($Parts -join ' ')"

  if ($text -match "(?i)distribution\s*list|material\s*list|nguyen\s*vat\s*lieu|nguyên\s*vật\s*liệu|bom") { return "Material List" }
  if ($text -match "(?i)work\s*guide|workguide|guide|thứ\s*tự\s*thao\s*tác|thu\s*tu\s*thao\s*tac") { return "Workguide" }
  if ($text -match "(?i)sop") { return "SOP" }
  return "Document"
}

function Get-FileType {
  param([string]$Extension)

  switch ($Extension.ToLowerInvariant()) {
    ".pdf" { return "PDF" }
    { $_ -in @(".xlsx", ".xls", ".xlsm", ".xlsb", ".xltx", ".xltm", ".csv") } { return "Excel" }
    { $_ -in @(".docx", ".doc", ".docm", ".dotx", ".dotm", ".rtf") } { return "Word" }
    { $_ -in @(".pptx", ".ppt", ".pptm", ".potx", ".potm", ".ppsx", ".ppsm") } { return "PowerPoint" }
    { $_ -in @(".accdb", ".mdb") } { return "Access" }
    ".mpp" { return "Project" }
    ".pub" { return "Publisher" }
    ".one" { return "OneNote" }
    { $_ -in @(".mp4", ".mov", ".avi", ".wmv") } { return "Video" }
    { $_ -in @(".dwg", ".dxf") } { return "AutoCAD" }
    { $_ -in @(".vsd", ".vsdx") } { return "Visio" }
    ".txt" { return "Text" }
    { $_ -in @(".jpg", ".jpeg", ".png") } { return "Image" }
    default { return "Other" }
  }
}

function Get-ItemCode {
  param([string[]]$Parts, [string]$FileName)

  $text = "$FileName $($Parts -join ' ')"
  $match = [regex]::Match($text, "(?<!\d)(?:7224|7223|7250|7210|7221|72\d{2})\d{6}(?!\d)")
  if ($match.Success) {
    return $match.Value
  }

  return "No item code"
}

function Convert-FileToRow {
  param(
    [System.IO.FileInfo]$File,
    [string]$RootPath
  )

  $root = $RootPath.TrimEnd("\")
  $relative = $File.FullName.Substring($root.Length).TrimStart("\")
  $parts = $relative -split "\\"
  $model = if ($parts.Length -ge 1) { $parts[0] } else { "" }
  $codeSystem = if ($parts.Length -ge 2) { $parts[1] } else { "" }

  [pscustomobject]@{
    Model = $model
    CodeSystem = $codeSystem
    Area = Get-Area -Parts $parts -FileName $File.Name
    ItemCode = Get-ItemCode -Parts $parts -FileName $File.Name
    DocumentType = Get-DocumentType -FileName $File.Name -Parts $parts
    FileType = Get-FileType -Extension $File.Extension
    FileName = $File.Name
    Updated = $File.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
    SizeKB = [math]::Round($File.Length / 1KB, 1)
    FolderPath = $File.DirectoryName
    FullPath = $File.FullName
  }
}

function Set-Status {
  param([string]$Text)
  $statusLabel.Text = $Text
  $form.Refresh()
}

function Scan-SopFolder {
  param([string]$RootPath)

  if (-not (Test-Path -LiteralPath $RootPath)) {
    [System.Windows.Forms.MessageBox]::Show(
      "Folder not found:`r`n$RootPath",
      "Scan failed",
      [System.Windows.Forms.MessageBoxButtons]::OK,
      [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
    return
  }

  Set-Status "Scanning server folder..."
  $scanButton.Enabled = $false
  $listView.Items.Clear()
  $treeView.Nodes.Clear()

  try {
    $files = Get-ChildItem -LiteralPath $RootPath -Recurse -File -ErrorAction Stop |
      Where-Object { $AllowedExtensions -contains $_.Extension.ToLowerInvariant() }

    $Script:AllRows = @($files | ForEach-Object { Convert-FileToRow -File $_ -RootPath $RootPath } |
      Sort-Object Model, Area, ItemCode, DocumentType, FileName)

    Apply-Filters
    Set-Status "Scanned $($Script:AllRows.Count) files. Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  }
  catch {
    [System.Windows.Forms.MessageBox]::Show(
      "Error while scanning folder:`r`n$($_.Exception.Message)",
      "Error",
      [System.Windows.Forms.MessageBoxButtons]::OK,
      [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    Set-Status "Scan was not successful."
  }
  finally {
    $scanButton.Enabled = $true
  }
}

function Apply-Filters {
  $query = $searchBox.Text.Trim().ToLowerInvariant()
  $fileNameQuery = $quickFileBox.Text.Trim().ToLowerInvariant()
  $process = [string]$processCombo.SelectedItem
  $fileType = [string]$typeCombo.SelectedItem

  $Script:FilteredRows = @($Script:AllRows | Where-Object {
    $processOk = $true
    if ($process -and $process -ne "All" -and $process -ne "Tất cả" -and $process -ne "전체") {
      $processOk = $_.Area -eq $process
    }

    $typeOk = $true
    if ($fileType -and $fileType -ne "All" -and $fileType -ne "Tất cả" -and $fileType -ne "전체") {
      $typeOk = $_.FileType -eq $fileType
    }

    $queryOk = $true
    if ($query) {
      $haystack = "$($_.Model) $($_.CodeSystem) $($_.Area) $($_.ItemCode) $($_.DocumentType) $($_.FileType) $($_.FileName) $($_.FolderPath)".ToLowerInvariant()
      $queryOk = $haystack.Contains($query)
    }

    $fileNameOk = $true
    if ($fileNameQuery) {
      $fileNameOk = $_.FileName.ToLowerInvariant().Contains($fileNameQuery)
    }

    $processOk -and $typeOk -and $queryOk -and $fileNameOk
  })

  Render-Tree
  Render-List
  Update-Summary
}

function Render-Tree {
  $treeView.BeginUpdate()
  $treeView.Nodes.Clear()

  $models = $Script:FilteredRows | Group-Object Model | Sort-Object Name
  foreach ($modelGroup in $models) {
    $modelNode = New-Object System.Windows.Forms.TreeNode("$($modelGroup.Name) ($($modelGroup.Count))")
    $modelNode.Tag = $modelGroup.Group

    $processGroups = $modelGroup.Group | Group-Object Area | Sort-Object Name
    foreach ($processGroup in $processGroups) {
      $processName = if ($processGroup.Name) { $processGroup.Name } else { "OTHER" }
      $processNode = New-Object System.Windows.Forms.TreeNode("$processName ($($processGroup.Count))")
      $processNode.Tag = $processGroup.Group

      $itemGroups = $processGroup.Group | Group-Object ItemCode | Sort-Object Name
      foreach ($itemGroup in $itemGroups) {
        $itemName = if ($itemGroup.Name) { $itemGroup.Name } else { "No item code" }
        $itemNode = New-Object System.Windows.Forms.TreeNode("$itemName ($($itemGroup.Count))")
        $itemNode.Tag = $itemGroup.Group

        $docGroups = $itemGroup.Group | Group-Object DocumentType | Sort-Object Name
        foreach ($docGroup in $docGroups) {
          $docName = if ($docGroup.Name) { $docGroup.Name } else { "Document" }
          $docNode = New-Object System.Windows.Forms.TreeNode("$docName ($($docGroup.Count))")
          $docNode.Tag = $docGroup.Group
          [void]$itemNode.Nodes.Add($docNode)
        }

        [void]$processNode.Nodes.Add($itemNode)
      }

      [void]$modelNode.Nodes.Add($processNode)
    }

    [void]$treeView.Nodes.Add($modelNode)
  }

  if ($treeView.Nodes.Count -le 30) {
    $treeView.ExpandAll()
  }

  $treeView.EndUpdate()
}

function Render-List {
  $listView.BeginUpdate()
  $listView.Items.Clear()

  foreach ($row in $Script:FilteredRows) {
    $item = New-Object System.Windows.Forms.ListViewItem($row.Model)
    [void]$item.SubItems.Add($row.CodeSystem)
    [void]$item.SubItems.Add($row.Area)
    [void]$item.SubItems.Add($row.ItemCode)
    [void]$item.SubItems.Add($row.DocumentType)
    [void]$item.SubItems.Add($row.FileType)
    [void]$item.SubItems.Add($row.FileName)
    [void]$item.SubItems.Add($row.Updated)
    [void]$item.SubItems.Add([string]$row.SizeKB)
    [void]$item.SubItems.Add($row.FolderPath)
    $item.Tag = $row
    [void]$listView.Items.Add($item)
  }

  $listView.EndUpdate()
}

function Update-Summary {
  $modelCount = @($Script:AllRows | Select-Object -ExpandProperty Model -Unique).Count
  $s2Count = @($Script:AllRows | Where-Object { $_.Area -eq "S2" }).Count
  $uotCount = @($Script:AllRows | Where-Object { $_.Area -eq "UOT" }).Count
  $otherCount = @($Script:AllRows | Where-Object { $_.Area -eq "OTHER" }).Count
  $visibleCount = $Script:FilteredRows.Count
  $summaryLabel.Text = "Models: $modelCount    S2: $s2Count    UOT: $uotCount    Other: $otherCount    Visible: $visibleCount"
  Update-DoughnutData
}

function Get-ChartCategory {
  param($Row)

  $text = "$($Row.FileName) $($Row.FolderPath) $($Row.DocumentType)".ToLowerInvariant()
  if ($text -match "distribution\s*list") { return "Distribution" }
  if ($text -match "thứ\s*tự\s*thao\s*tác|thu\s*tu\s*thao\s*tac|work\s*guide|workguide|guide") { return "Workguide" }
  if ($text -match "sop") { return "SOP" }
  if ($Row.DocumentType -eq "Material List") { return "Material List" }
  return "Other"
}

function Update-DoughnutData {
  $groups = @($Script:FilteredRows | ForEach-Object {
    [pscustomobject]@{ Category = Get-ChartCategory -Row $_ }
  } | Group-Object Category | Sort-Object Count -Descending)

  $topGroups = @($groups | Select-Object -First 3)
  $otherTotal = 0
  if ($groups.Count -gt 3) {
    $otherTotal = @($groups | Select-Object -Skip 3 | Measure-Object Count -Sum).Sum
  }

  $Script:DoughnutData = @($topGroups | ForEach-Object {
    [pscustomobject]@{ Name = $_.Name; Count = $_.Count }
  })

  if ($otherTotal -gt 0) {
    $Script:DoughnutData += [pscustomobject]@{ Name = "Other"; Count = $otherTotal }
  }

  if ($Script:DoughnutData.Count -gt 0) {
    $chartLegendLabel.Text = (($Script:DoughnutData | ForEach-Object { "$($_.Name): $($_.Count)" }) -join "  |  ")
  }
  else {
    $chartLegendLabel.Text = "No data"
  }

  $chartPanel.Invalidate()
}

function Get-SelectedRow {
  if ($listView.SelectedItems.Count -gt 0) {
    return $listView.SelectedItems[0].Tag
  }

  if ($treeView.SelectedNode -and $treeView.SelectedNode.Tag) {
    $tag = $treeView.SelectedNode.Tag
    if ($tag -is [array]) {
      return $tag[0]
    }
    return $tag
  }

  return $null
}

function Open-SelectedFile {
  $row = Get-SelectedRow
  if (-not $row) {
    [System.Windows.Forms.MessageBox]::Show("Select a file first.", "No file selected") | Out-Null
    return
  }

  if (Test-Path -LiteralPath $row.FullPath) {
    Start-Process -FilePath $row.FullPath
  }
  else {
    [System.Windows.Forms.MessageBox]::Show("File not found:`r`n$($row.FullPath)", "Cannot open file") | Out-Null
  }
}

function Open-SelectedFolder {
  $row = Get-SelectedRow
  if (-not $row) {
    [System.Windows.Forms.MessageBox]::Show("Select a file or folder first.", "No selection") | Out-Null
    return
  }

  if (Test-Path -LiteralPath $row.FolderPath) {
    $argument = '/select,"{0}"' -f $row.FullPath
    Start-Process -FilePath "explorer.exe" -ArgumentList $argument
  }
  else {
    [System.Windows.Forms.MessageBox]::Show("Folder not found:`r`n$($row.FolderPath)", "Cannot open folder") | Out-Null
  }
}

function Copy-SelectedPath {
  $row = Get-SelectedRow
  if (-not $row) {
    [System.Windows.Forms.MessageBox]::Show("Select one row first.", "No selection") | Out-Null
    return
  }

  [System.Windows.Forms.Clipboard]::SetText($row.FullPath)
  Set-Status "Copied path: $($row.FullPath)"
}

function Set-UiLanguage {
  $language = [string]$languageCombo.SelectedItem

  switch ($language) {
    "Vietnamese" {
      $pathLabel.Text = "Thư mục server"
      $searchLabel.Text = "Tìm"
      $processLabel.Text = "Process"
      $typeLabel.Text = "Loại"
      $browseButton.Text = "Chọn"
      $scanButton.Text = "Quét"
      $quickFileLabel.Text = "Tên file"
      $chartTitleLabel.Text = "Top nhóm tài liệu"
      $openFileButton.Text = "Mở file"
      $openFolderButton.Text = "Mở thư mục"
      $copyButton.Text = "Copy path"
      $languageLabel.Text = "Ngôn ngữ"
      $listView.Columns[0].Text = "Model"
      $listView.Columns[1].Text = "Code system"
      $listView.Columns[2].Text = "Area"
      $listView.Columns[3].Text = "Item code"
      $listView.Columns[4].Text = "Loại tài liệu"
      $listView.Columns[5].Text = "Loại file"
      $listView.Columns[6].Text = "Tên file"
      $listView.Columns[7].Text = "Cập nhật"
      $listView.Columns[8].Text = "KB"
      $listView.Columns[9].Text = "Thư mục"
    }
    "Korean" {
      $pathLabel.Text = "서버 폴더"
      $searchLabel.Text = "검색"
      $processLabel.Text = "공정"
      $typeLabel.Text = "유형"
      $browseButton.Text = "찾기"
      $scanButton.Text = "스캔"
      $quickFileLabel.Text = "파일명"
      $chartTitleLabel.Text = "상위 문서 그룹"
      $openFileButton.Text = "파일 열기"
      $openFolderButton.Text = "폴더 열기"
      $copyButton.Text = "경로 복사"
      $languageLabel.Text = "언어"
      $listView.Columns[0].Text = "모델"
      $listView.Columns[1].Text = "코드 시스템"
      $listView.Columns[2].Text = "구역"
      $listView.Columns[3].Text = "아이템 코드"
      $listView.Columns[4].Text = "문서 유형"
      $listView.Columns[5].Text = "파일 유형"
      $listView.Columns[6].Text = "파일명"
      $listView.Columns[7].Text = "수정일"
      $listView.Columns[8].Text = "KB"
      $listView.Columns[9].Text = "폴더"
    }
    default {
      $pathLabel.Text = "Server folder"
      $searchLabel.Text = "Search"
      $processLabel.Text = "Process"
      $typeLabel.Text = "Type"
      $browseButton.Text = "Browse"
      $scanButton.Text = "Scan"
      $quickFileLabel.Text = "File name"
      $chartTitleLabel.Text = "Top document groups"
      $openFileButton.Text = "Open file"
      $openFolderButton.Text = "Open folder"
      $copyButton.Text = "Copy path"
      $languageLabel.Text = "Language"
      $listView.Columns[0].Text = "Model"
      $listView.Columns[1].Text = "Code system"
      $listView.Columns[2].Text = "Area"
      $listView.Columns[3].Text = "Item code"
      $listView.Columns[4].Text = "Doc type"
      $listView.Columns[5].Text = "File type"
      $listView.Columns[6].Text = "File name"
      $listView.Columns[7].Text = "Updated"
      $listView.Columns[8].Text = "KB"
      $listView.Columns[9].Text = "Folder"
    }
  }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Management Newline SOP - Innovation Team, design by TheQuang"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(1180, 760)
$form.MinimumSize = New-Object System.Drawing.Size(980, 620)

$main = New-Object System.Windows.Forms.TableLayoutPanel
$main.Dock = "Fill"
$main.RowCount = 5
$main.ColumnCount = 1
$main.Padding = New-Object System.Windows.Forms.Padding(12)
[void]$main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 78)))
[void]$main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 48)))
[void]$main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 38)))
[void]$main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$main.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 30)))
$form.Controls.Add($main)

$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock = "Fill"
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Management Newline SOP - Innovation Team"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(0, 0)
$titleLabel.Size = New-Object System.Drawing.Size(720, 34)
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Access the shared Z: drive to view SOPs, Work Guides, and Material Lists directly in Windows Explorer. Designed by TheQuang."
$subtitleLabel.Location = New-Object System.Drawing.Point(2, 39)
$subtitleLabel.Size = New-Object System.Drawing.Size(930, 24)
$subtitleLabel.ForeColor = [System.Drawing.Color]::DimGray
$languageLabel = New-Object System.Windows.Forms.Label
$languageLabel.Text = "Language"
$languageLabel.Size = New-Object System.Drawing.Size(78, 24)
$languageLabel.TextAlign = "MiddleRight"
$languageCombo = New-Object System.Windows.Forms.ComboBox
$languageCombo.DropDownStyle = "DropDownList"
$languageCombo.Size = New-Object System.Drawing.Size(128, 26)
[void]$languageCombo.Items.Add("English")
[void]$languageCombo.Items.Add("Vietnamese")
[void]$languageCombo.Items.Add("Korean")
$languageCombo.SelectedIndex = 0
function Position-LanguageControls {
  $rightPadding = 0
  $gap = 6
  $languageCombo.Left = [Math]::Max(0, $headerPanel.ClientSize.Width - $languageCombo.Width - $rightPadding)
  $languageCombo.Top = 1
  $languageLabel.Left = [Math]::Max(0, $languageCombo.Left - $languageLabel.Width - $gap)
  $languageLabel.Top = 2
  $availableSubtitleWidth = $languageLabel.Left - $subtitleLabel.Left - 12
  $subtitleLabel.Width = [Math]::Max(320, $availableSubtitleWidth)
}
$headerPanel.Add_Resize({ Position-LanguageControls })
$headerPanel.Controls.Add($titleLabel)
$headerPanel.Controls.Add($subtitleLabel)
$headerPanel.Controls.Add($languageLabel)
$headerPanel.Controls.Add($languageCombo)
$main.Controls.Add($headerPanel, 0, 0)

$pathPanel = New-Object System.Windows.Forms.TableLayoutPanel
$pathPanel.Dock = "Fill"
$pathPanel.ColumnCount = 4
[void]$pathPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 86)))
[void]$pathPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$pathPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 96)))
[void]$pathPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 132)))
$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Text = "Server folder"
$pathLabel.Dock = "Fill"
$pathLabel.TextAlign = "MiddleLeft"
$rootBox = New-Object System.Windows.Forms.TextBox
$rootBox.Text = $DefaultRoot
$rootBox.Dock = "Fill"
$rootBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Browse"
$browseButton.Dock = "Fill"
$scanButton = New-Object System.Windows.Forms.Button
$scanButton.Text = "Scan"
$scanButton.Dock = "Fill"
$scanButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$pathPanel.Controls.Add($pathLabel, 0, 0)
$pathPanel.Controls.Add($rootBox, 1, 0)
$pathPanel.Controls.Add($browseButton, 2, 0)
$pathPanel.Controls.Add($scanButton, 3, 0)
$main.Controls.Add($pathPanel, 0, 1)

$filterPanel = New-Object System.Windows.Forms.TableLayoutPanel
$filterPanel.Dock = "Fill"
$filterPanel.ColumnCount = 8
[void]$filterPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 64)))
[void]$filterPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$filterPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 72)))
[void]$filterPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 98)))
[void]$filterPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 58)))
[void]$filterPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 108)))
[void]$filterPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 128)))
[void]$filterPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 128)))

$searchLabel = New-Object System.Windows.Forms.Label
$searchLabel.Text = "Search"
$searchLabel.Dock = "Fill"
$searchLabel.TextAlign = "MiddleLeft"
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Dock = "Fill"
$searchBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$processLabel = New-Object System.Windows.Forms.Label
$processLabel.Text = "Process"
$processLabel.Dock = "Fill"
$processLabel.TextAlign = "MiddleCenter"
$processCombo = New-Object System.Windows.Forms.ComboBox
$processCombo.DropDownStyle = "DropDownList"
$processCombo.Dock = "Fill"
[void]$processCombo.Items.Add("All")
[void]$processCombo.Items.Add("S2")
[void]$processCombo.Items.Add("UOT")
[void]$processCombo.Items.Add("OTHER")
$processCombo.SelectedIndex = 0
$typeLabel = New-Object System.Windows.Forms.Label
$typeLabel.Text = "Type"
$typeLabel.Dock = "Fill"
$typeLabel.TextAlign = "MiddleCenter"
$typeCombo = New-Object System.Windows.Forms.ComboBox
$typeCombo.DropDownStyle = "DropDownList"
$typeCombo.Dock = "Fill"
[void]$typeCombo.Items.Add("All")
[void]$typeCombo.Items.Add("PDF")
[void]$typeCombo.Items.Add("Excel")
[void]$typeCombo.Items.Add("PowerPoint")
[void]$typeCombo.Items.Add("Word")
[void]$typeCombo.Items.Add("Access")
[void]$typeCombo.Items.Add("Project")
[void]$typeCombo.Items.Add("Publisher")
[void]$typeCombo.Items.Add("OneNote")
[void]$typeCombo.Items.Add("Video")
[void]$typeCombo.Items.Add("AutoCAD")
[void]$typeCombo.Items.Add("Visio")
[void]$typeCombo.Items.Add("Text")
[void]$typeCombo.Items.Add("Image")
[void]$typeCombo.Items.Add("Other")
$typeCombo.SelectedIndex = 0
$openFileButton = New-Object System.Windows.Forms.Button
$openFileButton.Text = "Open file"
$openFileButton.Dock = "Fill"
$openFolderButton = New-Object System.Windows.Forms.Button
$openFolderButton.Text = "Open folder"
$openFolderButton.Dock = "Fill"

$filterPanel.Controls.Add($searchLabel, 0, 0)
$filterPanel.Controls.Add($searchBox, 1, 0)
$filterPanel.Controls.Add($processLabel, 2, 0)
$filterPanel.Controls.Add($processCombo, 3, 0)
$filterPanel.Controls.Add($typeLabel, 4, 0)
$filterPanel.Controls.Add($typeCombo, 5, 0)
$filterPanel.Controls.Add($openFileButton, 6, 0)
$filterPanel.Controls.Add($openFolderButton, 7, 0)
$main.Controls.Add($filterPanel, 0, 2)

$split = New-Object System.Windows.Forms.SplitContainer
$split.Dock = "Fill"
$split.SplitterDistance = 330
$split.Panel1MinSize = 260
$split.Panel2MinSize = 520

$treeView = New-Object System.Windows.Forms.TreeView
$treeView.Dock = "Fill"
$treeView.HideSelection = $false
$split.Panel1.Controls.Add($treeView)

$rightPanel = New-Object System.Windows.Forms.TableLayoutPanel
$rightPanel.Dock = "Fill"
$rightPanel.RowCount = 2
$rightPanel.ColumnCount = 1
[void]$rightPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 132)))
[void]$rightPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))

$dashboardPanel = New-Object System.Windows.Forms.TableLayoutPanel
$dashboardPanel.Dock = "Fill"
$dashboardPanel.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$dashboardPanel.ColumnCount = 2
$dashboardPanel.RowCount = 1
$dashboardPanel.Padding = New-Object System.Windows.Forms.Padding(0, 0, 0, 8)
[void]$dashboardPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$dashboardPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 320)))

$dashboardLeftPanel = New-Object System.Windows.Forms.TableLayoutPanel
$dashboardLeftPanel.Dock = "Fill"
$dashboardLeftPanel.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$dashboardLeftPanel.RowCount = 4
$dashboardLeftPanel.ColumnCount = 1
[void]$dashboardLeftPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 28)))
[void]$dashboardLeftPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 34)))
[void]$dashboardLeftPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 24)))
[void]$dashboardLeftPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))

$summaryLabel = New-Object System.Windows.Forms.Label
$summaryLabel.Text = "Models: 0    S2: 0    UOT: 0    Other: 0    Visible: 0"
$summaryLabel.Dock = "Fill"
$summaryLabel.TextAlign = "MiddleLeft"
$summaryLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$summaryLabel.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$dashboardLeftPanel.Controls.Add($summaryLabel, 0, 0)

$quickFilePanel = New-Object System.Windows.Forms.TableLayoutPanel
$quickFilePanel.Dock = "Fill"
$quickFilePanel.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$quickFilePanel.ColumnCount = 2
[void]$quickFilePanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 92)))
[void]$quickFilePanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$quickFileLabel = New-Object System.Windows.Forms.Label
$quickFileLabel.Text = "File name"
$quickFileLabel.Dock = "Fill"
$quickFileLabel.TextAlign = "MiddleLeft"
$quickFileBox = New-Object System.Windows.Forms.TextBox
$quickFileBox.Dock = "Fill"
$quickFileBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$quickFilePanel.Controls.Add($quickFileLabel, 0, 0)
$quickFilePanel.Controls.Add($quickFileBox, 1, 0)
$dashboardLeftPanel.Controls.Add($quickFilePanel, 0, 1)

$chartTitleLabel = New-Object System.Windows.Forms.Label
$chartTitleLabel.Text = "Top document groups"
$chartTitleLabel.Dock = "Fill"
$chartTitleLabel.TextAlign = "MiddleLeft"
$chartTitleLabel.ForeColor = [System.Drawing.Color]::DimGray
$chartTitleLabel.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$dashboardLeftPanel.Controls.Add($chartTitleLabel, 0, 2)

$chartLegendLabel = New-Object System.Windows.Forms.Label
$chartLegendLabel.Text = "No data"
$chartLegendLabel.Dock = "Fill"
$chartLegendLabel.TextAlign = "TopLeft"
$chartLegendLabel.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$dashboardLeftPanel.Controls.Add($chartLegendLabel, 0, 3)

$chartPanel = New-Object System.Windows.Forms.Panel
$chartPanel.Dock = "Fill"
$chartPanel.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$chartPanel.Add_Paint({
  param($sender, $e)

  $graphics = $e.Graphics
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.Clear([System.Drawing.Color]::FromArgb(242, 242, 242))

  $data = @($Script:DoughnutData)
  $total = @($data | Measure-Object Count -Sum).Sum
  if (-not $total -or $total -le 0) {
    $emptyPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(190, 190, 190), 18)
    $graphics.DrawEllipse($emptyPen, 22, 22, 84, 84)
    $noDataFont = New-Object System.Drawing.Font("Segoe UI", 9)
    $graphics.DrawString("No data", $noDataFont, [System.Drawing.Brushes]::DimGray, 128, 52)
    $noDataFont.Dispose()
    $emptyPen.Dispose()
    return
  }

  $colors = @(
    [System.Drawing.Color]::FromArgb(64, 64, 64),
    [System.Drawing.Color]::FromArgb(108, 108, 108),
    [System.Drawing.Color]::FromArgb(155, 155, 155),
    [System.Drawing.Color]::FromArgb(205, 205, 205)
  )
  $rect = New-Object System.Drawing.Rectangle(20, 18, 88, 88)
  $startAngle = -90.0
  for ($i = 0; $i -lt $data.Count; $i++) {
    $sweep = [double]$data[$i].Count / [double]$total * 360.0
    $brush = New-Object System.Drawing.SolidBrush($colors[$i % $colors.Count])
    $graphics.FillPie($brush, $rect, [single]$startAngle, [single]$sweep)
    $brush.Dispose()
    $startAngle += $sweep
  }
  $innerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242, 242, 242))
  $graphics.FillEllipse($innerBrush, 45, 43, 38, 38)
  $innerBrush.Dispose()
  $font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Center
  $totalRect = New-Object System.Drawing.RectangleF -ArgumentList 45, 43, 38, 38
  $graphics.DrawString([string]$total, $font, [System.Drawing.Brushes]::Black, $totalRect, $format)

  $labelFont = New-Object System.Drawing.Font("Segoe UI", 8)
  for ($i = 0; $i -lt $data.Count; $i++) {
    $labelY = 14 + ($i * 24)
    $swatchBrush = New-Object System.Drawing.SolidBrush($colors[$i % $colors.Count])
    $graphics.FillRectangle($swatchBrush, 128, $labelY + 4, 12, 12)
    $swatchBrush.Dispose()
    $percent = [Math]::Round(([double]$data[$i].Count / [double]$total) * 100, 1)
    $labelText = "$($data[$i].Name): $($data[$i].Count) ($percent`%)"
    $graphics.DrawString($labelText, $labelFont, [System.Drawing.Brushes]::DimGray, 146, $labelY)
  }
  $labelFont.Dispose()
  $font.Dispose()
  $format.Dispose()
})

$dashboardPanel.Controls.Add($dashboardLeftPanel, 0, 0)
$dashboardPanel.Controls.Add($chartPanel, 1, 0)
$rightPanel.Controls.Add($dashboardPanel, 0, 0)

$listView = New-Object System.Windows.Forms.ListView
$listView.Dock = "Fill"
$listView.View = "Details"
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.HideSelection = $false
[void]$listView.Columns.Add("Model", 120)
[void]$listView.Columns.Add("Code system", 150)
[void]$listView.Columns.Add("Area", 70)
[void]$listView.Columns.Add("Item code", 100)
[void]$listView.Columns.Add("Doc type", 100)
[void]$listView.Columns.Add("File type", 90)
[void]$listView.Columns.Add("File name", 260)
[void]$listView.Columns.Add("Updated", 130)
[void]$listView.Columns.Add("KB", 70)
[void]$listView.Columns.Add("Folder", 300)
$rightPanel.Controls.Add($listView, 0, 1)
$split.Panel2.Controls.Add($rightPanel)
$main.Controls.Add($split, 0, 3)

$bottomPanel = New-Object System.Windows.Forms.TableLayoutPanel
$bottomPanel.Dock = "Fill"
$bottomPanel.ColumnCount = 2
[void]$bottomPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$bottomPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 120)))
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Ready."
$statusLabel.Dock = "Fill"
$statusLabel.TextAlign = "MiddleLeft"
$copyButton = New-Object System.Windows.Forms.Button
$copyButton.Text = "Copy path"
$copyButton.Dock = "Fill"
$bottomPanel.Controls.Add($statusLabel, 0, 0)
$bottomPanel.Controls.Add($copyButton, 1, 0)
$main.Controls.Add($bottomPanel, 0, 4)

$scanButton.Add_Click({ Scan-SopFolder -RootPath $rootBox.Text.Trim() })
$browseButton.Add_Click({
  $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
  $dialog.Description = "Select SOP root folder"
  $dialog.SelectedPath = $rootBox.Text.Trim()
  if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $rootBox.Text = $dialog.SelectedPath
    Scan-SopFolder -RootPath $rootBox.Text.Trim()
  }
})
$searchBox.Add_TextChanged({ Apply-Filters })
$quickFileBox.Add_TextChanged({ Apply-Filters })
$processCombo.Add_SelectedIndexChanged({ Apply-Filters })
$typeCombo.Add_SelectedIndexChanged({ Apply-Filters })
$languageCombo.Add_SelectedIndexChanged({ Set-UiLanguage })
$openFileButton.Add_Click({ Open-SelectedFile })
$openFolderButton.Add_Click({ Open-SelectedFolder })
$copyButton.Add_Click({ Copy-SelectedPath })
$listView.Add_DoubleClick({ Open-SelectedFile })
$treeView.Add_AfterSelect({
  if ($treeView.SelectedNode -and $treeView.SelectedNode.Tag) {
    $Script:FilteredRows = @($treeView.SelectedNode.Tag)
    Render-List
    Update-Summary
  }
})

$form.Add_Shown({
  Position-LanguageControls
  if (Test-Path -LiteralPath $rootBox.Text.Trim()) {
    Scan-SopFolder -RootPath $rootBox.Text.Trim()
  }
  else {
    Set-Status "Drive Z not found. Check network drive connection, then click Scan."
  }
})

[void][System.Windows.Forms.Application]::Run($form)
