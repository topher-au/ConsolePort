---------------------------------------------------------------
-- Update.lua: Update management
---------------------------------------------------------------
-- Keeps a stack of update snippets to run continuously. 
-- Allows plug-ins to hook/unhook scripts on the main frame.

local interval = 0.1
local time = 0
local UpdateSnippets = {}

local function OnUpdate (self, elapsed)
	time = time + elapsed
	while time > interval do
		for Snippet in pairs(UpdateSnippets) do
			Snippet(self)
		end
		time = time - interval
	end
end

ConsolePort:SetScript("OnUpdate", OnUpdate);

function ConsolePort:AddUpdateSnippet(snippet)
	if type(snippet) == "function" then
		UpdateSnippets[snippet] = true
	end
end

function ConsolePort:RemoveUpdateSnippet(snippet)
	UpdateSnippets[snippet] = nil
end

function ConsolePort:GetUpdateSnippets()
	return UpdateSnippets
end

