-- Desktop_WindowsLess.lua
-- OpenRDX
-- Use to register frame to be manage by RDX

-------------------------------------------------------------------
-- WINDOWLESS, register any external frame to be manage by RDXDK
-------------------------------------------------------------------

--
--
--

local classes = {};

function RDXDK.RegisterWindowLess(tbl)
	if (not tbl) or (not tbl.name) then RDX.printW(VFLI.i18n("attempt to register anonymous WindowLess")); return; end
	local n = tbl.name;
	if classes[n] then RDX.printW(VFLI.i18n("Duplicate registration WindowLess ") .. tbl.name); return; end
	classes[n] = tbl;
end

function RDXDK.GetWindowLess(cn)
	if not cn then return nil; end
	return classes[cn];
end

function RDXDK._GetWindowsLess()
	return classes;
end

RDX.RegisterFeature({
	name = "desktop_windowless",
	title = VFLI.i18n("RW");
	category = VFLI.i18n("Windows");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("Desktop") then return nil; end
		if not state:Slot("Desktop main") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if not __DesktopCheck_Name(desc, state, errs) then return nil; end
		return true;
	end,
	ApplyFeature = function(desc, state)
		state.Code:AppendCode([[
DesktopEvents:Dispatch("WINDOW_OPEN", "]] .. desc.name .. [[", "desktop_windowless");
		]]);
		
		return true;
	end,
	UIFromDescriptor = RDXUI.defaultUIFromDescriptor;
	CreateDescriptor = function()
		return {
			feature = "desktop_windowless";
			open = true;
			scale = 1;
			alpha = 1;
			strata = "MEDIUM";
			anchor = "TOPLEFT";
		}; 
	end;
});

-- direct function access

function RDXDK._AddRegisteredWindowRDX(path)
	DesktopEvents:Dispatch("WINDOW_OPEN", path, "desktop_windowless");
end

function RDXDK._DelRegisteredWindowRDX(path)
	DesktopEvents:Dispatch("WINDOW_CLOSE", path, "desktop_windowless");
end