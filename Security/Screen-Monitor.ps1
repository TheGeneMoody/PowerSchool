#admin config
$quality = 50  #1-100%
#hour 24hr format
$dayStart = 6
$dayend = 17
#0-6 = Sun-Sat
$weekStart = 1
$weekEnd = 5
$cycle = 10 #value in seconds
$target = 'C:\ImgTemp'

[Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$height = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
$width = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$count = [System.Windows.Forms.SystemInformation]::MonitorCount
$bounds = [Drawing.Rectangle]::FromLTRB(0, 0, ($width * $count) , $height)

$font = new-object System.Drawing.Font Consolas,18 
$brush = [System.Drawing.Brushes]::Yellow

$Encoder = [System.Drawing.Imaging.Encoder]::Quality
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($Encoder, $quality)
$ImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | ?{$_.MimeType -eq 'image/jpeg'}
 
function screenshot([Drawing.Rectangle]$bounds, $path) {
   $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
   $graphics = [Drawing.Graphics]::FromImage($bmp)
   $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
   $graphics.DrawString($(Get-Date -f "MM/dd/yyyy HH:mm:ss"),$font,$brush,(($width / 2) - 145),($height - 30)) 
   $bmp.Save($path,$ImageCodecInfo, $($encoderParams))
   $graphics.Dispose()
   $bmp.Dispose()
}

while ($true)
{
    $hour = [int]$(get-date -f HH)
    $dow = [int]$(Get-Date).DayOfweek
    if ((($dow -ge $weekStart) -and ($dow -le $weekEnd)) -and (($hour -ge $dayStart) -and ($hour -lt $dayEnd))) {
        $root = "$target\$($env:USERNAME)@$($env:COMPUTERNAME)\$(Get-Date -f yyyyMMdd)"
        if (-not (Test-Path -Path $root)){New-Item -ItemType Directory $root}
        screenshot $bounds "$root\$(Get-Date -f HH.mm.ss).jpg"
    }
    Start-Sleep -Seconds $cycle
}
