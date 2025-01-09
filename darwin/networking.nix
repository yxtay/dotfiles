{...}: {
  networking = {
    knownNetworkServices = [
      "Wi-Fi"
      # "Thunderbolt Bridge"
    ];
    dns = [
      # adguard
      "94.140.14.14"
      "2a10:50c0::ad1:ff"
      # mullvad
      "194.242.2.4"
      "2a07:e340::4"
    ];
  };
}
