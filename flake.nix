{
  description = "FIXME: A basic starter devshell template";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";
  inputs.nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable
  }: let
    # System types to support.
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
    nixpkgsUnstableFor = forAllSystems (system: import nixpkgs-unstable {inherit system;});
  in {
    # Provide some binary packages for selected system types.
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
      pkgs-unstable = nixpkgsUnstableFor.${system};
    in {
    });

    # Add dependencies that are only needed for development
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
      pkgs-unstable = nixpkgsUnstableFor.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          starship
          # put other package below
          erlang
        ] ++ (with pkgs-unstable; [gleam]);

        shellHook = "
              eval \"$(starship init bash)\";
            ";
      };
    });

    formatter = forAllSystems (
      system:
        nixpkgsFor.${system}.alejandra
    );
  };
}
