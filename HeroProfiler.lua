local function ExportProfession(index)
	local profession = {}
	if (index == nil) then
		profession.index = nil
		profession.name = ""
		profession.levels = {}
	else
		local name = GetProfessionInfo(index)
		profession.index = index
		profession.name = name
		profession.levels = {}
	end
	return profession
end

local function ExportBackpack()
	local bag = {}
	bag.link = nil
	bag.numSlots = GetContainerNumSlots(0)
	bag.freeSlots = GetContainerNumFreeSlots(0)
	return bag
end

local function ExportContainer(index)
	local bag = {}
	bag.link = GetInventoryItemLink("player", ContainerIDToInventoryID(index))
	bag.numSlots = GetContainerNumSlots(index)
	bag.freeSlots = GetContainerNumFreeSlots(index)
	return bag
end

local function ExportProfiles() 
	HeroProfiles.name = UnitName("player")
	HeroProfiles.realm = GetRealmName()
	HeroProfiles.level = UnitLevel("player")
	HeroProfiles.money = GetMoney()
	HeroProfiles.zone = GetZoneText()
	HeroProfiles.heartstone = GetBindLocation()
	HeroProfiles.gender = UnitSex("player")
	HeroProfiles.xp = UnitXP("player")
	HeroProfiles.health = UnitHealthMax("player")
	HeroProfiles.side = UnitFactionGroup("player")
	
	local restId, restName = GetRestState()
	HeroProfiles.restId = restId
	HeroProfiles.restName = restName
	
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
		local name, description, standingId, bottomValue, topValue, earnedValue, _, _, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(i)
		if (isHeader == false) then
			local faction = {}
			faction.name = name
			faction.earned = earnedValue
			table.insert(HeroProfiles.factions, faction)
		end
	end
	
	local prof1, prof2, archaelogy, fishing, cooking = GetProfessions();
	if (HeroProfiles.professions == nil) then
		HeroProfiles.professions = {}
	end
	if (HeroProfiles.professions.prof1 == nil) then
		HeroProfiles.professions.prof1 = ExportProfession(prof1)
	end
	if (HeroProfiles.professions.prof2 == nil) then
		HeroProfiles.professions.prof2 = ExportProfession(prof2)
	end
	if (HeroProfiles.professions.fishing == nil) then
		HeroProfiles.professions.fishing = ExportProfession(fishing)
	end
	if (HeroProfiles.professions.cooking == nil) then
		HeroProfiles.professions.cooking = ExportProfession(cooking)
	end
	
	-- Archaelogy is a bit specific
	HeroProfiles.professions.archaelogy = {}
	if (archaelogy == nil) then
		HeroProfiles.professions.archaelogy.index = nil
		HeroProfiles.professions.archaelogy.currentLevel = nil
		HeroProfiles.professions.archaelogy.maxLevel = nil
	else
		local archName, _, archCurrentLevel, archMaxLevel = GetProfessionInfo(archaelogy)
		HeroProfiles.professions.archaelogy.index = archaelogy
		HeroProfiles.professions.archaelogy.currentLevel = archCurrentLevel
		HeroProfiles.professions.archaelogy.maxLevel = archMaxLevel
	end	
	
	-- Bags
	HeroProfiles.bags = {}
	HeroProfiles.bags.backpack = ExportBackpack()
	HeroProfiles.bags.bag1 = ExportContainer(1)
	HeroProfiles.bags.bag2 = ExportContainer(2)
	HeroProfiles.bags.bag3 = ExportContainer(3)
	HeroProfiles.bags.bag4 = ExportContainer(4)
end

SlashCmdList['HERO_PROFILER'] = function()
	ExportProfiles()
end

SLASH_HERO_PROFILER1 = '/heroprofiler'

local frame = CreateFrame("Frame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_GUILD_UPDATE");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:RegisterEvent("TIME_PLAYED_MSG");
frame:RegisterEvent("BANKFRAME_OPENED");
frame:RegisterEvent("TRADE_SKILL_LIST_UPDATE");
frame:Hide();

frame:SetScript("OnEvent", function(self, event, ...)
	local arg = {...}
	
	if (event == "TIME_PLAYED_MSG") then 
		HeroProfiles.totalTime = arg[1]
		HeroProfiles.currentLevelTime = arg[2]
	end
	
	if (event == "ADDON_LOADED" and arg[1] == 'HeroProfiler') then
		if (HeroProfiles == nil) then
			HeroProfiles = {}
		end
	end
	
	if (event == "PLAYER_LOGIN") then
		ExportProfiles()
	end
	
	if (event == "PLAYER_GUILD_UPDATE") then
		local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
		HeroProfiles.guildName = guildName
		HeroProfiles.guildRankName = guildRankName
		HeroProfiles.guildRankIndex = guildRankIndex
	end
	
	if (event == "BANKFRAME_OPENED") then
		HeroProfiles.bags.bank1 = ExportContainer(5)
		HeroProfiles.bags.bank2 = ExportContainer(6)
		HeroProfiles.bags.bank3 = ExportContainer(7)
		HeroProfiles.bags.bank4 = ExportContainer(8)
		HeroProfiles.bags.bank5 = ExportContainer(9)
		HeroProfiles.bags.bank6 = ExportContainer(10)
		HeroProfiles.bags.bank7 = ExportContainer(11)
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
			local _, _, _, _, _, parentSkillLineID, parentSkillLineName =  C_TradeSkillUI.GetTradeSkillLine();
			if (HeroProfiles.professions.prof1.name == parentSkillLineName) then
				HeroProfiles.professions.prof1.id = parentSkillLineID
				HeroProfiles.professions.prof1.levels = levels
			elseif (HeroProfiles.professions.prof2.name == parentSkillLineName) then
				HeroProfiles.professions.prof2.id = parentSkillLineID
				HeroProfiles.professions.prof2.levels = levels
			elseif (HeroProfiles.professions.cooking.name == parentSkillLineName) then
				HeroProfiles.professions.cooking.id = parentSkillLineID
				HeroProfiles.professions.cooking.levels = levels
			elseif (HeroProfiles.professions.fishing.name == parentSkillLineName) then
				HeroProfiles.professions.fishing.id = parentSkillLineID
				HeroProfiles.professions.fishing.levels = levels
			end
		end
	end
	
end)