# Do not modify! This file is generated.

{
  description = "A very basic flake";

  inputs.flakegen.url = "github:jorsn/flakegen";

  outputs = inputs: inputs.flakegen ./flake.in.nix inputs;
}
