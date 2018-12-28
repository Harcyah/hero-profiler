local function ExportProfession(index)
	local name = GetProfessionInfo(index)
	local profession = {}
	profession.index = index
	profession.name = name
	profession.levels = {}
	return profession
end

local function ExportProfiles() 
	HeroProfiles.name = UnitName("player")
	HeroProfiles.realm = GetRealmName()
	HeroProfiles.level = UnitLevel("player")
	HeroProfiles.money = GetMoney()
	HeroProfiles.heartstone = GetBindLocation()
	HeroProfiles.gender = UnitSex("player")
	HeroProfiles.xp = UnitXP("player")
	
	HeroProfiles.hasMasterRiding = tostring(IsSpellKnown(90265))
	
	local className, classFile, classID = UnitClass("player");
	HeroProfiles.class = classFile
	
	local raceName, raceFile, raceID = UnitRace("player")
	HeroProfiles.race = raceFile
	
	local englishFaction, localizedFaction = UnitFactionGroup("player")
	HeroProfiles.faction = englishFaction
	
	local specIndex = GetSpecialization()
	local specId, specName, _, _, _, specRole = GetSpecializationInfo(specIndex)
	HeroProfiles.specId = specId
	HeroProfiles.specName = specName
	HeroProfiles.specRole = GetSpecializationRoleByID(specId)
	
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
	HeroProfiles.guildName = guildName
	HeroProfiles.guildRankName = guildRankName
	HeroProfiles.guildRankIndex = guildRankIndex
	
	local totalAchievements, completedAchievements = GetNumCompletedAchievements()
	HeroProfiles.totalAchievements = totalAchievements
	HeroProfiles.completedAchievements = completedAchievements
	HeroProfiles.totalAchievementPoints = GetTotalAchievementPoints()
	
	local prof1, prof2, archaelogy, fishing, cooking = GetProfessions();
	if (HeroProfiles.professions == nil) then
		HeroProfiles.professions.prof1 = ExportProfession(prof1)
		HeroProfiles.professions.prof2 = ExportProfession(prof2)
		HeroProfiles.professions.fishing = ExportProfession(fishing)
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
end

SlashCmdList['HERO_PROFILER'] = function()
	ExportProfiles()
end

SLASH_HERO_PROFILER1 = '/heroprofiler'

local frame = CreateFrame("Frame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:RegisterEvent("TIME_PLAYED_MSG");
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
	
	if (event == "PLAYER_LOGOUT") then
		ExportProfiles()
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
			local _, _, _, _, _, _, parentSkillLineName =  C_TradeSkillUI.GetTradeSkillLine();
			if (HeroProfiles.professions.prof1.name == parentSkillLineName) then
				HeroProfiles.professions.prof1.levels = levels
			elseif (HeroProfiles.professions.prof2.name == parentSkillLineName) then
				HeroProfiles.professions.prof2.levels = levels
			elseif (HeroProfiles.professions.cooking.name == parentSkillLineName) then
				HeroProfiles.professions.cooking.levels = levels
			elseif (HeroProfiles.professions.fishing.name == parentSkillLineName) then
				HeroProfiles.professions.fishing.levels = levels
			end
		end
	end
	
end)