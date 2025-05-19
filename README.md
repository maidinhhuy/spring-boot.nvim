## Neovim plugin for Spring Boot developer

### Using lazyvim

```lua
return {
	{
		"maidinhhuy/spring-boot.nvim",
		version = "*",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "akinsho/toggleterm.nvim" },
		config = function()
			local sb = require("spring-boot.nvim")
			vim.api.nvim_create_user_command("SpringBootRun", sb.find_mvnw, {})
			vim.api.nvim_create_user_command("SpringBootInit", sb.create_project, {})
			vim.keymap.set("n", "<leader>sr", sb.find_mvnw, { desc = "Run Spring Boot (find mvnw)" })
		end,
		init = function()
			require("spring-boot.nvim")
		end,
	},
}
```
```
```
