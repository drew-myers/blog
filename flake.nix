{
  description = "Pollen blog — Racket + Pollen dev environment";

  # Reuse the nixpkgs from your Nix registry (that's your system nixpkgs on
  # NixOS), so nothing extra gets downloaded. If you'd rather pin this project
  # for full reproducibility, swap the line below for e.g.
  #   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "nixpkgs";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            # The full Racket distribution is intentional: it already bundles
            # the libraries Pollen depends on (and DrRacket, the editor the
            # Pollen docs recommend). With racket-minimal, `raco` would instead
            # spend minutes rebuilding the whole distribution on first install.
            packages = [
              pkgs.racket
              # Cloudflare Workers CLI, for deploying the built site.
              pkgs.wrangler
              # Jujutsu VCS (and git, which its git backend uses).
              pkgs.jujutsu
              pkgs.git
            ];

            shellHook = ''
              # Install Racket packages into the project instead of the global
              # user scope, so this repo is self-contained.
              project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
              export PLTADDONDIR="$project_root/.racket"

              if ! raco pkg show --scope user pollen 2>/dev/null | grep -q '^pollen'; then
                echo "==> First run: installing Pollen into $PLTADDONDIR (needs network)..."
                raco pkg install --auto -D --scope user pollen
              fi

              echo "Pollen is ready."
              echo "  raco pollen start      # live-preview server on http://localhost:8080"
              echo "  raco pollen render .   # build output files"
            '';
          };
        }
      );
    };
}
