---------------------------------------------------------------
-- Init.lua: Main frame creation, version checking, slash cmd
---------------------------------------------------------------
-- Create the main frame and check all loaded settings.
-- Validate compatibility with older versions.
-- Create the slash handler function.

local addOn, db = ...
---------------------------------------------------------------
-- Create main frame (not visible to user)
---------------------------------------------------------------
local ConsolePort = CreateFrame("FRAME", addOn)
---------------------------------------------------------------
-- CRITICALUPDATE: flag when old settings are incompatible. 
---------------------------------------------------------------
local CRITICALUPDATE = false
---------------------------------------------------------------
-- VERSION: generate a comparable integer from addon metadata 
---------------------------------------------------------------
local v1, v2, v3 = strsplit("%d+.", GetAddOnMetadata(addOn, "Version"))
local VERSION = v1*10000+v2*100+v3
---------------------------------------------------------------
-- Initialize crucial addon-wide tables
---------------------------------------------------------------
db.TEXTURE 	= {}
db.SECURE 	= {}
---------------------------------------------------------------
-- Plug-in access to addon table
---------------------------------------------------------------
function ConsolePort:DB() return db end

local function ResetAllSettings()
	if not InCombatLockdown() then
		local bindings = ConsolePort:GetBindingNames()
		for i, binding in pairs(bindings) do
			local key1, key2 = GetBindingKey(binding)
			if key1 then SetBinding(key1) end
			if key2 then SetBinding(key2) end
		end
		SaveBindings(GetCurrentBindingSet())
		ConsolePortBindingSet = nil
		ConsolePortBindingButtons = nil
		ConsolePortMouse = nil
		ConsolePortSettings = nil
		ConsolePortCharacterSettings = nil
		ReloadUI()
	else
		print(db.TUTORIAL.SLASH.COMBAT)
	end
end

function ConsolePort:LoadSettings()
	if not ConsolePortBindingSet then
		ConsolePortBindingSet = self:GetDefaultBindingSet()
	end

	-- Interface binding buttons and interface commands.
	if not ConsolePortBindingButtons then
		ConsolePortBindingButtons = self:GetDefaultBindingButtons()
	end

	if not ConsolePortMouse then
		ConsolePortMouse = {
			Events = self:GetDefaultMouseEvents(),
			Cursor = self:GetDefaultMouseCursor(),
		}
	end

	if not ConsolePortSettings then
		ConsolePortSettings = self:GetDefaultAddonSettings()
		self:CreateSplashFrame()
	end

	-- Use these frames in the virtual cursor stack
	if not ConsolePortUIFrames then
		ConsolePortUIFrames = self:GetDefaultUIFrames()
	end

	-- Load the binding wizard if a button does not have a registered mock binding
	if 	self:CheckUnassignedBindings() then
		self:CreateBindingWizard()
	end

	-- Slash handler and stuff related to that
	local SLASH = db.TUTORIAL.SLASH

	local function ShowSplash() ConsolePort:CreateSplashFrame() end
	local function ShowBinds() for i=1, 2 do InterfaceOptionsFrame_OpenToCategory(db.Binds) end end

	local function ResetAll()
		if not InCombatLockdown() then
			local bindings = ConsolePort:GetBindingNames()
			for i, binding in pairs(bindings) do
				local key1, key2 = GetBindingKey(binding)
				if key1 then SetBinding(key1) end
				if key2 then SetBinding(key2) end
			end
			SaveBindings(GetCurrentBindingSet())
			ConsolePortBindingSet = ConsolePort:GetDefaultBindingSet()
			ConsolePortBindingButtons = ConsolePort:GetDefaultBindingButtons()
			ConsolePortUIFrames = nil
			ConsolePortSettings = nil
			ConsolePortMouse = nil
			ReloadUI()
		else
			print("|cffffe00aConsolePort|r:", SLASH.COMBAT)
		end
	end

	local function CursorLock()
		if ConsolePortMouseLook:GetPoint() then
			ConsolePortMouseLook:SetPoint("LEFT", UIParent, "RIGHT")
			ConsolePortMouseLook:ClearAllPoints()
			print("|cffffe00aConsolePort|r:", SLASH.MOUSEOFF)
		else
			ConsolePortMouseLook:SetPoint("CENTER", 0, 0)
			print("|cffffe00aConsolePort|r:", SLASH.MOUSEON)
		end
	end

	local instructions = {
		["type"] = {desc = SLASH.TYPE, func = ShowSplash},
		["binds"] = {desc = SLASH.BINDS, func = ShowBinds},
		["resetall"] = {desc = SLASH.RESET, func = ResetAll},
		["lockcursor"] = {desc = SLASH.TOGGLEMOUSE, func = CursorLock},
	}

	SLASH_CONSOLEPORT1, SLASH_CONSOLEPORT2 = "/cp", "/consoleport"
	local function SlashHandler(msg, editBox)
		if instructions[msg] then
			instructions[msg].func()
		else
			print("|cffffe00aConsolePort|r:")
			for k, v in pairs(instructions) do
				print(format("|cff69ccf0/cp %s|r: %s", k, v.desc))
			end
		end
	end
	SlashCmdList["CONSOLEPORT"] = SlashHandler
	self.LoadSettings = nil
end

function ConsolePort:CheckLoadedSettings()
    if 	(ConsolePortSettings and not ConsolePortSettings.version) or 
		(ConsolePortSettings.version < VERSION and CRITICALUPDATE) then
		StaticPopupDialogs["CONSOLEPORT_CRITICALUPDATE"] = {
			text = format(db.TUTORIAL.SLASH.CRITICALUPDATE, GetAddOnMetadata(addOn, "Version")),
			button1 = "Yes (recommended)",
			button2 = "Cancel",
			showAlert = true,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
			enterClicksFirstButton = true,
			exclusive = true,
			OnAccept = ResetAllSettings,
		}
		StaticPopup_Show("CONSOLEPORT_CRITICALUPDATE")
	end
	self.CheckLoadedSettings = nil
end

function ConsolePort:CreateActionButtons()
	local keys = ConsolePortBindingButtons
	local y = 1
	table.sort(keys)
	for name, key in db.pairsByKeys(keys) do
		self:CreateSecureButton(name, "_NOMOD",	key.action,	key.ui)
		self:CreateSecureButton(name, "_SHIFT", key.shift, 	key.ui)
		self:CreateSecureButton(name, "_CTRL",  key.ctrl, 	key.ui)
		self:CreateSecureButton(name, "_CTRLSH",key.ctrlsh, key.ui)
		self:CreateConfigButton(name, "_NOMOD", 0)
		self:CreateConfigButton(name, "_SHIFT", 1)
		self:CreateConfigButton(name, "_CTRL",  2)
		self:CreateConfigButton(name, "_CTRLSH",3)
	end
	self.CreateActionButtons = nil
end

