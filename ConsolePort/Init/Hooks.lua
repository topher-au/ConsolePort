---------------------------------------------------------------
-- Hooks.lua: Default interface hooking and script alteration
---------------------------------------------------------------
-- Customizes the behaviour of Blizzard frames to accommodate
-- the gimmicky nature of controller input. Also contains a
-- terrible tooltip hook to provide click instructions.

local _, db = ...

function ConsolePort:LoadHookScripts()
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton")
	InterfaceOptionsFrame:HookScript("OnDragStart", InterfaceOptionsFrame.StartMoving)
	InterfaceOptionsFrame:HookScript("OnDragStop", InterfaceOptionsFrame.StopMovingOrSizing)
	-- Click instruction hooks. Pending removal for cleaner solution
	GameTooltip:HookScript("OnTooltipSetItem", function(self)
		local owner = self:GetOwner()
		if owner == ConsolePortExtraButton then
			return
		end
		local item = self:GetItem()
		if 	not InCombatLockdown() then
			local 	CLICK_STRING
			if		owner:GetParent():GetName() and
					string.find(owner:GetParent():GetName(), "MerchantItem") ~= nil then
					CLICK_STRING = db.CLICK.BUY
					if GetMerchantItemMaxStack(owner:GetID()) > 1 then 
						self:AddLine(db.CLICK.STACK_BUY, 1,1,1)
					end
			elseif	owner:GetParent() == LootFrame then
					self:AddLine(db.CLICK_LOOT, 1,1,1)
			elseif 	GetItemSpell(item) 	 		then CLICK_STRING = db.CLICK.USE
			end
			if 	GetItemCount(item, false) ~= 0 or
				MerchantFrame:IsVisible() then
				if 	EquipmentFlyoutFrame:IsVisible() then
					self:AddLine(db.CLICK_CANCEL, 1,1,1)
				end
				self:AddLine(CLICK_STRING, 1,1,1)
				if CLICK_STRING == db.CLICK.USE then
					self:AddLine(db.CLICK.ADD_TO_EXTRA, 1,1,1)
				end
				if not owner:GetParent() == LootFrame then
					self:AddLine(db.CLICK.PICKUP, 1,1,1)
				end
				self:Show()
			end
		end
	end)
	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		if not InCombatLockdown() then
			if 	self:GetOwner():GetParent() == SpellBookSpellIconsFrame and not
				self:GetOwner().isPassive then
				if not self:GetOwner().UnlearnedFrame:IsVisible() then
					self:AddLine(db.CLICK.USE_NOCOMBAT, 1,1,1)
					self:AddLine(db.CLICK.PICKUP, 1,1,1)
				end
				self:Show()
			end
		end
	end)
	-- Disable keyboard input when splitting stacks (will obstruct controller input)
	StackSplitFrame:EnableKeyboard(false)
	-- Remove the need to type "DELETE" when removing rare or better quality items
	StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM

	self.LoadHookScripts = nil
end