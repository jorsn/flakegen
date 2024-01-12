# Do not modify! This file is generated.

{
  description = "A very basic flake";

  inputs.flakegen.url = "github:jorsn/flakegen";

  outputs = { flakegen, ... }: flakegen ./. {};
}
