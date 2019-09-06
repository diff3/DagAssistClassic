------------------------------------------------
--                 DagAssist                  --
--             Dagos of Cenarius              --
------------------------------------------------

if (not DagAssist) then
	DagAssist = {};
end

function DagAssist:Debug(msg)
	if (msg) then
		DEFAULT_CHAT_FRAME:AddMessage(msg);
	else
		DEFAULT_CHAT_FRAME:AddMessage("nil");
	end
end

-- Setup slash command for resetting variables and position
SLASH_DAGASSIST1, SLASH_DAGASSIST2 = '/dagassist', '/da';
function DagAssist.SlashHandler(msg, editbox)
	local title = GetAddOnMetadata("DagAssistClassic", "title").." v"..GetAddOnMetadata("DagAssistClassic", "version");
	if msg == 'reset' then
		if (InCombatLockdown() == 1) then
			print("<"..title.."> Reset cannot be completed in combat!");
		else
			DA_Vars = {Minimap = {}};
			DagAssist.LoadMenu();
		--	DagAssistConfigLoadHeaders();
			 DagAssist:PositionMinimapButton();
			print("<"..title.."> Reset complete");
		end
	else
		print("<"..title.."> Usage: /da [reset]");
	end
end
SlashCmdList["DAGASSIST"] = DagAssist.SlashHandler;

--Set up the minimap button
DagAssist.MinimapButton = CreateFrame("Button", "DA_Minimap", Minimap, "SecureHandlerClickTemplate, DA_MinimapButton");
local btnMinimap = DagAssist.MinimapButton;
btnMinimap:RegisterForDrag("LeftButton");
btnMinimap:SetClampedToScreen(true);

local texture = btnMinimap:CreateTexture(nil, "ARTWORK");
texture:SetTexture("Interface\\AddOns\\DagAssistClassic\\Images\\MinmapIconHighlight");
texture:SetBlendMode("BLEND");
texture:SetAllPoints(btnMinimap);
btnMinimap:SetHighlightTexture(texture);

DagAssist.Menu = CreateFrame("Frame", "DA_Menu", UIParent, "SecureHandlerBaseTemplate, DA_MenuContainer");
DagAssist.Menu:SetClampedToScreen(true);
DagAssist.Menu:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
DagAssist.Menu:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, 1);
btnMinimap:SetFrameRef("dag_menu", DagAssist.Menu);

--Pressing ESC will close the menu out of combat
tinsert(UISpecialFrames,DagAssist.Menu:GetName()); --http://forums.wowace.com/showthread.php?t=17709
DagAssist.Menu.IsShownOld = DagAssist.Menu.IsShown;
DagAssist.Menu.IsShown = function(self, ...)
	if (InCombatLockdown() == 1) then
		return false;
	else
		return DagAssist.Menu:IsShownOld();
	end
end
DagAssist.Menu:Hide();

btnMinimap:Execute([[
	menuItems = table.new();

	Close = [=[
		self:GetFrameRef("dag_menu"):Hide();
	]=]

	Show = [=[
		local dag_menu = self:GetFrameRef("dag_menu");

		dag_menu:Show();
		dag_menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT");

		for i, button in ipairs(menuItems) do
			local enabled = button:GetAttribute("enabled");
			if (enabled) then
				button:Enable();
			else
				button:Disable();
			end
			button:Show();
		end
	]=]

	table.insert(menuItems, dag_menu);
]]);

btnMinimap:SetAttribute("_onclick", [[
	if self:GetFrameRef("dag_menu"):IsVisible() then
		control:Run(Close);
	else
		control:Run(Show);
	end
]]);

btnMinimap:SetScript("OnDragStart",
	function(self, event, ...)
		self:StartMoving();
		self.Dragging = true;
		if (InCombatLockdown() ~= 1) then
			btnMinimap:Execute([[
				control:Run(Close);
			]]);
		end
	end
)

btnMinimap:SetScript("OnDragStop",
	function(self, event, ...)
		self:StopMovingOrSizing();

		if (self.Dragging) then
			self.Dragging = false;
			local s = self:GetEffectiveScale();
			DA_Vars.Minimap.X = self:GetLeft() * s;
			DA_Vars.Minimap.Y = self:GetTop() * s;
		end
	end
)

btnMinimap:RegisterForClicks("AnyDown");
btnMinimap:SetScript("OnEvent", function(self, event, ...)
	if (type(DagAssist[event]) == 'function') then
		DagAssist[event](self, event, ...);
	end
end)
btnMinimap:RegisterEvent("PLAYER_ENTERING_WORLD");

function DagAssist.OnUpdate(self, elapsed, ...)
	if (not DagAssist.MenuLoaded) then
		return;
	end
	if (DagAssist.AllIconsSet) then
		btnMinimap:SetScript("OnUpdate", nil);
		return;
	end

	if (self.TimeSinceLastUpdate) then
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

		if (self.TimeSinceLastUpdate > 0.5) then
			self.TimeSinceLastUpdate = 0;

			local allIconsSet = true;
			for buttonIndex = 1, table.getn(DagAssist.Buttons) do
				local btn = DagAssist.Buttons[buttonIndex];
				if (not btn.IconSet) then
					local actionInfo = DagAssistGetActionInfo(btn.Action.DA_ActionType, btn.Action.DA_ActionData, btn.Action.DA_ActionSubType);
					if (actionInfo.Name) then
						btn:SetText(actionInfo.Name);
						if (btn.Action.DA_ActionData == "6948") then
							btn:SetText(GetBindLocation());
						end

						if (actionInfo.Texture) then
							btn.Texture:SetTexture(actionInfo.Texture);

							if (InCombatLockdown() ~= 1) then
								if btn.Action.DA_ActionType == "item" then
									btn:SetAttribute("type","item");
									btn:SetAttribute("*item1", actionInfo.Name);

								elseif btn.Action.DA_ActionType == "spell" then
									if (btn.Action.DA_ActionSubType == "spell") then
										btn:SetAttribute("type","spell");
										btn:SetAttribute("*spell1", actionInfo.Name);
									else
										btn:SetAttribute("type","pet");
										btn:SetAttribute("*pet1", actionInfo.Name);
									end
								end

								btn.IconSet = true;
							end
						else
							btn.IconSet = false;
							allIconsSet = false;
						end
					else
						btn.IconSet = false;
						allIconsSet = false;
					end
				end
			end

			DagAssist.AllIconsSet = allIconsSet;
		end
	else
		self.TimeSinceLastUpdate = 0;
	end
end
btnMinimap:SetScript("OnUpdate", DagAssist.OnUpdate);

function DagAssist:PositionMinimapButton()
	if (not DA_Vars) then
		DA_Vars = {Minimap = {}};
	end
	if (not DA_Vars.Minimap) then
		DA_Vars.Minimap = {};
	end

	if (DA_Vars.Minimap.X and DA_Vars.Minimap.Y) then
		--Restore last position
		local s = btnMinimap:GetEffectiveScale();

		btnMinimap:ClearAllPoints()
		btnMinimap:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", DA_Vars.Minimap.X / s, DA_Vars.Minimap.Y /s);
	else
		btnMinimap:ClearAllPoints()
		btnMinimap:SetPoint("CENTER", Minimap, "BOTTOMLEFT", 15, 15);
	end
end

function DagAssist:PLAYER_ENTERING_WORLD(self, event)
	DagAssist:PositionMinimapButton();
	DagAssist:LoadMenu();
	DagAssist.MinimapButton:Show();

	btnMinimap:RegisterEvent("BAG_UPDATE");
	btnMinimap:RegisterEvent("LEARNED_SPELL_IN_TAB");
	btnMinimap:RegisterEvent("PLAYER_REGEN_DISABLED");
	btnMinimap:RegisterEvent("PLAYER_REGEN_ENABLED");
end

function DagAssist:LoadMenu()
	if (InCombatLockdown()) then
		DagAssist.ReloadNeeded = true;
		return;
	end

  local menu = DagAssist.Menu;
  if (not DA_Vars.Menu) then
    DA_Vars.Menu = DagAssist.LoadDefaultMenu()
  end
  
  if (not DagAssist.Buttons) then
    DagAssist.Buttons = {};
  end

	DagAssist.MenuLoaded = false;
	DagAssist.AllIconsSet = false;
	btnMinimap:SetScript("OnUpdate", DagAssist.OnUpdate);

	btnMinimap:Execute([[
		if (menuItems) then
			for i, button in ipairs(menuItems) do
				button:Hide();
			end
		end
		menuItems = table.new();
	]]);


	local menuItems = DA_Vars.Menu;
	local btnMenuItem;
	for index = 1, table.getn(menuItems) do
		local section = menuItems[index];

		--Create section header
		btnMenuItem = _G["DA_MenuHeader"..index];
		if (not btnMenuItem) then
			btnMenuItem = CreateFrame("Button", "DA_MenuHeader"..index, menu, "SecureHandlerBaseTemplate, DA_MenuLabelTemplate");
		end
		btnMenuItem:SetText(section.Name);
		btnMenuItem:SetFrameRef("dag_menu", DagAssist.Menu);
		btnMenuItem:Show();
		btnMinimap:SetFrameRef("child", btnMenuItem);
		btnMinimap:Execute([[
			table.insert(menuItems, self:GetFrameRef("child"));
		]]);

		for actionIndex = 1, table.getn(section.Actions) do
			local action = section.Actions[actionIndex];
			local actionInfo = DagAssistGetActionInfo(action.DA_ActionType, action.DA_ActionData, action.DA_ActionSubType);

			local buttonIndex = actionIndex + (index * 100);
			if action.DA_ActionType == "companion" or action.DA_ActionType == "equipmentset" then
				btnMenuItem = _G["DA_MenuButton"..buttonIndex];
				if (not btnMenuItem) then
					btnMenuItem = CreateFrame("Button", "DA_MenuButton"..buttonIndex, menu, "SecureHandlerBaseTemplate, DA_MenuSpellButtonTemplate");
				end
				btnMenuItem.Texture = _G["DA_MenuButton"..buttonIndex.."Icon"];
				btnMenuItem.Action = action;

				if action.DA_ActionType == "companion" then
					btnMenuItem:SetScript("OnClick", function(self)
														if (IsMounted()) then
															Dismount();
														else
															local companionID = DagAssistGetCompanionID(self.Action.DA_ActionSubType, self.Action.DA_ActionData);
															CallCompanion(self.Action.DA_ActionSubType, companionID);
														end
													 end);

				elseif action.DA_ActionType == "equipmentset" then
					btnMenuItem:SetScript("OnClick", function(self)
														UseEquipmentSet(self.Action.DA_ActionData);
													 end);
				end

			else
				btnMenuItem = _G["DA_MenuSecureButton"..buttonIndex];
				if (not btnMenuItem) then
					btnMenuItem = CreateFrame("Button", "DA_MenuSecureButton"..buttonIndex, menu, "SecureActionButtonTemplate, SecureHandlerBaseTemplate, DA_MenuSpellButtonTemplate");
				end
				btnMenuItem.Texture = _G["DA_MenuSecureButton"..buttonIndex.."Icon"];
				btnMenuItem.Action = action;

				if action.DA_ActionType == "item" then
					btnMenuItem:SetAttribute("type","item");
					btnMenuItem:SetAttribute("*item1", actionInfo.Name);

				elseif action.DA_ActionType == "macro" then
					btnMenuItem:SetAttribute("type","macro");
					btnMenuItem:SetAttribute("*macro1", action.DA_ActionData);

				elseif action.DA_ActionType == "spell" then
					if (action.DA_ActionSubType == "spell") then
						btnMenuItem:SetAttribute("type","spell");
						btnMenuItem:SetAttribute("*spell1", actionInfo.Name);
					else
						btnMenuItem:SetAttribute("type","pet");
						btnMenuItem:SetAttribute("*pet1", actionInfo.Name);
					end
				end
			end
			btnMenuItem:SetAttribute("checkselfcast","1");
			btnMenuItem:SetAttribute("checkfocuscast","1");
			btnMenuItem:SetFrameRef("dag_menu", DagAssist.Menu);
			btnMinimap:WrapScript(btnMenuItem, "OnClick", [[control:Run(Close)]])
			btnMenuItem:SetAttribute("enabled", true);
			btnMenuItem:SetFrameLevel(btnMenuItem:GetFrameLevel() + 1);

			if (actionInfo.Name) then
				btnMenuItem:SetText(actionInfo.Name);
				if (action.DA_ActionData == "6948") then
					btnMenuItem:SetText(GetBindLocation());
				end

				if (actionInfo.Texture) then
					btnMenuItem.Texture:SetTexture(actionInfo.Texture);
					btnMenuItem.IconSet = true;
				else
					btnMenuItem.IconSet = false;
				end
			else
				btnMenuItem.IconSet = false;
			end
			btnMenuItem:Show();

			btnMinimap:SetFrameRef("child", btnMenuItem);
			btnMinimap:Execute([[
				table.insert(menuItems, self:GetFrameRef("child"));
			]]);
			table.insert(DagAssist.Buttons, btnMenuItem);
		end
	end

	--Add the config button
	btnMenuItem = _G["DA_MenuButtonConfig"];
	if (not btnMenuItem) then
		btnMenuItem = CreateFrame("Button", "DA_MenuButtonConfig", menu, "SecureHandlerBaseTemplate, DA_MenuButtonTemplate");
	end
	btnMenuItem:SetText("Config");
	btnMenuItem:SetAttribute("visible", true);
	btnMenuItem:SetAttribute("enabled", true);
	btnMenuItem:SetScript("OnClick",
		function(self, event, ...)
			DagAssistConfigFrame_Show();
		end
	);
	btnMinimap:WrapScript(btnMenuItem, "OnClick", [[control:Run(Close)]])
	btnMinimap:SetFrameRef("child", btnMenuItem);
	btnMenuItem:Show();
	btnMinimap:Execute([[
		table.insert(menuItems, self:GetFrameRef("child"));
	]]);

	--Add the close button
	btnMenuItem = _G["DA_MenuButtonClose"];
	if (not btnMenuItem) then
		btnMenuItem = CreateFrame("Button", "DA_MenuButtonClose", menu, "SecureActionButtonTemplate, SecureHandlerBaseTemplate, DA_MenuButtonTemplate");
	end
	btnMenuItem:SetText("Close");
	btnMenuItem:SetAttribute("type", "click");
	btnMenuItem:SetAttribute("clickbutton", btnMinimap);
	btnMenuItem:SetAttribute("visible", true);
	btnMenuItem:SetAttribute("enabled", true);
	btnMinimap:SetFrameRef("child", btnMenuItem);
	btnMenuItem:Show();
	btnMinimap:Execute([[
		table.insert(menuItems, self:GetFrameRef("child"));
	]]);

	btnMinimap:Execute([[
		local previous;
		local dag_menu = self:GetFrameRef("dag_menu");
		local menuHeight = 20;
		for i, button in ipairs(menuItems) do
			menuHeight = menuHeight + 18;
			if (previous) then
				button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT");
			else
				button:SetPoint("TOPLEFT", dag_menu, "TOPLEFT", 10, -10);
			end
			previous = button;
		end

		dag_menu:SetHeight(menuHeight);
	]]);
	DagAssist.MenuLoaded = true;
end

function DagAssist:PLAYER_REGEN_DISABLED(self, event)
        --DagAssist:SetMenuItemVisibility();
end
function DagAssist:PLAYER_REGEN_ENABLED(self, event)
	if (DagAssist.ReloadNeeded) then
		DagAssist:LoadMenu();
		DagAssist.ReloadNeeded = false;
	end
end
function DagAssist:BAG_UPDATE(self, event)
        --DagAssist:SetMenuItemVisibility();
end
function DagAssist:LEARNED_SPELL_IN_TAB(self, event)
        --DagAssist:SetMenuItemVisibility();
end
