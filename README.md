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
      sb.setup()
    end,
    init = function()
      require("spring-boot.nvim")
    end,
  },
}
```
```
