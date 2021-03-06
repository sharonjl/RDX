-- Builtin.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- A few useful built-in structures.

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()

	local default = RDXDB.GetOrCreatePackage("default");
	if not default["assists"] then
		default["assists"] = {
			["ty"] = "NominativeSet",
			["version"] = 1,
			["data"] = {}
		};
	end

	if not default["Health_ds"] then
		default["Health_ds"] = {
			["ty"] = "Design",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Variables: Status Flags (dead, ld, feigned)",
				}, -- [1]
				{
					["feature"] = "Variable: Fractional health (fh)",
				}, -- [2]
				{
					["feature"] = "commentline",
				}, -- [3]
				{
					["a"] = 1,
					["h"] = 14,
					["version"] = 1,
					["feature"] = "base_default",
					["w"] = 90,
					["alpha"] = 1,
					["ph"] = true,
				}, -- [4]
				{
					["interpolate"] = 1,
					["frac"] = "fh",
					["owner"] = "Base",
					["w"] = "90",
					["color1"] = {
						["a"] = 1,
						["r"] = 1,
						["g"] = 0,
						["b"] = 0,
					},
					["feature"] = "statusbar_horiz",
					["h"] = "14",
					["name"] = "statusBar",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
					["orientation"] = "HORIZONTAL",
					["version"] = 1,
					["color2"] = {
						["a"] = 1,
						["r"] = 0,
						["g"] = 1,
						["b"] = 0,
					},
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX\\Skin\\bar1",
					},
				}, -- [5]
				{
					["owner"] = "Base",
					["w"] = "50",
					["classColor"] = 1,
					["font"] = {
						["size"] = 10,
						["face"] = "Interface\\Addons\\VFL\\Fonts\\LiberationSans-Regular.ttf",
						["justifyV"] = "CENTER",
						["justifyH"] = "LEFT",
						["sa"] = 1,
						["sg"] = 0,
						["name"] = "Default",
						["sx"] = 1,
						["title"] = "Default",
						["sy"] = -1,
						["sb"] = 0,
						["sr"] = 0,
					},
					["version"] = 1,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["h"] = "14",
					["feature"] = "txt_np",
					["name"] = "np",
				}, -- [6]
				{
					["owner"] = "Base",
					["w"] = "40",
					["feature"] = "txt_status",
					["font"] = {
						["size"] = 8,
						["face"] = "Interface\\Addons\\VFL\\Fonts\\LiberationSans-Regular.ttf",
						["justifyV"] = "CENTER",
						["justifyH"] = "RIGHT",
						["sa"] = 1,
						["sg"] = 0,
						["name"] = "Default",
						["sx"] = 1,
						["title"] = "Default",
						["sy"] = -1,
						["sb"] = 0,
						["sr"] = 0,
					},
					["name"] = "status_text",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["version"] = 1,
					["ty"] = "fdld",
					["h"] = "14",
				}, -- [7]
				{
					["owner"] = "Base",
					["w"] = "40",
					["feature"] = "txt_status",
					["font"] = {
						["size"] = 8,
						["face"] = "Interface\\Addons\\VFL\\Fonts\\LiberationSans-Regular.ttf",
						["justifyV"] = "CENTER",
						["justifyH"] = "RIGHT",
						["sa"] = 1,
						["sg"] = 0,
						["name"] = "Default",
						["sx"] = 1,
						["title"] = "Default",
						["sy"] = -1,
						["sb"] = 0,
						["sr"] = 0,
					},
					["name"] = "text_hp_percent",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["version"] = 1,
					["ty"] = "hpp",
					["h"] = "14",
				}, -- [8]
			},
		};
	end
end);

--------------------------------------
-- Builtin default mouse bindings
--------------------------------------

local function heal_default()
	local _,class = UnitClass("player");
	local ret = nil;
	if class == "PRIEST" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 2061,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 17,
		    },
		};
	elseif class == "DRUID" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 5185,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 774,
		    },
		};
	elseif class == "PALADIN" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 635,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 19750,
		    },
		};
	elseif class == "SHAMAN" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 331,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 8004,
		    },
		};
	elseif class == "MAGE" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 54646,
		    },
		};
	elseif class == "HUNTER" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 34477,
		    },
		};
	elseif class == "WARRIOR" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 3411,
		    },
		};
	elseif class == "WARLOCK" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 80398,
		    },
		};
	elseif class == "DEATHKNIGHT" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 47541,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 47541,
		    },
		};
	elseif class == "ROGUE" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 57934,
		    },
		};
	else
		ret = {};
	end
	return ret;
end

local function dmg_default()
	local _,class = UnitClass("player");
	local ret = nil;
	if class == "PRIEST" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 585,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 8092,
		    },
		};
	elseif class == "DRUID" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 5176,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 8921,
		    },
		};
	elseif class == "PALADIN" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 879,
		    },
		};
	elseif class == "SHAMAN" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 403,
		    },
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 421,
		    },
		};
	elseif class == "MAGE" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 133,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 116,
		    },
		};
	elseif class == "HUNTER" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 56641,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 5116,
		    },
		};
	elseif class == "WARRIOR" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 1464,
		    },
		};
	elseif class == "WARLOCK" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 686,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 348,
		    },
		};
	elseif class == "DEATHKNIGHT" then
		ret = {
		    ["1"] = {
			["action"] = "cast",
			["spell"] = 47541,
		    },
		    ["2"] = {
			["action"] = "cast",
			["spell"] = 77575,
		    },
		};
	else
		ret = {};
	end
	return ret;
end


RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	--
	-- Create player-talent-specific bindings if they don't exist
	-- default:bindings_player
	-- type talent&name&realm
	
	local mbo = RDXDB.TouchObject("default:bindings_player_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.data = {
			["1"] = {
			    ["action"] = "target",
			},
			["2"] = {
			    ["action"] = "menu",
			},
	     };
	     mbo.ty = "MouseBindings"; 
	     mbo.version = 1;
	end
	local mbo = RDXDB.TouchObject("default:bindings_player_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.data = {
			["1"] = {
			    ["action"] = "target",
			},
			["2"] = {
			    ["action"] = "menu",
			},
	     };
	     mbo.ty = "MouseBindings"; 
	     mbo.version = 1;
	end
	local mbo = RDXDB.TouchObject("default:bindings_player_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.data = {
			["1"] = {
			    ["action"] = "target",
			},
			["2"] = {
			    ["action"] = "menu",
			},
	     };
	     mbo.ty = "MouseBindings"; 
	     mbo.version = 1;
	end
	local mbsl = RDXDB.TouchObject("default:bindings_player");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "bindings_player_", ty = "MouseBindings"};
	end
	
	--
	-- Create player-talent-specific bindings if they don't exist
	-- default:bindings_target
	-- type talent&name&realm
	
	local mbo = RDXDB.TouchObject("default:bindings_target_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.data = {
			["1"] = {
			    ["action"] = "target",
			},
			["2"] = {
			    ["action"] = "menu",
			},
			["S1"] = {
			    ["action"] = "focus",
			},
	     };
	     mbo.ty = "MouseBindings"; 
	     mbo.version = 1;
	end
	local mbo = RDXDB.TouchObject("default:bindings_target_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.data = {
			["1"] = {
			    ["action"] = "target",
			},
			["2"] = {
			    ["action"] = "menu",
			},
			["S1"] = {
			    ["action"] = "focus",
			},
	     };
	     mbo.ty = "MouseBindings"; 
	     mbo.version = 1;
	end
	local mbo = RDXDB.TouchObject("default:bindings_target_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.data = {
			["1"] = {
			    ["action"] = "target",
			},
			["2"] = {
			    ["action"] = "menu",
			},
			["S1"] = {
			    ["action"] = "focus",
			},
	     };
	     mbo.ty = "MouseBindings"; 
	     mbo.version = 1;
	end
	local mbsl = RDXDB.TouchObject("default:bindings_target");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "bindings_target_", ty = "MouseBindings"};
	end
	
	-- heal bindings
	
	local mbo = RDXDB.TouchObject("default:bindings_heal_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.data = heal_default();
		mbo.ty = "MouseBindings"; 
		mbo.version = 1;
	end
	local mbo = RDXDB.TouchObject("default:bindings_heal_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.data = heal_default();
		mbo.ty = "MouseBindings"; 
		mbo.version = 1;
	end
	local mbo = RDXDB.TouchObject("default:bindings_heal_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.data = heal_default();
		mbo.ty = "MouseBindings"; 
		mbo.version = 1;
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:bindings_heal");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "bindings_heal_", ty = "MouseBindings"};
	end
	
	-- damage
	local mbo = RDXDB.TouchObject("default:bindings_dmg_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.data = dmg_default();
		mbo.ty = "MouseBindings"; 
		mbo.version = 1;
	end
	local mbo = RDXDB.TouchObject("default:bindings_dmg_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.data = dmg_default();
		mbo.ty = "MouseBindings"; 
		mbo.version = 1;
	end
	local mbo = RDXDB.TouchObject("default:bindings_dmg_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.data = dmg_default();
		mbo.ty = "MouseBindings"; 
		mbo.version = 1;
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:bindings_dmg");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "bindings_dmg_", ty = "MouseBindings"};
	end

end);

--
-- Builtin Aurafilter
--

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	local mbo = RDXDB.TouchObject("default:aurafilter_priest_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			17, -- priest bouclié
			139, -- priest rénovation
			6346, -- priest gardien de peur
			33076, -- priest prière de guérison
			10060, -- priest infusion de puissance
			33206, -- priest suppression de la douleur
			47788, -- priest esprit gardien
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_druid_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			774, -- druid récupération
			8936, -- druid rétablissement
			29166, -- druid innervation
			33778, -- druid fleur de vie
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_paladin_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			1022, -- paladin main de protection
			1044, -- paladin main de liberté
			1038, -- paladin main de salut
			6940, -- paladin main de sacrifice
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_shaman_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			2825, -- shaman fury sanguinaire
			32182, -- shaman heroisme
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_mage_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			80353, -- mage distorsion temporelle
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_hunter_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			34477, -- hunter détournement
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_warrior_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			6673, -- warrior shout
			469, -- warrior cri de commandement
			97462, -- warrior cri de ralliement
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_deathknight_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_warlock_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_rogue_buff");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
		};
	end

	local mbsl = RDXDB.TouchObject("default:aurafilter_buff");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "class" then
		mbsl.ty = "SymLink"; mbsl.version = 3; 
		mbsl.data = {
			class = "class",
			targetpath_1 = "default:aurafilter_priest_buff",
			targetpath_2 = "default:aurafilter_druid_buff",
			targetpath_3 = "default:aurafilter_paladin_buff",
			targetpath_4 = "default:aurafilter_shaman_buff",
			targetpath_5 = "default:aurafilter_warrior_buff",
			targetpath_6 = "default:aurafilter_warlock_buff",
			targetpath_7 = "default:aurafilter_mage_buff",
			targetpath_8 = "default:aurafilter_rogue_buff",
			targetpath_9 = "default:aurafilter_hunter_buff",
			targetpath_10 = "default:aurafilter_deathknight_buff",
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_dot");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			5570, -- druid essain d'insecte
			589, -- priest douleur
			2944, -- priest peste dévorante
			34914, -- priest toucher vampirique
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_block");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			51514, -- shaman maléfice
			5782, -- warlock fear
			710, -- warlock bannir
			2637, -- druid hibernation
			118, -- mage métamorphose
			9484, -- priest entrave des morts vivants
			28271, -- mage
			28272, -- mage
			61305, -- mage
			61721, -- mage
			61780, -- mage
			20066, -- paladin repentir
			6770, -- rogue assome
			2094, -- rogue cecité
		};
	end
	
	local mbo = RDXDB.TouchObject("default:aurafilter_boss");
	if not mbo.data then 
		mbo.ty = "AuraFilter"; 
		mbo.version = 1;
		mbo.data = {
			"@other", -- [1]
			"!69127", -- [2]
			"!57724", -- [3]
		};
	end
end);

---------------------------------------------
-- Builtin default set magic, curse, poison
---------------------------------------------
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	local mbo = RDXDB.TouchObject("default:set_debuff_magic");
	if not mbo.data then
		mbo.ty = "FilterSet";
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"set", -- [1]
				{
					["buff"] = "@magic",
					["class"] = "debuff",
				}, -- [2]
			}, -- [2]
			{
				"not", -- [1]
				{
					"set", -- [1]
					{
						["buff"] = 30108,
						["class"] = "debuff",
					}, -- [2]
				}, -- [2]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_debuff_curse");
	if not mbo.data then
		mbo.ty = "FilterSet";
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"set", -- [1]
				{
					["buff"] = "@curse",
					["class"] = "debuff",
				}, -- [2]
			}, -- [2]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_debuff_poison");
	if not mbo.data then
		mbo.ty = "FilterSet";
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"set", -- [1]
				{
					["buff"] = "@poison",
					["class"] = "debuff",
				}, -- [2]
			}, -- [2]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_debuff_disease");
	if not mbo.data then
		mbo.ty = "FilterSet";
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"set", -- [1]
				{
					["buff"] = "@disease",
					["class"] = "debuff",
				}, -- [2]
			}, -- [2]
		};
	end
end);

--------------------------------------
-- Builtin default set color
--------------------------------------
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	-- Create player-specific set yellow if they don't exist
	local mbo = RDXDB.TouchObject("default:set_yellow_" .. RDX.pspace .. "1");
	if not mbo.data then 
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	local mbo = RDXDB.TouchObject("default:set_yellow_" .. RDX.pspace .. "2");
	if not mbo.data then 
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	local mbo = RDXDB.TouchObject("default:set_yellow_" .. RDX.pspace .. "3");
	if not mbo.data then 
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_yellow");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_yellow_", ty = "FilterSet"};
	end
	
	-- Create player-specific set red if they don't exist
	local mbo = RDXDB.TouchObject("default:set_red_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet";
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	local mbo = RDXDB.TouchObject("default:set_red_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet";
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	local mbo = RDXDB.TouchObject("default:set_red_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet";
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_red");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_red_", ty = "FilterSet"};
	end
	
	-- Create player-specific set green if they don't exist
	local mbo = RDXDB.TouchObject("default:set_green_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	local mbo = RDXDB.TouchObject("default:set_green_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	local mbo = RDXDB.TouchObject("default:set_green_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "ags",
			},
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_green");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_green_", ty = "FilterSet"};
	end
	
	-- Create player-specific set blue if they don't exist
	local mbo = RDXDB.TouchObject("default:set_blue_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "haspet",
			},
		};
	end
	local mbo = RDXDB.TouchObject("default:set_blue_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "haspet",
			},
		};
	end
	local mbo = RDXDB.TouchObject("default:set_blue_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"set",
			{
				["class"] = "haspet",
			},
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_blue");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_blue_", ty = "FilterSet"};
	end
	
	-- Create player-specific set group 1
	local mbo = RDXDB.TouchObject("default:set_raid_group1_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[2] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group1_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[2] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group1_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[2] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_raid_group1");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_raid_group1_", ty = "FilterSet"};
	end
	
	-- Create player-specific set group 2
	local mbo = RDXDB.TouchObject("default:set_raid_group2_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[3] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group2_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[3] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	
	local mbo = RDXDB.TouchObject("default:set_raid_group2_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[3] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_raid_group2");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_raid_group2_", ty = "FilterSet"};
	end
	
	-- Create player-specific set group 3
	local mbo = RDXDB.TouchObject("default:set_raid_group3_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[4] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group3_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[4] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group3_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[4] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_raid_group3");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_raid_group3_", ty = "FilterSet"};
	end
	
	-- Create player-specific set group 4
	local mbo = RDXDB.TouchObject("default:set_raid_group4_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[5] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group4_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[5] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group4_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[5] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_raid_group4");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_raid_group4_", ty = "FilterSet"};
	end
	
	-- Create player-specific set group 5
	local mbo = RDXDB.TouchObject("default:set_raid_group5_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[6] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group5_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[6] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group5_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[6] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_raid_group5");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_raid_group5_", ty = "FilterSet"};
	end
	
	-- Create player-specific set group 6
	local mbo = RDXDB.TouchObject("default:set_raid_group6_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[7] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group6_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[7] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group6_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[7] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_raid_group6");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_raid_group6_", ty = "FilterSet"};
	end
	
	-- Create player-specific set group 7
	local mbo = RDXDB.TouchObject("default:set_raid_group7_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[8] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group7_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[8] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group7_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[8] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_raid_group7");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_raid_group7_", ty = "FilterSet"};
	end
	
	-- Create player-specific set group 8
	local mbo = RDXDB.TouchObject("default:set_raid_group8_" .. RDX.pspace .. "1");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[9] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group8_" .. RDX.pspace .. "2");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[9] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	local mbo = RDXDB.TouchObject("default:set_raid_group8_" .. RDX.pspace .. "3");
	if not mbo.data then
		mbo.ty = "FilterSet"; 
		mbo.version = 1;
		mbo.data = {
			"and", -- [1]
			{
				"groups", -- [1]
				[9] = true,
			}, -- [2]
			{
				"classes", -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				true, -- [6]
				true, -- [7]
				true, -- [8]
				true, -- [9]
				true, -- [10]
				true, -- [11]
				true, -- [12]
			}, -- [3]
		};
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:set_raid_group8");
	if not mbsl.data or type(mbsl.data) ~= "table" or mbsl.data.class ~= "talent&name&realm" then
		mbsl.ty = "SymLink"; mbsl.version = 3; mbsl.data = {class = "talent&name&realm", pkg = "default", prefixfile = "set_raid_group8_", ty = "FilterSet"};
	end
end);


