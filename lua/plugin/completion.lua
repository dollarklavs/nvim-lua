local remap = vim.api.nvim_set_keymap

require'compe'.setup {
  enabled              = true;
  autocomplete         = true;
  debug                = false;
  min_length           = 2;
  preselect            = 'enable';
  throttle_time        = 80;
  source_timeout       = 200;
  incomplete_delay     = 400;
  documentation        = true;

  source = {
    path          = true;
    buffer = {
      enable = true,
      priority = 1,     -- last priority
    },
    nvim_lsp = {
      enable = true,
      priority = 10001, -- takes precedence over file completion
    },
    nvim_lua      = true;
    calc          = true;
    omni          = false;
    spell         = false;
    tags          = true;
    treesitter    = true;
    snippets_nvim = false;
    vsnip         = false;
  };
}

require'lspconfig'.pyright.setup{}

local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { "pyright", "rust_analyzer" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- Tab completion
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- <s-tab> to force open completion menu
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    --return vim.fn['compe#complete']()
    return t "<Tab>"
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    --return t "<S-Tab>"
    --return t "<C-n>"
    return vim.fn['compe#complete']()
  end
end

remap('i', '<Tab>', 'v:lua.tab_complete()', {expr = true})
remap('s', '<Tab>', 'v:lua.tab_complete()', {expr = true})
remap('i', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
remap('s', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})

-- We use <s-tab> to reopen the completion popup instead of <c-space>
--remap('i', '<C-Space>', 'compe#complete()',         { silent = true, expr = true })
remap('i', '<CR>',      'compe#confirm(\'<CR>\')',  { silent = true, expr = true })
remap('i', '<C-e>',     'compe#close(\'<C-e>\')',   { silent = true, expr = true })
remap('i', '<C-f>',     "compe#scroll({ 'delta': +4 })", { silent = true, expr = true })
remap('i', '<C-b>',     "compe#scroll({ 'delta': -4 })", { silent = true, expr = true })

-- <cr>:     select item and close the popup menu
-- <esc>:    revert selection (stay in insert mode)
-- <ctrl-c>: revert selection (switch to normal mode)
--remap('i', '<CR>',  '(pumvisible() ? "\\<c-y>" : "\\<CR>")',         { noremap = true, expr = true })
remap('i', '<Esc>', '(pumvisible() ? "\\<c-e>" : "\\<Esc>")',        { noremap = false, expr = true })
remap('i', '<c-c>', '(pumvisible() ? "\\<c-e>\\<c-c>" : "\\<c-c>")', { noremap = true,  expr = true })

-- Make up/down arrows behave in completion popups
-- without this they move up/down but v:completed_item remains empty
remap('i', '<down>', '(pumvisible() ? "\\<C-n>" : "\\<down>")', { noremap = true, expr = true })
remap('i', '<up>',   '(pumvisible() ? "\\<C-p>" : "\\<up>")',   { noremap = true, expr = true })
