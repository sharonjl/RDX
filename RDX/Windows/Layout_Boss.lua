-- Layout_Boss.lua
-- OpenRDX
-- Daniel LY
--
-- The specific boss layout

local bor, band = bit.bor, bit.band;

-------------------------------------------------------
-- Grid layout engine. Uses a VFLUI.Grid control to drive on-screen content rendering.
-------------------------------------------------------
RDX.RegisterFeature({
	name = "Boss Layout";
	category = VFLI.i18n("Layout");
	IsPossible = function(state)
		if not state:Slot("Frame") then return nil; end
		if not state:Slot("SetupSubFrame") then return nil; end
		if not state:Slot("SubFrameDimensions") then return nil; end
		--if not state:Slot("DataSource") then return nil; end
		if not state:Slot("SecureDataSource") then return nil; end
		if state:Slot("RAID") or state:Slot("RAIDPET") or state:Slot("ARENA") or state:Slot("ARENAPET") then return nil; end
		if state:Slot("Layout") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then return nil; end
		state:AddSlot("Layout");
		state:AddSlot("RepaintAll"); state:AddSlot("RepaintSort"); state:AddSlot("RepaintData");
		state:AddSlot("CellPrePaintAdvice", true);
		state:AddSlot("CellPostPaintAdvice", true);
		state:AddSlot("TotalPrePaintAdvice", true);
		state:AddSlot("TotalPostPaintAdvice", true);
		state:AddSlot("AcclimatizeAdvice", true);
		state:AddSlot("DeacclimatizeAdvice", true);
		return true;
	end;
	ApplyFeature = function(desc, state)
		---------------- Parameters
		local cols, axis, limit, dxn = desc.cols or 1, desc.axis or 1, desc.limit or 1000, 1;
		local autoShowHide = desc.autoShowHide;
		if desc.dxn == 1 then dxn = 5; end
		local defaultPaintMask = 0;

		---------------- Metafunctions
		local iFunc = state:GetSlotFunction("DataSourceIterator");
		local sizeFunc = state:GetSlotFunction("DataSourceSize");
		local tprepa, prePaintAdvice, postPaintAdvice, tpostpa = VFL.Noop, VFL.Noop, VFL.Noop, VFL.Noop;
		local acca, deacca = VFL.Noop, VFL.Noop;
		local setTitle = VFL.Noop;

		-- Attempt to acquire pre-build functions.
		-- BUGFIX: Defer this until the last possible instant in case the Frame feature is below us.
		state:_Attach("Assemble", true, function(state, win)
			setTitle = state:GetSlotFunction("SetTitleText");
			tprepa = state:GetSlotFunction("TotalPrePaintAdvice");
			prePaintAdvice = state:GetSlotFunction("CellPrePaintAdvice");
			postPaintAdvice = state:GetSlotFunction("CellPostPaintAdvice");
			tpostpa = state:GetSlotFunction("TotalPostPaintAdvice");
			acca = state:GetSlotFunction("AcclimatizeAdvice");
			deacca = state:GetSlotFunction("DeacclimatizeAdvice");
		end);

		---------------- The unit framepool
		local uf = state:GetSlotFunction("SetupSubFrame");
		local dx, dy = (state:GetSlotFunction("SubFrameDimensions"))();
		dx = dx or 50; dy = dy or 12; -- BUGFIX: incase something goes wrong, don't crash/do unreasonable things

		local fp = VFL.Pool:new();
		fp.OnRelease = function(_,frame)
			frame._paintmask = defaultPaintMask;
			frame:Hide(); 
		end
		fp.OnFallback = function(pool, grid)
			-- Create the unit frame
			local frame = VFLUI.AcquireFrame("Frame");
			frame:SetParent(grid); frame:SetFrameLevel(grid:GetFrameLevel() + 1);
			-- Imbue it with unit-frame-hood.
			uf(frame); 
			if not frame.Cleanup then
				frame.Cleanup = VFL.Noop;
				frame.SetData = VFL.Noop;
				frame.GetHotspot = VFL.Noop;
				frame.SetHotspot = VFL.Noop;
				frame.Destroy = VFL.hook(function(frame)
					frame.Cleanup = nil; frame.SetData = nil; 
					frame.GetHotspot = nil; frame.SetHotspot = nil;
					frame._paintmask = nil;
				end, frame.Destroy);
			end
			frame:Cleanup(); 
			acca(nil, nil, frame);
			-- Apply default paintmask
			frame._paintmask = defaultPaintMask;
			return frame;
		end
		fp.OnAcquire = function(pool, frame) frame.OnDeparent = pool.Releaser; end
		local acq = fp.Acquirer;

		------------ In-window unit lookup
		local umap = {};
		local function lookupUnit(rdxu,_,nid)
			if rdxu then
				return umap[rdxu.nid];
			elseif nid then
				return umap[nid];
			end
		end

		------------ UI locals and metadata
		local faux, grid, win, succ, err = nil, nil, nil, nil, nil;

		--------------- Painting ops
		local function update(maskmod)
			if (not win) or (not grid) or (not win:IsShown()) then return; end
			maskmod = maskmod or 0;
			tprepa(win); -- Invoke pre paint advice

			local grid_i_func, grid_i_state, grid_i_ctl = grid:StatelessIterator(dxn);
			local index, cell = 0, nil;
			-- Iterate over the datasource
			for ctl,uid,rdxUnit,a1,a2,a3,a4,a5,a6,a7 in iFunc() do
				index = index + 1;
				-- Iterate to the next cell in the grid
				grid_i_ctl, cell = grid_i_func(grid_i_state, grid_i_ctl);
				if not cell then break; end
				-- test existence of the boss, paint or cleanup
				if rdxUnit and rdxUnit:IsValid() then
					cell._paintmask = bor(cell._paintmask or 0, maskmod);
					prePaintAdvice(win, cell, index, ctl, uid, rdxUnit, a1, a2, a3, a4, a5, a6, a7);
					succ,err = pcall(cell.SetData, cell, ctl, uid, rdxUnit, a1, a2, a3, a4, a5, a6, a7);
					if not succ then RDXDK.PrintError(win, "SetData", err); end
					postPaintAdvice(win, cell, index, ctl, uid, rdxUnit, a1, a2, a3, a4, a5, a6, a7);
				else
					cell:Cleanup();
				end
				-- Reset the paintmask
				cell._paintmask = defaultPaintMask;
			end
			tpostpa(win); -- Invoke post paint advice
		end

		local function relayout()
			if (not win) or (not grid) then return; end
			local n = sizeFunc(); if not n then return; end
			if n > 4 then n = 4; end -- in case of
			
			if not win.secure or (win.secure and not InCombatLockdown()) then
				local height = math.ceil(n/cols);
				local eff_cols = math.max(math.min(cols, n), 1);
				-- Resize the grid element
				if axis == 2 then
					grid:Size(height, eff_cols, acq);
				else
					grid:Size(eff_cols, height, acq);
				end
				-- Resize the container
				if(n == 0) then
					faux:SetWidth(dx); faux:SetHeight(.1);
				else
					faux:SetWidth(grid:GetWidth());  faux:SetHeight(grid:GetHeight());
				end
				
				-- stuff
				local grid_i_func, grid_i_state, grid_i_ctl = grid:StatelessIterator(dxn);
				local index, cell = 0, nil;
				-- reset
				for k in pairs(umap) do umap[k] = nil; end
				
				for ctl,uid,rdxUnit,a1,a2,a3,a4,a5,a6,a7 in iFunc() do
					index = index + 1;
					-- Iterate to the next cell in the grid
					grid_i_ctl, cell = grid_i_func(grid_i_state, grid_i_ctl);
					if not cell then break; end
					--cell._paintmask = bor(cell._paintmask or 0, maskmod);
					cell:Show();
					-- Associate the unit with this cell.
					if rdxUnit then
						cell:SetAttribute("unit", uid);	umap[rdxUnit.nid] = cell;
					end
					-- Reset the paintmask
					cell._paintmask = defaultPaintMask;
				end
			end

			-- Also trip a downstream full update
			update(1);
		end

		local function create(w)
			win = w;
			-- "Faux frame" that will stand in as a client in the inverted control window.
			faux = VFLUI.AcquireFrame("Frame");
			faux:SetScale(1); faux:SetMovable(true); faux:Show();
			w:SetClient(faux);
			-- The grid is in turn anchored to the faux frame.
			grid = VFLUI.Grid:new(w);
			grid.OnOrient = VFL.Noop;
			grid:SetPoint("TOPLEFT", faux, "TOPLEFT"); grid:Show();
			-- Profiling hooks
			if w._path then
				VFLP.RegisterCategory("Win: " .. w._path);
				VFLP.RegisterFunc("Win: " .. w._path, "RepaintLayout", relayout, true);
				VFLP.RegisterFunc("Win: " .. w._path, "RepaintData", update, true);
			end
		end

		local function destroy()
			if win then
				-- Remove profiler hooks
				if win._path then VFLP.UnregisterCategory("Win: " .. win._path); end
				-- Remove API
				win.LookupUnit = nil;
				-- BUGFIX: remember to remove client refs before destroying client..
				win:SetClient(nil);
			end
			if grid then grid:Destroy(); grid = nil; end
			if faux then faux:Destroy(); faux = nil; end
			-- Quash framepool
			if umap then VFL.empty(umap); end
			if fp then fp:Shunt(function(x) 
				x:Destroy(); 
			end); end
			win = nil;
		end

		-- At assembly time, download the default paintmask from the multiplexer...
		state:Attach("Assemble", true, function(state, w)
			defaultPaintMask = tonumber(state:GetSlotValue("DefaultPaintMask")) or 0;
			w.LookupUnit = lookupUnit;
		end);

		state:Attach("Create", true, create);
		state:Attach("Destroy", true, destroy);
		state:Attach("RepaintAll", nil, function()
			local succ,err = pcall(relayout);
			if not succ then RDXDK.PrintError(win, "RepaintAll", err); end
		end);
		state:Attach("RepaintData", nil, function(z)
			local succ,err = pcall(update, z);
			if not succ then RDXDK.PrintError(win, "RepaintData", err); end
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local axis = VFLUI.RadioGroup:new(ui);
		axis:SetLayout(2,2);
		axis.buttons[1]:SetText(VFLI.i18n("Expand vertically"));
		axis.buttons[2]:SetText(VFLI.i18n("Expand horizontally"));
		if desc and desc.axis then
			axis:SetValue(desc.axis);
		else
			axis:SetValue(1);
		end
		ui:InsertFrame(axis);

		local rg_dxn = VFLUI.RadioGroup:new(ui);
		rg_dxn:SetLayout(2,2);
		rg_dxn.buttons[1]:SetText(VFLI.i18n("Fill vertically"));
		rg_dxn.buttons[2]:SetText(VFLI.i18n("Fill horizontally"));
		if desc and desc.dxn then
			rg_dxn:SetValue(desc.dxn);
		else
			rg_dxn:SetValue(1);
		end
		ui:InsertFrame(rg_dxn);

		local ed_width = VFLUI.LabeledEdit:new(ui, 50); ed_width:Show();
		ed_width:SetText(VFLI.i18n("Width along minor axis"));
		if desc and desc.cols then ed_width.editBox:SetText(desc.cols); end
		ui:InsertFrame(ed_width);

		local chk_limit = VFLUI.Checkbox:new(ui); chk_limit:Show();
		local ed_limit = VFLUI.Edit:new(chk_limit); ed_limit:Show();
		ed_limit:SetHeight(25); ed_limit:SetWidth(50); ed_limit:SetPoint("RIGHT", chk_limit, "RIGHT");
		chk_limit.Destroy = VFL.hook(function() ed_limit:Destroy(); end, chk_limit.Destroy);
		chk_limit:SetText(VFLI.i18n("Limit number of displayed frames to:"));
		if desc and desc.limit then 
			chk_limit:SetChecked(true); 
			ed_limit:SetText(desc.limit);
		else 
			chk_limit:SetChecked();
			ed_limit:SetText("1");
		end
		ui:InsertFrame(chk_limit);

		local chk_ash = VFLUI.Checkbox:new(ui); chk_ash:Show();
		chk_ash:SetText(VFLI.i18n("Auto hide/show this window when empty/nonempty"));
		if desc then chk_ash:SetChecked(desc.autoShowHide); end
		ui:InsertFrame(chk_ash);

		local chk_title = VFLUI.Checkbox:new(ui); chk_title:Show();
		chk_title:SetText(VFLI.i18n("Do not show UnitFrame count in title"));
		if desc then chk_title:SetChecked(desc.countTitle); end
		ui:InsertFrame(chk_title);

		function ui:GetDescriptor()
			local cols = VFL.clamp(ed_width.editBox:GetNumber(), 1, 10);
			local limit = nil; 
			if chk_limit:GetChecked() then
				limit = VFL.clamp(ed_limit:GetNumber(), 1, 100);
			end
			return { 
				feature = "Boss Layout"; 
				axis = axis:GetValue(); cols = cols; dxn = rg_dxn:GetValue(); limit = limit;
				autoShowHide = chk_ash:GetChecked();
				countTitle = chk_title:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function() 
		return {
			feature = "Boss Layout", axis = 1, cols = 1, dxn = 1
		}; 
	end;
});
