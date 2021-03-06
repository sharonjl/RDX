-- Set.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- A Set is a collection of units that is updated based on various Impulses
-- generated by script or the game engine itself.
--
-- Sets are either active or inactive. Inactive sets neither receive nor generate
-- events.
--
-- API FOR ALL SETS:
--
-- GetSize()
-- IsEmpty()
-- IsMember(rdxUnit)
-- Iterator()
-- OnMembersChanged(obj, callback)
-- Open()/Close()/IsOpen() - reference counting
-- 

-------- Imports
local GetUnitByNumber = RDXDAL.GetUnitByNumber;
local NumberToUID = RDXDAL.NumberToUID;
local tempty = VFL.empty;
local MAX_UNITS = RDXDAL.NUM_UNITS;

-------- Profiling
VFLP.RegisterCategory(VFLI.i18n("RDXDAL: Set API"));

-----------------------------------------------------------
-- SET DATABASE
--
-- Every set that has been touched by the engine is added into an integer-indexed
-- database. Once added, no set's index EVER changes.
-----------------------------------------------------------
-- Master set database; maps IDs to instances of Set
local setdb = {};
-- The current set number
local setdb_curid = 0;

function RDXDAL._GetSetDatabase() return setdb; end

--- Get a set by its numerical ID.
-- @param sid The ID of the set to retrieve;
-- @return An object descended from RDX:Set, if the given Set exists. NIL if not.
function RDXDAL.GetSetByID(sid) return setdb[sid]; end

--- Add a set to the set database.
-- @param set The set to register.
-- @return The SID of the registered set.
function RDXDAL.RegisterSet(set)
	if not set then return nil; end
	setdb_curid = setdb_curid + 1;
	setdb[setdb_curid] = set;
	set.sid = setdb_curid;
	return setdb_curid;
end

-----------------------------------------------------------
-- DEPENDENCY TREE
--
-- The idea behind the dependency tree is to iterate over dirty sets,
-- triggering delta updates, until the list of potentially dirty sets becomes
-- completely empty.
-----------------------------------------------------------

local set_batchmode = nil;

-- Dirty sets
local dirty_sets_1 = {};
local dirty_sets_2 = {};
local dirty_sets = dirty_sets_1;
local dirty_sets_count = 0;

-- Propagate one wave of the dependency tree.
local function DepTreePropagate()
	-- During our loop over the currently dirty sets, we'll be swapping the dirty
	-- sets arrays. This is because you can't add entries to a table that's being iterated over.
	local last_dirty_sets = dirty_sets;
	if dirty_sets == dirty_sets_1 then dirty_sets = dirty_sets_2; else dirty_sets = dirty_sets_1; end
	tempty(dirty_sets); dirty_sets_count = 0;
	-- For each set that was dirty as of the beginning of this round...
	for set,_ in pairs(last_dirty_sets) do
		-- Clean it!
		set.laundry = nil; set:_Clean();
	end
end
VFLP.RegisterFunc(VFLI.i18n("RDXDAL: Set API"), "Batch propagation", DepTreePropagate, true);

-- Propagate all deltas.
local set_recursion_limit = 5;
local function Delta()
	local i = 1;
	while ((dirty_sets_count > 0) and (i < set_recursion_limit)) do 
		DepTreePropagate();
		i=i+1;
	end
end

-----------------------------------------------------------
-- EVENT BATCHING
-----------------------------------------------------------

--- Informs the RDX data processing engine that a batch of events is about to occur.
-- Use this as a "performance hint" to allow sets to process entire batches at a time
-- before fully rebuilding themselves
function RDXDAL.BeginEventBatch()
	if not set_batchmode then
		set_batchmode = 1;
	else
		set_batchmode = set_batchmode + 1;
	end
end

--- Informs the RDX data processing engine that the stream of events caused by the
-- last call to RDXDAL.BeginEventBatch() is over. This will cause the batch to be processed
-- by the underlying sets.
function RDXDAL.EndEventBatch()
	if set_batchmode then
		if set_batchmode == 1 then
			Delta();
			set_batchmode = nil;
--			RDX:Debug(20, "*** Sets: Batch complete ***");
		else
			set_batchmode = set_batchmode - 1;
		end
	end
end

--- @return TRUE iff the RDX data processing engine is currently in batch mode.
function RDXDAL.IsBatchMode()
	return set_batchmode;
end

-----------------------------------------------------------
-- ProtoSet
--
-- A ProtoSet is the "bare minimum" necessary to achieve sethood.
-- Other types of sets can derive from ProtoSet to inherit
-- needed code.
-----------------------------------------------------------
RDXDAL.ProtoSet = {};
RDXDAL.ProtoSet.__index = RDXDAL.ProtoSet;

--- Is this set open?
function RDXDAL.ProtoSet:IsOpen()
	return (self.refcount > 0);
end

--- Get the current reference count for this set.
function RDXDAL.ProtoSet:_GetRefCount()
	return self.refcount;
end

--- Increases the reference count of this set by 1, activating it if it was not already active.
function RDXDAL.ProtoSet:Open()
	self.refcount = self.refcount + 1;
	if(self.refcount == 1) then
		RDX:Debug(6, "+ Activating set: ", self.name);
		self:_OnActivate();
	end
end

--- Decreases the reference count of this set by 1, deactivating it if the refcount reaches 0.
function RDXDAL.ProtoSet:Close()
	if(self.refcount > 0) then
		self.refcount = self.refcount - 1;
		if(self.refcount == 0) then
			RDX:Debug(6, "- Deactivating set: ", self.name);
			self:_OnDeactivate();
		end
	end
end

--- Adds this set to the "Dirty sets" list, causing it to receive an update signal on the next
-- update sweep.
function RDXDAL.ProtoSet:_AddToLaundry()
	self.laundry = true;
	dirty_sets[self] = true; dirty_sets_count = dirty_sets_count + 1;
end

function RDXDAL.ProtoSet:init()
	self.refcount = 0;
	self.name = "(anonymous)";
	self.laundry = nil;
	self._OnActivate = VFL.Noop;
	self._OnDeactivate = VFL.Noop;
end

function RDXDAL.ProtoSet:new()
	local self = {};
	setmetatable(self, RDXDAL.ProtoSet);
	self:init();
	return self;
end

-----------------------------------------------------------
-- Set
--
-- A Set is a map between a unit numerical ID and an arbitrary non-nil piece of data.
-- A unit is a "member" of the set if the data associated with that unit is not
-- false.
-----------------------------------------------------------
RDXDAL.Set = {};
-- Set inherits from ProtoSet
VFL.mixin(RDXDAL.Set, RDXDAL.ProtoSet);
RDXDAL.Set.__index = RDXDAL.Set;

--- Get the size of this set
function RDXDAL.Set:GetSetSize(rostertype)
	if not rostertype or rostertype == "ALL" then return self.size;
	elseif rostertype == "RAID" then return self.raidsize;
	elseif rostertype == "RAIDPET" then return self.raidpetsize;
	elseif rostertype == "RAID&RAIDPET" then return self.raidsize + self.raidpetsize;
	elseif rostertype == "ARENA" then return self.arenasize;
	elseif rostertype == "ARENAPET" then return self.arenapetsize;
	elseif rostertype == "ARENA&ARENAPET" then return self.arenasize + self.arenapetsize;
	elseif rostertype == "BOSS" then return self.bosssize;
	end
end

--- Determine if this set is empty.
function RDXDAL.Set:IsEmpty(rostertype)
	if not rostertype or rostertype == "ALL" then return (self.size == 0);
	elseif rostertype == "RAID" then return (self.raidsize == 0);
	elseif rostertype == "RAIDPET" then return (self.raidpetsize == 0);
	elseif rostertype == "RAID&RAIDPET" then return (self.raidsize + self.raidpetsize == 0);
	elseif rostertype == "ARENA" then return (self.arenasize == 0);
	elseif rostertype == "ARENAPET" then return (self.arenapetsize == 0);
	elseif rostertype == "ARENA&ARENAPET" then return (self.arenasize + self.arenapetsize == 0);
	elseif rostertype == "BOSS" then return (self.bosssize == 0);
	end
end

--- Determine if the given RDX unit is a member of this set.
function RDXDAL.Set:IsMember(rdxu)
	if not rdxu then return nil; end
	return self[rdxu.nid];
end

--- Determine if the RDX unit with the given nid is a member of this set.
-- DEPRECATED
function RDXDAL.Set:_IsMemberByNid(nid)
	return self[nid];
end

local function Set_ClosureFreeIterator(set, idx)
	idx = idx + 1;
	while set[idx] == false do idx = idx + 1; end
	if set[idx] then
		return idx, NumberToUID(idx), GetUnitByNumber(idx);
	end
end

local function Set_Raid_ClosureFreeIterator(set, idx)
	idx = idx + 1;
	while set[idx] == false do idx = idx + 1; end
	if set[idx] and idx < 41 then
		return idx, NumberToUID(idx), GetUnitByNumber(idx);
	end
end

local function Set_RaidPet_ClosureFreeIterator(set, idx)
	idx = idx + 1;
	while set[idx] == false or (set[idx] and idx < 41) do idx = idx + 1; end
	if set[idx] and idx < 81 then
		return idx, NumberToUID(idx), GetUnitByNumber(idx);
	end
end

local function Set_RaidRaidPet_ClosureFreeIterator(set, idx)
	idx = idx + 1;
	while set[idx] == false do idx = idx + 1; end
	if set[idx] and idx < 81 then
		return idx, NumberToUID(idx), GetUnitByNumber(idx);
	end
end

local function Set_Arena_ClosureFreeIterator(set, idx)
	idx = idx + 1;
	while set[idx] == false or (set[idx] and idx < 81) do idx = idx + 1; end
	if set[idx] and idx < 86 then
		return idx, NumberToUID(idx), GetUnitByNumber(idx);
	end
end

local function Set_ArenaPet_ClosureFreeIterator(set, idx)
	idx = idx + 1;
	while set[idx] == false or (set[idx] and idx < 86) do idx = idx + 1; end
	if set[idx] and idx < 91 then
		return idx, NumberToUID(idx), GetUnitByNumber(idx);
	end
end

local function Set_ArenaArenaPet_ClosureFreeIterator(set, idx)
	idx = idx + 1;
	while set[idx] == false or (set[idx] and idx < 81) do idx = idx + 1; end
	if set[idx] and idx < 91 then
		return idx, NumberToUID(idx), GetUnitByNumber(idx);
	end
end

local function Set_Boss_ClosureFreeIterator(set, idx)
	idx = idx + 1;
	while set[idx] == false or (set[idx] and idx < 91) do idx = idx + 1; end
	if set[idx] and idx < 96 then
		return idx, NumberToUID(idx), GetUnitByNumber(idx);
	end
end

--- Return a stateless iterator over this set.
function RDXDAL.Set:Iterator(rostertype)
	if not rostertype or rostertype == "ALL" then return Set_ClosureFreeIterator, self, 0;
	elseif rostertype == "RAID" then return Set_Raid_ClosureFreeIterator, self, 0;
	elseif rostertype == "RAIDPET" then return Set_RaidPet_ClosureFreeIterator, self, 0;
	elseif rostertype == "RAID&RAIDPET" then return Set_RaidRaidPet_ClosureFreeIterator, self, 0;
	elseif rostertype == "ARENA" then return Set_Arena_ClosureFreeIterator, self, 0;
	elseif rostertype == "ARENAPET" then return Set_ArenaPet_ClosureFreeIterator, self, 0;
	elseif rostertype == "ARENA&ARENAPET" then return Set_ArenaArenaPet_ClosureFreeIterator, self, 0;
	elseif rostertype == "BOSS" then return Set_Boss_ClosureFreeIterator, self, 0;
	end
end

--- Connect a handler to this set's delta signal
function RDXDAL.Set:ConnectDelta(obj, func)
	self.SigUpdate:Connect(obj, func);
end

--- Remove a handler from this set's delta signal.
function RDXDAL.Set:RemoveDelta(obj)
	self.SigUpdate:Disconnect(obj);
end

--- Poke directly into set internal data. WARNING: Don't use this unless you
-- know what you're doing.
function RDXDAL.Set:_Poke(un, val)
	self[un] = val;
end

--- Modify the state of a member of this set, propagating all appropriate events
-- as needed.
function RDXDAL.Set:_Set(un, val)
	local oldv = self[un];
	if(oldv ~= val) then
		self[un] = val;
		if oldv ~= false then
			if val == false then 
				self.size = self.size - 1;
				if un > 0 and un < 41 then
					self.raidsize = self.raidsize - 1;
				elseif un > 40 and un < 81 then
					self.raidpetsize = self.raidpetsize - 1;
				elseif un > 80 and un < 86 then
					self.arenasize = self.arenasize - 1;
				elseif un > 85 and un < 91 then
					self.arenapetsize = self.arenapetsize - 1;
				elseif un > 90 and un < 96 then
					self.bosssize = self.bosssize - 1;
				end
			end
		elseif val ~= false then
			self.size = self.size + 1;
			if un > 0 and un < 41 then
				self.raidsize = self.raidsize + 1;
			elseif un > 40 and un < 81 then
				self.raidpetsize = self.raidpetsize + 1;
			elseif un > 80 and un < 86 then
				self.arenasize = self.arenasize + 1;
			elseif un > 85 and un < 91 then
				self.arenapetsize = self.arenapetsize + 1;
			elseif un > 90 and un < 96 then
				self.bosssize = self.bosssize + 1;
			end
		end
		-------------- PROPAGATION CODE ------------------
		if self:IsOpen() then -- only propagate if active
			if set_batchmode then -- if in batchmode, we have to use delta-wave propagation.
				local delta = self.delta;
				if not delta[un] then
					RDX:Debug(9, "! set ", self.name, " batch delta: unit(", un, ") to ", tostring(val));
					delta[un] = true;
					if not self.laundry then self:_AddToLaundry(); end
				end
			else -- non batchmode, send single delta signals every time a unit changes
				RDX:Debug(9, "! set ", self.name, " nonbatch update: unit(", un, ") to ", tostring(val));
				self.SigUpdate:Raise(x, nil, un);
			end -- if set_batchmode
		end -- if actve
		-------------- END PROPAGATION CODE ------------------
	end
end
VFLP.RegisterFunc(VFLI.i18n("RDXDAL: Set API"), "Toggles", RDXDAL.Set._Set, true);

--- Clear this set completely.
function RDXDAL.Set:_Clear()
	RDXDAL.BeginEventBatch();
	for k,v in ipairs(self) do self:_Set(k, false); end
	RDXDAL.EndEventBatch();
end

--- Propagate delta subsignals for this set.
function RDXDAL.Set:_Clean()
	local delta = self.delta;
	self.SigUpdate:Raise(self, delta);
	tempty(delta);
end

function RDXDAL.Set:init()
	-- Call protoset init
	RDXDAL.ProtoSet.init(self);
	-- Reset to empty state
	for i=1,MAX_UNITS do self[i] = false; end
	self.size = 0;
	self.raidsize = 0;
	self.raidpetsize = 0;
	self.arenasize = 0;
	self.arenapetsize = 0;
	self.bosssize = 0;
	self.delta = {};
	-- Create updater signals.
	local sigUpdate = VFL.Signal:new();
	sigUpdate.OnNonEmpty = function() self:Open(); end
	sigUpdate.OnEmpty = function() self:Close(); end
	self.SigUpdate = sigUpdate;
end


function RDXDAL.Set:new()
	local self = {}
	setmetatable(self, RDXDAL.Set);
	self:init();
	return self;
end

---------------------------------------------------------------------
-- FILTER SET
-- Set based on a filter, and whose contents change whenever the filter
-- would so indicate.
---------------------------------------------------------------------
RDXDAL.FilterSet = {};

--- Given a filter descriptor, create a filter set based upon it.
function RDXDAL.FilterSet:new()
	local self = RDXDAL.Set:new();
	
	local test = VFL.Nil;
	local filter_desc, gen_events, gen_sets = nil, {}, {};
	local batch_deferred_rebuild = nil;
	
	-- Full rebuild
	local function ForceFullRebuild()
		local unit = nil;
		-- RDX:Debug(8, self.name, ":FullRebuild(): examining ", n, " units");
		RDXDAL.BeginEventBatch();
		for i=1,MAX_UNITS do
			unit = GetUnitByNumber(i);
			if test(unit) then self:_Set(i, true); else self:_Set(i, false); end
		end
		RDXDAL.EndEventBatch();
	end
	local function FullRebuild()
		if set_batchmode then 
			batch_deferred_rebuild = true;
			self:_AddToLaundry();
		else ForceFullRebuild(); end
	end

	-- Single unit requery
	local function Recheck(rdxu)
		if batch_deferred_rebuild then return; end
		-- RDX:Debug(15, self.name, " examining unit# ", rdxu.nid);
		if test(rdxu) then self:_Set(rdxu.nid, true); else self:_Set(rdxu.nid, false); end
	end

	-- Recheck all keys in a set delta table
	local function RecheckDelta(_, _, t, un)
		local unit = nil;
		-- If a full rebuild was scheduled, then individual unit checks are meaningless
		if batch_deferred_rebuild then return; end
		if un then
			unit = GetUnitByNumber(un);
			-- RDX:Debug(15, self.name, " examining unit# ", un);
			if test(unit) then self:_Set(un, true); else self:_Set(un, false); end
		else
			for k,_ in pairs(t) do
				unit = GetUnitByNumber(k);
				-- RDX:Debug(15, self.name, " multi-examining unit# ", k);
				if test(unit) then self:_Set(k, true); else self:_Set(k, false); end
			end
		end
	end

	-- Bind this set to all of the necessary engine triggers.
	local function SetupTriggers()
		for ev,m in pairs(gen_events) do
			if m.actionid == 2 then -- Fully rebuild the set whenever the given event fires
				-- RDX:Debug(4, "* Full update on event: ", ev);
				RDXEvents:Bind(ev, nil, FullRebuild, self);
			elseif m.actionid == 1 then -- Reexamine a specific unit whenever the given event fires
				-- RDX:Debug(4, "* Reexamine unit on event: ", ev);
				RDXEvents:Bind(ev, nil, Recheck, self);
			end
		end

		-- Bind to each dependent set.
		for sid,_ in pairs(gen_sets) do
--			RDX:Debug(4, "* Examine delta residue of set id ", sid);
			local theset = RDXDAL.GetSetByID(sid);
			if theset then theset:ConnectDelta(self, RecheckDelta); end
		end

		-- On a disruption, rebuild the whole shebang.
		RDXEvents:Bind("DISRUPT_SETS", nil, FullRebuild, self);
	end

	-- Undo that which was done by SetupTriggers
	local function TearDownTriggers()
		-- RDX:Debug(4, self.name, ":TearDownTriggers()");
		RDXEvents:Unbind(self);
		if not gen_sets then return; end
		for sid,m in pairs(gen_sets) do
			local theset = RDXDAL.GetSetByID(sid);
			if theset then theset:RemoveDelta(self); end
		end
	end

	-- Set the filter descriptor for this set
	self.SetFilter = function(x, desc)
		-- RDX:Debug(4, self.name, ":SetFilter(", Serialize(desc), ")");
		-- Tear down any old filters we may have
		TearDownTriggers();
		-- Generate filter
		local x1, x2 = RDXDAL.FilterFunctor(desc, x.path);
		if not x1 then
			VFL.TripError("RDX", x.name .. VFLI.i18n(": could not generate filter."), VFLI.i18n("Filter generation failed for filter:\n") .. Serialize(desc));
			return; 
		end
		-- Reassociate all filter metadata
		filter_desc = desc; test = x1;
		tempty(gen_events); tempty(gen_sets);
		x2.EventsFromDescriptor(desc, gen_events);
		x2.SetsFromDescriptor(desc, gen_sets);
		-- Activate us if necessary
		if x:IsOpen() then
			SetupTriggers();
			ForceFullRebuild();
		end
	end

	-- Activator
	self._OnActivate = function(x)
		if not filter_desc then return; end -- filter hasn't been set yet...
--		RDX:Debug(4, self.name, ":_OnActivate()");
		SetupTriggers();
		ForceFullRebuild();
	end
	self._OnDeactivate = function(x)
		if not filter_desc then return; end -- filter hasn't been set yet...
		-- Clear any residue before deactivating.
		x:_Clear();
		-- Tear down any event bindings
		TearDownTriggers();
	end

	self._Clean = function(x)
		if batch_deferred_rebuild then
			batch_deferred_rebuild = nil;
			ForceFullRebuild();
		else
			RDXDAL.Set._Clean(x);
		end
	end

	return self;
end


--- The universal empty set.
RDXDAL.emptySet = RDXDAL.Set:new();
RDXDAL.emptySet._Set = VFL.Noop;
RDXDAL.emptySet.ConnectDelta = VFL.Noop;
RDXDAL.emptySet.RemoveDelta = VFL.Noop;
RDXDAL.emptySet._Clear = VFL.Noop; RDXDAL.emptySet._Clean = VFL.Noop;
RDXDAL.emptySet.name = "<emptyset>";
RDXDAL.RegisterSet(RDXDAL.emptySet);

--- The whole raid set
local gs = RDXDAL.Set:new();
RDXEvents:Bind("DISRUPT_SETS", nil, function()
	local u = nil;
	for i=1,40 do
		u = GetUnitByNumber(i);
		if u:IsCacheValid() then gs:_Set(i, true); else gs:_Set(i, false); end
	end
end);
gs.name = "<group>";
RDXDAL.RegisterSet(gs);
RDXDAL.groupSet = gs;
