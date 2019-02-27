local function ExportBackpack()
	local backpack = {}
	backpack.numSlots = GetContainerNumSlots(0)
	backpack.freeSlots = GetContainerNumFreeSlots(0)
	return backpack
end

local function ExportBag(index)
	local bag = {}
	bag.link = GetInventoryItemLink("player", ContainerIDToInventoryID(index))
	bag.numSlots = GetContainerNumSlots(index)
	bag.freeSlots = GetContainerNumFreeSlots(index)

	if GetBagSlotFlag(index, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then
		bag.sortable = false
	else 
		bag.sortable = true
	end
	
	if GetBagSlotFlag(index, LE_BAG_FILTER_FLAG_EQUIPMENT) then
		bag.content = 'EQUIPMENT'
	end
	if GetBagSlotFlag(index, LE_BAG_FILTER_FLAG_CONSUMABLES) then
		bag.content = 'CONSUMABLES'
	end
	if GetBagSlotFlag(index, LE_BAG_FILTER_FLAG_TRADE_GOODS) then
		bag.content = 'TRADE_GOODS'
	end
	if bag.content == nil then
		bag.content = 'UNDEFINED'
	end

	return bag
end

local function ExportBank(index)
	local bank = {}
	bank.link = GetInventoryItemLink("player", ContainerIDToInventoryID(index))
	bank.numSlots = GetContainerNumSlots(index)
	bank.freeSlots = GetContainerNumFreeSlots(index)

	if GetBankBagSlotFlag(index, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP) then
		bank.sortable = false
	else 
		bank.sortable = true
	end
	
	if GetBankBagSlotFlag(index, LE_BAG_FILTER_FLAG_EQUIPMENT) then
		bank.content = 'EQUIPMENT'
	end
	if GetBankBagSlotFlag(index, LE_BAG_FILTER_FLAG_CONSUMABLES) then
		bank.content = 'CONSUMABLES'
	end
	if GetBankBagSlotFlag(index, LE_BAG_FILTER_FLAG_TRADE_GOODS) then
		bank.content = 'TRADE_GOODS'
	end
	if bank.content == nil then
		bank.content = 'UNDEFINED'
	end

	return bank
end

local function ExportProfession(index)
	if (index == nil) then
		return {
			id = 0,
			name = "UNKNOWN"
		}
	end

	local name, _, _, _, _, _, skillLine = GetProfessionInfo(index);
	return {
		id = skillLine,
		name = name
	}
end

local function ExportArchaelogy(index)
	if (index == nil) then
		return {
			id = 0,
			name = "UNKNOWN"
		}
	end

	local name, _, rank, maxRank, _, _, skillLine, _, _, _, skillLineName = GetProfessionInfo(index);
	return {
		id = skillLine,
		name = skillLineName,
		currentLevel = rank,
		maxLevel = maxRank
	}
end

local function ExportRest()
	local restId, restName = GetRestState()
	HeroProfiles.restId = restId
	HeroProfiles.restName = restName
end

local function ClearProfiles()
	HeroProfiles = {}
end

local function IsAchievementCompleted(id)
	local _, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(id)
	return (completed and wasEarnedByMe)
end

local function ExportAchievements()
	HeroProfiles.achievements = {}
	HeroProfiles.achievements.warCampaign80 = IsAchievementCompleted(12510)
	HeroProfiles.achievements.warCampaign81 = IsAchievementCompleted(13467)
	HeroProfiles.achievements.tyrandeAscension = IsAchievementCompleted(13251)
	HeroProfiles.achievements.zoneTiragardeSound = IsAchievementCompleted(12473)
	HeroProfiles.achievements.zoneStormsongValley = IsAchievementCompleted(12496)
	HeroProfiles.achievements.zoneDrustvar = IsAchievementCompleted(12497)
	HeroProfiles.achievements.classyOutfit = IsAchievementCompleted(11298)
	HeroProfiles.achievements.gloriousCampaign = IsAchievementCompleted(10994)
end

local function ExportFollowers()
	HeroProfiles.followers = {}
	HeroProfiles.followers.falstadWildhammer = false
	HeroProfiles.followers.kelseySteelspark = false
	HeroProfiles.followers.magisterUmbric = false
	HeroProfiles.followers.johnKeeshan = false
	HeroProfiles.followers.shandrisFeathermoon = false

	local followers = C_Garrison.GetFollowers(LE_FOLLOWER_TYPE_GARRISON_8_0)
	if (followers == nil) then
		return
	end
	
	for _, value in ipairs(followers) do
		if value.garrFollowerID == 1065 and value.isCollected == true then
			HeroProfiles.followers.falstadWildhammer = true
		end
		if value.garrFollowerID == 1068 and value.isCollected == true then
			HeroProfiles.followers.kelseySteelspark = true
		end
		if value.garrFollowerID == 1072 and value.isCollected == true then
			HeroProfiles.followers.magisterUmbric = true
		end
		if value.garrFollowerID == 1069 and value.isCollected == true then
			HeroProfiles.followers.johnKeeshan = true
		end
		if value.garrFollowerID == 1062 and value.isCollected == true then
			HeroProfiles.followers.shandrisFeathermoon = true
		end
	end
end

local function ExportProfiles()
	HeroProfiles.guid = UnitGUID("player")
	HeroProfiles.name = UnitName("player")
	HeroProfiles.realm = GetRealmName()
	HeroProfiles.level = UnitLevel("player")
	HeroProfiles.hearthstone = GetBindLocation()
	HeroProfiles.gender = UnitSex("player")
	HeroProfiles.xp = UnitXP("player")
	HeroProfiles.xpMax = UnitXPMax("player")
	HeroProfiles.health = UnitHealthMax("player")
	HeroProfiles.side = UnitFactionGroup("player")

	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
	HeroProfiles.avgItemLevel = avgItemLevel
	HeroProfiles.avgItemLevelEquipped = avgItemLevelEquipped
	HeroProfiles.avgItemLevelPvp = avgItemLevelPvp

	HeroProfiles.hasMasterRiding = tostring(IsSpellKnown(90265))

	local className, classFile, classID = UnitClass("player");
	HeroProfiles.clazz = classFile

	local raceName, raceFile, raceID = UnitRace("player")
	HeroProfiles.race = raceFile

	local englishFaction, localizedFaction = UnitFactionGroup("player")
	HeroProfiles.faction = englishFaction

	local specIndex = GetSpecialization()
	local specId, specName, _, _, _, specRole = GetSpecializationInfo(specIndex)
	HeroProfiles.specId = specId
	HeroProfiles.specName = specName
	HeroProfiles.specRole = GetSpecializationRoleByID(specId)

	local totalAchievements, completedAchievements = GetNumCompletedAchievements()
	HeroProfiles.totalAchievements = totalAchievements
	HeroProfiles.completedAchievements = completedAchievements
	HeroProfiles.totalAchievementPoints = GetTotalAchievementPoints()

	HeroProfiles.factions = {}
	for i=1,GetNumFactions() do
		local name, description, standingId, bottomValue, topValue, earnedValue, _, _, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID = GetFactionInfo(i)
		if (isHeader == false) then
			local faction = {}
			faction.id = factionID
			faction.name = name
			faction.earned = earnedValue
			table.insert(HeroProfiles.factions, faction)
		end
	end

	local prof1, prof2, archaelogy, fishing, cooking = GetProfessions();
	if (HeroProfiles.professions == nil) then
		HeroProfiles.professions = {
			prof1 = ExportProfession(prof1),
			prof2 = ExportProfession(prof2),
			cooking = ExportProfession(cooking),
			fishing = ExportProfession(fishing),
			archaeology = ExportArchaelogy(archaelogy)
		}
	end

	-- Bags
	if (HeroProfiles.bags == nil) then
		HeroProfiles.bags = {}
	end
	HeroProfiles.bags.backpack = ExportBackpack()
	HeroProfiles.bags.bag1 = ExportBag(1)
	HeroProfiles.bags.bag2 = ExportBag(2)
	HeroProfiles.bags.bag3 = ExportBag(3)
	HeroProfiles.bags.bag4 = ExportBag(4)

	-- Achievements
	ExportAchievements()

	-- Rest
	ExportRest()
end

local function PrintButtons() 
	for i=49,60 do 
		print(i) 
		local actionType, id, subType = GetActionInfo(i)
		print ('button ', i, ' action:', actionType, ' id:', id, ' subtype:', subType)
	end
end

local function SlashCmdList_AddSlashCommand(name, func, ...)
	SlashCmdList[name] = func
	local command = ''
	for i = 1, select('#', ...) do
		command = select(i, ...)
		if strsub(command, 1, 1) ~= '/' then
			command = '/' .. command
		end
		_G['SLASH_'..name..i] = command
	end
end

SlashCmdList_AddSlashCommand('HERO_PROFILER_SLASHCMD_EXPORT', ExportProfiles, '/hpexport')
SlashCmdList_AddSlashCommand('HERO_PROFILER_SLASHCMD_CLEAR', ClearProfiles, '/hpclear')
SlashCmdList_AddSlashCommand('HERO_PROFILER_SLASHCMD_BUTTON', PrintButtons, '/hppb')

local frame = CreateFrame("Frame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:RegisterEvent("ACHIEVEMENT_EARNED");
frame:RegisterEvent("PLAYER_GUILD_UPDATE");
frame:RegisterEvent("TIME_PLAYED_MSG");
frame:RegisterEvent("BANKFRAME_OPENED");
frame:RegisterEvent("PLAYER_MONEY");
frame:RegisterEvent("PLAYER_XP_UPDATE");
frame:RegisterEvent("TRADE_SKILL_LIST_UPDATE");
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
frame:RegisterEvent("PLAYER_UPDATE_RESTING");
frame:RegisterEvent("GARRISON_FOLLOWER_ADDED");
frame:RegisterEvent("GARRISON_FOLLOWER_REMOVED");
frame:RegisterEvent("GARRISON_UPDATE");
frame:Hide();

frame:SetScript("OnEvent", function(self, event, ...)
	local arg = {...}

	if (event == "ADDON_LOADED" and arg[1] == 'HeroProfiler') then
		if (HeroProfiles == nil) then
			HeroProfiles = {}
		end
	end

	if (event == "PLAYER_LOGIN") then
		ExportProfiles()
		RequestTimePlayed()
	end

	if (event == "PLAYER_LOGOUT") then
		HeroProfiles.time = GetServerTime()
	end

	if (event == "ACHIEVEMENT_EARNED") then
		ExportAchievements()
	end

	if (event == "TIME_PLAYED_MSG") then
		HeroProfiles.totalTime = arg[1]
		HeroProfiles.currentLevelTime = arg[2]
	end

	if (event == "PLAYER_GUILD_UPDATE") then
		local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
		HeroProfiles.guildName = guildName
		HeroProfiles.guildRankName = guildRankName
		HeroProfiles.guildRankIndex = guildRankIndex
	end

	if (event == "BANKFRAME_OPENED") then
		HeroProfiles.bags.bank1 = ExportBank(5)
		HeroProfiles.bags.bank2 = ExportBank(6)
		HeroProfiles.bags.bank3 = ExportBank(7)
		HeroProfiles.bags.bank4 = ExportBank(8)
		HeroProfiles.bags.bank5 = ExportBank(9)
		HeroProfiles.bags.bank6 = ExportBank(10)
		HeroProfiles.bags.bank7 = ExportBank(11)
	end

	if (event == "PLAYER_MONEY") then
		HeroProfiles.money = GetMoney()
	end

	if (event == "PLAYER_XP_UPDATE") then
		HeroProfiles.xp = UnitXP("player")
	end

	if (event == "ZONE_CHANGED_NEW_AREA") then
		HeroProfiles.zone = GetZoneText()
	end

	if (event == "PLAYER_UPDATE_RESTING") then
		ExportRest()
	end

	if (event == "GARRISON_FOLLOWER_ADDED" or event == "GARRISON_FOLLOWER_REMOVED" or event == "GARRISON_UPDATE") then
		ExportFollowers()
	end

	if (event == "TRADE_SKILL_LIST_UPDATE") then
		if (C_TradeSkillUI.IsTradeSkillReady()) then
			levels = {}
			local categories = { C_TradeSkillUI.GetCategories() };
			for i, categoryID in ipairs(categories) do
				local info = C_TradeSkillUI.GetCategoryInfo(categoryID);
				if (info.type == 'subheader') then
					level = {}
					level.id = categoryID
					level.name = info.name
					level.maxLevel = info.skillLineMaxLevel
					level.currentLevel = info.skillLineCurrentLevel
					table.insert(levels, level)
				end
			end

			-- where to put this ?
			local p = HeroProfiles.professions
			local _, _, _, _, _, parentID =  C_TradeSkillUI.GetTradeSkillLine();
			if (p.prof1.id == parentID) then
				p.prof1.levels = levels
			elseif (p.prof2.id == parentID) then
				p.prof2.levels = levels
			elseif (p.cooking.id == parentID) then
				p.cooking.levels = levels
			elseif (p.fishing.id == parentID) then
				p.fishing.levels = levels
			end
		end
	end

end)
