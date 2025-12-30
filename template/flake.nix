# If you use a different template than "flake.in.nix" set
# its relative path through the first argument to inputs.flakegen.

{
  description = "A very basic flake";

  inputs.flakegen.url = "github:jorsn/flakegen";

  outputs = inputs: inputs.flakegen ./flake.in.nix inputs;
}
