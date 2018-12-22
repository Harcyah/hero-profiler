
HeroProfiles = {}

local function ExportProfession(index) 
	local name, _, skillLevel, maxSkillLevel, _, _, skillLine = GetProfessionInfo(index)
	
	Profession = {}
	Profession.name = name
	Profession.index = index
	Profession.skillLevel = skillLevel
	Profession.maxSkillLevel = maxSkillLevel
	Profession.skillLine = skillLine
	
	return Profession
end

local function PrintRecursive(prefix, var) 
	for k,v in pairs(var) do
		local t = type(v)
		local p = prefix .. '/' .. k
		
		if (t == 'string' or t == 'number') then
			print(p .. ' => ' .. v)
		end
		
		if (t == 'table') then
			PrintRecursive(p, v)
		end
    end
end

local function ExportProfiles() 
	HeroProfiles.name = UnitName("player")
	HeroProfiles.realm = GetRealmName()
	HeroProfiles.level = UnitLevel("player")
	HeroProfiles.money = GetMoney()
	HeroProfiles.heartstone = GetBindLocation()
	HeroProfiles.gender = UnitSex("player")
	
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
	
	local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
	
	HeroProfiles.professions = {}
	HeroProfiles.professions.prof1 = ExportProfession(prof1)
	HeroProfiles.professions.prof2 = ExportProfession(prof2)
	HeroProfiles.professions.archaeology = ExportProfession(archaeology)
	HeroProfiles.professions.fishing = ExportProfession(fishing)
	HeroProfiles.professions.cooking = ExportProfession(cooking)
	
	HeroProfiles.hasMasterRiding = tostring(IsSpellKnown(90265))
	
	local totalAchievements, completedAchievements = GetNumCompletedAchievements()
	HeroProfiles.totalAchievements = totalAchievements
	HeroProfiles.completedAchievements = completedAchievements
	HeroProfiles.totalAchievementPoints = GetTotalAchievementPoints()
	
	print('ExportProfiles OK')
	PrintRecursive('', HeroProfiles)
end

local function OnTimePlayedMsgEvent(event, totalTime, currentLevelTime)
	print('OnTimePlayedMsgEvent', totalTime, currentLevelTime)
	HeroProfiles.totalTime = totalTime
	HeroProfiles.currentLevelTime = currentLevelTime
end

SlashCmdList['HERO_PROFILER'] = function()
	ExportProfiles()
end

SLASH_HERO_PROFILER1 = '/heroprofiler'

local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:RegisterEvent("TIME_PLAYED_MSG");
frame:Hide();

frame:SetScript("OnEvent", function(self, event, ...)
	
	if (event == "TIME_PLAYED_MSG") then 
		OnTimePlayedMsgEvent(event)
	end

	if (event == "PLAYER_LOGIN") then
		ExportProfiles()
	end
	
	if (event == "PLAYER_LOGOUT") then
		ExportProfiles()
	end
	
end)