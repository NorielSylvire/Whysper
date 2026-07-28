-- Whysper RealmBlacklist.lua
-- Realm blacklist feature for blocking whispers from specific realms

local addonName, ns = ...

-- =========================================================
-- REALM DATA BY REGION
-- =========================================================
-- Region IDs: 1 = US, 2 = Korea, 3 = Europe, 4 = Taiwan, 5 = China

local RealmsByRegion = {
    [1] = { -- US/Oceanic/Latin America
        "Aegwynn", "Aerie Peak", "Agamaggan", "Aggramar", "Akama", "Alexstrasza", "Alleria",
        "Altar of Storms", "Alterac Mountains", "Aman'Thul", "Andorhal", "Anetheron",
        "Antonidas", "Anub'arak", "Anvilmar", "Arathor", "Archimonde", "Area 52", "Argent Dawn",
        "Arthas", "Arygos", "Auchindoun", "Azgalor", "Azjol-Nerub", "Azralon", "Azshara",
        "Azuremyst", "Baelgun", "Balnazzar", "Barthilas", "Black Dragonflight", "Blackhand",
        "Blackrock", "Blackwater Raiders", "Blackwing Lair", "Blade's Edge", "Bladefist",
        "Bleeding Hollow", "Blood Furnace", "Bloodhoof", "Bloodscalp", "Bonechewer",
        "Borean Tundra", "Boulderfist", "Bronzebeard", "Burning Blade", "Burning Legion",
        "Caelestrasz", "Cairne", "Cenarion Circle", "Cenarius", "Cho'gall", "Chromaggus",
        "Coilfang", "Crushridge", "Daggerspine", "Dalaran", "Dalvengyr", "Dark Iron",
        "Darkspear", "Darrowmere", "Dath'Remar", "Dawnbringer", "Deathwing", "Demon Soul",
        "Dentarg", "Destromath", "Dethecus", "Detheroc", "Doomhammer", "Draenor", "Dragonblight",
        "Dragonmaw", "Drak'Tharon", "Drak'thul", "Draka", "Drakkari", "Dreadmaul", "Drenden",
        "Dunemaul", "Durotan", "Duskwood", "Earthen Ring", "Echo Isles", "Eitrigg", "Eldre'Thalas",
        "Elune", "Emerald Dream", "Eonar", "Eredar", "Executus", "Exodar", "Farstriders",
        "Feathermoon", "Fenris", "Firetree", "Fizzcrank", "Frostmane", "Frostmourne", "Frostwolf",
        "Galakrond", "Gallywix", "Garithos", "Garona", "Garrosh", "Ghostlands", "Gilneas",
        "Gnomeregan", "Goldrinn", "Gorefiend", "Gorgonnash", "Greymane", "Grizzly Hills",
        "Gul'dan", "Gundrak", "Gurubashi", "Hakkar", "Haomarush", "Hellscream", "Hydraxis",
        "Hyjal", "Icecrown", "Illidan", "Jaedenar", "Jubei'Thos", "Kael'thas", "Kalecgos",
        "Kargath", "Kel'Thuzad", "Khadgar", "Khaz Modan", "Khaz'goroth", "Kil'jaeden",
        "Kilrogg", "Kirin Tor", "Korgath", "Korialstrasz", "Kul Tiras", "Laughing Skull",
        "Lethon", "Lightbringer", "Lightning's Blade", "Lightninghoof", "Llane", "Lothar",
        "Madoran", "Maelstrom", "Magtheridon", "Maiev", "Mal'Ganis", "Malfurion", "Malorne",
        "Malygos", "Mannoroth", "Medivh", "Misha", "Mok'Nathal", "Moon Guard", "Moonrunner",
        "Muradin", "Nagrand", "Nathrezim", "Nazgrel", "Nazjatar", "Nemesis", "Ner'zhul",
        "Nesingwary", "Nordrassil", "Norgannon", "Onyxia", "Perenolde", "Proudmoore",
        "Quel'Thalas", "Quel'dorei", "Ragnaros", "Ravencrest", "Ravenholdt", "Rexxar", "Rivendare",
        "Runetotem", "Sargeras", "Saurfang", "Scarlet Crusade", "Scilla", "Sen'jin", "Sentinels",
        "Shadow Council", "Shadowmoon", "Shadowsong", "Shandris", "Shattered Halls",
        "Shattered Hand", "Shu'halo", "Silver Hand", "Silvermoon", "Sisters of Elune", "Skullcrusher",
        "Skywall", "Smolderthorn", "Spinebreaker", "Spirestone", "Staghelm", "Steamwheedle Cartel",
        "Stonemaul", "Stormrage", "Stormreaver", "Stormscale", "Suramar", "Tanaris", "Terenas",
        "Terokkar", "Thaurissan", "The Forgotten Coast", "The Scryers", "The Underbog",
        "The Venture Co", "Thorium Brotherhood", "Thrall", "Thunderhorn", "Thunderlord",
        "Tichondrius", "Tol Barad", "Tortheldrin", "Trollbane", "Turalyon", "Twisting Nether",
        "Uldaman", "Uldum", "Undermine", "Ursin", "Uther", "Vashj", "Vek'nilash", "Velen",
        "Warsong", "Whisperwind", "Wildhammer", "Windrunner", "Winterhoof", "Wyrmrest Accord",
        "Ysera", "Ysondre", "Zangarmarsh", "Zul'jin", "Zuluhed",
    },
    [2] = { -- Korea
        "Alexstrasza", "Azshara", "Burning Legion", "Cenarius", "Dalaran", "Deathwing",
        "Durotan", "Garona", "Gul'dan", "Hellscream", "Hyjal", "Malfurion", "Norgannon",
        "Ragnaros", "Rexxar", "Stormrage", "Wildhammer", "Windrunner", "Zul'jin",
    },
    [3] = { -- Europe
        "Aegwynn", "Aerie Peak", "Agamaggan", "Aggra", "Aggramar", "Ahn'Qiraj", "Al'Akir",
        "Alexstrasza", "Alleria", "Alonsus", "Aman'Thul", "Ambossar", "Anachronos",
        "Anetheron", "Antonidas", "Anub'arak", "Arak-arahm", "Arathi", "Arathor", "Archimonde",
        "Area 52", "Argent Dawn", "Arthas", "Arygos", "Aszune", "Auchindoun", "Azjol-Nerub",
        "Azshara", "Azuremyst", "Baelgun", "Balnazzar", "Blackhand", "Blackmoore", "Blackrock",
        "Blackscar", "Blade's Edge", "Bladefist", "Bloodfeather", "Bloodhoof", "Bloodscalp",
        "Blutkessel", "Booty Bay", "Borean Tundra", "Boulderfist", "Bronze Dragonflight",
        "Bronzebeard", "Burning Blade", "Burning Legion", "Burning Steppes", "C'Thun",
        "Chamber of Aspects", "Chants éternels", "Cho'gall", "Chromaggus", "Colinas Pardas",
        "Confrérie du Thorium", "Conseil des Ombres", "Crushridge", "Culte de la Rive noire",
        "Daggerspine", "Dalaran", "Dalvengyr", "Darkmoon Faire", "Darksorrow", "Darkspear",
        "Das Konsortium", "Das Syndikat", "Deathguard", "Deathweaver", "Deathwing", "Deepholm",
        "Defias Brotherhood", "Dentarg", "Der Mithrilorden", "Der Rat von Dalaran", "Der abyssische Rat",
        "Destromath", "Dethecus", "Die Aldor", "Die Arguswacht", "Die Nachtwache", "Die Silberne Hand",
        "Die Todeskrallen", "Die ewige Wacht", "Doomhammer", "Draenor", "Dragonblight",
        "Dragonmaw", "Drak'thul", "Drek'Thar", "Dun Modr", "Dun Morogh", "Dunemaul", "Durotan",
        "Earthen Ring", "Echsenkessel", "Eitrigg", "Eldre'Thalas", "Elune", "Emerald Dream",
        "Emeriss", "Eonar", "Eredar", "Executus", "Exodar", "Festung der Stürme", "Fordragon",
        "Forscherliga", "Frostmane", "Frostmourne", "Frostwhisper", "Frostwolf", "Galakrond",
        "Garona", "Garrosh", "Genjuros", "Ghostlands", "Gilneas", "Goldrinn", "Gordunni",
        "Gorgonnash", "Greymane", "Grim Batol", "Grom", "Gruul", "Gul'dan", "Hakkar",
        "Haomarush", "Hellfire", "Hellscream", "Howling Fjord", "Hyjal", "Illidan", "Jaedenar",
        "Kael'thas", "Karazhan", "Kargath", "Kazzak", "Kel'Thuzad", "Khadgar", "Khaz Modan",
        "Khaz'goroth", "Kil'jaeden", "Kilrogg", "Kirin Tor", "Kor'gall", "Krag'jin", "Krasus",
        "Kul Tiras", "Kult der Verdammten", "La Croisade écarlate", "Laughing Skull", "Les Clairvoyants",
        "Les Sentinelles", "Lich King", "Lightbringer", "Lightning's Blade", "Lordaeron",
        "Los Errantes", "Lothar", "Madmortem", "Magtheridon", "Mal'Ganis", "Malfurion", "Malorne",
        "Malygos", "Mannoroth", "Marécage de Zangar", "Mazrigos", "Medivh", "Minahonda",
        "Moonglade", "Mug'thol", "Nagrand", "Nathrezim", "Naxxramas", "Nazjatar", "Nefarian",
        "Nemesis", "Neptulon", "Ner'zhul", "Nera'thor", "Nethersturm", "Nordrassil", "Norgannon",
        "Nozdormu", "Onyxia", "Outland", "Perenolde", "Pozzo dell'Eternità", "Proudmoore",
        "Quel'Thalas", "Ragnaros", "Rajaxx", "Rashgarroth", "Ravencrest", "Ravenholdt", "Razuvious",
        "Rexxar", "Runetotem", "Sanguino", "Sargeras", "Saurfang", "Scarshield Legion",
        "Sen'jin", "Shadowsong", "Shattered Halls", "Shattered Hand", "Shattrath", "Shen'dralar",
        "Silvermoon", "Sinstralis", "Skullcrusher", "Soulflayer", "Spinebreaker", "Sporeggar",
        "Steamwheedle Cartel", "Stormrage", "Stormreaver", "Stormscale", "Sunstrider", "Suramar",
        "Sylvanas", "Taerar", "Talnivarr", "Tarren Mill", "Teldrassil", "Temple noir", "Terenas",
        "Terokkar", "Terrordar", "The Maelstrom", "The Sha'tar", "The Venture Co", "Theradras",
        "Thrall", "Throk'Feroth", "Thunderhorn", "Tichondrius", "Tirion", "Todeswache",
        "Trollbane", "Turalyon", "Twilight's Hammer", "Twisting Nether", "Tyrande", "Uldaman",
        "Ulduar", "Uldum", "Un'Goro", "Varimathras", "Vashj", "Vek'lor", "Vek'nilash", "Vol'jin",
        "Wildhammer", "Wrathbringer", "Xavius", "Ysera", "Ysondre", "Zenedar", "Zirkel des Cenarius",
        "Zul'jin", "Zuluhed",
    },
    [4] = { -- Taiwan
        "Arthas", "Arygos", "Bleeding Hollow", "Chillwind Point", "Crystalpine Stinger",
        "Demon Fall Canyon", "Dragonmaw", "Frostmane", "Hellscream", "Icecrown", "Light's Hope",
        "Menethil", "Nightsong", "Order of the Cloud Serpent", "Quel'dorei", "Shadowmoon",
        "Silverwing Hold", "Skywall", "Spirestone", "Stormscale", "Sundown Marsh", "Whisperwind",
        "World Tree", "Wrathbringer", "Zealot Blade",
    },
    [5] = { -- China
        -- China has many realms; these are representative examples
        "Bladestorm", "Burning Plain", "Darkstorm", "Demon", "Frostmourne", "Golden Plain",
        "Greymane", "Illidan", "Lordaeron", "Proudmoore", "Ragnaros", "Shadowmoon",
        "Silvermoon", "Stormwind", "The Great Sea", "Thunderhorn", "Tirisfal",
    },
}

-- Region names for display
local RegionNames = {
    [1] = "US/Oceanic/Latin America",
    [2] = "Korea",
    [3] = "Europe",
    [4] = "Taiwan",
    [5] = "China",
}

-- =========================================================
-- LANGUAGE DATA
-- =========================================================
-- Maps realms to their primary language (mainly relevant for EU)
-- Realms not listed default to English

local RealmLanguages = {
    -- German realms (EU)
    ["Aegwynn"] = "German",
    ["Alexstrasza"] = "German",
    ["Alleria"] = "German",
    ["Ambossar"] = "German",
    ["Antonidas"] = "German",
    ["Anub'arak"] = "German",
    ["Aman'Thul"] = "German",
    ["Arthas"] = "German",
    ["Arygos"] = "German",
    ["Azshara"] = "German",
    ["Baelgun"] = "German",
    ["Blackhand"] = "German",
    ["Blackmoore"] = "German",
    ["Blackrock"] = "German",
    ["Blutkessel"] = "German",
    ["Das Konsortium"] = "German",
    ["Das Syndikat"] = "German",
    ["Der Mithrilorden"] = "German",
    ["Der Rat von Dalaran"] = "German",
    ["Der abyssische Rat"] = "German",
    ["Destromath"] = "German",
    ["Dethecus"] = "German",
    ["Die Aldor"] = "German",
    ["Die Arguswacht"] = "German",
    ["Die Nachtwache"] = "German",
    ["Die Silberne Hand"] = "German",
    ["Die Todeskrallen"] = "German",
    ["Die ewige Wacht"] = "German",
    ["Dun Morogh"] = "German",
    ["Durotan"] = "German",
    ["Echsenkessel"] = "German",
    ["Eredar"] = "German",
    ["Festung der Stürme"] = "German",
    ["Forscherliga"] = "German",
    ["Frostwolf"] = "German",
    ["Garrosh"] = "German",
    ["Gilneas"] = "German",
    ["Gorgonnash"] = "German",
    ["Gul'dan"] = "German",
    ["Kargath"] = "German",
    ["Kel'Thuzad"] = "German",
    ["Khaz'goroth"] = "German",
    ["Kil'jaeden"] = "German",
    ["Krag'jin"] = "German",
    ["Kult der Verdammten"] = "German",
    ["Lordaeron"] = "German",
    ["Lothar"] = "German",
    ["Madmortem"] = "German",
    ["Mal'Ganis"] = "German",
    ["Malfurion"] = "German",
    ["Malorne"] = "German",
    ["Malygos"] = "German",
    ["Mannoroth"] = "German",
    ["Nazjatar"] = "German",
    ["Nefarian"] = "German",
    ["Nera'thor"] = "German",
    ["Nethersturm"] = "German",
    ["Norgannon"] = "German",
    ["Nozdormu"] = "German",
    ["Perenolde"] = "German",
    ["Proudmoore"] = "German",
    ["Rajaxx"] = "German",
    ["Rexxar"] = "German",
    ["Sen'jin"] = "German",
    ["Shattrath"] = "German",
    ["Taerar"] = "German",
    ["Teldrassil"] = "German",
    ["Terrordar"] = "German",
    ["Theradras"] = "German",
    ["Thrall"] = "German",
    ["Tichondrius"] = "German",
    ["Tirion"] = "German",
    ["Todeswache"] = "German",
    ["Ulduar"] = "German",
    ["Un'Goro"] = "German",
    ["Vek'lor"] = "German",
    ["Wrathbringer"] = "German",
    ["Zirkel des Cenarius"] = "German",
    ["Zuluhed"] = "German",

    -- French realms (EU)
    ["Arak-arahm"] = "French",
    ["Arathi"] = "French",
    ["Archimonde"] = "French",
    ["Chants éternels"] = "French",
    ["Cho'gall"] = "French",
    ["Confrérie du Thorium"] = "French",
    ["Conseil des Ombres"] = "French",
    ["Culte de la Rive noire"] = "French",
    ["Dalaran"] = "French",
    ["Drek'Thar"] = "French",
    ["Eitrigg"] = "French",
    ["Eldre'Thalas"] = "French",
    ["Elune"] = "French",
    ["Garona"] = "French",
    ["Hyjal"] = "French",
    ["Illidan"] = "French",
    ["Kael'thas"] = "French",
    ["Khaz Modan"] = "French",
    ["Kirin Tor"] = "French",
    ["Krasus"] = "French",
    ["La Croisade écarlate"] = "French",
    ["Les Clairvoyants"] = "French",
    ["Les Sentinelles"] = "French",
    ["Marécage de Zangar"] = "French",
    ["Medivh"] = "French",
    ["Naxxramas"] = "French",
    ["Ner'zhul"] = "French",
    ["Rashgarroth"] = "French",
    ["Sargeras"] = "French",
    ["Sinstralis"] = "French",
    ["Suramar"] = "French",
    ["Temple noir"] = "French",
    ["Throk'Feroth"] = "French",
    ["Uldaman"] = "French",
    ["Varimathras"] = "French",
    ["Vol'jin"] = "French",
    ["Ysondre"] = "French",

    -- Spanish realms (EU)
    ["C'Thun"] = "Spanish",
    ["Colinas Pardas"] = "Spanish",
    ["Dun Modr"] = "Spanish",
    ["Exodar"] = "Spanish",
    ["Los Errantes"] = "Spanish",
    ["Minahonda"] = "Spanish",
    ["Sanguino"] = "Spanish",
    ["Shen'dralar"] = "Spanish",
    ["Tyrande"] = "Spanish",
    ["Uldum"] = "Spanish",
    ["Zul'jin"] = "Spanish",

    -- Italian realms (EU)
    ["Pozzo dell'Eternità"] = "Italian",
    ["Nemesis"] = "Italian",

    -- Russian realms (EU)
    ["Blackscar"] = "Russian",
    ["Booty Bay"] = "Russian",
    ["Deathguard"] = "Russian",
    ["Deathweaver"] = "Russian",
    ["Deepholm"] = "Russian",
    ["Fordragon"] = "Russian",
    ["Galakrond"] = "Russian",
    ["Grom"] = "Russian",
    ["Gordunni"] = "Russian",
    ["Greymane"] = "Russian",
    ["Howling Fjord"] = "Russian",
    ["Lich King"] = "Russian",
    ["Razuvious"] = "Russian",
    ["Soulflayer"] = "Russian",
    ["Thermaplugg"] = "Russian",

    -- Portuguese (Brazil) realms (US)
    ["Azralon"] = "Portuguese",
    ["Gallywix"] = "Portuguese",
    ["Goldrinn"] = "Portuguese",
    ["Nemesis"] = "Portuguese",
    ["Tol Barad"] = "Portuguese",

    -- Latin American Spanish realms (US)
    ["Drakkari"] = "Spanish",
    ["Quel'Thalas"] = "Spanish",
    ["Ragnaros"] = "Spanish",
}

-- Available languages by region
local LanguagesByRegion = {
    [1] = { "English", "Portuguese", "Spanish" }, -- US
    [2] = { "Korean" }, -- Korea
    [3] = { "English", "French", "German", "Italian", "Russian", "Spanish" }, -- Europe
    [4] = { "Chinese" }, -- Taiwan
    [5] = { "Chinese" }, -- China
}

-- Current language filter (nil = no filter)
local selectedLanguageFilter = nil

-- Get the language of a realm (defaults to region's primary language)
local function GetRealmLanguage(realm, regionID)
    if RealmLanguages[realm] then
        return RealmLanguages[realm]
    end
    -- Default language by region
    if regionID == 1 then return "English" end
    if regionID == 2 then return "Korean" end
    if regionID == 3 then return "English" end
    if regionID == 4 then return "Chinese" end
    if regionID == 5 then return "Chinese" end
    return "English"
end

-- =========================================================
-- UTILITY FUNCTIONS
-- =========================================================

-- Extract realm name from a full player name (e.g., "PlayerName-RealmName")
local function GetRealmFromName(fullName)
    if not fullName then return nil end
    local realm = string.match(fullName, "%-(.+)$")
    return realm
end

-- Normalize realm name for comparison (remove spaces, apostrophes, etc.)
local function NormalizeRealmName(realm)
    if not realm then return nil end
    -- WoW removes spaces and special characters from realm names in player names
    return realm:gsub("%s", ""):gsub("'", "")
end

-- Check if a realm is in the blacklist
local function IsRealmBlacklisted(realm)
    if not realm or not WhysperConfig.realmBlacklist then return false end
    local normalized = NormalizeRealmName(realm)
    for _, blacklistedRealm in ipairs(WhysperConfig.realmBlacklist) do
        if NormalizeRealmName(blacklistedRealm) == normalized then
            return true
        end
    end
    return false
end

-- Export the check function to the namespace for core.lua to use
ns.IsRealmBlacklisted = IsRealmBlacklisted
ns.GetRealmFromName = GetRealmFromName

-- =========================================================
-- DROPDOWN MENU (Scrollable)
-- =========================================================

local DROPDOWN_MAX_VISIBLE = 20
local DROPDOWN_BUTTON_HEIGHT = 16

local function GetAvailableRealms()
    local regionID = GetCurrentRegion()
    local realms = RealmsByRegion[regionID] or {}
    local available = {}

    for _, realm in ipairs(realms) do
        if not IsRealmBlacklisted(realm) then
            -- Apply language filter if set
            if selectedLanguageFilter then
                local realmLang = GetRealmLanguage(realm, regionID)
                if realmLang == selectedLanguageFilter then
                    table.insert(available, realm)
                end
            else
                table.insert(available, realm)
            end
        end
    end

    table.sort(available)
    return available
end

local function AddRealmToBlacklist(realm)
    if not WhysperConfig.realmBlacklist then
        WhysperConfig.realmBlacklist = {}
    end

    -- Check if already in blacklist
    if not IsRealmBlacklisted(realm) then
        table.insert(WhysperConfig.realmBlacklist, realm)
        table.sort(WhysperConfig.realmBlacklist)
        print("|cff00ff00Whysper:|r Added |cffff8000" .. realm .. "|r to realm blacklist.")
    end
end

local function RemoveRealmFromBlacklist(realm)
    if not WhysperConfig.realmBlacklist then return end

    local normalized = NormalizeRealmName(realm)
    for i, blacklistedRealm in ipairs(WhysperConfig.realmBlacklist) do
        if NormalizeRealmName(blacklistedRealm) == normalized then
            table.remove(WhysperConfig.realmBlacklist, i)
            print("|cff00ff00Whysper:|r Removed |cffff8000" .. blacklistedRealm .. "|r from realm blacklist.")
            return
        end
    end
end

-- Custom scrollable dropdown frame
local dropdownFrame = CreateFrame("Frame", "WhysperRealmDropdown", UIParent, "UIDropDownMenuTemplate")
local scrollListFrame = nil

local function HideScrollList()
    if scrollListFrame then
        scrollListFrame:Hide()
    end
end

local function ShowScrollList(anchorFrame)
    if not scrollListFrame then
        -- Create the scrollable list frame
        scrollListFrame = CreateFrame("Frame", "WhysperRealmScrollList", UIParent, "BackdropTemplate")
        scrollListFrame:SetFrameStrata("DIALOG")
        scrollListFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        scrollListFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)

        -- Scroll frame (may be hidden if not needed)
        local scrollFrame = CreateFrame("ScrollFrame", "WhysperRealmScrollFrame", scrollListFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 8, -8)
        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

        -- Scroll child
        local scrollChild = CreateFrame("Frame", "WhysperRealmScrollChild", scrollFrame)
        scrollChild:SetSize(180, 1) -- Height will be set dynamically
        scrollFrame:SetScrollChild(scrollChild)

        scrollListFrame.scrollFrame = scrollFrame
        scrollListFrame.scrollChild = scrollChild
        scrollListFrame.buttons = {}

        -- Close when clicking elsewhere
        scrollListFrame:SetScript("OnHide", function()
            -- Clean up buttons
            for _, btn in ipairs(scrollListFrame.buttons) do
                btn:Hide()
            end
        end)
    end

    -- Position below the dropdown
    scrollListFrame:ClearAllPoints()
    scrollListFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 15, 0)

    -- Populate with realms
    local availableRealms = GetAvailableRealms()
    local scrollChild = scrollListFrame.scrollChild
    local scrollFrame = scrollListFrame.scrollFrame

    -- Hide existing buttons
    for _, btn in ipairs(scrollListFrame.buttons) do
        btn:Hide()
    end

    -- Determine if we need scrolling
    local numItems = math.max(1, #availableRealms)
    local needsScroll = numItems > DROPDOWN_MAX_VISIBLE
    local visibleItems = needsScroll and DROPDOWN_MAX_VISIBLE or numItems
    local frameHeight = visibleItems * DROPDOWN_BUTTON_HEIGHT + 16

    -- Adjust frame size and scroll frame visibility
    scrollListFrame:SetSize(220, frameHeight)
    if needsScroll then
        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
        _G["WhysperRealmScrollFrameScrollBar"]:Show()
    else
        scrollFrame:SetPoint("BOTTOMRIGHT", -8, 8)
        _G["WhysperRealmScrollFrameScrollBar"]:Hide()
    end

    if #availableRealms == 0 then
        -- Create or reuse a button for "No realms available"
        local btn = scrollListFrame.buttons[1]
        if not btn then
            btn = CreateFrame("Button", nil, scrollChild)
            btn:SetHeight(DROPDOWN_BUTTON_HEIGHT)
            btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
            btn.text:SetPoint("LEFT", 5, 0)
            scrollListFrame.buttons[1] = btn
        end
        btn:SetPoint("TOPLEFT", 0, 0)
        btn:SetPoint("TOPRIGHT", 0, 0)
        btn.text:SetText("No realms available")
        btn.text:SetFontObject("GameFontDisableSmall")
        btn:SetScript("OnClick", nil)
        btn:Show()
        scrollChild:SetHeight(DROPDOWN_BUTTON_HEIGHT)
    else
        local yOffset = 0
        for i, realm in ipairs(availableRealms) do
            local btn = scrollListFrame.buttons[i]
            if not btn then
                btn = CreateFrame("Button", nil, scrollChild)
                btn:SetHeight(DROPDOWN_BUTTON_HEIGHT)
                btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                btn.text:SetPoint("LEFT", 5, 0)
                btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
                scrollListFrame.buttons[i] = btn
            end
            btn:SetPoint("TOPLEFT", 0, yOffset)
            btn:SetPoint("TOPRIGHT", 0, yOffset)
            btn.text:SetText(realm)
            btn.text:SetFontObject("GameFontHighlightSmall")
            btn:SetScript("OnClick", function()
                AddRealmToBlacklist(realm)
                HideScrollList()
                if ns.RefreshBlacklistDisplay then
                    ns.RefreshBlacklistDisplay()
                end
            end)
            btn:Show()
            yOffset = yOffset - DROPDOWN_BUTTON_HEIGHT
        end
        scrollChild:SetHeight(#availableRealms * DROPDOWN_BUTTON_HEIGHT)
    end

    scrollListFrame:Show()
end

-- Toggle the scroll list when dropdown button is clicked
local function InitializeRealmDropdown(self, level, menuList)
    -- We override the dropdown behavior entirely
end

UIDropDownMenu_Initialize(dropdownFrame, InitializeRealmDropdown)
UIDropDownMenu_SetWidth(dropdownFrame, 200)
UIDropDownMenu_SetText(dropdownFrame, "Select a realm to blacklist")

-- Hook the dropdown button to show our custom scroll list
-- Note: We'll update this after languageScrollListFrame is defined
local dropdownButton = _G["WhysperRealmDropdownButton"]

-- Close scroll list when clicking elsewhere
local closeChecker = CreateFrame("Frame")
closeChecker:RegisterEvent("GLOBAL_MOUSE_DOWN")
closeChecker:SetScript("OnEvent", function(self, event)
    if scrollListFrame and scrollListFrame:IsShown() then
        if not scrollListFrame:IsMouseOver() and not dropdownFrame:IsMouseOver() then
            HideScrollList()
        end
    end
    if languageScrollListFrame and languageScrollListFrame:IsShown() then
        if not languageScrollListFrame:IsMouseOver() and not languageDropdownFrame:IsMouseOver() then
            HideLanguageScrollList()
        end
    end
end)

-- =========================================================
-- LANGUAGE DROPDOWN (Scrollable)
-- =========================================================

local languageDropdownFrame = CreateFrame("Frame", "WhysperLanguageDropdown", UIParent, "UIDropDownMenuTemplate")
local languageScrollListFrame = nil

local function HideLanguageScrollList()
    if languageScrollListFrame then
        languageScrollListFrame:Hide()
    end
end

local function ShowLanguageScrollList(anchorFrame)
    if not languageScrollListFrame then
        -- Create the scrollable list frame
        languageScrollListFrame = CreateFrame("Frame", "WhysperLanguageScrollList", UIParent, "BackdropTemplate")
        languageScrollListFrame:SetFrameStrata("DIALOG")
        languageScrollListFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        languageScrollListFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)

        -- Scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", "WhysperLanguageScrollFrame", languageScrollListFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 8, -8)
        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

        -- Scroll child
        local scrollChild = CreateFrame("Frame", "WhysperLanguageScrollChild", scrollFrame)
        scrollChild:SetSize(140, 1) -- Height will be set dynamically
        scrollFrame:SetScrollChild(scrollChild)

        languageScrollListFrame.scrollFrame = scrollFrame
        languageScrollListFrame.scrollChild = scrollChild
        languageScrollListFrame.buttons = {}

        -- Close when clicking elsewhere
        languageScrollListFrame:SetScript("OnHide", function()
            for _, btn in ipairs(languageScrollListFrame.buttons) do
                btn:Hide()
            end
        end)
    end

    -- Position below the dropdown
    languageScrollListFrame:ClearAllPoints()
    languageScrollListFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 15, 0)

    -- Get available languages for this region
    local regionID = GetCurrentRegion()
    local languages = LanguagesByRegion[regionID] or { "English" }
    local scrollChild = languageScrollListFrame.scrollChild
    local scrollFrame = languageScrollListFrame.scrollFrame

    -- Hide existing buttons
    for _, btn in ipairs(languageScrollListFrame.buttons) do
        btn:Hide()
    end

    -- Determine if we need scrolling (languages + 1 for "None" option)
    local numItems = #languages + 1
    local needsScroll = numItems > 10
    local visibleItems = needsScroll and 10 or numItems
    local frameHeight = visibleItems * DROPDOWN_BUTTON_HEIGHT + 16

    -- Adjust frame size and scroll frame visibility
    languageScrollListFrame:SetSize(180, frameHeight)
    if needsScroll then
        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
        _G["WhysperLanguageScrollFrameScrollBar"]:Show()
    else
        scrollFrame:SetPoint("BOTTOMRIGHT", -8, 8)
        _G["WhysperLanguageScrollFrameScrollBar"]:Hide()
    end

    local yOffset = 0
    local buttonIndex = 1

    -- Add "None" option first
    local noneBtn = languageScrollListFrame.buttons[buttonIndex]
    if not noneBtn then
        noneBtn = CreateFrame("Button", nil, scrollChild)
        noneBtn:SetHeight(DROPDOWN_BUTTON_HEIGHT)
        noneBtn.text = noneBtn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        noneBtn.text:SetPoint("LEFT", 5, 0)
        noneBtn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        languageScrollListFrame.buttons[buttonIndex] = noneBtn
    end
    noneBtn:SetPoint("TOPLEFT", 0, yOffset)
    noneBtn:SetPoint("TOPRIGHT", 0, yOffset)
    noneBtn.text:SetText(selectedLanguageFilter == nil and "|cff00ff00None (All)|r" or "None (All)")
    noneBtn.text:SetFontObject("GameFontHighlightSmall")
    noneBtn:SetScript("OnClick", function()
        selectedLanguageFilter = nil
        UIDropDownMenu_SetText(languageDropdownFrame, "None (All)")
        HideLanguageScrollList()
    end)
    noneBtn:Show()
    yOffset = yOffset - DROPDOWN_BUTTON_HEIGHT
    buttonIndex = buttonIndex + 1

    -- Add language options
    for _, lang in ipairs(languages) do
        local btn = languageScrollListFrame.buttons[buttonIndex]
        if not btn then
            btn = CreateFrame("Button", nil, scrollChild)
            btn:SetHeight(DROPDOWN_BUTTON_HEIGHT)
            btn.text = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            btn.text:SetPoint("LEFT", 5, 0)
            btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
            languageScrollListFrame.buttons[buttonIndex] = btn
        end
        btn:SetPoint("TOPLEFT", 0, yOffset)
        btn:SetPoint("TOPRIGHT", 0, yOffset)
        btn.text:SetText(selectedLanguageFilter == lang and "|cff00ff00" .. lang .. "|r" or lang)
        btn.text:SetFontObject("GameFontHighlightSmall")
        btn:SetScript("OnClick", function()
            selectedLanguageFilter = lang
            UIDropDownMenu_SetText(languageDropdownFrame, lang)
            HideLanguageScrollList()
        end)
        btn:Show()
        yOffset = yOffset - DROPDOWN_BUTTON_HEIGHT
        buttonIndex = buttonIndex + 1
    end

    scrollChild:SetHeight(numItems * DROPDOWN_BUTTON_HEIGHT)

    languageScrollListFrame:Show()
end

-- Initialize language dropdown
local function InitializeLanguageDropdown(self, level, menuList)
    -- We override the dropdown behavior entirely
end

UIDropDownMenu_Initialize(languageDropdownFrame, InitializeLanguageDropdown)
UIDropDownMenu_SetWidth(languageDropdownFrame, 120)
UIDropDownMenu_SetText(languageDropdownFrame, "None (All)")

-- Hook the language dropdown button
local languageDropdownButton = _G["WhysperLanguageDropdownButton"]
if languageDropdownButton then
    languageDropdownButton:SetScript("OnClick", function(self)
        if languageScrollListFrame and languageScrollListFrame:IsShown() then
            HideLanguageScrollList()
        else
            HideScrollList() -- Close realm list if open
            ShowLanguageScrollList(languageDropdownFrame)
        end
    end)
end

-- Hook the realm dropdown button (now that HideLanguageScrollList is defined)
if dropdownButton then
    dropdownButton:SetScript("OnClick", function(self)
        if scrollListFrame and scrollListFrame:IsShown() then
            HideScrollList()
        else
            HideLanguageScrollList() -- Close language list if open
            ShowScrollList(dropdownFrame)
        end
    end)
end

-- =========================================================
-- OPTIONS UI INTEGRATION
-- =========================================================

local function CreateRealmBlacklistUI(parentFrame, anchorTo)
    -- Section header
    local header = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -30)
    header:SetText("Realm Blacklist")
    header:SetTextColor(1, 0.82, 0)

    -- Region info
    local regionID = GetCurrentRegion()
    local regionName = RegionNames[regionID] or "Unknown"

    local regionLabel = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    regionLabel:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    regionLabel:SetText("Your region: |cff00ff00" .. regionName .. "|r")

    -- Language filter dropdown
    local languageLabel = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    languageLabel:SetPoint("TOPLEFT", regionLabel, "BOTTOMLEFT", 0, -15)
    languageLabel:SetText("Filter by language:")

    languageDropdownFrame:SetParent(parentFrame)
    languageDropdownFrame:ClearAllPoints()
    languageDropdownFrame:SetPoint("TOPLEFT", languageLabel, "BOTTOMLEFT", -15, -5)

    -- Dropdown for adding realms (positioned to the right of language dropdown)
    local dropdownLabel = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    dropdownLabel:SetPoint("LEFT", languageLabel, "RIGHT", 130, 0)
    dropdownLabel:SetText("Add realm to blacklist:")

    -- Re-parent the dropdown to the options frame
    dropdownFrame:SetParent(parentFrame)
    dropdownFrame:ClearAllPoints()
    dropdownFrame:SetPoint("TOPLEFT", dropdownLabel, "BOTTOMLEFT", -15, -5)

    -- Blacklisted realms display
    local blacklistLabel = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    blacklistLabel:SetPoint("TOPLEFT", languageDropdownFrame, "BOTTOMLEFT", 15, -10)
    blacklistLabel:SetText("Blacklisted realms (click to remove):")

    -- Scrollable frame for blacklisted realms
    local scrollFrame = CreateFrame("ScrollFrame", nil, parentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(280, 100)
    scrollFrame:SetPoint("TOPLEFT", blacklistLabel, "BOTTOMLEFT", 0, -5)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(260, 100)
    scrollFrame:SetScrollChild(scrollChild)

    local realmButtons = {}

    local function RefreshBlacklistDisplay()
        -- Clear existing buttons
        for _, btn in ipairs(realmButtons) do
            btn:Hide()
            btn:SetParent(nil)
        end
        wipe(realmButtons)

        local blacklist = WhysperConfig.realmBlacklist or {}

        if #blacklist == 0 then
            local emptyText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
            emptyText:SetPoint("TOPLEFT", 5, -5)
            emptyText:SetText("No realms blacklisted")
            table.insert(realmButtons, emptyText)
        else
            local yOffset = -5
            for _, realm in ipairs(blacklist) do
                local btn = CreateFrame("Button", nil, scrollChild)
                btn:SetSize(250, 18)
                btn:SetPoint("TOPLEFT", 5, yOffset)

                local text = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                text:SetPoint("LEFT", 5, 0)
                text:SetText("|cffff6666x|r " .. realm)
                btn:SetFontString(text)

                btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

                btn:SetScript("OnClick", function()
                    RemoveRealmFromBlacklist(realm)
                    RefreshBlacklistDisplay()
                end)

                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText("Click to remove from blacklist", 1, 1, 1)
                    GameTooltip:Show()
                end)

                btn:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)

                table.insert(realmButtons, btn)
                yOffset = yOffset - 20
            end

            -- Adjust scroll child height
            scrollChild:SetHeight(math.max(100, #blacklist * 20 + 10))
        end

        -- Also refresh the dropdown text
        UIDropDownMenu_SetText(dropdownFrame, "Select a realm to blacklist")
    end

    -- Export refresh function
    ns.RefreshBlacklistDisplay = RefreshBlacklistDisplay

    -- Refresh on show
    parentFrame:HookScript("OnShow", RefreshBlacklistDisplay)

    -- Initial refresh
    RefreshBlacklistDisplay()

    return scrollFrame
end

-- Export the UI creation function
ns.CreateRealmBlacklistUI = CreateRealmBlacklistUI

-- =========================================================
-- SLASH COMMAND EXTENSIONS
-- =========================================================

ns.HandleRealmCommand = function(args)
    local cmd, realm = args:match("^(%S+)%s*(.*)$")
    cmd = cmd and cmd:lower() or ""

    if cmd == "add" and realm ~= "" then
        AddRealmToBlacklist(realm)
        return true
    elseif cmd == "remove" and realm ~= "" then
        RemoveRealmFromBlacklist(realm)
        return true
    elseif cmd == "list" then
        local blacklist = WhysperConfig.realmBlacklist or {}
        if #blacklist == 0 then
            print("|cff00ff00Whysper:|r No realms blacklisted.")
        else
            print("|cff00ff00Whysper:|r Blacklisted realms:")
            for _, r in ipairs(blacklist) do
                print("  - " .. r)
            end
        end
        return true
    elseif cmd == "clear" then
        WhysperConfig.realmBlacklist = {}
        print("|cff00ff00Whysper:|r Realm blacklist cleared.")
        return true
    end

    return false
end

ns.PrintRealmHelp = function()
    print("/why realm add <name>    - Add a realm to blacklist")
    print("/why realm remove <name> - Remove a realm from blacklist")
    print("/why realm list          - List blacklisted realms")
    print("/why realm clear         - Clear realm blacklist")
end
