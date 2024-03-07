$file = Get-ChildItem -Path "C:\Users\alsmith1\Desktop\PowershellScripts\SqlFiles\AccessBarcodes" | Select-Object -First 1

$Excel = New-Object -ComObject Excel.Application
$Workbook = $Excel.Workbooks.Open($file.FullName)
$Worksheet = $Workbook.Worksheets.Item(1)

$Range = $Worksheet.Range("T1").EntireColumn
$Range.Font.Name = "3 of 9 Barcode"

$Workbook.Save()
$Excel.Quit()
