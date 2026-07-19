local addonName, _ = ...

-- Global table for SavedVariables
WhysperConfig = WhysperConfig or {}

local frame = CreateFrame("Frame")
local guildMembers = {}
local replyCooldowns = {}

-- Rebuild the local guild cache whenever the roster updates
local function UpdateGuildRoster()
    wipe(guildMembers)
    if IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local name = GetGuildRosterInfo(i)
            if name then
                guildMembers[name] = true
                local shortName = string.match(name, "(.*)-")
                if shortName then
                    guildMembers[shortName] = true
                end
            end
        end
    end
end

-- Determine the most specific category for the sender
local function GetSenderCategory(sender, guid)
    if guid then
        if C_FriendList.IsFriend(guid) then return "friend" end
        local bnetInfo = C_BattleNet.GetAccountInfoByGUID(guid)
        if bnetInfo and bnetInfo.isFriend then return "friend" end
    end

    local senderShort = string.match(sender, "(.*)-") or sender
    if guildMembers[sender] or guildMembers[senderShort] then return "guildie" end
    if UnitInRaid(sender) or UnitInRaid(senderShort) then return "raid" end
    if UnitInParty(sender) or UnitInParty(senderShort) then return "party" end

    return "stranger"
end

-- Initialize default settings on load
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        local defaults = {
            allowFriends = true,
            allowGuildies = true,
            allowParty = true,
            allowRaid = true,
            allowStrangers = false,
            sendIgnoredMessage = false
        }
        for k, v in pairs(defaults) do
            if WhysperConfig[k] == nil then
                WhysperConfig[k] = v
            end
        end
    elseif event == "PLAYER_LOGIN" then
        if IsInGuild() then C_GuildInfo.GuildRoster() end
    elseif event == "GUILD_ROSTER_UPDATE" then
        UpdateGuildRoster()
    end
end)

-- The whisper filter hook
local function FilterIncomingWhispers(self, event, msg, sender, language, channelString, target, flags, zoneID, channelNumber, channelName, unused, lineID, guid)
    if flags == "GM" or flags == "DEV" then return false end
    local myName = UnitName("player")
    local senderShort = string.match(sender, "(.*)-") or sender
    if sender == myName or senderShort == myName then return false end

    local category = GetSenderCategory(sender, guid)
    local isAllowed = false

    if category == "friend" then
        isAllowed = WhysperConfig.allowFriends
    elseif category == "guildie" then
        isAllowed = WhysperConfig.allowGuildies
    elseif category == "raid" then
        isAllowed = WhysperConfig.allowRaid
    elseif category == "party" then
        isAllowed = WhysperConfig.allowParty
    elseif category == "stranger" then
        isAllowed = WhysperConfig.allowStrangers
    end

    if not isAllowed then
        if WhysperConfig.sendIgnoredMessage then
            local now = GetTime()
            if not replyCooldowns[sender] or (now - replyCooldowns[sender] > 10) then
                replyCooldowns[sender] = now
                SendChatMessage("You are currently being ignored by the user.", "WHISPER", nil, sender)
            end
        end
        return true
    end
    return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", FilterIncomingWhispers)

----------------------------------------
-- Addon Options Menu (Settings API)
----------------------------------------
local optionsFrame = CreateFrame("Frame", "WhysperOptionsFrame", UIParent)
optionsFrame.name = "Whysper"

local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Whysper Configuration")

local function CreateCheckbox(label, yOffset, configKey, parentNode)
    local cb = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
    if parentNode then
        cb:SetPoint("TOPLEFT", parentNode, "BOTTOMLEFT", 0, yOffset)
    else
        cb:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, yOffset)
    end

    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    cb.text:SetText(label)

    cb:SetScript("OnShow", function(self)
        self:SetChecked(WhysperConfig[configKey])
    end)

    cb:SetScript("OnClick", function(self)
        WhysperConfig[configKey] = self:GetChecked()
    end)

    return cb
end

local cbFriends = CreateCheckbox("Allow whispers from friends", -20, "allowFriends", nil)
local cbGuild = CreateCheckbox("Allow whispers from guildies", -10, "allowGuildies", cbFriends)
local cbParty = CreateCheckbox("Allow whispers from party members", -10, "allowParty", cbGuild)
local cbRaid = CreateCheckbox("Allow whispers from raid members", -10, "allowRaid", cbParty)
local cbStrangers = CreateCheckbox("Allow whispers from strangers", -10, "allowStrangers", cbRaid)
local cbReply = CreateCheckbox("Send ignored message to blocked senders", -30, "sendIgnoredMessage", cbStrangers)

-- Register the options frame into the modern WoW Settings menu
local category = Settings.RegisterCanvasLayoutCategory(optionsFrame, "Whysper")
Settings.RegisterAddOnCategory(category)

----------------------------------------
-- Slash Commands
----------------------------------------
SLASH_WHYSPER1 = "/why"
SlashCmdList["WHYSPER"] = function(msg)
    local cmd = msg:lower():match("^%s*(%w+)")

    if cmd == "menu" or cmd == "config" or cmd == "settings" then
        Settings.OpenToCategory(category:GetID())
    elseif cmd == "stranger" then
        WhysperConfig.allowStrangers = not WhysperConfig.allowStrangers
        print("Whysper - Strangers: " .. (WhysperConfig.allowStrangers and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "friend" then
        WhysperConfig.allowFriends = not WhysperConfig.allowFriends
        print("Whysper - Friends: " .. (WhysperConfig.allowFriends and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "guild" then
        WhysperConfig.allowGuildies = not WhysperConfig.allowGuildies
        print("Whysper - Guildies: " .. (WhysperConfig.allowGuildies and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "party" then
        WhysperConfig.allowParty = not WhysperConfig.allowParty
        print("Whysper - Party: " .. (WhysperConfig.allowParty and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "raid" then
        WhysperConfig.allowRaid = not WhysperConfig.allowRaid
        print("Whysper - Raid: " .. (WhysperConfig.allowRaid and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "reply" then
        WhysperConfig.sendIgnoredMessage = not WhysperConfig.sendIgnoredMessage
        print("Whysper - Auto-reply: " .. (WhysperConfig.sendIgnoredMessage and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    else
        print("|cffffff00Whysper Commands:|r")
        print("/why menu     - Open the Interface Settings panel")
        print("/why stranger - Toggle stranger whispers")
        print("/why friend   - Toggle friend whispers")
        print("/why guild    - Toggle guild whispers")
        print("/why party    - Toggle party whispers")
        print("/why raid     - Toggle raid whispers")
        print("/why reply    - Toggle auto-reply to blocked users")
    end
end
