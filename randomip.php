<?php

function generateRandomIPv4($ipRange) {
    // Parse the IP range
    list($ip, $mask) = explode('/', $ipRange);
    $ipLong = ip2long($ip);
    $maskLong = pow(2, (32 - $mask)) - 1;

    // Generate random IP addresses
    $ipAddresses = [];
    for ($i = 0; $i < 10; $i++) {
        $randomIpLong = $ipLong + mt_rand(0, $maskLong);
        $randomIp = long2ip($randomIpLong);
        $ipAddresses[] = $randomIp;
    }

    return $ipAddresses;
}

// Example usage
$ipRange = '10.53.128.0/18';
$randomIPs = generateRandomIPv4($ipRange);

// Print the generated IP addresses
foreach ($randomIPs as $ip) {
    echo $ip . "\n";
}
