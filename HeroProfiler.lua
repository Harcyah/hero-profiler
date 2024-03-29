local function ExportBackpack()
	local backpack = {}
	backpack.numSlots = GetContainerNumSlots(0)
	backpack.freeSlots = GetContainerNumFreeSlots(0)
	return backpack
end

local function ExportBag(index)
	local bag = {}
	bag.link = GetInventoryItemLink('player', ContainerIDToInventoryID(index))
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

local function ExportBags()
	if (HeroProfiles.bags == nil) then
		HeroProfiles.bags = {}
	end
	HeroProfiles.bags.backpack = ExportBackpack()
	HeroProfiles.bags.bag1 = ExportBag(1)
	HeroProfiles.bags.bag2 = ExportBag(2)
	HeroProfiles.bags.bag3 = ExportBag(3)
	HeroProfiles.bags.bag4 = ExportBag(4)
end

local function ExportBank(index)
	local bank = {}
	bank.link = GetInventoryItemLink('player', ContainerIDToInventoryID(index))
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

local function ExportQuests()
	HeroProfiles.quests = {}
	local questIDs = C_QuestLog.GetAllCompletedQuestIDs()
	for k,v in pairs(questIDs) do
		tinsert(HeroProfiles.quests, v)
	end
end

local MAP_ID_THE_MAW = 1543;
local MAP_ID_BASTION = 1533;
local MAP_ID_ARDENWEALD = 1565;
local MAP_ID_MALDRAXXUS = 1536;
local MAP_ID_REVENDRETH = 1525;

local function ExportWorldBoss(bossQuestID, mapID, expansion)
	local result = {}
	result.available = false
	result.completed = C_QuestLog.IsQuestFlaggedCompleted(bossQuestID)
	result.questID = bossQuestID
	result.expansion = expansion

	local questsData = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
	for i, data in pairs(questsData) do
		if (data.questId == bossQuestID) then
			result.available = true
		end
	end

	if (result.completed) then
		result.available = true
	end

	return result
end

local function ExportWorldBosses()
	HeroProfiles.weekly.worldBosses = {}
	HeroProfiles.weekly.worldBosses.valinor = ExportWorldBoss(61813, MAP_ID_BASTION, "9.0.0")
	HeroProfiles.weekly.worldBosses.morgeth = ExportWorldBoss(64531, MAP_ID_THE_MAW, "9.1.0")
	HeroProfiles.weekly.worldBosses.mortanis = ExportWorldBoss(61816, MAP_ID_MALDRAXXUS, "9.0.0")
	HeroProfiles.weekly.worldBosses.nurgash = ExportWorldBoss(61814, MAP_ID_REVENDRETH, "9.0.0")
	HeroProfiles.weekly.worldBosses.oranomonos = ExportWorldBoss(61815, MAP_ID_ARDENWEALD, "9.0.0")
end

local function ExportWeekly()
	HeroProfiles.weekly = {}
	ExportWorldBosses()
end

local TRACKED_ACHIEVEMENTS = {
	10459,
	10994,
	11223,
	11298,
	11546,
	11846,
	12066,
	12473,
	12496,
	12497,
	12510,
	13467,
	13572,
	14281,
	14206,
	14164,
	13878,
	14801,
	14799,
	14800,
	14798
}

local function ExportAchievements()
	HeroProfiles.achievements = {}
	for i = 1, #TRACKED_ACHIEVEMENTS do
		id = TRACKED_ACHIEVEMENTS[i]
		HeroProfiles.achievements[tostring(id)] = IsAchievementCompleted(id)
	end
end

local function ExportEquipmentSlot(name)
	slot = GetInventorySlotInfo(name)
	link = GetInventoryItemLink('player', slot)
	if (link == nil) then
		return {
			link = '',
			level = -1
		}
	else
		return {
			link = link,
			level = GetDetailedItemLevelInfo(link)
		}
	end
end

local function ExportEquipment()
	HeroProfiles.equipment = {
		headSlot = ExportEquipmentSlot('HeadSlot'),
		neckSlot = ExportEquipmentSlot('NeckSlot'),
		shoulderSlot = ExportEquipmentSlot('ShoulderSlot'),
		backSlot = ExportEquipmentSlot('BackSlot'),
		chestSlot = ExportEquipmentSlot('ChestSlot'),
		shirtSlot = ExportEquipmentSlot('ShirtSlot'),
		tabardSlot = ExportEquipmentSlot('TabardSlot'),
		wristSlot = ExportEquipmentSlot('WristSlot'),
		handsSlot = ExportEquipmentSlot('HandsSlot'),
		waistSlot = ExportEquipmentSlot('WaistSlot'),
		legsSlot = ExportEquipmentSlot('LegsSlot'),
		feetSlot = ExportEquipmentSlot('FeetSlot'),
		finger0Slot = ExportEquipmentSlot('Finger0Slot'),
		finger1Slot = ExportEquipmentSlot('Finger1Slot'),
		trinket0Slot = ExportEquipmentSlot('Trinket0Slot'),
		trinket1Slot = ExportEquipmentSlot('Trinket1Slot'),
		mainHandSlot = ExportEquipmentSlot('MainHandSlot'),
		secondaryHandSlot = ExportEquipmentSlot('SecondaryHandSlot')
	}
end

local function ExportCurrencies()
	HeroProfiles.currencies = {}
	for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
		local info = C_CurrencyInfo.GetCurrencyListInfo(i)
		if not info.isHeader then
			local currency = {}
			currency.name = info.name
			currency.count = info.quantity
			table.insert(HeroProfiles.currencies, currency)
		end
	end
end

local function ExportMounts()
	HeroProfiles.mounts = {};
	local ids = C_MountJournal.GetMountIDs();
	for i, id in pairs(ids) do
		local name, spellId, _, _, _, _, _, _, _, _, collected, mountId = C_MountJournal.GetMountInfoByID(id);
		local mount = {}
		mount['mountId'] = mountId;
		mount['spellId'] = spellId;
		mount['name'] = name;
		mount['owned'] = collected;
		table.insert(HeroProfiles.mounts, mount);
	end
end

local function ExportPets()
	HeroProfiles.pets = {};
	local total = C_PetJournal.GetNumPets();
	for i = 1, total do
		local _, _, isOwned, _, _, _, _, speciesName, _, _, companionID, _, _, _, _, _, _, _ = C_PetJournal.GetPetInfoByIndex(i);
		local pet = {}
		pet['petId'] = companionID;
		pet['name'] = speciesName;
		pet['owned'] = isOwned;
		table.insert(HeroProfiles.pets, pet);
	end
end

local function ExportToys()
	C_ToyBox.SetAllSourceTypeFilters(true);
	C_ToyBox.SetCollectedShown(true);
	C_ToyBox.SetUncollectedShown(true);
	C_ToyBox.SetUnusableShown(true);
	C_ToyBox.SetFilterString('');

	HeroProfiles.toys = {};
	local toys = C_ToyBox.GetNumToys();
	for i = 1, toys do
		local id = C_ToyBox.GetToyFromIndex(i);
		local _, toyName, _, _, _, _ = C_ToyBox.GetToyInfo(id);
		local toy = {};
		toy['toyId'] = id;
		toy['name'] = toyName;
		toy['owned'] = PlayerHasToy(id);
		table.insert(HeroProfiles.toys, toy);
	end
end

local function ExportFollowersOfExpansion(expansionId)
	local followers = C_Garrison.GetFollowers(expansionId);
	if (followers == nil) then
		return {}
	else
		return followers
	end
end

local function ExportFollowers()
	HeroProfiles.followers = {
		garrison60 = ExportFollowersOfExpansion(Enum.GarrisonFollowerType.FollowerType_6_0),
		garrison70 = ExportFollowersOfExpansion(Enum.GarrisonFollowerType.FollowerType_7_0),
		garrison80 = ExportFollowersOfExpansion(Enum.GarrisonFollowerType.FollowerType_8_0),
		garrison90 = ExportFollowersOfExpansion(Enum.GarrisonFollowerType.FollowerType_9_0),
	}
end

local function ExportArchaeology()
	local prof1, prof2, archaeology, fishing, cooking, _ = GetProfessions();
	if (HeroProfiles.professions == nil) then
		HeroProfiles.professions = {}
	end

	local _, _, rank, maxRank, _, _, skillLine, _, _, _, skillLineName = GetProfessionInfo(archaeology);
	HeroProfiles.professions.archaeology = {
		id = skillLine,
		name = skillLineName,
		currentLevel = rank,
		maxLevel = maxRank
	}
end

local function ExportProfession()
	local prof1, prof2, archaeology, fishing, cooking, _ = GetProfessions();
	if (HeroProfiles.professions == nil) then
		HeroProfiles.professions = {}
	end

	if (prof1 ~= nil and HeroProfiles.professions.prof1 == nil) then
		local _, _, _, _, _, _, skillLine = GetProfessionInfo(prof1);
		HeroProfiles.professions.prof1 = {
			id = skillLine
		};
	end
	if (prof2 ~= nil and HeroProfiles.professions.prof2 == nil) then
		local _, _, _, _, _, _, skillLine = GetProfessionInfo(prof2);
		HeroProfiles.professions.prof2 = {
			id = skillLine
		};
	end
	if (cooking ~= nil and HeroProfiles.professions.cooking == nil) then
		local _, _, _, _, _, _, skillLine = GetProfessionInfo(cooking);
		HeroProfiles.professions.cooking = {
			id = skillLine
		};
	end
	if (fishing ~= nil and HeroProfiles.professions.fishing == nil) then
		local _, _, _, _, _, _, skillLine = GetProfessionInfo(fishing);
		HeroProfiles.professions.fishing = {
			id = skillLine
		};
	end

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
		if (p.prof1 ~= nil and p.prof1.id == parentID) then
			p.prof1.levels = levels
		elseif (p.prof2 ~= nil and p.prof2.id == parentID) then
			p.prof2.levels = levels
		elseif (p.cooking ~= nil and p.cooking.id == parentID) then
			p.cooking.levels = levels
		elseif (p.fishing ~= nil and p.fishing.id == parentID) then
			p.fishing.levels = levels
		end
	end
end

local function ExportProfile()
	HeroProfiles.guid = UnitGUID('player')
	HeroProfiles.name = UnitName('player')
	HeroProfiles.realm = GetRealmName()
	HeroProfiles.level = UnitLevel('player')
	HeroProfiles.hearthstone = GetBindLocation()
	HeroProfiles.gender = UnitSex('player')
	HeroProfiles.xp = UnitXP('player')
	HeroProfiles.xpMax = UnitXPMax('player')
	HeroProfiles.health = UnitHealthMax('player')
	HeroProfiles.side = UnitFactionGroup('player')

	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
	HeroProfiles.avgItemLevel = avgItemLevel
	HeroProfiles.avgItemLevelEquipped = avgItemLevelEquipped
	HeroProfiles.avgItemLevelPvp = avgItemLevelPvp

	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
	if azeriteItemLocation and azeriteItemLocation:IsEquipmentSlot() then
		HeroProfiles.azeriteLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
	else
		HeroProfiles.azeriteLevel = 0
	end

	HeroProfiles.hasMasterRiding = tostring(IsSpellKnown(90265))

	local className, classFile, classID = UnitClass('player');
	HeroProfiles.clazz = classFile

	local raceName, raceFile, raceID = UnitRace('player')
	HeroProfiles.race = raceFile

	local englishFaction, localizedFaction = UnitFactionGroup('player')
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

	ExportAchievements();
	ExportQuests();
	ExportWeekly();
	ExportEquipment();
	ExportFollowers();
	ExportCurrencies();
	ExportRest();
	ExportBags();
	ExportMounts();
	ExportToys();
end

local frame = CreateFrame('Frame');
frame:RegisterEvent('ACHIEVEMENT_EARNED');
frame:RegisterEvent('ADDON_LOADED');
frame:RegisterEvent('ARCHAEOLOGY_TOGGLE');
frame:RegisterEvent('BAG_UPDATE');
frame:RegisterEvent('BANKFRAME_OPENED');
frame:RegisterEvent('COVENANT_CALLINGS_UPDATED');
frame:RegisterEvent('GARRISON_FOLLOWER_ADDED');
frame:RegisterEvent('GARRISON_FOLLOWER_REMOVED');
frame:RegisterEvent('GARRISON_UPDATE');
frame:RegisterEvent('GET_ITEM_INFO_RECEIVED');
frame:RegisterEvent('PET_JOURNAL_LIST_UPDATE');
frame:RegisterEvent('PLAYER_ENTERING_WORLD');
frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED');
frame:RegisterEvent('PLAYER_GUILD_UPDATE');
frame:RegisterEvent('PLAYER_LOGIN');
frame:RegisterEvent('PLAYER_LOGOUT');
frame:RegisterEvent('PLAYER_MONEY');
frame:RegisterEvent('PLAYER_UPDATE_RESTING');
frame:RegisterEvent('PLAYER_XP_UPDATE');
frame:RegisterEvent('QUEST_FINISHED');
frame:RegisterEvent('TIME_PLAYED_MSG');
frame:RegisterEvent('TRADE_SKILL_LIST_UPDATE');
frame:RegisterEvent('TRADE_SKILL_SHOW');
frame:RegisterEvent('ZONE_CHANGED_NEW_AREA');
frame:Hide();

frame:SetScript('OnEvent', function(self, event, ...)
	local arg = {...}

	if (event == 'ADDON_LOADED' and arg[1] == 'HeroProfiler') then
		if (HeroProfiles == nil) then
			HeroProfiles = {}
		end
	end

	if (event == 'PLAYER_LOGIN') then
		HeroProfiles.time = {}
		HeroProfiles.time.login = GetServerTime()
		RequestTimePlayed()
		C_CovenantCallings.RequestCallings()
	end

	if (event == 'PLAYER_ENTERING_WORLD') then
		ExportProfile()
	end

	if (event == 'PLAYER_LOGOUT') then
		HeroProfiles.time.logout = GetServerTime()
		ExportCurrencies()
	end

	if (event == 'ACHIEVEMENT_EARNED') then
		ExportAchievements()
	end

	if (event == 'QUEST_FINISHED') then
		ExportQuests()
		ExportWeekly()
	end

	if (event == 'TIME_PLAYED_MSG') then
		HeroProfiles.totalTime = arg[1]
		HeroProfiles.currentLevelTime = arg[2]
	end

	if (event == 'COVENANT_CALLINGS_UPDATED') then
		HeroProfiles.callings = {}
		if (C_CovenantCallings.AreCallingsUnlocked()) then
			for i = 1, 3 do
				local calling = arg[1][i]
				if (calling) then
					HeroProfiles.callings[i] = {}
					HeroProfiles.callings[i].available = true
					HeroProfiles.callings[i].completed = true
				else
					HeroProfiles.callings[i] = {}
					HeroProfiles.callings[i].available = false
					HeroProfiles.callings[i].completed = false
				end
			end
		else
			for i = 1, 3 do
				HeroProfiles.callings[i] = {}
				HeroProfiles.callings[i].available = false
				HeroProfiles.callings[i].completed = false
			end
		end
	end

	if (event == 'PLAYER_GUILD_UPDATE') then
		local guildName, guildRankName, guildRankIndex = GetGuildInfo('player')
		HeroProfiles.guildName = guildName
		HeroProfiles.guildRankName = guildRankName
		HeroProfiles.guildRankIndex = guildRankIndex
	end

	if (event == 'BANKFRAME_OPENED') then
		HeroProfiles.bags.bank1 = ExportBank(5)
		HeroProfiles.bags.bank2 = ExportBank(6)
		HeroProfiles.bags.bank3 = ExportBank(7)
		HeroProfiles.bags.bank4 = ExportBank(8)
		HeroProfiles.bags.bank5 = ExportBank(9)
		HeroProfiles.bags.bank6 = ExportBank(10)
		HeroProfiles.bags.bank7 = ExportBank(11)
	end

	if (event == 'BAG_UPDATE') then
		ExportBags()
	end

	if (event == 'PLAYER_MONEY') then
		HeroProfiles.money = GetMoney()
	end

	if (event == 'PLAYER_XP_UPDATE') then
		HeroProfiles.xp = UnitXP('player')
	end

	if (event == 'ZONE_CHANGED_NEW_AREA') then
		HeroProfiles.zone = GetZoneText()
	end

	if (event == 'PLAYER_UPDATE_RESTING') then
		ExportRest()
	end

	if (event == 'PLAYER_EQUIPMENT_CHANGED') then
		ExportEquipment()
	end

	if (event == 'GET_ITEM_INFO_RECEIVED') then
		ExportEquipment()
	end

	if (event == 'GARRISON_FOLLOWER_ADDED' or event == 'GARRISON_FOLLOWER_REMOVED' or event == 'GARRISON_UPDATE') then
		ExportFollowers()
	end

	if (event == 'ARCHAEOLOGY_TOGGLE') then
		ExportArchaeology();
	end

	if (event == 'TRADE_SKILL_SHOW') then
		ExportProfession();
	end

	if (event == 'TRADE_SKILL_LIST_UPDATE') then
		ExportProfession();
	end

	if (event == 'PET_JOURNAL_LIST_UPDATE') then
		ExportPets();
	end

end)
