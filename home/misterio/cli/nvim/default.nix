{ config, pkgs, ... }:

{
  imports = [ ./lsp.nix ];

  home = {
    sessionVariables.EDITOR = "nvim";
    preferredApps.editor = {
      cmd = config.home.preferredApps.terminal.cmd-spawn "nvim";
    };
  };

  programs.neovim = {
    enable = true;

    extraConfig = /* vim */ ''
      "Use truecolor
      set termguicolors

      "Set fold level to highest in file
      "so everything starts out unfolded at just the right level
      autocmd BufWinEnter * let &foldlevel = max(map(range(1, line('$')), 'foldlevel(v:val)'))

      "Tabs
      set ts=4 sts=4 sw=4 "4 char-wide tab
      set expandtab "Use spaces
      autocmd FileType json,html,htmldjango,hamlet,nix,scss,typescript,php,haskell,terraform setlocal ts=2 sts=2 sw=2 "2 char-wide overrides

      "Set tera to use htmldjango syntax
      autocmd BufRead,BufNewFile *.tera setfiletype htmldjango

      "Options when composing mutt mail
      autocmd FileType mail set noautoindent wrapmargin=0 textwidth=0 linebreak wrap formatoptions +=w

      "Fix nvim size according to terminal
      "(https://github.com/neovim/neovim/issues/11330)
      autocmd VimEnter * silent exec "!kill -s SIGWINCH" getpid()

      "Line numbers
      set number relativenumber

      "Scroll up and down
      nmap <C-j> <C-e>
      nmap <C-k> <C-y>

      "Bind make"
      nmap <space>m <cmd>make<cr>
    '';

    plugins = with pkgs.vimPlugins; [
      # Syntaxes
      rust-vim
      dart-vim-plugin
      plantuml-syntax
      vim-markdown
      vim-nix
      vim-toml
      vim-syntax-shakespeare
      gemini-vim-syntax
      kotlin-vim
      haskell-vim
      mermaid-vim
      pgsql-vim

      # UI
      vim-illuminate
      vim-numbertoggle
      {
        plugin = undotree;
        config = /* vim */ ''
          let g:undotree_SetFocusWhenToggle = 1
          nmap <C-n> :UndotreeToggle<cr>
        '';
      }
      {
        plugin = which-key-nvim;
        config = /* vim */ ''
          lua require('which-key').setup{}
        '';
      }
      {
        plugin = range-highlight-nvim;
        config = /* vim */ ''
          lua require('range-highlight').setup{}
        '';
      }
      {
        plugin = indent-blankline-nvim;
        config = /* vim */ ''
          lua require('indent_blankline').setup{char_highlight_list={'IndentBlankLine'}}
        '';
      }
      {
        plugin = nvim-web-devicons;
        config = /* vim */ ''
          lua require('nvim-web-devicons').setup{}
        '';
      }
      {
        plugin = gitsigns-nvim;
        config = /* vim */ ''
          lua require('gitsigns').setup()
        '';
      }
      {
        plugin = nvim-colorizer-lua;
        config = /* vim */ ''
          set termguicolors
          lua require('colorizer').setup()
        '';
      }

      # Misc
      editorconfig-vim
      vim-surround
      vim-fugitive
      {
        plugin = nvim-autopairs;
        config = /* vim */ ''
          lua require('nvim-autopairs').setup{}
        '';
      }
      {
        plugin = pkgs.writeTextDir "colors/nix-${config.colorscheme.slug}.vim"
          (import ./theme.nix config.colorscheme);
        config = /* vim */ ''
          colorscheme nix-${config.colorscheme.slug}
        '';
      }
    ];
  };

  xdg.configFile."nvim/init.vim".onChange =
    let
      nvr = "${pkgs.neovim-remote}/bin/nvr";
    in
      /* sh */ ''
      ${nvr} --serverlist | while read server; do
        ${nvr} --servername $server --nostart -c ':so $MYVIMRC' & \
      done
    '';

  xdg.desktopEntries = {
    nvim = {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}
