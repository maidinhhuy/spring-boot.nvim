local M = {}
local Terminal = require("toggleterm.terminal").Terminal

local function find_mvnw()
	local current_dir = vim.fn.expand("%:p:h")
	local files = vim.fn.systemlist("find " .. vim.fn.escape(current_dir, "") .. " -name mvnw -type f")

	if #files > 0 then
		local results = {}
		for _, file in ipairs(files) do
			table.insert(results, { text = file })
		end

		if #results == 1 then
			M.run_mvnw(results[1].text)
		elseif #results > 1 then
			require("telescope.builtin").pick(results, {
				previewer = false,
				sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
				finder = require("telescope.finders").new_table({
					results = results,
					entry_maker = function(entry)
						return {
							value = entry.text,
							display = entry.text,
							ordinal = entry.text,
						}
					end,
				}),
				on_selection = function(prompt_bufnr, selection, opts)
					M.run_mvnw(selection.value)
					return true
				end,
			})
		else
			vim.notify("No mvnw file found in the current directory or insert subdirectories", vim.log.levels.WARN)
		end
	else
		vim.notify("No mvnw file found in the current directory or its subdirectories.", vim.log.levels.WARN)
	end
end

local spring_boot_termial = nil

function M.run_mvnw(mvnw_path)
	if not spring_boot_termial or not spring_boot_termial:is_open() then
		local cwd = vim.fn.fnamemodify(mvnw_path, ":h")
		spring_boot_termial = Terminal:new({
			cmd = table.concat({ mvnw_path, "spring-boot:run" }, " "),
			cwd = cwd,
			size = 20,
			direction = "window",
			close_on_exit = false,
		})

		spring_boot_termial:toggle()
	end
end

M.find_mvnw = find_mvnw

return M
