{

  description = "The real nix file";

  inputs = let
    dep = url: { inherit url; inputs.nixpkgs.follows = "nixpkgs"; };
  in {
    # flakegen needn't be declared, here. It is automatically added when
    # generating flake.nix.
    nixlib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = (dep "github:LnL7/nix-darwin");
    home-manager = (dep "github:nix-community/home-manager");
  };

  outputs = { nixpkgs, ... }@inputs: {
    # you can write the outputs as usual. They will be called from the generated
    # flake.nix.
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
  };

}
