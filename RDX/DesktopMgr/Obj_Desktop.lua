-- Obj_Desktop.lua
-- OpenRDX

RDXDK = RegisterVFLModule({
	name = "RDXDK";
	title = VFLI.i18n("RDX Desktop Object");
	description = "RDX Desktop GUI Editor";
	version = {1,0,0};
	parent = RDX;
});
--RDXDK:ModuleSetDebugLevel(10);

DesktopEvents = DispatchTable:new();
-- Main currentDesktop Object
local currentDesktop = nil;
local currentpath = nil;

--[[ 
DESKTOP events
To open a desktop
DesktopEvents:Dispatch("DESKTOP_OPEN", name);
To close a desktop
DesktopEvents:Dispatch("DESKTOP_CLOSE");
To rebuild a desktop
DesktopEvents:Dispatch("DESKTOP_REBUILD");
DesktopEvents:Dispatch("DESKTOP_LOCK");
DesktopEvents:Dispatch("DESKTOP_UNLOCK");
DesktopEvents:Dispatch("DESKTOP_VIEWPORT", useviewport, offsetleft, offsettop, offsetright, offsetbottom);

WINDOW events
DesktopEvents:Dispatch("WINDOW_OPEN", name, wtype);
DesktopEvents:Dispatch("WINDOW_CLOSE", name, wtype);
DesktopEvents:Dispatch("WINDOW_REBUILD", name);
DesktopEvents:Dispatch("WINDOW_REBUILD_ALL);
DesktopEvents:Dispatch("WINDOW_UPDATE", name, key, value);
DesktopEvents:Dispatch("WINDOW_UPDATE_ALL", key, value);
key is : STRATA, ALPHA, SCALE, POSITION

DOCKING events
DesktopEvents:Dispatch("WINDOW_DOCK", srcname, srcpt, tgtname, tgtpt);
DesktopEvents:Dispatch("WINDOW_DOCKOFFSET", srcname, srcpt, x, y);
DesktopEvents:Dispatch("WINDOW_UNDOCK", srcname, tgtname);
DesktopEvents:Dispatch("WINDOW_PARENTDOCK", name);

NAMEPLATE events
DesktopEvents:Dispatch("NAMEPLATE", path);

frameprops structure :
["strata"] = "MEDIUM",
["r"] = 1046.319788517272,
["scale"] = 1,
["t"] = 449.2802488668881,
["open"] = 1,
["feature"] = "desktop_window",
["name"] = "RDX_ActionBars:barsh3",
["dock"] = {
	["TOPLEFT"] = {
		["id"] = "RDX_ActionBars:barsh4",
		["point"] = "TOPRIGHT",
	},
},
["alpha"] = 1,
["l"] = 1019.319777045922,
["b"] = 125.280253018464,
["ap"] = "TOPLEFT",


]]
----------------------------------------------------
-- Helper functions
----------------------------------------------------

--- Print an error message from inside compiled paint code.
local _err_norepeat = {};
setmetatable(_err_norepeat, {__mode = 'k'});
function RDXDK.PrintError(win, info, err)
	if (type(win) == "table") and (not _err_norepeat[win]) then
		_err_norepeat[win] = true;
		local ident, path = "<unknown>", "<unknown>";
		if (type(win._dk_name) == "string") then
			ident = win._dk_name;
		end
		if (type(win._path) == "string") then
			path = win._path;
		end
		VFL.TripError("RDX", VFLI.i18n("Window <") .. ident .. VFLI.i18n("> caused a paint error.", "Pointer: ") .. tostring(win) .. VFLI.i18n("\nIdentity: ") .. ident ..VFLI.i18n("\nPath: ") .. path .. VFLI.i18n("\nError\n--------\n") .. err);
	end
end

--------------------------------------------
-- Desktop object
--------------------------------------------
RDXDK.Desktop = {};
function RDXDK.Desktop:new(parent)
	local self = VFLUI.AcquireFrame("Frame");
	--if not parent then parent = UIParent; end
	self:SetParent(VFLparent);
	
	--frameList contain all windows of the desktop.
	--framePropsList properties of each window.
	
	local frameList, framePropsList = {}, {};
	function self:_GetFrame(name) return frameList[name]; end
	function self:_GetFrameList() return frameList; end
	function self:_GetFrameProps(name) return framePropsList[name]; end
	function self:_GetFramePropsList() return framePropsList; end
	
	----------------------------------------------
	local lockstate = true;
	function self:_IsLocked() return lockstate; end
	----------------------------------------------
	
	local function LockDesktop()
		RDXDK:Debug(6, "LockDesktop");
		for name, frame in pairs(frameList) do
			frame:Lock();
		end
		local tooltipmouse, anchorx, anchory = RDXDK.GetLockGameTooltip();
		local froot = framePropsList["root"];
		froot.tooltipmouse = tooltipmouse;
		froot.anchorx = anchorx;
		froot.anchory = anchory;
		lockstate = true;
	end
	
	local function UnlockDesktop()
		RDXDK:Debug(6, "UnlockDesktop");
		for name, frame in pairs(frameList) do
			frame:Unlock(framePropsList[name]);
		end
		RDXDK.SetUnlockGameTooltip();
		lockstate = nil;
	end
	
	local function UpdateViewport(viewport, left, top, right, bottom)
		RDXDK:Debug(6, "UpdateViewport");
		if viewport then
			WorldFrame:ClearAllPoints();
			WorldFrame:SetPoint("TOPLEFT", left, 0 - top);
			WorldFrame:SetPoint("BOTTOMRIGHT", 0 - right, bottom);
		else
			WorldFrame:SetAllPoints(RDXParent);
		end
		local froot = framePropsList["root"];
		froot.viewport = viewport;
		froot.offsetleft = left;
		froot.offsettop = top;
		froot.offsetright = right;
		froot.offsetbottom = bottom;
	end
	
	-- call by desktop_basic
	-- call by update
	local function UpdateGameTooltip(tooltipmouse, anchorx, anchory)
		RDXDK.SetGameTooltipLocation(tooltipmouse, anchorx, anchory);
	end
	
	DesktopEvents:Bind("DESKTOP_LOCK", nil, LockDesktop, "desktop");
	DesktopEvents:Bind("DESKTOP_UNLOCK", nil, UnlockDesktop, "desktop");
	DesktopEvents:Bind("DESKTOP_VIEWPORT", nil, UpdateViewport, "desktop");
	DesktopEvents:Bind("DESKTOP_GAMETOOLTIP", nil, UpdateGameTooltip, "desktop");
	
	local function LayoutFrame(name, noanim)
		local frame, frameprops = frameList[name], framePropsList[name];
		RDXDK:Debug(9, " -- LayoutFrame(".. name ..")");
		-- If this window doesn't need to be laid out, don't.
		if frame._dk_nolayout or frame._dk_layout then return true; end
		
		if not frame:WMGetPositionalFrame() then return nil; end
		
		-- Don't layout secure windows during ICLD
		if frame.secure and InCombatLockdown() then return true; end
		
		-- Apply scale, alpha, stratum, level
		if name ~= "root" then
			frame:SetScale(frameprops.scale);
			frame:SetAlpha(frameprops.alpha);
			if frameprops.strata == "BACKGROUND" then frameprops.strata = "LOW"; end
			frame:WMGetPositionalFrame():SetFrameStrata(frameprops.strata);
		else
			frame:WMGetPositionalFrame():SetFrameStrata("LOW");
		end
		
		-- deprecated
		--DesktopEvents:Dispatch("EMBEDDEDWINDOW_UPDATE", name, frameprops.scale, frameprops.alpha, frameprops.strata);
		
		-- Clear preexisting layout.
		frame:WMGetPositionalFrame():ClearAllPoints();
		
		-- If we're docked...
		local di = RDXDK.GetDockPoints(frameprops);
		if di and (not RDXDK.IsDGP(frameprops)) and name ~= "root" then
			-- For each neighbor...
			for localPoint, remoteInfo in pairs(di) do
				local otherframe = frameList[remoteInfo.id];
				local otherframeprops = framePropsList[remoteInfo.id];
				-- If the neighbor was successfully laid out...
				if otherframe and otherframe._dk_layout then
					--RDXDK:Debug(8, "* docking " .. frameprops.name .. ":" .. localPoint .. " to " .. otherframeprops.name .. ":" .. remoteInfo.point);
					-- Dock us!
					--frame:SetClampedToScreen(nil);
					local actualLocalPoint, dxl, dyl = frame:WMGetDockSourcePoint(localPoint);
					local actualRemotePoint, dxr, dyr = otherframe:WMGetDockTargetPoint(remoteInfo.point);
					local x, y = RDXDK.GetDockOffset(frameprops, localPoint);
					if x ~= 0 or y ~= 0 then
						frame:WMGetPositionalFrame():SetPoint(actualLocalPoint, otherframe:WMGetPositionalFrame(), actualRemotePoint, x, y);
					else
						frame:WMGetPositionalFrame():SetPoint(actualLocalPoint, otherframe:WMGetPositionalFrame(), actualRemotePoint, dxl+dxr, dyl+dyr);
					end
					RDXDK:Debug(9, "   -- LayoutFrame DOCK(" .. actualLocalPoint ..",".. otherframe._dk_name .."," .. actualRemotePoint .. ")");
					-- We're done!
					frame._dk_layout = true;
				end
			end
		else
			--frame:SetClampedToScreen(frameprops.cts);
			frame:WMGetPositionalFrame():SetClampedToScreen(true); --frameprops.cts);
			local ap, l = frameprops.ap, frameprops.l;
			if name == "root" then
				frame:WMGetPositionalFrame():SetAllPoints(RDXParent);
				RDXDK:Debug(9, "   -- LayoutFrame AllPoints(RDXParent)");
			elseif l then
				--if not ap then ap = VFLUI.GetBoxQuadrantbyPosition(frameprops.l, frameprops.t, frameprops.r, frameprops.b); end
				if not ap or ap == "Auto" then ap = "TOPLEFT"; end
				VFLUI.SetAnchorFramebyPosition(frame:WMGetPositionalFrame(), ap, frameprops.l, frameprops.t, frameprops.r, frameprops.b);
				RDXDK:Debug(9, "   -- LayoutFrame Position(".. ap ..",".. frameprops.l ..")");
			else
				frame:WMGetPositionalFrame():SetPoint("CENTER", RDXParent, "CENTER");
				RDXDK:Debug(9, "   -- LayoutFrame CENTER(RDXParent)");
			end
			frame._dk_layout = true; 
		end
		
		-- Now show the window !!!
		if noanim and not frame:IsShown() then
			frame:Show();
		elseif not frame:IsShown() then
			frame:Show(RDX.smooth);
		end
		--RDX:Debug(5, "Show WindowObject<", frame._dk_name, ">");
		frame:UpdateUnlockOverlay(frameprops);
		
		return true;
	end
	
	local function LayoutDockGroup(name, noanim)
		RDXDK:Debug(8, "LayoutDockGroup(".. name ..")");
		local frame, frameprops = frameList[name], framePropsList[name];
		if RDXDK.IsDocked(frameprops) then
			RDXDK:Debug(8, " -- LayoutDockGroup DOCK");
			-- Find the dock group's parent; start there.
			local dgpframeprops = RDXDK.FindDockGroupParent(frameprops);
			if not dgpframeprops then
				--RDXDK:Debug(8, " -- LayoutDockGroup doesn't have a DGP");
				dgpframeprops = frameprops;
				RDXDK.MakeDockGroupParent(dgpframeprops); 
			end
			local fplist, fplistmissed = RDXDK.GetlistDockGroup(dgpframeprops);
			for _,fp in pairs(fplist) do
				RDXDK:Debug(8, " -- LayoutDockGroup DOCK FRAME(".. fp.name ..")");
				if frameList[fp.name] then 
					LayoutFrame(fp.name, noanim);
				end
			end
			for name,_ in pairs(fplistmissed) do
				RDXDK:Debug(8, " -- LayoutDockGroup DOCK FRAME Missed(".. name ..")");
				RDXDK.ClearDockPointByName(dgpframeprops, name);
			end
			if #fplist == 1 then RDXDK.SetDGP(dgpframeprops, nil); dgpframeprops.dock = nil; end
		else
			RDXDK:Debug(8, " -- LayoutDockGroup SINGLE");
			LayoutFrame(name, noanim);
		end
	end
	
	local function LayoutAll()
		for name,frame in pairs(frameList) do
			if (not frame._dk_nolayout) and (not frame._dk_layout) then
				LayoutDockGroup(name);
			end
		end
	end
	
	
	function self:LayoutDesktop()
		RDXDK:Debug(7, "LayoutDesktop");
		LayoutAll();
	end
	
	local function UnlayoutFrame(name, noanim)
		RDXDK:Debug(9, "UnlayoutFrame(".. name ..")");
		local frame, frameprops = frameList[name], framePropsList[name];
		if frame then
			if frame._dk_drag then frame:WMStopDrag(true); end
			--if noanim then
			--	frame:Hide();
			--else
			--	frame:Hide(RDX.smooth);
			--end
			--if name ~= "root" and frame:WMGetPositionalFrame() then frame:WMGetPositionalFrame():ClearAllPoints(); end
			local posFrame = frame:WMGetPositionalFrame();
			if posFrame then
				posFrame:ClearAllPoints();
			end
			frame._dk_layout = nil;
			return true;
		end
	end
	
	local function UnlayoutDockGroup(name)
		RDXDK:Debug(8, "UnlayoutDockGroup(".. name ..")");
		local frame, frameprops = frameList[name], framePropsList[name];
		local fplist = RDXDK.GetlistDockGroup(frameprops);
		for _,fp in pairs(fplist) do
			if frameList[fp.name] then
				RDXDK:Debug(8, " -- UnlayoutDockGroup(".. fp.name ..")");
				UnlayoutFrame(fp.name);
			end
		end
		return true;
	end
	
	local function UnlayoutAll()
		for name,frame in pairs(frameList) do
			if (not frame._dk_nolayout) and (not frame._dk_layout) then
				UnlayoutDockGroup(name);
			end
		end
	end
	
	function self:UnlayoutDesktop()
		RDXDK:Debug(7, "UnlayoutDesktop");
		UnlayoutAll();
		for name,frame in pairs(frameList) do
			RDXDK.RemoveUnlockOverlay(frame);
			RDXDK.UnimbueManagedFrame(frame);
			if name == "root" then
				frame:Destroy(); frame = nil;
			else
				local wtype = framePropsList[name].feature;
				if wtype == "desktop_window" or wtype == "desktop_statuswindow" then
					RDXDB._RemoveInstance(name);
				elseif wtype == "desktop_windowless" then 
					local wless = RDXDK.GetWindowLess(name);
					wless.Close(frame, name);
				end
			end
			framePropsList[name] = nil;
			frameList[name] = nil;
		end
	end
	
	-----------------------------------------
	-- WINDOW
	
	local function windowOpen(name, wtype)
		RDXDK:Debug(6, "windowOpen " .. name .. ":" .. wtype);
		if not frameList[name] then
			local frame;
			if wtype == "desktop_window" or wtype == "desktop_statuswindow" then
				frame = RDXDB.GetObjectInstance(name);
			elseif wtype == "desktop_windowless" then 
				local wless = RDXDK.GetWindowLess(name);
				if wless then
					frame = wless.Open(name);
				end
			elseif wtype == "Desktop main" then
				frame = VFLUI.AcquireFrame("Frame");
			end
			if frame then
				local frameprops = nil;
				if wtype == "Desktop main" then
					frameprops = RDXDB.GetFeatureData(self._path, wtype);
				else
					frameprops = RDXDB.GetFeatureData(self._path, wtype, "name", name);
				end
				local dolayout = nil;
				if not frameprops then
					frameprops = {
						feature = wtype;
						name = name;
						open = true;
						scale = 1;
						alpha = 1;
						strata = "MEDIUM";
						anchor = "TOPLEFT";
					};
					RDXDB.AddFeatureData(self._path, wtype, "name", name, frameprops);
					dolayout = true;
				end
				RDXDK.AddUnlockOverlay(frame, frameprops);
				RDXDK.ImbueManagedFrame(frame, name);
				frameList[name] = frame;
				framePropsList[name] = frameprops;
				if dolayout then LayoutFrame(name); end
				if not lockstate then frame:Unlock(frameprops); end
			end
		else
			RDX.printE("Window " .. name .. " already add");
		end
	end
	
	local function windowClose(name, wtype)
		RDXDK:Debug(6, "windowClose " .. name);
		local frame = frameList[name];
		if frame then
			if not lockstate then frame:Lock(); end
			RDXDK.CompletelyUndock(framePropsList[name]);
			RDXDK.RemoveUnlockOverlay(frame);
			UnlayoutFrame(name);
			RDXDK.UnimbueManagedFrame(frame);
			if wtype == "desktop_window" or wtype == "desktop_statuswindow" then
				RDXDB._RemoveInstance(name);
			elseif wtype == "desktop_windowless" then 
				local wless = RDXDK.GetWindowLess(name);
				wless.Close(frame, name);
			end
			framePropsList[name] = nil;
			frameList[name] = nil;
			RDXDB.DelFeatureData(self._path, wtype, "name", name);
		else
			RDX.printE("Window " .. name .. " is not in the desktop");
		end
	end
	
	local function windowRebuild(name, wtype)
		RDXDK:Debug(6, "windowRebuild " .. name);
		local frame = frameList[name];
		if frame then
			local md = RDXDB.GetObjectData(name);
			if md and md.data then
				if not lockstate then frame:Lock(); end
				UnlayoutDockGroup(name);
				if wtype == "desktop_window" then
					if RDX.SetupWindow(name, frame, md.data) then
						LayoutDockGroup(name);
						if not lockstate then frame:Unlock(framePropsList[name]); end
					end
				elseif wtype == "desktop_statuswindow" then
					if RDX.SetupStatusWindow(name, frame, md.data) then
						LayoutDockGroup(name);
						if not lockstate then frame:Unlock(framePropsList[name]); end
					end
				end
			end
		--else
			--windowOpen(name, wtype);
			--RDX.printE("Window " .. name .. " is not in the desktop");
		end
	end
	
	local function windowRebuildAll()
		RDXDK:Debug(6, "windowRebuildAll");
		for name, frameProps in pairs(framePropsList) do
			local frame = frameList[name];
			if frame then
				local md, _, _, ty = RDXDB.GetObjectData(name);
				if md and md.data then
					if not lockstate then frame:Lock(); end
					UnlayoutDockGroup(name);
					if ty == "Window" then
						if RDX.SetupWindow(name, frame, md.data) then
							LayoutDockGroup(name);
							if not lockstate then frame:Unlock(framePropsList[name]); end
						end
					elseif ty == "StatusWindow" then
						if RDX.SetupStatusWindow(name, frame, md.data) then
							LayoutDockGroup(name);
							if not lockstate then frame:Unlock(framePropsList[name]); end
						end
					end
				end
			else
				RDX.printE("Window " .. name .. " is not in the desktop");
			end
		end
	end
	
	local function windowUpdate(name, key, value, value2)
		RDXDK:Debug(6, "windowUpdate " .. name);
		local frame = frameList[name];
		local frameProps = framePropsList[name];
		if frame then
			if key == "STRATA" then
				frame:WMGetPositionalFrame():SetFrameStrata(value);
				frameProps["strata"] = value;
				frame:UpdateUnlockOverlay(frameProps);
			elseif key == "SCALE" then
				frame:SetScale(value);
				frameProps["scale"] = value;
			elseif key == "ALPHA" then
				frame:SetAlpha(value);
				frameProps["alpha"] = value;
			elseif key == "CTS" then
				--frame:SetAlpha(value);
				frameProps["cts"] = value;
			elseif key == "POSITION" then
				local rgn = frame:WMGetPositionalFrame();
				local l,t,r,b = VFLUI.GetUniversalBoundary(rgn);
				frameProps["l"] = l; frameProps["t"] = t; frameProps["r"] = r; frameProps["b"] = b;
			elseif key == "OVERLAY" then
				if value == "LEFT" then
					frame.tfl:SetBackdrop(value2);
				elseif value == "TOPLEFT" then
					frame.tftl:SetBackdrop(value2);
				elseif value == "TOP" then
					frame.tft:SetBackdrop(value2);
				elseif value == "TOPRIGHT" then
					frame.tftr:SetBackdrop(value2);
				elseif value == "RIGHT" then
					frame.tfr:SetBackdrop(value2);
				elseif value == "BOTTOMRIGHT" then
					frame.tfbr:SetBackdrop(value2);
				elseif value == "BOTTOM" then
					frame.tfb:SetBackdrop(value2);
				elseif value == "BOTTOMLEFT" then
					frame.tfbl:SetBackdrop(value2);
				elseif value == "CENTER" then
					frame.tfc:SetBackdrop(value2);
				end
			end
		else
			RDX.printE("Window " .. name .. " is not in the desktop");
		end
	end
	
	local function windowUpdateAll(key, value)
		RDXDK:Debug(6, "windowUpdateAll " .. key);
		for name, frameProps in pairs(framePropsList) do
			local frame = frameList[name];
			if frame then
				if key == "STRATA" then
					frame:WMGetPositionalFrame():SetFrameStrata(value);
					frameProps["strata"] = value;
					frame:UpdateUnlockOverlay(frameProps);
				elseif key == "SCALE" then
					frame:SetScale(value);
					frameProps["scale"] = value;
				elseif key == "ALPHA" then
					frame:SetAlpha(value);
					frameProps["alpha"] = value;
				elseif key == "POSITION" then
					local rgn = frame:WMGetPositionalFrame();
					if rgn then
						local l,t,r,b = VFLUI.GetUniversalBoundary(rgn);
						frameProps["l"] = l; frameProps["t"] = t; frameProps["r"] = r; frameProps["b"] = b;
					end
				elseif key == "OVERLAY" then
					frame:UpdateUnlockOverlay(frameProps);
				end
			else
				RDX.printE("Window " .. name .. " is not in the desktop");
			end
		end
	end
	
	local function windowResetPosition()
		RDXDK:Debug(6, "windowResetPosition");
		for name, frameProps in pairs(framePropsList) do
			frameProps.dock = nil;
			frameProps.dgp = nil;
			frameProps["l"] = nil; frameProps["t"] = nil; frameProps["r"] = nil; frameProps["b"] = nil;
		end
		--UnlayoutAll();
		--LayoutAll();
	end
	
	DesktopEvents:Bind("WINDOW_OPEN", nil, windowOpen, "desktop");
	DesktopEvents:Bind("WINDOW_CLOSE", nil, function(name, wtype) windowClose(name, wtype); windowUpdateAll("OVERLAY"); end, "desktop");
	DesktopEvents:Bind("WINDOW_REBUILD", nil, windowRebuild, "desktop");
	DesktopEvents:Bind("WINDOW_REBUILD_ALL", nil, windowRebuildAll, "desktop");
	DesktopEvents:Bind("WINDOW_UPDATE", nil, windowUpdate, "desktop");
	DesktopEvents:Bind("WINDOW_UPDATE_ALL", nil, windowUpdateAll, "desktop");
	DesktopEvents:Bind("WINDOW_ResetPosition", nil, windowUpdateAll, "desktop");
	
	local function windowdock(src, srcpt, tgt, tgtpt, offset)
		if RDXDK.Check2Dock(src, srcpt, tgt, tgtpt) then
			if offset then
				local srcframe = frameList[src.name];
				local tgtframe = frameList[tgt.name];
				if srcframe and tgtframe then
					local srcx, srcy = VFLUI.GetPoint(srcframe, srcpt);
					local tgtx, tgty = VFLUI.GetPoint(tgtframe, tgtpt);
					x = srcx - tgtx ;
					y = srcy - tgty;
					RDXDK.DoOffset(src, srcpt, tgt, tgtpt, x, y);
				end
			end
			UnlayoutDockGroup(src.name);
			LayoutDockGroup(src.name, true);
			windowUpdateAll("POSITION");
			windowUpdateAll("OVERLAY");
		end
	end
	
	local function windowundock(src, srcpt)
		if RDXDK.IsDockedPoint(src, srcpt) then
			UnlayoutDockGroup(src.name);
			RDXDK.UndockPoint(src, srcpt);
			LayoutAll();
			windowUpdateAll("POSITION");
			windowUpdateAll("OVERLAY");
		end
	end
	
	local function windowparentdock(src)
		RDXDK.MakeDockGroupParent(src);
		UnlayoutDockGroup(src.name);
		LayoutDockGroup(src.name, true);
	end
	
	local function windowdockoffset(src, srcpt, x, y)
		local di = RDXDK.GetDockPoints(src);
		local ri = di[srcpt];
		local tgt, tgtpt = framePropsList[ri.id], ri.point;
		if RDXDK.DoOffset(src, srcpt, tgt, tgtpt, x, y) then
			UnlayoutDockGroup(src.name);
			LayoutDockGroup(src.name, true);
			windowUpdateAll("POSITION");
			windowUpdateAll("OVERLAY");
		end
	end
	
	DesktopEvents:Bind("WINDOW_DOCK", nil, windowdock, "desktop");
	DesktopEvents:Bind("WINDOW_UNDOCK", nil, windowundock, "desktop");
	DesktopEvents:Bind("WINDOW_PARENTDOCK", nil, windowparentdock, "desktop");
	DesktopEvents:Bind("WINDOW_DOCKOFFSET", nil, windowdockoffset, "desktop");
	
	-- BETA nameplate
	--local nstate = RDX.GenericWindowState:new();
	--local dstate = RDX.DesignState:new();
	--dstate:SetContainingWindowState(nstate);
	
	local function nameplate(path)
		if path == nil then
			self.nameplate = nil;
		else
			self.nameplate = RDX.DesignGeneratingFunctor(dstate, path);	
		end
	end
	
	--DesktopEvents:Bind("NAMEPLATE", nil, nameplate, "desktop");
	
	self.Destroy = VFL.hook(function(s)
		DesktopEvents:Unbind("desktop");
		s.nameplate = nil;
		VFL.empty(frameList); framelist = nil;
		VFL.empty(framePropsList); framePropsList = nil;
		s.LayoutDesktop = nil; s.UnlayoutDesktop = nil;
		s._IsLocked = nil;
		s._GetFrame = nil; s._GetFrameList = nil; 
		s._GetFrameProps = nil; s._GetFramePropsList = nil;
	end, self.Destroy);
	
	return self;
end

-----------------------------------
-- The desktop state
-----------------------------------
RDXDK.DesktopState = {};
function RDXDK.DesktopState:new()
	local st = RDXDB.ObjectState:new();
	
	st.OnResetSlots = function(state)
		state:AddSlot("Desktop", nil);
	end;
	
	st.Code = VFL.Snippet:new();
	
	st:Clear();
	return st;
end

-- A general state object to be reused by this engine
local dkState = RDXDK.DesktopState:new();
RDXDK._GetdkState = function() return dkState; end;

----------------------------------------------------------------------
-- Desktop meta-control 
----------------------------------------------------------------------
local function SetupDesktop(path, dk, desc)
	if (not path) or (not dk) or (not desc) then return nil; end
	
	-- init
	dkState:Clear();
	dkState:ResetSlots();
	
	-- Load the features
	dkState:LoadDescriptor(desc, path);
	local _errs = VFL.Error:new();
	if not dkState:ApplyAll(_errs) then
		_errs:ToErrorHandler("RDX", VFLI.i18n("Could not build desktop at <") .. tostring(path) .. ">");
		return nil;
	end
	_errs = nil;
	
	local code = dkState.Code:GetCode();
	
	if RDXG.cdebug and RDXM_Debug.StoreCompiledObject then
		RDXM_Debug.StoreCompiledObject(path, code);
	end

	local f,err = loadstring(code);
	if not f then
		VFL.TripError("RDX", VFLI.i18n("Could not compile desktop at <") .. tostring(path) .. ">", VFLI.i18n("Error: ") .. err);
		return nil;
	else
		f();
		dk._f = f;
	end
	return true;
end

-------------------------------------------
-- DESKTOP EDITOR
-- just a modified feature editor for unitframe
-------------------------------------------
RDX.IsDesktopEditorOpen = RDXIE.IsFeatureEditorOpen;

function RDX.DesktopEditor(state, callback, augText, parent)
	local dlg = RDXIE.FeatureEditor(state, callback, augText, parent);
	if not dlg then return nil; end
	

	------ Close procedure
	dlg.Destroy = VFL.hook(function(s)
		--RDXDB.ClosePreviewWindow();
	end, dlg.Destroy);
end

local function EditDesktop(parent, path, md)
	if RDX.IsDesktopEditorOpen() then return; end
	dkState:LoadDescriptor(md.data, path);
	RDX.DesktopEditor(dkState, function(x) 
		md.data = x:GetDescriptor();
		RDXDB.NotifyUpdate(path);
	end, path, parent);
end
RDXDK.EditDesktop = EditDesktop;

function RDXDK.ToggleDesktopEditor(parent, path, md)
	if RDX.IsDesktopEditorOpen() then
		RDXIE.CloseFeatureEditor();
	else
		EditDesktop(parent, path, md);
	end
end

-- The Desktop object type.
RDXDB.RegisterObjectType({
	name = "Desktop";
	version = 2;
	isFeatureDriven = true;
	VersionMismatch = function(md)
		-- code update version 1 to version 2;
		md.version = 2;
		-- save md.data
		local tmpdata = nil;
		if md.data then
			tmpdata = VFL.copy(md.data);
			-- empty md.data
			VFL.empty(md.data);
		else
			md.data = {};
		end
		-- Add the first feature
		table.insert(md.data, { feature = "Desktop main"; title = "updated"; resolution = VFLUI.GetCurrentResolution(); uiscale = VFLUI.GetCurrentEffectiveScale();});
		-- convert all old data to features.
		for k,v in pairs(tmpdata) do
			-- remove dock (bugs from old desktop object)
			v.dgp = nil;
			if v.dock then VFL.empty(v.dock); v.dock = nil; end
			if k == "_root" then
				v.feature = "desktop_windowless";
				v.name = "desktop_bossmod";
				table.insert(md.data, v);
			elseif k == "_multi_track_window" then
				v.feature = "desktop_windowless";
				v.name = "desktop_multi_track";
				table.insert(md.data, v);
			elseif k == "_omni_live" then
				v.feature = "desktop_windowless";
				v.name = "desktop_omnilive";
				table.insert(md.data, v);
			elseif k == "_thw" then
				v.feature = "desktop_windowless";
				v.name = "desktop_healtarget";
				table.insert(md.data, v);
			elseif k == "_streams" then
				-- do nothing
				-- the RPC window is now manage by RDXPM
			elseif v.class == "gwin" then
				v.feature = "desktop_window";
				v.name = k;
				table.insert(md.data, v);
			elseif v.class == "statwin" then
				v.feature = "desktop_statuswindow";
				v.name = k;
				table.insert(md.data, v);
			else
				if k then RDX.printE("Error Unknown window " .. k .. " Send this message to OpenRDX Team"); end
			end
		end
		-- clear
		VFL.empty(tmpdata);
		tmpdata = nil;
		return true;
	end,
	New = function(path, md)
		md.version = 2;
		md.ty = "Desktop";
		table.insert(md.data, { feature = "Desktop main"; title = path; resolution = VFLUI.GetCurrentResolution(); uiscale = VFLUI.GetCurrentEffectiveScale();});
	end,
	Edit = function(path, md, parent)
		EditDesktop(parent, path, md);
	end;
	Instantiate = function(path, obj)
		RDXDK:Debug(5, "instantiate(".. path ..")");
		if currentDesktop then RDX.printE("Instantiate Desktop: already instantiated"); return nil; end
		if not obj then RDX.printE("Instantiate Desktop: desktop exist ? " .. path); return nil; end
		local dk = RDXDK.Desktop:new();
		-- Set the path
		dk._path = path;
		currentDesktop = dk;
		-- Attempt to setup the desktop; if it fails, just bail out.
		if not SetupDesktop(path, dk, obj.data) then dk:Destroy(); return nil; end
		dk:LayoutDesktop();
		return dk;
	end,
	Deinstantiate = function(instance, path, obj, nosave)
		RDXDK:Debug(5, "deinstantiate(".. path ..")");
		instance:UnlayoutDesktop();
		instance:Destroy();
		instance._path = nil; -- Remove the path previously stored
		instance._f = nil; -- Remove the function
		currentDesktop = nil;
	end,
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = VFLI.i18n("Edit..."),
			OnClick = function()
				VFL.poptree:Release();
				RDXDB.OpenObject(path, "Edit", dlg);
			end
		});
		if RDXDK.GetCurrentDesktopPath() ~= path then 
			table.insert(mnu, {
				text = VFLI.i18n("Open"),
				OnClick = function()
					VFL.poptree:Release();
					RDXDK.SecuredChangeDesktop(path);
				end
			});
		--else
		--	table.insert(mnu, {
		--		text = VFLI.i18n("Rebuild Desktop"),
		--		OnClick = function()
		--			VFL.poptree:Release();
		--			RDXDK.SecuredChangeDesktop(path);
		--		end
		--	});
		end
	end,
});

---------------------------
-- 
---------------------------

function RDXDK.GetCurrentDesktop()
	return currentDesktop;
end

function RDXDK.GetCurrentDesktopPath()
	if currentDesktop and currentDesktop._path then
		return currentDesktop._path;
	else
		return currentpath;
	end
end

function RDXDK._IsWindowOpen(path)
	if not currentDesktop then return nil; end
	return currentDesktop:_GetFrame(path);
end

function RDXDK._OpenWindowRDX(path, windowsbar)
	local _, _, _, ty = RDXDB.GetObjectData(path);
	-- add a new feature window to this desktop
	if ty == "Window" then
		RDXDK._AddWindowRDX(path);
	elseif ty == "StatusWindow" then
		RDXDK._AddStatusWindowRDX(path)
	else
		RDXDK._AddRegisteredWindowRDX(path);
	end
end

function RDXDK._CloseWindowRDX(path, windowsbar)
	local _, _, _, ty = RDXDB.GetObjectData(path);
	-- add a new feature window to this desktop
	if ty == "Window" then
		RDXDK._DelWindow(path)
	elseif ty == "StatusWindow" then
		RDXDK._DelStatusWindowRDX(path);
	else
		RDXDK._DelRegisteredWindowRDX(path);
	end
end

function RDXDK._AsyncRebuildWindowRDX(path)
	local _, _, _, ty = RDXDB.GetObjectData(path);
	local a = "";
	if ty == "Window" then
		a = "desktop_window";
	elseif ty == "StatusWindow" then
		a = "desktop_statuswindow";
	else
		a = "desktop_windowless";
	end
	
	VFLT.ZMSchedule(0.01, function()
		DesktopEvents:Dispatch("WINDOW_REBUILD", path, a);
	end);
end


-----------------------------------------------------------------
-- Update hooks - make sure when a desktop changes we reload it.
-----------------------------------------------------------------

--RDXDBEvents:Bind("OBJECT_DELETED", nil, function(pkg, file, md)
--	local path = RDXDB.MakePath(pkg,file);
--	if md and md.ty == "Desktop" and path == RDXDK.GetCurrentDesktopPath() then
--		RDXDK.SecuredChangeDesktop("desktops:default");
--	end
--end);

--RDXDBEvents:Bind("OBJECT_UPDATED", nil, function(pkg, file) 
--	local path = RDXDB.MakePath(pkg,file);
--	local _,_,_,ty = RDXDB.GetObjectData(path)
--	if ty == "Desktop" and path == RDXDK.GetCurrentDesktopPath() then RDXDK.SecuredChangeDesktop(path); end
--end);


-----------------------------------------------------------------
-- LOCKDOWN ACTION QUEUE
-- Execute a series of actions after combat lockdown ends.
-----------------------------------------------------------------

local caq = {};
function RDXDK.QueueLockdownAction(method, a1, a2, a3, a4)
	if not InCombatLockdown() then 
		method(a1, a2, a3, a4);
	else
		--if not caq[object] then caq[object] = method; end
		table.insert(caq, {method, a1, a2, a3, a4});
	end
end

VFLEvents:Bind("PLAYER_COMBAT", nil, function(flag)
	if not flag then
		local f = nil;
		for k,v in pairs(caq) do
			f = v[1];
			f(v[2], v[3], v[4], v[5]);
			caq[k] = nil;
		end
	end
end);

-----------------------------------------------------
-- functions
-----------------------------------------------------

local function ChangeDesktop(path, nosave)
	if RDX.IsDesktopEditorOpen() then RDXIE.CloseFeatureEditor(); end
	RDXDK:Debug(4, "ChangeDesktop(".. path ..")");
	RDX.printI("Change desktop " .. path);
	-- close
	if currentDesktop then
		if RDXDK.IsDesktopToolsOpen() then RDXDK.ToggleDesktopTools(); end
		RDXDB._RemoveInstance(currentDesktop._path, nosave);
	end
	
	--RDXPM.RemoveAllButtonsWB();
	
	if RDX.smooth then
		VFLT.schedule(RDX.smooth + 0.2, function() 
			--RDXPM.GetMainPane():SetDesktopName("|cFFFF0000" .. path .. "|r", path);
			currentpath = path;
			-- open
			currentDesktop = RDXDB.GetObjectInstance(path);
			
			--if currentDesktop then 
			--	if not RDXDK.IsDesktopLocked() then RDXDK.LockDesktop(); RDXDK.CloseMiniWindowList(); end
			--else
			--	RDXPM.SetStatusText("|cFFFF0000ERROR|r");
			--end
		end);
	else
		currentpath = path;
		-- open
		currentDesktop = RDXDB.GetObjectInstance(path);
		
		--if currentDesktop then 
		--	if not RDXDK.IsDesktopLocked() then RDXDK.LockDesktop(); RDXDK.CloseMiniWindowList(); end
		--else
		--	RDXPM.SetStatusText("|cFFFF0000ERROR|r");
		--end
	end
end
RDXDK._ChangeDesktop = ChangeDesktop;

-----------------------------------------
-- desktop change are lock under combat
-- change after combat
-----------------------------------------

local newpath;
function RDXDK.SecuredChangeDesktop(path, nosave)
	RDXDK:Debug(4, "RDXDK.SecuredChangeDesktop(".. path ..")");
	
	if not path or path == "" then RDX.printE("No desktop Open AUI Manager"); return; end
	--VFL.print(path);
	if not InCombatLockdown() then 
		ChangeDesktop(path, nosave); 
	else
		newpath = path;
	end
end

VFLEvents:Bind("PLAYER_COMBAT", nil, function(flag)
	if not flag and newpath then
		ChangeDesktop(newpath);
		newpath = nil;
	end
end);

----------------------------------------
-- command
----------------------------------------
RDXPM.RegisterSlashCommand("desktop", function(rest)
	local path = VFL.word(rest);
	if path then
		RDXDK.SecuredChangeDesktop(path);
	end
end);
