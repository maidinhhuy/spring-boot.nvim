local Terminal = require("toggleterm.terminal").Terminal

local M = {}
local function find_mvn(callback)
	local mvn_cmd = vim.fn.executable("mvn") == 1 and "mvn" or nil
	if mvn_cmd then
		callback(mvn_cmd)
		return
	end
	local current_dir = vim.fn.expand("%:p:h")
	local files = vim.fn.systemlist("find " .. vim.fn.escape(current_dir, "") .. " -name mvnw -type f")

	if #files == 0 then
		vim.notify("No mvnw file found", vim.log.levels.WARN)
		return
	elseif #files == 1 then
		callback(files[1])
	else
		local results = {}
		for _, file in ipairs(files) do
			table.insert(results, { text = file })
		end

		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local sorters = require("telescope.sorters")
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		pickers
			.new({}, {
				prompt_title = "Select mvnw",
				finder = finders.new_table({
					results = results,
					entry_maker = function(entry)
						return {
							value = entry.text,
							display = entry.text,
							ordinal = entry.text,
						}
					end,
				}),
				sorter = sorters.get_generic_fuzzy_sorter(),
				previewer = false,
				attach_mappings = function(prompt_bufnr, _)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						callback(selection.value)
					end)
					return true
				end,
			})
			:find()
	end
end

local function find_pom_xml(callback)
	local current_dir = vim.fn.expand("%:p:h")
	local files = vim.fn.systemlist("find " .. vim.fn.escape(current_dir, "") .. " -name pom.xml -type f")

	if #files == 0 then
		vim.notify("No pom.xml file found", vim.log.levels.WARN)
		return
	elseif #files == 1 then
		callback(vim.fn.fnamemodify(files[1], ":h")) -- return the directory
	else
		-- multiple pom.xml files, use telescope to select one
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local sorters = require("telescope.sorters")
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		local results = {}
		for _, f in ipairs(files) do
			table.insert(results, { text = f })
		end

		pickers
			.new({}, {
				prompt_title = "Select pom.xml location",
				finder = finders.new_table({
					results = results,
					entry_maker = function(entry)
						return {
							value = vim.fn.fnamemodify(entry.text, ":h"),
							display = entry.text,
							ordinal = entry.text,
						}
					end,
				}),
				sorter = sorters.get_generic_fuzzy_sorter(),
				attach_mappings = function(prompt_bufnr, map)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						callback(selection.value)
					end)
					return true
				end,
			})
			:find()
	end
end

local spring_boot_termial = nil
local function run_spring_boot()
	find_mvn(function(mvn_cmd)
		if not mvn_cmd then
			vim.notify("Maven not found", vim.log.levels.ERROR)
			return
		end

		local cwd = vim.fn.fnamemodify(mvn_cmd, ":h")

		vim.notify("Maven running: " .. cwd .. " with manven: " .. mvn_cmd, vim.log.levels.INFO)
		if not spring_boot_terminal or not spring_boot_terminal:is_open() then
			spring_boot_terminal = Terminal:new({
				cmd = mvn_cmd .. " spring-boot:run",
				cwd = cwd,
				direction = "horizontal",
				size = 50,
				close_on_exit = false,
				hidden = true,
			})
			spring_boot_terminal:toggle()
		else
			spring_boot_terminal:toggle()
		end
	end)
end

M.run_spring_boot = run_spring_boot
M.find_pom_xml = find_pom_xml
M.find_mvn = find_mvn
return M
