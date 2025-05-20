local M = {}
local maven = require("spring-boot.nvim.utils.maven")

local function find_test_files()
	local root = vim.fn.getcwd()
	local test_files = vim.fn.systemlist("find " .. root .. " -type f -name '*Test.java' -o -name '*Tests.java'")
	return test_files
end

local function run_all_tests()
	local mvn_cmd = maven.find_mvn()
	print(mvn_cmd)
	vim.cmd("split | terminal " .. mvn_cmd .. " test")
end

local function run_test_file()
	local test_files = find_test_files()

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Select Test File",
			finder = require("telescope.finders").new_table({
				results = test_files,
			}),
			sorter = require("telescope.config").values.generic_sorter({}),
			attach_mappings = function(_, map)
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")

				map("i", "<CR>", function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					-- Convert file path to fully qualified class name
					local path = selection[1]
					local class_name = path:match("src/test/java/(.-)%.java")
					if class_name then
						class_name = class_name:gsub("/", ".")
						local mvn_cmd = vim.fn.executable("./mvnw") == 1 and "./mvnw" or "mvn"
						vim.cmd("split | terminal " .. mvn_cmd .. " -Dtest=" .. class_name .. " test")
						vim.api.nvim_feedkeys("i", "n", true) -- Go into insert mode, like `startinsert`
					else
						vim.notify("Could not resolve test class name", vim.log.levels.ERROR)
					end
				end)

				return true
			end,
		})
		:find()
end

M.run_all_tests = run_all_tests
M.run_test_file = run_test_file

return M
