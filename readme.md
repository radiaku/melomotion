# Plugin to create melody ( motion ) on neovim

This just beta version for log neovim motion, there is so much work, but this is just idea.

I dont suggest you, used it.

if you want helping to develop this. you can pull request.


set this your config:

local:
```
return {
  dir = "~/Dev/personal/melomotion",
  name = "melomotion",
  lazy = true,
  cmd = { "MelomotionStart", "MelomotionStop", "MelomotionSave" }, -- Load only on these commands
}
```

online
```
return {
	"radiaku/melomotion",
      lazy = true,
      cmd = { "MelomotionStart", "MelomotionStop", "MelomotionSave" }, -- Load only on these commands
}

```
