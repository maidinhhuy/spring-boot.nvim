local M = {}

local create_project = require("spring-boot.nvim.utils.create_project")
local maven = require("spring-boot.nvim.utils.maven")
local test = require("spring-boot.nvim.utils.test")

function M.setup()
	vim.api.nvim_create_user_command("SpringBootRun", maven.run_spring_boot, {})
	vim.api.nvim_create_user_command("SpringBootInit", create_project.create_application, {})
	vim.api.nvim_create_user_command("RunAllTests", test.run_all_tests, {})
	vim.api.nvim_create_user_command("RunTest", test.run_test_file, {})
end

return M
