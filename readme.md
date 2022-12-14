# Get-DhcpMacReservation
Small powershell script that creates a Cisco DHCP MAC reservation pool configuration from a 
supplied IP, MAC CSV. For each IP, MAC this script creates a ip dhcp excluded-address and  
a matching dhcp pool named MAC-X. The MAC address is "cleaned up" and prepended with a 01  

## Usage
``` Powershell
PS> Get-DhcpMacReservation -CsvPath reservation-list.csv -DefaultRouter 10.0.0.1 -NetworkIp 10.0.0.0 -NetworkMask 255.255.255.0 -PoolName LAN-INTER
ip dhcp excluded-address 192.168.1.10
ip dhcp excluded-address 192.168.1.20
ip dhcp excluded-address 192.168.1.30
ip dhcp pool LAN-INTER
    network 10.0.0.0 255.255.255.0
    default-router 10.0.0.1
exit
ip dhcp pool MAC-0
    host 192.168.1.10 255.255.255.0
    client-identifier 01005079666800
exit
ip dhcp pool MAC-1
    host 192.168.1.20 255.255.255.0
    client-identifier 01005079666801
exit
ip dhcp pool MAC-2
    host 192.168.1.30 255.255.255.0
    client-identifier 0100AA79FF6801
exit
```

## TODO
- VRF
- DNS server
- look into supporting pipeline input of IP,mac (maybe not worth the time because the default is csv)
- Media type support currenly have ethernet (01) hard coded



