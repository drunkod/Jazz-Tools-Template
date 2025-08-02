{
  description = "Minimal Jazz-Tools project template with tests";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Create a derivation with pre-installed node modules
        jazzProject = pkgs.stdenv.mkDerivation {
          name = "jazz-tools-template";
          src = ./.;

          buildInputs = [ pkgs.nodejs_20 ];

          buildPhase = ''
            export HOME=$TMPDIR
            npm install --production
          '';

          installPhase = ''
            mkdir -p $out
            cp -r * $out/
            cp -r node_modules $out/
          '';
        };

      in {
        # Development shell
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

        # Basic tests
        checks = {
          # Test Jazz sync server connectivity
          syncServerTest = pkgs.testers.runNixOSTest {
            name = "jazz-sync-test";

            nodes.server = { pkgs, ... }: {
              networking.firewall.allowedTCPPorts = [ 4200 ];

              environment.systemPackages = [ pkgs.nodejs_20 ];

              systemd.services.jazz-sync = {
                wantedBy = [ "multi-user.target" ];
                path = [ pkgs.nodejs_20 ];
                serviceConfig = {
                  WorkingDirectory = "${jazzProject}";
                  ExecStart = "${pkgs.nodejs_20}/bin/node ${jazzProject}/node_modules/.bin/jazz-run sync-server --port 4200";
                  Restart = "on-failure";
                };
              };
            };

            testScript = ''
              server.wait_for_unit("jazz-sync.service")
              server.wait_for_open_port(4200)

              # Verify the service is actually running
              server.succeed("systemctl is-active jazz-sync.service")
            '';
          };

          # Test basic data flow
          dataFlowTest = pkgs.writeShellScriptBin "test-data-flow" ''
            echo "🧪 Testing Jazz data flow..."

            # Copy project with dependencies
            cp -r ${jazzProject}/* .
            export PATH="${pkgs.nodejs_20}/bin:$PATH"

            # Start sync server in background
            node node_modules/.bin/jazz-run sync-server --port 4200 &
            SYNC_PID=$!
            sleep 2

            # Run test
            node tests/test-flow.js
            TEST_RESULT=$?

            # Cleanup
            kill $SYNC_PID

            exit $TEST_RESULT
          '';
        };

        # Package the project
        packages.default = jazzProject;
      });
}
