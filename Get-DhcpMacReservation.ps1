
<#
        .SYNOPSIS
        Creates a Cisco DHCP MAC reservation pool configuration from a supplied IP, MAC CSV.

        .DESCRIPTION
        Creates a Cisco DHCP MAC reservation pool configuration from a supplied IP, MAC CSV.
        For each IP, MAC this script creates a ip dhcp excluded-address and
        a matching dhcp pool named MAC-X. The MAC address is "cleaned up" and prepended with a 01

        .PARAMETER DefaultRouter
        the defautl gateway used for all dhcp pools.
        .PARAMETER NetworkIp
        The network IP used for the main DHCP pool.
        .PARAMETER NetworkMask
        The network mask used for all DHCP pools.
        Four-part dotted-decimal format used as input
        .PARAMETER PoolName
        The named used for the main DHCP pool.
        .PARAMETER CsvPath
        The path to the CSV file with the format IP, MAC.

        .OUTPUTS
        System.String. Get-DhcpMacReservation return a string containing the DHCP configuration.

        .EXAMPLE
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
                default-router 10.0.0.1
        exit
        ip dhcp pool MAC-1
                host 192.168.1.20 255.255.255.0
                client-identifier 01005079666801
                default-router 10.0.0.1
        exit
        ip dhcp pool MAC-2
                host 192.168.1.30 255.255.255.0
                client-identifier 0100AA79FF6801
                default-router 10.0.0.1
        exit
        .EXAMPLE
        PS> Get-DhcpMacReservation -CsvPath reservation-list.csv >> output.txt
#>
Param(
    [String] $DefaultRouter = "192.168.1.1",
    [String] $NetworkIp = "192.168.1.0",
    [String] $NetworkMask = "255.255.255.0",
    [String] $PoolName = "POOL_LAN",
    [Parameter(Mandatory = $true)]
    [String] $CsvPath
)
Begin {
    function Test-IpInput {
        Param(
            [String]$InputString
        )
        if ($InputString -notmatch "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$") {
            throw "Invalid IP input: $InputString is not a valid IP. example: 192.168.1.1";
        }
    }
    Test-IpInput -InputString $DefaultRouter;
    Test-IpInput -InputString $NetworkIp;
    Test-IpInput -InputString $NetworkMask;
    [String]$dhcp_conf = "";
    [System.Collections.ArrayList]$excluded_ip_address = @();
    [System.Collections.ArrayList]$excluded_mac_address = @();
    $list = Import-Csv -Path $CsvPath -Header "IP", "MAC";
    foreach ($reserve in $list) {
        Test-IpInput -InputString $reserve.ip;
        $null = $excluded_ip_address.Add($reserve.ip);
        $null = $excluded_mac_address.Add($reserve.mac);
    }
}
Process {
    for ($i = 0; $i -lt $excluded_mac_address.Count; $i++) {
        # Remove any non a-z, A-Z, 0-9 char
        $excluded_mac_address[$i] = $excluded_mac_address[$i] -replace '[\W]', '';
        $excluded_mac_address[$i] = [String]::Format("01{0}", $excluded_mac_address[$i]);
    }

    for ($i = 0; $i -lt $excluded_ip_address.Count; $i++) {
        $dhcp_conf += [String]::Format("ip dhcp excluded-address {0}`n", $excluded_ip_address[$i]);  
    }
    $dhcp_conf += [String]::Format("ip dhcp pool {0}`n`tnetwork {1} {2}`n`tdefault-router {3}`nexit`n", $PoolName, $NetworkIp, $NetworkMask, $DefaultRouter);

    for ($i = 0; $i -lt $excluded_ip_address.Count; $i++) {
        $dhcp_conf += [String]::Format("ip dhcp pool MAC-{0}`n`thost {1} {2}`n`tclient-identifier {3}`n`tdefault-router {4}`nexit`n", $i, $excluded_ip_address[$i], $NetworkMask, $excluded_mac_address[$i], $DefaultRouter);
    }
}
End {
    return $dhcp_conf;
}
