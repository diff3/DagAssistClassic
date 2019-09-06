------------------------------------------------
--               DagAssistConfig              --
--             Dagos of Cenarius              --
------------------------------------------------

if (not DagAssist) then
	DagAssist = {};
end

--Set up the config frame
DagAssist.Config = CreateFrame("Frame", "DA_ConfigFrame", UIParent);
local fraConfig = DagAssist.Config;
fraConfig:SetFrameStrata("DIALOG");
fraConfig:EnableMouse(true);
fraConfig:RegisterForDrag("LeftButton");
fraConfig:SetToplevel(true);
fraConfig:SetMovable(true);
fraConfig:SetSize(384, 572);
fraConfig:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100);
fraConfig:SetClampedToScreen(true);
fraConfig:Hide();

fraConfig.configBackdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 13,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}
fraConfig:SetBackdrop(fraConfig.configBackdrop);
fraConfig:SetBackdropColor(0, 0, 0, 0.9);

fraConfig:SetScript("OnMouseDown",
	function(self, event, ...)
		self:StartMoving();
	end
)

fraConfig:SetScript("OnMouseUp",
	function(self, event, ...)
		self:StopMovingOrSizing();
	end
)

--Title
fraConfig.lblTitle = fraConfig:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
fraConfig.lblTitle:SetPoint("TOPLEFT", fraConfig, "TOPLEFT", 16, -16);
fraConfig.lblTitle:SetHeight(25);
fraConfig.lblTitle:SetText(GetAddOnMetadata("DagAssistClassic", "title").." v"..GetAddOnMetadata("DagAssistClassic", "version"));

-- Instructions
fraConfig.lblInstructions = fraConfig:CreateFontString(nil, 'ARTWORK');
fraConfig.lblInstructions:SetFont("Fonts\\FRIZQT__.TTF", 10, nil);
fraConfig.lblInstructions:SetPoint("TOPLEFT", fraConfig.lblTitle, "BOTTOMLEFT", 5, -5);
fraConfig.lblInstructions:SetWidth(340);
fraConfig.lblInstructions:SetJustifyH("LEFT");
fraConfig.lblInstructions:SetText("Please drag abilities/items for the selected menu section to the action slots below.  "..
								  "New sections can be created by typing in the New Section box and pressing Enter.");
fraConfig.lblInstructions:SetTextColor(1,1,1,1);

--Set up the group frame
DagAssist.SectionGroup = CreateFrame("Frame", "DA_ConfigFrame", fraConfig);
DagAssist.SectionGroup:EnableMouse(true);
DagAssist.SectionGroup:SetSize(344, 80);
DagAssist.SectionGroup:SetPoint("TOPLEFT", fraConfig, "TOPLEFT", 18, -80);
DagAssist.SectionGroup:SetBackdrop(fraConfig.configBackdrop);
DagAssist.SectionGroup:SetBackdropColor(1, 1, 1, 0.2);

--Header list
fraConfig.cboHeaders = CreateFrame("Frame", "DagAssistConfigHeaderList", fraConfig, "DA_Combobox");
fraConfig.cboHeaders:SetPoint("TOPLEFT", DagAssist.SectionGroup, "TOPLEFT", -5, -20)
function fraConfig.cboHeaders:OnClickEvent(selectedItem)
	DagAssistConfigSaveSection(fraConfig.cboHeaders.PreviousItem);
	DagAssistConfigLoadSection(selectedItem);
end

--Section label
fraConfig.lblMenuSection = DagAssist.SectionGroup:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
fraConfig.lblMenuSection:SetPoint("BOTTOMLEFT", fraConfig.cboHeaders, "TOPLEFT", 18, 0);
fraConfig.lblMenuSection:SetHeight(15);
fraConfig.lblMenuSection:SetText("Section");
fraConfig.lblMenuSection:SetTextColor(1,1,0,1);

-- Move up button
fraConfig.btnMoveUp = CreateFrame("Button", "DagAssistConfigMoveUpButton", DagAssist.SectionGroup, "DA_Button2");
fraConfig.btnMoveUp:SetSize(55, 25);
fraConfig.btnMoveUp:SetPoint("TOPLEFT", fraConfig.cboHeaders, "TOPRIGHT", -15, 0);
fraConfig.btnMoveUp:SetText("Up");
fraConfig.btnMoveUp:SetScript("OnClick",
	function(self, event, ...)
		for index = 1, table.getn(fraConfig.EditMenu) do
			local sectionData = fraConfig.EditMenu[index];
			if (sectionData.Name == fraConfig.cboHeaders.SelectedItem) then
				if (index ~= 1) then
					table.remove(fraConfig.EditMenu, index);
					table.insert(fraConfig.EditMenu, index-1, sectionData);
					DagAssistConfigSaveSection(sectionData.Name);
					DagAssistConfigLoadHeaders(sectionData.Name);
				end
				return;
			end
		end
	end
)

-- Move up button
fraConfig.btnMoveDown = CreateFrame("Button", "DagAssistConfigMoveDownButton", DagAssist.SectionGroup, "DA_Button2");
fraConfig.btnMoveDown:SetSize(55, 25);
fraConfig.btnMoveDown:SetPoint("TOPLEFT", fraConfig.btnMoveUp, "TOPRIGHT", 2, 0);
fraConfig.btnMoveDown:SetText("Down");
fraConfig.btnMoveDown:SetScript("OnClick",
	function(self, event, ...)
		for index = 1, table.getn(fraConfig.EditMenu) do
			local sectionData = fraConfig.EditMenu[index];
			if (sectionData.Name == fraConfig.cboHeaders.SelectedItem) then
				if (index ~= table.getn(fraConfig.EditMenu)) then
					table.remove(fraConfig.EditMenu, index);
					table.insert(fraConfig.EditMenu, index+1, sectionData);
					DagAssistConfigSaveSection(sectionData.Name);
					DagAssistConfigLoadHeaders(sectionData.Name);
				end
				return;
			end
		end
	end
)

--Delete button
fraConfig.btnDelete = CreateFrame("Button", "DagAssistConfigDeleteButton", DagAssist.SectionGroup, "DA_Button2");
fraConfig.btnDelete:SetSize(65, 25);
fraConfig.btnDelete:SetPoint("TOPLEFT", fraConfig.btnMoveDown, "TOPRIGHT", 2, 0);
fraConfig.btnDelete:SetText("Delete");
fraConfig.btnDelete:SetScript("OnClick",
	function(self, event, ...)
		if (table.getn(fraConfig.EditMenu) == 1) then
			return;
		end

		for index = 1, table.getn(fraConfig.EditMenu) do
			local sectionData = fraConfig.EditMenu[index];
			if (sectionData.Name == fraConfig.cboHeaders.SelectedItem) then
				table.remove(fraConfig.EditMenu, index);
				break;
			end
		end
		DagAssistConfigLoadHeaders();
	end
)

--New header editbox
fraConfig.txtNewHeader = CreateFrame("EditBox", "DagAssistConfigNewHeader", DagAssist.SectionGroup, "DA_Editbox");
fraConfig.txtNewHeader:SetSize(150, 25);
fraConfig.txtNewHeader:SetPoint("TOPLEFT", fraConfig.cboHeaders, "BOTTOMRIGHT", -45, 5);
fraConfig.txtNewHeader:SetAutoFocus(false);
function fraConfig.txtNewHeader:OnEnterEvent(editText)
	DagAssistConfigSaveSection(fraConfig.cboHeaders.SelectedItem);

	local newSection = {};
	newSection.Name = editText;
	newSection.Actions = {};
	table.insert(fraConfig.EditMenu, newSection);

	DagAssistConfigLoadHeaders(editText);

	self:SetText("");
	self:ClearFocus();
end

--New section label
fraConfig.lblNewSection = DagAssist.SectionGroup:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
fraConfig.lblNewSection:SetPoint("RIGHT", fraConfig.txtNewHeader, "LEFT", -5, 0);
fraConfig.lblNewSection:SetHeight(15);
fraConfig.lblNewSection:SetText("New Section");
fraConfig.lblNewSection:SetTextColor(1,1,0,1);

--Cancel button
fraConfig.btnCancel = CreateFrame("Button", "DagAssistConfigCancelButton", fraConfig, "DA_Button2");
fraConfig.btnCancel:SetSize(75, 25);
fraConfig.btnCancel:SetPoint("BOTTOMRIGHT", fraConfig, "BOTTOMRIGHT", -10, 10);
fraConfig.btnCancel:SetText("Cancel");
fraConfig.btnCancel:SetScript("OnClick",
	function(self, event, ...)
		DagAssistConfigSaveSection(fraConfig.cboHeaders.SelectedItem);
		fraConfig:Hide();
		DagAssist:LoadMenu();
	end
)

--OK button
fraConfig.btnOk = CreateFrame("Button", "DagAssistConfigOKButton", fraConfig, "DA_Button2");
fraConfig.btnOk:SetSize(75, 25);
fraConfig.btnOk:SetPoint("TOPRIGHT", fraConfig.btnCancel, "TOPLEFT");
fraConfig.btnOk:SetText("Okay");
fraConfig.btnOk:SetScript("OnClick",
	function(self, event, ...)
		DagAssistConfigSaveSection(fraConfig.cboHeaders.SelectedItem);
		DA_Vars.Menu = 	fraConfig.EditMenu;
		fraConfig:Hide();
		DagAssist:LoadMenu();
	end
)

--[[
--Hide minimap button
fraConfig.chkHideMinimap = CreateFrame("CheckButton", "DagAssistConfigHideMinimapButton", fraConfig, "ChatConfigCheckButtonTemplate");
fraConfig.chkHideMinimap:SetPoint("BOTTOMLEFT", fraConfig, "BOTTOMLEFT", 10, 10);

--Hide minimap button label
fraConfig.lblHideButton = fraConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
fraConfig.lblHideButton:SetPoint("LEFT", fraConfig.chkHideMinimap, "RIGHT", 0, 2);
fraConfig.lblHideButton:SetHeight(7);
fraConfig.lblHideButton:SetText("Hide minimap button");
--]]

function DagAssistRetrieveCursorItem(self, event, ...)
	if (InCombatLockdown() == 1) then
		return;
	end

	if (GetCursorInfo()) then
		local oldActionType, oldActionData, oldActionSubType;
		if (self.DA_ActionData) then
			oldActionType = self.DA_ActionType;
			oldActionData = self.DA_ActionData;
			oldActionSubType = self.DA_ActionSubType;
		end

		local cursorType, cursorData, cursorSubType;
		cursorType, cursorData, cursorSubType, spellID = GetCursorInfo();
		ClearCursor();

		local itemName, itemID;

		if cursorType == "companion" then
			_, itemName = GetCompanionInfo(cursorSubType, cursorData);
			cursorData = itemName;
		elseif cursorType == "item" then
			_, link, _, _, _, _, _, _, _, itemTexture, _ = GetItemInfo(cursorData);
			local _, _, parts = strsplit("|", link);
			_, itemID = strsplit(":", parts);
			cursorData = itemID;
		elseif cursorType == "spell" then
			cursorData = spellID;
		end

		DagAssistAssignConfigButtonAction(self, cursorType, cursorData, cursorSubType);

		if (oldActionData) then
			DagAssistPickupAction(oldActionType, oldActionData, oldActionSubType);
		end
	end
end

function DagAssistAssignConfigButtonAction(self, actionType, actionData, actionSubType)
	--local itemTexture, itemName;

	local actionInfo = DagAssistGetActionInfo(actionType, actionData, actionSubType);

	self.DA_ActionType = actionType;
	self.DA_ActionSubType = actionSubType;
	self.DA_ActionData = actionData;

	if (actionInfo.Texture) then self.Icon:SetTexture(actionInfo.Texture); end
	if (actionInfo.Name) then
		self:SetText(actionInfo.Name);
	else
		self:SetText("nil");
	end
end

function DagAssistGetActionInfo(actionType, actionData, actionSubType)
	local itemTexture, itemName;
	local ret = {};

	if actionType == "companion" then
		local companionID = DagAssistGetCompanionID(actionSubType, actionData)
		_, itemName, _, itemTexture, _ = GetCompanionInfo(actionSubType, companionID);
	elseif actionType == "equipmentset" then
		itemName = actionData;
		itemTexture, _ = GetEquipmentSetInfoByName(actionData);
		if (itemTexture) then
			itemTexture = "Interface\\Icons\\"..itemTexture;
		end
	elseif actionType == "item" then
		itemName, _, _, _, _, _, _, _, _, itemTexture, _ = GetItemInfo(actionData);

	elseif actionType == "macro" then
		itemName, itemTexture, _ = GetMacroInfo(actionData);
	elseif actionType == "spell" then
		itemName = GetSpellInfo(actionData);
		itemTexture = GetSpellTexture(itemName);
	end
	if (itemName) then
		ret.Name = itemName;
	end
	if (itemTexture) then
		ret.Texture = itemTexture;
	end

	return ret;
end

function DagAssistClearConfigButtonAction(self)
	self:SetText(nil);
	self.Icon:SetTexture(nil);
	self.DA_ActionType = nil;
	self.DA_ActionData = nil;
	self.DA_ActionSubType = nil;
end

function DagAssistPickupAction(actionType, actionData, actionSubType)
	if actionType == "companion" then
		local companionID = DagAssistGetCompanionID(actionSubType, actionData);
		PickupCompanion(actionSubType, companionID);
	elseif actionType == "equipmentset" then
		PickupEquipmentSetByName(actionData);
	elseif actionType == "item" then
		PickupItem(actionSubType);
	elseif actionType == "macro" then
		PickupMacro(actionData);
	elseif actionType == "spell" then
		PickupSpell(actionData);
	end
end

function DagAssistGetCompanionID(subType, name)
	local i = 1;
	local _, itemName = GetCompanionInfo(subType, i);

	while (itemName) do
		if (itemName == name) then
			return i;
		end

		i = i + 1;
		_, itemName = GetCompanionInfo(subType, i);
	end
end


function DagAssistOnDragStart(self, event, ...)
	if (InCombatLockdown() == 1) then
		return;
	end

	local cursorType, cursorData, cursorSubType;
	if (GetCursorInfo()) then
		cursorType, cursorData, cursorSubType = GetCursorInfo();
		ClearCursor();
	end

	if (self.DA_ActionData) then
		DagAssistPickupAction(self.DA_ActionType, self.DA_ActionData, self.DA_ActionSubType);

		if (cursorData) then
			DagAssistAssignConfigButtonAction(self, cursorType, cursorData, cursorSubType);
		else
			DagAssistClearConfigButtonAction(self);
		end
	end
end


--Items label
fraConfig.lblMenuItems = fraConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
fraConfig.lblMenuItems:SetPoint("TOPLEFT", fraConfig, "TOPLEFT", 40, -165);
fraConfig.lblMenuItems:SetHeight(15);
fraConfig.lblMenuItems:SetText("Drag Actions Below");
fraConfig.lblMenuItems:SetTextColor(1,1,0,1);

--Menu items
fraConfig.previousMenuItem = nil;
fraConfig.configButtons = {};
for index = 1, 15 do
	local currentItem = CreateFrame("Button", "DagAssistMenuItem"..index, fraConfig, "DAConfig_MenuButtonTemplate");
	table.insert(fraConfig.configButtons, currentItem);
	currentItem:SetBackdropColor(1, 0, 0, 0.5);
	if (fraConfig.previousMenuItem) then
		currentItem:SetPoint("TOPLEFT", fraConfig.previousMenuItem, "BOTTOMLEFT");
	else
		currentItem:SetPoint("TOPLEFT", fraConfig, "TOPLEFT", 50, -185);
	end

	currentItem.Icon = currentItem:CreateTexture("DagAssistMenuItemIcon"..index, "OVERLAY");
	currentItem.Icon:SetSize(16, 16);
	currentItem.Icon:SetPoint("TOPLEFT", currentItem, "TOPLEFT", 2, -2);
	currentItem:RegisterForDrag("LeftButton");

	currentItem:SetScript("OnDragStart", DagAssistOnDragStart);
	currentItem:SetScript("OnReceiveDrag", DagAssistRetrieveCursorItem);
	currentItem:SetScript("OnClick", DagAssistRetrieveCursorItem);

	fraConfig.previousMenuItem = currentItem;
end

function DagAssistConfigSaveSection(section)
	--Save the displayed menu section

	--Find the correct menu section
	for index = 1, table.getn(fraConfig.EditMenu) do
		local sectionData = fraConfig.EditMenu[index];
		if (sectionData.Name == section) then
			sectionData.Actions = {};

			for actionIndex = 1, table.getn(fraConfig.configButtons) do
				local configButton = fraConfig.configButtons[actionIndex];
				if (configButton.DA_ActionData) then
					local saveData = {};
					saveData.DA_ActionType = configButton.DA_ActionType;
					saveData.DA_ActionData = configButton.DA_ActionData;
					saveData.DA_ActionSubType = configButton.DA_ActionSubType;
					table.insert(sectionData.Actions, saveData);
				end
			end

			break;
		end
	end

end

function DagAssistConfigLoadHeaders(selectedHeader)
	local headers = {};
	local selectedIndex = 1;

	for index = 1, table.getn(fraConfig.EditMenu) do
		local sectionData = fraConfig.EditMenu[index];

		if (not selectedHeader) then
			selectedHeader = sectionData.Name;
		end
		if (sectionData.Name == selectedHeader) then
			selectedIndex = index;
		end

		table.insert(headers, sectionData.Name);
	end
	fraConfig.cboHeaders.AddRange(headers);

	UIDropDownMenu_SetSelectedID(fraConfig.cboHeaders, selectedIndex);
	fraConfig.cboHeaders.PreviousItem = fraConfig.cboHeaders.SelectedItem;
	fraConfig.cboHeaders.SelectedItem = selectedHeader;

	DagAssistConfigLoadSection(selectedHeader);
end

function DagAssistConfigLoadSection(section)
	for index = 1, table.getn(fraConfig.configButtons) do
		local configButton = fraConfig.configButtons[index];
		DagAssistClearConfigButtonAction(configButton);
	end

	for index = 1, table.getn(fraConfig.EditMenu) do
		local sectionData = fraConfig.EditMenu[index];
		if (sectionData.Name == section) then
			if (sectionData.Actions) then
				for actionIndex = 1, table.getn(sectionData.Actions) do
					local configButton = fraConfig.configButtons[actionIndex];
					local saveData = sectionData.Actions[actionIndex];
					DagAssistAssignConfigButtonAction(configButton, saveData.DA_ActionType, saveData.DA_ActionData, saveData.DA_ActionSubType);
				end
			end
			break;
		end
	end
end

function DagAssistCloneTable(t)
	local ret = {};
	local i, v = next(t, nil);
	while i do
		if type(v)=="table" then
			v = DagAssistCloneTable(v);
		end
		ret[i] = v;
		i, v = next(t, i);
	end
	return ret
end

function DagAssistConfigFrame_Show()
	if ( not DagAssist.Config:IsVisible() ) then
		if (DA_Vars.Menu) then
			fraConfig.EditMenu = DagAssistCloneTable(DA_Vars.Menu);
		else
			fraConfig.EditMenu = DagAssist.LoadDefaultMenu();
		end

		DagAssistConfigLoadHeaders();
		DagAssist.Config:Show();
	end
end
