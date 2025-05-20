local Terminal = require("toggleterm.terminal").Terminal

local M = {}
local function find_mvn(callback)
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

local spring_boot_termial = nil
local function run_spring_boot()
	find_mvn(function(mvnw_path)
		if not mvnw_path then
			vim.notify("No mvnw path selected", vim.log.levels.ERROR)
			return
		end

		local cwd = vim.fn.fnamemodify(mvnw_path, ":h")

		if not spring_boot_terminal or not spring_boot_terminal:is_open() then
			spring_boot_terminal = Terminal:new({
				cmd = mvnw_path .. " spring-boot:run",
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
return M
