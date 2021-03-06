-- MainPanel.lua
-- OpenRDX
-- New Main Panel

-- mainbuttondb : first line of button
-- buttondb : second line of button

local mainbuttondb, buttondb = {}, {};
local sortedmb, sortedb = {}, {};

RDXPM.CompactMenu = RDXPM.Menu:new();

------------------------
-- "MINIMIZED" RDX ICON
------------------------
local miniPane = nil;

RDXPM.CompactMenu:RegisterMenuFunction(function(ent)
	ent.text = "RDX";
	ent.notCheckable = true;
	ent.isTitle = true;
	ent.justifyH = "CENTER";
end);

RDXPM.CompactMenu:RegisterMenuFunction(function(ent)
	ent.text = VFLI.i18n("Quick Options");
	ent.notCheckable = true;
	ent.hasArrow = true;
	ent.keepShownOnClick = false;
	ent.menuList = {
		{ text = VFLI.i18n("Tutorial RDX"), notCheckable = true, keepShownOnClick = false, func = function() RDX.NewLearnWizard(); end },
		{ text = VFLI.i18n("Package Explorer"), notCheckable = true, keepShownOnClick = false, func = RDXDB.ToggleObjectBrowser },
	};
end);

RDXPM.CompactMenu:RegisterMenuFunction(function(ent)
	ent.text = VFLI.i18n("Themes");
	ent.notCheckable = true;
	ent.hasArrow = true;
	ent.keepShownOnClick = false;
	ent.menuList = RDXPM.subMenus;
end);

RDXPM.CompactMenu:RegisterMenuFunction(function(ent)
	ent.text = VFLI.i18n("Theme state");
	ent.notCheckable = true;
	ent.hasArrow = true;
	ent.keepShownOnClick = false;
	ent.menuList = RDXPM.stateTypeMenus;
end);
	
--RDXPM.CompactMenu:RegisterMenuFunction(function(ent)
--	ent.text = VFLI.i18n("Action bars");
--	ent.notCheckable = true;
--	ent.hasArrow = true;
--	ent.menuList = {
		--{ text = "Desktop", checked = RDXDK.IsDesktopLocked, func = RDXDK.ToggleDesktopLock },
--		{ text = "Configure keys", checked = RDXDK.IsKeyBindingsLocked, func = RDXDK.ToggleKeyBindingsLock },
--		{ text = "Lock Action Buttons", checked = RDXDK.IsActionBindingsLocked, func = RDXDK.ToggleActionBindingsLock }
--	};
--end);
	
RDXPM.CompactMenu:RegisterMenuFunction(function(ent)
	ent.text = VFLI.i18n("Visibility");
	ent.notCheckable = true;
	ent.hasArrow = true;
	ent.menuList = {
		{ text = VFLI.i18n("Main Panel"), checked = function() return not RDXPM.IsPanelHidden(); end, func = RDXPM.ToggleHidePanel }
	};
end);

RDXPM.CompactMenu:RegisterMenuFunction(function(ent)
	ent.text = "**************";
	ent.notCheckable = true;
	ent.func = VFL.Noop;
	end);

RDXPM.CompactMenu:RegisterMenuFunction(function(ent)
	ent.text = VFLI.i18n("Reload UI");
	ent.notCheckable = true;
	ent.func = VFLReloadUI;
end);

local function CreateMiniPane()
	local mini = VFLUI.AcquireFrame("Button");
	mini:SetParent(VFLDIALOG); 
	mini:SetScale(Minimap:GetEffectiveScale() / RDXParent:GetEffectiveScale());
	mini:SetMovable(true);
	mini:SetPoint("CENTER", VFLParent, "CENTER");
	mini:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");
	mini:SetHeight(32); mini:SetWidth(32);
	mini:SetClampedToScreen(true);
	mini:Show();
	local tx1 = VFLUI.CreateTexture(mini);
	tx1:SetPoint("TOPLEFT", mini, "TOPLEFT"); tx1:SetWidth(56); tx1:SetHeight(56);
	tx1:SetDrawLayer("OVERLAY");
	tx1:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); tx1:Show();
	
	local tx2 = VFLUI.CreateTexture(mini);
	tx2:SetPoint("CENTER", mini, "CENTER"); tx2:SetHeight(24); tx2:SetWidth(24);
	tx2:SetDrawLayer("BACKGROUND");
	tx2:SetTexture("Interface\\Addons\\RDX\\Skin\\mmbtn"); tx2:Show();
	
	--mini:SetScript("OnEnter", function(self)
	--	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	--	GameTooltip:SetPoint("BOTTOMLEFT", self, anchor, 0, 20);
	--	GameTooltip:ClearLines();
	--	GameTooltip:AddDoubleLine("Tips", "Use the key Shift to drag this button");
	--	GameTooltip:Show();
	--end);
	
	--mini:SetScript("OnLeave", function(self)
	--	GameTooltip:Hide();
	--end);
	
	local mmvg = nil;
	local shiftRight = nil;
	mini:SetScript("OnMouseDown", function(self, arg1)
		if (arg1 == "LeftButton") then
			if (IsShiftKeyDown()) then
				mmvg = true;
				mini:StartMoving();
				return;
			end
		elseif (arg1 == "RightButton") then
			if not InCombatLockdown() then
				local curdesk = RDXDK.GetCurrentDesktop();
				if curdesk then
					RDXDK.ToggleDesktopTools(VFLFULLSCREEN_DIALOG, curdesk:_GetFrameProps("root"));
				end
			end
		end
	end);
	
	-- function main panel layout
	function mini:Layout()
		RDXPM.RestoreLayout(mini, "MiniButton");
	end
	
	mini:SetScript("OnMouseUp", function(this, arg1)
		if mmvg then
			mmvg = nil;
			mini:StopMovingOrSizing();
			RDXPM.StoreLayout(mini, "MiniButton");
			return;
		end
		if(arg1 == "LeftButton") then
			RDXPM.CompactMenu:Open();
		end
	end);
	
	return mini;
end

------------
-- INIT
-- Create the menu pane and show all buttons
----------------------------------------------
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()	
	-- Mini Panel
	miniPane = CreateMiniPane();
	miniPane:Layout();
end);

function RDXPM.GetMiniPane() return miniPane; end