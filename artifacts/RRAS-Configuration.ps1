#primary connection

$localIP="172.1.0.4"
$localSubnet="172.1.0.0/16"
$localASN="65414"
$peerIP="192.168.0.13"
$peerASN="65515"
$peername="rl-wu3-vhub-vpngw-instance-0"
$peerPublicIP="20.150.153.222"
$psk="rolightn3494"
$peersubnet=@($peerIP+"/32:100")

Add-VpnS2SInterface -Protocol IKEv2 -AuthenticationMethod PSKOnly -NumberOfTries 3 -ResponderAuthenticationMethod PSKOnly -Name -$peername -Destination $peerPublicIP -IPv4Subnet $peersubnet -PassThru -SharedSecret $psk

Add-BgpRouter -BgpIdentifier $localIP -LocalASN $localASN
Add-BgpPeer -Name $peername -LocalIPAddress $localIP -PeerIPAddress $peerIP -LocalASN $localASN -PeerASN $peerASN -OperationMode Mixed -PeeringMode Automatic
Add-BgpCustomRoute -Network $localSubnet -PassThru

Add-BgpCustomRoute -Network 90.0.0.0/32 -PassThru

# Add second interface and connection
$localASN="65414"
$peerIP="192.168.0.12"
$peerASN="65515"
$peername="rl-wu3-vhub-vpngw-instance-1"
$peerPublicIP="20.150.153.241"
$psk="rolightn3494"
$peersubnet=@($peerIP+"/32:100")

Add-VpnS2SInterface -Protocol IKEv2 -AuthenticationMethod PSKOnly -NumberOfTries 3 -ResponderAuthenticationMethod PSKOnly -Name -$peername -Destination $peerPublicIP -IPv4Subnet $peersubnet -PassThru -SharedSecret $psk
Add-BgpPeer -Name $peername -LocalIPAddress $localIP -PeerIPAddress $peerIP -LocalASN $localASN -PeerASN $peerASN -OperationMode Mixed -PeeringMode Automatic

Get-VpnS2SInterface
Get-BgpPeer
Get-BgpCustomRoute
Get-BgpRouteInformation