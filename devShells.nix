{ pkgs, ... }: {
	default = pkgs.mkShell {
		nativeBuildInputs = with pkgs; [ alejandra neovim ];
	};
}
