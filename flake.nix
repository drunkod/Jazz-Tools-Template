{
  description = "A simple Jazz-Tools project template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            nodePackages.pnpm
          ];

          shellHook = ''
            echo "🎷 Jazz-Tools Template"
            echo ""
            echo "Quick start:"
            echo "  pnpm install       - Install dependencies"
            echo "  pnpm start-sync    - Start local sync server"
            echo "  pnpm start-server  - Start Jazz server"
            echo "  pnpm start-client  - Run client example"
            echo "  pnpm test          - Run tests"
            echo ""
          '';
        };
      });
}