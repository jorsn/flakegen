{
  description = "Flake inputs with the full power of Nixlang";

  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, systems }: with builtins; with self.lib; {

    templates.default = {
      description = "Default template";
      path = ./template;
    };

    __functor = _: path: let s = import systems; in { systems ? s, inputFile ?  "flake.in.nix", apps ? {}, ... }@outputAttrs:
      {
        nextFlake = flake path inputFile;
        nextFlakeSource = flakeSource path inputFile;
      }
      // outputAttrs
      // {
        apps = self.lib.genAttrs (system:
          { genflake = { type = "app"; program = ./genflake; }; }
          // apps.${system} or {}
        ) systems;
      };
    
    lib = {

      flake = path: inputFile: toFile "flake.nix" (flakeSource path inputFile);

      flakeSource = path: inputFile:
      let
        attrs = import (path + "/${inputFile}");
        attrs' = attrs // {
          inputs = { flakegen.url = "github:jorsn/flakegen"; } // (attrs.inputs or {});
          outputs = "<outputs>";
        };
      in "# Do not modify! This file is generated.\n\n"
        + replaceStrings
          [ "\"<outputs>\"" ] [ "inputs: inputs.flakegen ./. ((import ./${inputFile}).outputs inputs)" ]
          (toPretty "" attrs')
        ;

      genAttrs = f: names:
        listToAttrs (map (name: { inherit name; value = f name; }) names);

      toPretty =
        let
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
            else if ! isAttrs x
            then toString x
            else let prefix' = prefix + "  "; in ''
              {
              ${mapAttrsToLines (n: v: prefix' + n + printChild prefix' v + ";") x}
              ${prefix}}'';
        in print;
    };

  };

}
