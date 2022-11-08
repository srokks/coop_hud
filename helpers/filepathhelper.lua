---------------------
-- FILEPATH HELPER --
---------------------
-- Version 4
-- Created by piber

-- This script creates functions to assist with manipulating and digging through directories and files, exposing some extremely hacky methods as easy to use ready made functions.

-- Overrides 'dofile' and 'Isaac.RegisterMod'. Compatibility may be sketchy but could still work.

-- FilepathHelper.KnownFilePathsByName
-- table
-- A table of known file paths, indexed by strings equal to the path.
-- If FilepathHelper.KnownFilePathsByName["path/to/mod/root/"] is true, then it is a known path to a mod.

-- FilepathHelper.KnownFilePathsByIndex
-- table
-- A table of known file paths, ordered by discovery.
-- Use ipairs to iterate through FilepathHelper.KnownFilePathsByIndex to get all the known root paths to mods.

-- FilepathHelper.GetCurrentModPath
-- function()
-- Returns the currently active file path. (the one require is currently usable in)
-- Used as mods load to aquire all the file paths of currently active mods. (specifically ones which utilize lua and register themselves)

-- FilepathHelper.DoFile - Overrides dofile
-- function(string "path/to/lua/file.lua")
-- Returns what the lua script returns.
-- Use this to load lua scripts instead of require.
-- Allows scripts to be run multiple times in the same session.
-- Runs based on the game's root path, then tests for game/resources/scripts, then tests in mods starting from the last one loaded.
-- Falls back to using require if dofile was unable to load the script, in case the user has a weird filesystem that only require works with.
-- Overrides dofile, call FilepathHelper.OldDoFile for the unmodified dofile function.

-- FilepathHelper.IsFile
-- function(string "path/to/file.png")
-- Returns true if the file exists.
-- Use this to test if a file exists at the given path.
-- Runs based on the game's root path.
-- DO NOT USE ON FILES WHICH CONTAIN LEGIBLE LUA CODE!

-- FilepathHelper.IsDirectory
-- function(string "path/to/folder/")
-- Returns true if the folder exists.
-- Use this to test if a folder exists at the given path.
-- Runs based on the game's root path.
-- DO NOT USE ON FILES WHICH CONTAIN LEGIBLE LUA CODE!

-- FilepathHelper.IsAnm2
-- function(string "path/to/animation/file.anm2")
-- Returns true if the anm2 file exists.
-- Use this to test if an isaac animation file exists at the given path.
-- Uses same path syntax Sprite:Load() uses.

-- FilepathHelper.RegisterMod - Overrides Isaac.RegisterMod
-- function(table mod, string mod name, number api version)
-- No return value
-- Used to detect file paths and store them when Isaac.RegisterMod is called
-- Overrides Isaac.RegisterMod, call FilepathHelper.OldRegisterMod for the unmodified RegisterMod function.

-- ModReference.path
-- string
-- The root path to this mod, added to mods loaded after FilepathHelper to assist in creating file paths.
-- Usage example:
--	local mod = RegisterMod("my cool mod")
--	dofile(mod.path .. "scripts/some_lua_script.lua")
-- Note that this specific example is redundant with the modifications to dofile, but this can still be useful for power users.

-- Plans / Wishlist:
-- - Find a way to test for pngs and create IsPng
-- - Find a way to read xml files

------------------------------------------------------------------------------
--                   IMPORTANT:  DO NOT EDIT THIS FILE!!!                   --
------------------------------------------------------------------------------
-- This file relies on other versions of itself being the same.             --
-- If you need something in this file changed, please let the creator know! --
------------------------------------------------------------------------------

-- CODE STARTS BELOW --


-------------
-- version --
-------------
local fileVersion = 4

--prevent older/same version versions of this script from loading
if FilepathHelper and FilepathHelper.Version >= fileVersion then

	return FilepathHelper

end

if not FilepathHelper then

	FilepathHelper = {}
	FilepathHelper.Version = fileVersion

elseif FilepathHelper.Version < fileVersion then

	local oldVersion = FilepathHelper.Version

	--handle old versions

	FilepathHelper.Version = fileVersion

end


-------------------------
-- basic path handling --
-------------------------
FilepathHelper.KnownFilePathsByName = {
	["resources/scripts/"] = true
}

FilepathHelper.KnownFilePathsByIndex = {
	"resources/scripts/"
}

--returns the path to the current mod
function FilepathHelper.GetCurrentModPath()

	--use some very hacky trickery to get the path to this mod
	local _, err = pcall(require, "")
	local _, basePathStart = string.find(err, "no file '", 1)
	local _, modPathStart = string.find(err, "no file '", basePathStart)
	local modPathEnd, _ = string.find(err, ".lua'", modPathStart)
	local modPath = string.sub(err, modPathStart + 1, modPathEnd - 1)
	modPath = string.gsub(modPath, "\\", "/")

	if not FilepathHelper.KnownFilePathsByName[modPath] then

		FilepathHelper.KnownFilePathsByName[modPath] = true
		table.insert(FilepathHelper.KnownFilePathsByIndex, 2, modPath)

	end

	return modPath

end


------------
-- dofile --
------------
FilepathHelper.OldDoFile = FilepathHelper.OldDoFile or dofile
function FilepathHelper.DoFile(filename)

	FilepathHelper.GetCurrentModPath()

	--intentionally let it error if they try to run this without a string
	if type(filename) ~= "string" then

		local fileLoaded, returned = pcall(FilepathHelper.OldDoFile, filename)

		error(returned, 2) --we're doing this so the line the error occured is visible, an improvement over dofile
		return returned

	end

	--run the original dofile with no changes
	local fileLoaded, returned = pcall(FilepathHelper.OldDoFile, filename)
	local errors = {} --fill this table with all the error messages we encounter

	--if that didnt work, go through all our paths until it works
	if not fileLoaded then

		errors[#errors + 1] = returned --add root path error to this

		--prevent loading more files if this wasnt a standard "cannot open" error, this gives syntax errors priority
		local tryOtherPaths = true
		if not string.find(returned, "cannot open") then
			tryOtherPaths = false
		end

		if tryOtherPaths then

			for _, path in ipairs(FilepathHelper.KnownFilePathsByIndex) do

				fileLoaded, returned = pcall(FilepathHelper.OldDoFile, path .. filename)

				if fileLoaded then

					break

				else

					errors[#errors + 1] = returned

					--prevent loading more files if this wasnt a standard "cannot open" error, this gives syntax errors priority
					if not string.find(returned, "cannot open") then
						break
					end

				end

			end

		end

	end

	local hasLuaExtension = string.find(filename, ".lua", -4)
	if not hasLuaExtension then

		--re-call this function if no lua extension was found and we still havent found the file that loaded
		if not fileLoaded then

			fileLoaded, returned = pcall(FilepathHelper.DoFile, filename .. ".lua")

			if not fileLoaded and not string.find(returned, "cannot open") then

				errors[#errors + 1] = returned

			end

		end

		--check if the file is missing
		local cannotOpen = true
		for _, errorString in ipairs(errors) do

			if not string.find(errorString, "cannot open")
					and not string.find(errorString, "no file")
					and not string.find(errorString, "falling back to require") then

				cannotOpen = false

			end

		end

		--try using require instead
		if cannotOpen and not fileLoaded then

			fileLoaded, returned = pcall(require, filename)

			local warnMsg = "dofile failed to load " .. filename .. ", falling back to require"

			if fileLoaded then

				print(warnMsg)
				Isaac.DebugString(warnMsg)

			elseif not string.find(returned, "no file") then

				errors[#errors + 1] = warnMsg
				errors[#errors + 1] = returned

			end

		end

	end

	--print an error
	if not fileLoaded then

		local fullErrorMessage = ""
		local cannotOpen = true

		if #errors <= 1 then

			--if there was only one error message, print that instead of tabbing it all below
			fullErrorMessage = errors[1]
			cannotOpen = false

		else

			--try to find an error that wasnt a standard "cannot open" error, this moves the focus to syntax errors
			for _, errorString in ipairs(errors) do

				if not string.find(errorString, "cannot open")
						and not string.find(errorString, "no file")
						and not string.find(errorString, "falling back to require") then

					fullErrorMessage = errorString
					cannotOpen = false

					break

				end

			end

		end

		if cannotOpen then

			fullErrorMessage = "file '" .. tostring(filename) .. "' not found:"

			for _, errorString in ipairs(errors) do

				fullErrorMessage = fullErrorMessage .. "\
	" .. tostring(errorString)

			end

		end

		--print the error(s)
		error(fullErrorMessage, 2)

	end

	return returned

end
dofile = FilepathHelper.DoFile


----------------------------
-- isfile and isdirectory --
----------------------------
--basic path testing used for IsFile and IsDirectory
function FilepathHelper.TestPath(filename, functionname)

	--intentionally let it error if they try to run this without a string
	if type(filename) ~= "string" then

		local fileLoaded, returned = pcall(FilepathHelper.OldDoFile, filename)

		error(returned, 2) --we're doing this so the line the error occured is visible, an improvement over dofile
		return returned

	end

	--run dofile
	local fileLoaded, returned = pcall(FilepathHelper.OldDoFile, filename)

	if fileLoaded then

		error("Do not run " .. functionname .. " on files that could contain legible lua code!", 2)
		return nil

	end

	return returned

end

--returns true if there is a file at the path specified, very hacky, not ideal for usage on lua files
function FilepathHelper.IsFile(filename)

	local returned = FilepathHelper.TestPath(filename, "FilepathHelper.IsFile")

	--if the error dofile gave us had cannot open, then there was a syntax error on a file that is not code, thus meaning there is something here
	if returned and not string.find(returned, "cannot open") then

		return true

	end

	return false

end

--returns true if there is a folder at the path specified, very hacky, not ideal for usage on lua files
function FilepathHelper.IsDirectory(filename)

	local returned = FilepathHelper.TestPath(filename, "FilepathHelper.IsDirectory")

	--if the error dofile gave us had cannot open and permission denied, then dofile was trying to search at a folder
	if returned and string.find(returned, "cannot open") and string.find(returned, "Permission denied") then

		return true

	end

	return false

end


------------
-- isanm2 --
------------
--returns true if there is a valid loadable anm2 at the path specified
local anm2Tester = Sprite()
function FilepathHelper.IsAnm2(filename)

	--load from the filename
	local anm2Loaded, returned = pcall(anm2Tester.Load, anm2Tester, filename, false)

	--error if load would error
	if not anm2Loaded then

		returned = string.gsub(returned, "?", "FilepathHelper.IsAnm2")
		error(returned, 2)

	end

	--test results
	if anm2Tester:GetDefaultAnimationName() ~= "" or anm2Tester:GetLayerCount() > 0 then

		anm2Tester:Reset()

		return true

	end

	anm2Tester:Reset()

	return false

end


-----------------
-- registermod --
-----------------
--override RegisterMod to store mods' filepaths within themselves
FilepathHelper.OldRegisterMod = FilepathHelper.OldRegisterMod or Isaac.RegisterMod
function FilepathHelper.RegisterMod(mod, modname, apiversion)

	--call the old register mod function
	--pcall to catch any errors
	local modRegistered, returned = pcall(FilepathHelper.OldRegisterMod, mod, modname, apiversion)

	--proper erroring, gives actual useful line
	if not modRegistered then

		returned = string.gsub(returned, "filepathhelper.OldRegisterMod", "RegisterMod")
		error(returned, 2)

	end

	if type(mod) == "table" then

		--store the path to this mod in the mod
		mod.path = FilepathHelper.GetCurrentModPath()

	end

end
Isaac.RegisterMod = FilepathHelper.RegisterMod

------------
-- return --
------------
return FilepathHelper
