local curl = require("plenary.curl")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local function fetch_metadata()
	local response = curl.get("https://start.spring.io/metadata/client", {
		accept = "application/json",
	})

	if response.status ~= 200 then
		vim.notify("Failed to fetch Spring Boot metadata: " .. response.status, vim.log.levels.ERROR)
		return nil
	end

	local ok, parsed = pcall(vim.fn.json_decode, response.body)
	if not ok then
		vim.notify("Failed to decode JSON response", vim.log.levels.ERROR)
		return nil
	end

	return parsed
end

function M.fetch_dependencies()
	local metadata = fetch_metadata()
	if not metadata then
		return {}
	end

	local deps = {}
	for _, category in ipairs(metadata.dependencies.values or {}) do
		for _, dep in ipairs(category.values or {}) do
			table.insert(deps, {
				id = dep.id,
				display = string.format("%-25s (%s)", dep.name, category.name),
				desc = dep.description,
			})
		end
	end

	return deps
end

function M.select_dependencies_with_telescope(deps, callback)
	local selected = {}

	local function is_selected(id)
		for _, sel in ipairs(selected) do
			if sel == id then
				return true
			end
		end
		return false
	end

	-- Convert deps into entries that include selection status
	local function make_entries()
		local entries = {}
		for _, dep in ipairs(deps) do
			local check = is_selected(dep.id) and "[x]" or "[ ]"
			table.insert(entries, {
				value = dep.id,
				display = string.format("%s %-25s (%s)", check, dep.display or dep.id, dep.desc or ""),
				ordinal = dep.display,
				dep = dep,
			})
		end
		return entries
	end

	local function launch_picker()
		pickers
			.new({}, {
				prompt_title = "Spring Boot Dependencies",
				finder = finders.new_table({
					results = make_entries(),
					entry_maker = function(entry)
						return {
							value = entry.value,
							display = entry.display,
							ordinal = entry.ordinal,
							dep = entry.dep,
						}
					end,
				}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr, map)
					local function toggle_selection()
						local entry = action_state.get_selected_entry()
						local id = entry.value

						if is_selected(id) then
							-- Deselect
							for i, v in ipairs(selected) do
								if v == id then
									table.remove(selected, i)
									break
								end
							end
						else
							table.insert(selected, id)
						end

						-- Relaunch the picker with updated selection
						actions.close(prompt_bufnr)
						vim.defer_fn(launch_picker, 10)
					end

					map("i", "<CR>", toggle_selection)
					map("n", "<CR>", toggle_selection)

					map("i", "<C-q>", function()
						actions.close(prompt_bufnr)
						callback(selected)
					end)

					map("n", "q", function()
						actions.close(prompt_bufnr)
						callback(selected)
					end)

					return true
				end,
			})
			:find()
	end

	launch_picker()
end

return M
