--> Copyright (c) 2023 TeknosQuet
--> Licensed under the BSD 3-Clause License (refer to LICENSE)



local http = require("socket.http")

local userHome = os.getenv("HOME")
local winePfx = userHome.."/.local/share/fermenter/pfx"
local tempDir = "/tmp"


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


-- Display help menu
local function help()
	print("Usage: fermenter [-ir] [roblox]  OR  fermenter -b [data]\n")
	print("-b	boot Roblox (used by generated .desktop file)")
	print("-h	display this menu")
	print("-i	install Roblox or modifications")
	print("-r	remove Roblox or modifications")
end

-- Boot Roblox
local function boot(data)
	local envVars = "WINEDEBUG=-all WINEPREFIX="..winePfx.." "
	local ver = http.request("http://setup.roblox.com/version")

	os.execute("sh -c '"..envVars.."wine "..winePfx.."/drive_c/Program\\ Files/Roblox/Versions/version-*/RobloxPlayerLauncher.exe "..data.."'")
end

-- Create .desktop file
local function create_desktop_file()
	local file = io.open(userHome.."/.local/share/applications/fermenter.desktop","w")
	local contents = {"[Desktop Entry]",
	"Name=Fermenter","Type=Application","Version=3.14",
	"Comment=Roblox wrapper for Linux and FreeBSD.",
	"Exec=/bin/sh -c 'fermenter -b %u'"}
	
	-- Write contents of array into file
	for i,v in pairs(contents) do
		file:write(v, "\n")
	end

	-- Add XDG capability
	os.execute("xdg-mime default fermenter.desktop x-scheme-handler/roblox-player")
end

-- Install program
local function install(name)
	local ver = http.request("http://setup.roblox.com/version")

	if name == "roblox" then
		-- Check for existing Roblox install
		if file_exists(winePfx.."/drive_c/Program Files/Roblox/Versions/"..ver.."/RobloxPlayerBeta.exe") == true then
			print("Roblox is already installed.")
			os.exit()
		end

		-- Download Roblox installer
		if file_exists(tempDir.."/rbx.exe") == false then
			print("Downloading Roblox installer... ["..tempDir.."]")
			download("https://setup.rbxcdn.com/"..ver.."-Roblox.exe", tempDir.."/rbx.exe")
		end

		-- Create WINE prefix directory
		print("Creating Fermenter directory...")
		os.execute("mkdir -p "..winePfx)

		-- Launch installer
		print("Launching installer...")

		local envVars = "WINEDEBUG=-all WINEPREFIX="..winePfx.." WINEARCH=win32 WINE_NO_WOW64=1 "
		os.execute("sh -c '"..envVars.."wine "..tempDir.."/rbx.exe > /dev/null'")
		create_desktop_file()

		print("Roblox has been installed successfully!")
	end
end

-- Uninstall program
local function uninstall()
	local desktopFile = userHome.."/.local/share/applications/fermenter.desktop"

	-- Check for desktop file
	if file_exists(desktopFile) then
		print ("Removing fermenter.desktop")
		os.execute("rm -f "..desktopFile)
	end

	-- Check for existing prefix
	if file_exists(winePfx) then
		print("Uninstalling Roblox...")
		os.execute("rm -rf "..winePfx)

		print("Roblox has been uninstalled successfully!")
	else
		print("Roblox is already uninstalled.")
	end
end

-- Check arguments
if arg[1] == "-b" then boot(arg[2])
elseif arg[1] == "-h" then help()
elseif arg[1] == "-i" then install(arg[2])
elseif arg[1] == "-r" then uninstall()
end
