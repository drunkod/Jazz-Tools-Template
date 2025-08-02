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

        # Test sync server URL
        testSyncUrl = "ws://localhost:4200";

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

              systemd.services.jazz-sync = {
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                  ExecStart = "${pkgs.nodejs_20}/bin/npx jazz-run sync-server --port 4200";
                };
              };
            };

            testScript = ''
              server.wait_for_unit("jazz-sync.service")
              server.wait_for_open_port(4200)
            '';
          };

          # Test basic data flow
          dataFlowTest = pkgs.writeShellScriptBin "test-data-flow" ''
            echo "🧪 Testing Jazz data flow..."

            # Start sync server in background
            ${pkgs.nodejs_20}/bin/npx jazz-run sync-server --port 4200 &
            SYNC_PID=$!
            sleep 2

            # Run test
            ${pkgs.nodejs_20}/bin/node tests/test-flow.js
            TEST_RESULT=$?

            # Cleanup
            kill $SYNC_PID

            exit $TEST_RESULT
          '';
        };
      });
}
