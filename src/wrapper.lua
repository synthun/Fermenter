--> Copyright (c) 2023 TeknosQuet
--> Licensed under the BSD 3-Clause License (refer to LICENSE)


local http = require("socket.http")

-- Download files from the internet easily
local function download(url, loc)
	local link = http.request(url)
	local file = io.open(loc, "wb")

	file:write(link)
	file:close()
end

-- Check if file exists
local function file_exists(loc)
	local file = io.open(loc)
	
	if file then
		file:close()
		return true
	end

	return false
end

-- Install program
local function install(name)
	local userHome = os.getenv("HOME")
	local winePfx = userHome.."/.local/share/fermenter/pfx"
	local tempDir = "/tmp"

	if name == "roblox" then
		-- Download Roblox installer
		if file_exists(tempDir.."/rbx.exe") == false then
			print("Downloading Roblox installer... ["..tempDir.."]")

			local ver = http.request("http://setup.roblox.com/version")
			download("https://setup.rbxcdn.com/"..ver.."-Roblox.exe", tempDir.."/rbx.exe")
		end

		-- Create WINE prefix directory
		print("Creating Fermenter directory...")
		os.execute("mkdir -p "..winePfx)

		-- Launch installer
		print("Launching installer...")

		local envVars = "WINEDEBUG=-all WINEPREFIX="..winePfx.." WINEARCH=win32 WINE_NO_WOW64=1 "
		os.execute("sh -c '"..envVars.."wine "..tempDir.."/rbx.exe'")

		print("Roblox has been installed successfully!")
	end
end


-- Check arguments
if arg[1] == "install" then
	if arg[2] == "roblox" then install("roblox") end
end
