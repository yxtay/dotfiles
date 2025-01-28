{ inputs, ... }:
{
  imports = [
    inputs.nixos-unified.flakeModules.default
    # inputs.nixos-unified.flakeModules.autoWire
  ];
}
