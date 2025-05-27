function Send-WOL{
    Param([string]$HWAddress)
    $PacketArrary = $HWAddress -split "[:-]" | ForEach-Object { [Byte] "0x$_"}
    [Byte[]] $MagicPacket = (,0xFF * 6) + ($PacketArrary  * 16)
    $UdpClient = New-Object System.Net.Sockets.UdpClient
    $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),7)
    $UdpClient.Send($MagicPacket,$MagicPacket.Length)
    $UdpClient.Close()
}

#Send-WOL -HWAddress <MAC in ##:##:##:##:##:## OR ##-##-##-##-##-## format>
