# flakegen

In Nix flakes, inputs must be written as pure data, without functions or thunks
(see issues [NixOS/nix#3966](https://github.com/NixOS/nix/issues/3966)
and [NixOS/nix#4945](https://github.com/NixOS/nix/issues/4945)).
To generate inputs with the full power of the Nix language,
one can create a template file, e.g. `flake.in.nix` and generate the
`flake.nix` by evaluating and pretty-printing the `inputs` attribute.

This flake is a convenience wrapper around that.


## Usage

To start using this, run
```
nix flake init -t github:jorsn/flakegen
```

This will create the files `flake.nix` and `flake.in.nix`.
It will not overwrite existing files.
After editing `flake.in.nix` as you like, run
```
nix run .#genflake flake.nix
```
to update the `flake.nix`.
To preview the new `flake.nix` without replacing it, run the following:
```
nix run .#genflake
```
If you prefer to use a different template than `flake.in.nix`, change the
first argument of `inputs.genflake` in  `flake.nix`.


## Repair broken `flake.nix`

You can repair a broken `flake.nix` by
deleting `flake.nix` and running
```
nix flake init -t github:jorsn/flakegen
nix run .#genflake flake.nix
```
as long as `flake.in.nix` works.
