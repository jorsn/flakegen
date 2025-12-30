{
  description = "Flake inputs with the full power of Nixlang";

  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, systems }: with builtins; with self.lib; {

    templates.default = {
      description = "Default template";
      path = ./template;
    };

    __functor = _:
      path':
      inputs:
    let
      path = path' + (if readFileType path' == "directory" then "/flake.in.nix" else "");
      isInputs = attrs: hasAttr "self" attrs && hasAttr "flakeSource" ((attrs.flakegen or {}).lib or {});
      outputAttrs' =
        if !isInputs inputs
        then inputs # compatibility with older flakegen versions where the arg was outputAttrs
        else maybeApply (import path).outputs inputs {
          packages.error."Update flake inputs by running 'nix run .#genflake flake.nix'." = 1;
          #packages = trace "\nUpdate flake inputs by running 'nix run .#genflake flake.nix'.\n" { error = 1; };
        };
      outputAttrs = { apps = {}; systems = import systems; } // outputAttrs';
    in
      {
        nextFlake = flake inputs path;
        nextFlakeSource = flakeSource inputs path;
      }
      // outputAttrs
      // {
        apps = genAttrs (system:
          { genflake = { type = "app"; program = toPath ./genflake; }; }
          // outputAttrs.apps.${system} or {}
        ) outputAttrs.systems;
      };

    lib = {

      flake = inputs: path: toFile "flake.nix" (flakeSource inputs path);

      flakeSource = inputs: path:
      let
        attrs = import path;
        attrs' = attrs // {
          inputs = { flakegen.url = "github:jorsn/flakegen"; } // (attrs.inputs or {});
          outputs = "<outputs>";
        };
        relPathString = replaceStrings [ inputs.self.outPath ] [ "." ] (toPath path);
      in ''
        # Do not modify! This file is generated.
        # One exception: If you use a different template than "flake.in.nix" set
        #                its relative path through the first argument to inputs.flakegen.

        ''
        + replaceStrings
          [ "\"<outputs>\"" ] [ "inputs: inputs.flakegen ${relPathString} inputs" ]
          (toPretty "" attrs')
        ;

      genAttrs = f: names:
        listToAttrs (map (name: { inherit name; value = f name; }) names);

      maybeApply = f: args: default: if missingArgs f args == [] then f args else default;

      # list all required args of a function 'f' that are missing in 'args'
      missingArgs = f: args:
        let
          declared = functionArgs f;
        in filter (n: !declared.${n} && !hasAttr n args) (attrNames declared);

      toPretty =
        let
          # from nixpkgs
          isDerivation =
            # Value to check.
            value: value.type or null == "derivation";

          printChild = prefix: x:
            let
              names = attrNames x;
            in
            if isAttrs x && length names == 1
            then "." + head names + printChild prefix x.${head names}
            else " = " + print prefix x
            ;

          mapAttrsToList = f: attrs: attrValues (mapAttrs f attrs);
          mapAttrsToLines = f: attrs: concatStringsSep "\n" (mapAttrsToList f attrs);
          print = prefix: x:
            if isString x
            then "\"${x}\""
            else if isList x
            then "[ ${toString (map (el: toPretty prefix el) x)} ]"
            else if isBool x
            then (if x then "true" else "false")
            else if isNull x then "null"
            else if ! isAttrs x || isDerivation x
            then toString x
            else let prefix' = prefix + "  "; in ''
              {
              ${mapAttrsToLines (n: v: prefix' + n + printChild prefix' v + ";") x}
              ${prefix}}'';
        in print;
    };

  };

}
