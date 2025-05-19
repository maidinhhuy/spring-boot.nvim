local M = {}

local deps_loader = require("spring-boot.nvim.utils.deps_loader")

-- Fetch latest deps from Spring
local deps = deps_loader.fetch_dependencies()

local function ask_input(prompt, default)
	vim.fn.inputsave()
	local answer = vim.fn.input(prompt .. " [" .. default .. "]: ")
	vim.fn.inputrestore()
	return answer ~= "" and answer or default
end

local function ask_select(prompt, items, default_index, callback)
	vim.ui.select(items, {
		prompt = prompt,
		format_item = function(item)
			return item
		end,
	}, function(choice)
		callback(choice or items[default_index])
	end)
end

function M.create_application()
	local project_name = ask_input("Project name", "demo")
	local package_name = ask_input("Package name", "com.example.demo")

	-- Define options
	local languages = { "java", "kotlin" }
	local boot_versions = { "3.3.11", "3.4.5", "3.5.0-RC1" }

	ask_select("Select language", languages, 1, function(language)
		ask_select("Select Spring Boot version", boot_versions, 1, function(boot_version)
			deps_loader.select_dependencies_with_telescope(deps, function(selected_ids)
				local dependency_string = table.concat(selected_ids, ",")

				local group_id = package_name:match("^[^.]+") or "com.example"
				local url = string.format(
					"https://start.spring.io/starter.zip?type=maven-project&language=%s&bootVersion=%s&baseDir=%s&groupId=%s&artifactId=%s&name=%s&packageName=%s&dependencies=%s",
					language,
					boot_version,
					project_name,
					group_id,
					project_name,
					project_name,
					package_name,
					dependency_string
				)

				local zip_path = "/tmp/" .. project_name .. ".zip"
				local unzip_dir = vim.fn.getcwd() .. "/" .. project_name

				vim.notify("Downloading Spring Boot project...", vim.log.levels.INFO)

				-- Download zip
				local result = os.execute("curl -L -o " .. zip_path .. " '" .. url .. "'")
				if result ~= 0 then
					vim.notify("Failed to download Spring Boot project", vim.log.levels.ERROR)
					return
				end

				-- Unzip
				os.execute("unzip -q " .. zip_path .. " -d " .. vim.fn.getcwd())
				os.remove(zip_path)

				vim.notify("Spring Boot project created at " .. unzip_dir, vim.log.levels.INFO)
				-- Open the main class
				vim.cmd("cd " .. unzip_dir)
				local ext = language == "kotlin" and "kt" or "java"
				local path = unzip_dir
					.. "/src/main/"
					.. language
					.. "/"
					.. package_name:gsub("%.", "/")
					.. "/Application."
					.. ext
				vim.cmd("edit " .. path)
			end)
		end)
	end)
end

return M
