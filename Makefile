NVIM ?= nvim
MINI := deps/mini.nvim

# stylua and luacheck come from PATH, or from Mason when they aren't on it. Full paths,
# because make 3.81 (macOS) ignores an exported PATH when it runs a command without a shell.
MASON_BIN := $(HOME)/.local/share/nvim/mason/bin
STYLUA ?= $(or $(shell command -v stylua),$(MASON_BIN)/stylua)
LUACHECK ?= $(or $(shell command -v luacheck),$(MASON_BIN)/luacheck)

.PHONY: check test lint fmt fmt-check

check: fmt-check lint test

# FILE=tests/test_x.lua runs one file; CASE="part of a case name" runs matching cases.
test: $(MINI)
	FILE='$(FILE)' CASE='$(CASE)' $(NVIM) --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"

$(MINI):
	git clone --quiet --filter=blob:none --branch stable https://github.com/nvim-mini/mini.nvim $(MINI)

lint:
	$(LUACHECK) lua plugin syntax tests

fmt:
	$(STYLUA) lua plugin syntax tests

fmt-check:
	$(STYLUA) --check lua plugin syntax tests
