NVIM ?= nvim
MINI := deps/mini.nvim

# stylua and luacheck come from Mason when they aren't installed globally.
export PATH := $(HOME)/.local/share/nvim/mason/bin:$(PATH)

.PHONY: check test lint fmt fmt-check

check: fmt-check lint test

# FILE=tests/test_x.lua runs one file; CASE="part of a case name" runs matching cases.
test: $(MINI)
	FILE='$(FILE)' CASE='$(CASE)' $(NVIM) --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"

$(MINI):
	git clone --quiet --filter=blob:none --branch stable https://github.com/nvim-mini/mini.nvim $(MINI)

lint:
	luacheck lua plugin syntax tests

fmt:
	stylua lua plugin syntax tests

fmt-check:
	stylua --check lua plugin syntax tests
