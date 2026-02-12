{ pkgs, actions-nvim, ... }:
let
  actions-nvim-plugin = pkgs.vimUtils.buildVimPlugin {
    name = "actions.nvim";
    src = actions-nvim;
  };
in {

  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  opts = {
    nu = true; # show numbers
    relativenumber = true;
    termguicolors = true; # fancier colours
    scrolloff = 12; # scroll at top and bottom of buffer
    signcolumn = "yes"; # always signcolumn, escpecially nice for netrw
    showmode = false; # Doesn't show insert two times in status bar
    breakindent = true; # Indent line-breaks better
                        # like this
    ignorecase = true; # search ignores case
    smartcase = true; # unless it actually contains a capital letter
    autoindent = true;
    smartindent = true; # respect language syntax with indent
    completeopt = "menuone,noselect";

    swapfile = false; # Is this best practice? No. Do I like opening the same file multiple times? Yes. Sorry.
    backup = false;
    undofile = true;
    undolevels = 50000;
    undodir.__raw = "os.getenv('HOME') .. '/.local/share/nvim/undodir'";
    
    hlsearch = true; # highlight search
    incsearch = true; # highlight search realtime   

    updatetime = 50;
    timeoutlen = 100;
  };

  keymaps = [
    {
      key = "<ESC>";
      action = "<C-\\><C-n>";
      mode = "t";
    }
    {
      key = "<leader>sg";
      action.__raw = "require('telescope.builtin').live_grep";
      options.desc = "Search by grep";
    }
    {
      key = "<leader>sf";
      action.__raw = "require('telescope.builtin').find_files";
      options.desc = "Search filenames";
    }
    {
      key = "<leader>sb";
      action.__raw = "require('telescope.builtin').buffers";
      options.desc = "Search buffers";
    }
    {
      key = "<leader>sr";
      action.__raw = "require('telescope.builtin').registers";
      options.desc = "Search registers";
    }
    {
      key = "<leader>le";
      action.__raw = "vim.diagnostic.open_float";
      options.desc = "View LSP diagnostic message";
    }
    {
      key = "<leader>lE";
      action.__raw = "require('telescope.builtin').diagnostics";
      options.desc = "View all LSP diagnostic messages";
    }
    {
      key = "<leader>lr";
      action.__raw = "vim.lsp.buf.definition";
      options.desc = "Rename LSP symbol";
    }
    {
      key = "<leader>gi";
      action.__raw = "require('telescope.builtin').lsp_implementations";
      options.desc = "Goto LSP implementation";
    }
    {
      key = "<leader>gd";
      action.__raw = "require('telescope.builtin').lsp_definitions";
      options.desc = "Goto LSP definition";
    }
    {
      key = "<leader>gt";
      action.__raw = "require('telescope.builtin').lsp_type_definitions";
      options.desc = "Goto LSP type definition";
    }
    {
      key = "<leader>a";
      action.__raw = "require('telescope').extensions.actions_nvim.actions_nvim";
    }
    {
      key = "<leader>tt";
      action = "<cmd>ToggleTerm<CR>";
      options.desc = "Toggle latest terminal";
    }
    {
      key = "<leader>ta";
      action.__raw = "require('telescope').extensions.actions_nvim_terminals.actions_nvim_terminals";
      options.desc = "Toggle action.nvim terminal";
    }
    {
      key = "<leader>t1";
      action = "<cmd>ToggleTerm 1<CR>";
      options.desc = "Toggle terminal 1";
    }
    {
      key = "<leader>t2";
      action = "<cmd>ToggleTerm 2<CR>";
      options.desc = "Toggle terminal 2";
    }
    {
      key = "<leader>t3";
      action = "<cmd>ToggleTerm 3<CR>";
      options.desc = "Toggle terminal 3";
    }
    {
      key = "<leader>t4";
      action = "<cmd>ToggleTerm 4<CR>";
      options.desc = "Toggle terminal 4";
    }
    {
      key = "<leader>e";
      action = "<cmd>lua ToggleNetrw()<CR>";
      options.desc = "Toggle Netrw";
    }
    {
      key = "<leader>u";
      action.__raw = "require('telescope').extensions.undo.undo";
      options.desc = "Search undotree";
    }
    {
      key = "<leader>dt";
      action.__raw = "require('dapui').toggle";
      options.desc = "Toggle nvim-dap-ui";
    }
    {
      key = "<leader>db";
      action.__raw = "require('dap').toggle_breakpoint";
      options.desc = "Toggle dap-breakpoint";
    }
    {
      key = "<leader>dh";
      action.__raw = "require('dap').step_out";
      options.desc = "Step out";
    }
    {
      key = "<leader>dj";
      action.__raw = "require('dap').step_over";
      options.desc = "Step over";
    }
    {
      key = "<leader>dl";
      action.__raw = "require('dap').step_into";
      options.desc = "Step into";
    }
    {
      key = "<leader>dr";
      action.__raw = "require('dap').continue";
      options.desc = "Continue running";
    }
  ];


  colorschemes.catppuccin = {
    enable = true;
    settings.flavour = "macchiato";
  };

  highlight = {
    "ScopeGrey" = { fg = "#8087a2"; };
  };

  lsp = {
    servers = {
      asm_lsp.enable = true;
      clangd.enable = true;
    };
  };

  extraPlugins = [ actions-nvim-plugin ] ;

  extraConfigLua = ''
    -- Toggle netrw in a split
    vim.g.NetrwIsOpen = 0
    function ToggleNetrw()
      -- Find any netrw buffers
      local netrw_bufs = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "netrw" then
          table.insert(netrw_bufs, buf)
        end
      end

      if #netrw_bufs > 0 then
        -- Close all netrw buffers
        for _, buf in ipairs(netrw_bufs) do
          vim.api.nvim_buf_delete(buf, { force = true })
        end
        vim.g.NetrwIsOpen = 0
      else
        -- Open netrw in same split, focused on current file's directory
        local current_file = vim.fn.expand("%:p:h")
        if current_file == "" then
          current_file = vim.fn.getcwd()
        end
        vim.cmd("silent Lexplore " .. vim.fn.fnameescape(current_file))
        vim.g.NetrwIsOpen = 1
      end
    end

  '';
  
  plugins = {
    lspconfig = {
      enable = true;
    };

    blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "none";
        keymap = {
          "<C-space>" = [ "show" "show_documentation" "hide_documentation" ];
          "<C-e>" = [ "hide" "fallback" ];

          "<C-j>" = [ "select_next" "fallback" ];
          "<C-k>" = [ "select_prev" "fallback" ];
          "<CR>" = [ "accept" "fallback" ];
          "<C-h>" = [ "cancel" "fallback" ];

          "<Tab>" = [ "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "snippet_backward" "fallback" ];

          "<C-n>" = [ "scroll_documentation_down" "scroll_signature_down" "fallback" ];
          "<C-m>" = [ "scroll_documentation_up" "scroll_signature_up" "fallback" ];

          "<C-b>" = [ "show_signature" "hide_signature" "fallback" ];
        };
        completion.list.selection = {
          auto_insert = true;
          preselect = false;
        };
        completion.documentation = {
          auto_show = true;
          auto_show_delay_ms = 0;
        };
        completion.menu.draw.__raw = ''
          {
            columns = { { "kind_icon" }, { "label", gap = 1 } },
            components = {
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
            },
          }
        '';
        snippets.preset = "luasnip";

        sources.default = [ "lsp" "path" "snippets" ];
        sources.providers = {
          lsp = {
            name = "lsp";
            module = "blink.cmp.sources.lsp";
            async = false;
            timeout_ms = 1000;
            score_offset = 0;
            fallbacks = [ "buffer" ];
          };

        };
      };
    };

    luasnip = {
      enable = true;
    };

    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        float_opts = {
          border = "curved";
        };
      };
    };

    telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
      extensions.undo.enable = true;
      enabledExtensions = [ "actions_nvim" "actions_nvim_terminals" ];
      settings.extensions.actions_nvim.get_actions.__raw = ''
        function()
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_win_get_buf(win)
          local filetype = vim.api.nvim_get_option_value("filetype", {buf = buf,})
          local filename = vim.api.nvim_buf_get_name(buf)
          local filebasename = filename:match("^(.+)%.[^/.]+$")
          local function concatTable(t1, t2)
            for _, v in ipairs(t2) do
              table.insert(t1, v)
            end
            return t1
          end
          local actions = {}
          local moppen_actions = {
            {
              name = '(moppen) Run make',
              cmd = 'make',
              terminal = 'make',
            },
            {
              name = '(moppen) Start simserver',
              cmd = 'simserver',
              terminal = 'simserver',
            }
          }
          if filetype == 'asm' then actions = concatTable(actions, moppen_actions) end
          if filetype == 'c' then actions = concatTable(actions, moppen_actions) end
          return actions
        end
      '';


    };

    which-key = {
      enable = true;
      settings = {
        spec = [
          { 
            __unkeyed-1 = "<C-space>"; 
            desc = "Show completion menu / Toggle completion documentation";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<C-e>"; 
            desc = "Hide completion menu";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<C-j>"; 
            desc = "Select next completion";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<C-k>"; 
            desc = "Select previous completion";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<CR>"; 
            desc = "Accept selected completion";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<C-h>"; 
            desc = "Undo last completion";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<Tab>"; 
            desc = "Go to next snippet section";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<S-Tab>"; 
            desc = "Go to next snippet section";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<C-n>"; 
            desc = "Scroll down documentation";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<C-m>"; 
            desc = "Scroll up documentation";
            icon = "󰊕";
            mode = "i";
          }
          { 
            __unkeyed-1 = "<C-l>"; 
            desc = "Show current function signature";
            icon = "󰊕";
            mode = "i";
          }
          {
            __unkeyed-1 = "<leader>s";
            desc = "Search with telescope";
          }
          {
            __unkeyed-1 = "<leader>l";
            desc = "LSP actions";
          }
          {
            __unkeyed-1 = "<leader>d";
            desc = "Debug actions";
          }
          {
            __unkeyed-1 = "<leader>t";
            desc = "Toggle terminals";
          }
        ];
      };
    };

    lualine = {
      enable = true;
      settings = {
        options.component_separators = "|";
        options.section_separators = "";
      };
    };

    web-devicons = {
      enable = true;
    };

    colorful-menu = {
      enable = true;
    };

    gitsigns = {
      enable = true;
    };

    indent-blankline = {
      enable = true;
      settings = {
        scope.highlight = [ "ScopeGrey" ];
      };
    };

    guess-indent = {
      enable = true;
    };

    nvim-autopairs = {
      enable = true;
      settings.check_ts = true;
      settings.disable_in_visualblock = true;
    };

    treesitter = {
      enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [ asm c make ];

      settings = {
        highlight.enable = true;
      };
    };

    dap = {
      enable = true;
      signs = {
        dapBreakpoint.text = "";
        dapBreakpoint.texthl = "DapBreakpoint";
        dapStopped.text = "";
        dapStopped.texthl = "DapUIPlayPause";
      };
      adapters.mdx07-gdb.__raw = ''
        {
          type = "executable",
          command = "gdb",
          args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
        }
      '';
      configurations.asm = [
        {
          name = "(data-tools) Debug program on simserver:1234";
          type = "mdx07-gdb";
          request = "attach";
          cwd = "\${workspaceFolder}";
          program = "\${workspaceFolder}/build/\${workspaceFolderBasename}.elf";
          target = "localhost:1234";
        }
      ];
      configurations.c = [
        {
          name = "(data-tools) Debug program on simserver:1234";
          type = "mdx07-gdb";
          request = "attach";
          cwd = "\${workspaceFolder}";
          program = "\${workspaceFolder}/build/\${workspaceFolderBasename}.elf";
          target = "localhost:1234";
        }
      ];
      luaConfig.post = ''
        local dap = require('dap')
        local dapui = require('dapui')
        dap.listeners.after.attach["mdx07-handlers"] = function()
          local repl = require('dap.repl')
          repl.execute('monitor reset halt')
          repl.execute('load')
          repl.execute('break main')
          repl.execute('continue')
        end
        dap.listeners.after.reset["mdx07-handlers"] = function()
          local repl = require('dap.repl')
          repl.execute('monitor reset halt')
          repl.execute('load')
          repl.execute('break main')
          repl.execute('continue')
        end
        dap.listeners.before.attach.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
          dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
          dapui.close()
        end
      '';
    };

    dap-ui = {
      enable = true;
      settings = {
        layouts = [
          {
            position = "left";
            size = 50;
            elements = [
              {
                id = "scopes";
                size = 0.50;
              }
              {
                id = "breakpoints";
                size = 0.25;
              }
              {
                id = "stacks";
                size = 0.25;
              }
            ];
          }
          {
            position = "bottom";
            size = 13;
            elements = [
              {
                id = "repl";
                size = 1.0;
              }
            ];
          }
        ];
      };
    };

  };
}
