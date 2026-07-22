local addonName, _ = ...

-- Global table for SavedVariables
WhysperConfig = WhysperConfig or {}

local frame = CreateFrame("Frame")
local guildMembers = {}
local replyCooldowns = {}
local recentBlockedWhispers = {} -- Tracks recently blocked senders AND their message payloads
local recentAutoReplies = {}     -- Tracks automated outgoing whispers to hide them

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

-- Centralized logic to check if a whisper should be blocked
local function ShouldBlockWhisper(sender, guid)
    local category = GetSenderCategory(sender, guid)
    if category == "friend" then return not WhysperConfig.allowFriends end
    if category == "guildie" then return not WhysperConfig.allowGuildies end
    if category == "raid" then return not WhysperConfig.allowRaid end
    if category == "party" then return not WhysperConfig.allowParty end
    if category == "stranger" then return not WhysperConfig.allowStrangers end
    return false
end

-- Safely hook the TTS system across all modern API execution paths
local function HookTTS()
    -- Central logic to determine if an event should be muted
    local function IsTTSBlocked(event, msg, sender, guid)
        if event == "CHAT_MSG_WHISPER" then
            local myName = UnitName("player")
            local senderShort = string.match(sender, "(.*)-") or sender
            if sender ~= myName and senderShort ~= myName then
                return ShouldBlockWhisper(sender, guid)
            end
        elseif event == "CHAT_MSG_WHISPER_INFORM" then
            if WhysperConfig.hideAutoReply then
                local timeSent = recentAutoReplies[sender] -- arg2 is the target we whispered
                if timeSent and (GetTime() - timeSent < 2) then
                    return true
                end
            end
        end
        return false
    end

    -- 1. Mixin/Table Function Hook (Modern WoW 10.0+)
    if TextToSpeechFrame and TextToSpeechFrame.OnEvent and not TextToSpeechFrame.WhysperMixinHooked then
        TextToSpeechFrame.WhysperMixinHooked = true
        local origOnEvent = TextToSpeechFrame.OnEvent
        TextToSpeechFrame.OnEvent = function(self, event, ...)
            if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_WHISPER_INFORM" then
                local msg, sender, _, _, _, flags, _, _, _, _, _, guid = ...
                if flags ~= "GM" and flags ~= "DEV" then
                    if IsTTSBlocked(event, msg, sender, guid) then return end
                end
            end
            return origOnEvent(self, event, ...)
        end
    end

    -- 2. Frame Script Hook (Legacy fallback)
    if TextToSpeechFrame and not TextToSpeechFrame.WhysperScriptHooked then
        TextToSpeechFrame.WhysperScriptHooked = true
        local origScript = TextToSpeechFrame:GetScript("OnEvent")
        if origScript then
            TextToSpeechFrame:SetScript("OnEvent", function(self, event, ...)
                if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_WHISPER_INFORM" then
                    local msg, sender, _, _, _, flags, _, _, _, _, _, guid = ...
                    if flags ~= "GM" and flags ~= "DEV" then
                        if IsTTSBlocked(event, msg, sender, guid) then return end
                    end
                end
                return origScript(self, event, ...)
            end)
        end
    end

    -- 3. C_VoiceChat API Hook (Absolute failsafe for EventRegistry / unpredictable routing)
    if C_VoiceChat and C_VoiceChat.SpeakText and not C_VoiceChat.WhysperHooked then
        C_VoiceChat.WhysperHooked = true
        local origSpeakText = C_VoiceChat.SpeakText
        C_VoiceChat.SpeakText = function(voiceID, text, ...)
            if text then
                local now = GetTime()
                local block = false

                -- Failsafe 1: Check against incoming blocked whispers (matching name OR exact message text)
                for blockedSender, data in pairs(recentBlockedWhispers) do
                    if now - data.time > 2 then
                        recentBlockedWhispers[blockedSender] = nil
                    else
                        if string.find(text, blockedSender, 1, true) or (data.msg and string.find(text, data.msg, 1, true)) then
                            block = true
                        end
                    end
                end

                -- Failsafe 2: Check against outgoing auto-replies getting read aloud
                if WhysperConfig.hideAutoReply then
                    local customMsg = WhysperConfig.ignoredMessageText or "You are currently being ignored by the user."
                    if customMsg:match("^%s*$") then customMsg = "You are currently being ignored by the user." end
                    if string.find(text, customMsg, 1, true) then
                        block = true
                    end
                end

                if block then
                    return -- Silently drop the TTS playback entirely
                end
            end
            return origSpeakText(voiceID, text, ...)
        end
    end
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
            sendIgnoredMessage = false,
            ignoredMessageText = "You are currently being ignored by the user.",
            hideAutoReply = false
        }
        for k, v in pairs(defaults) do
            if WhysperConfig[k] == nil then
                WhysperConfig[k] = v
            end
        end
    elseif event == "PLAYER_LOGIN" then
        if IsInGuild() then C_GuildInfo.GuildRoster() end
        HookTTS() -- Inject the TTS hooks once UI is fully available
    elseif event == "GUILD_ROSTER_UPDATE" then
        UpdateGuildRoster()
    end
end)

-- The whisper filter hook for the ChatFrame
local function FilterIncomingWhispers(self, event, msg, sender, language, channelString, target, flags, zoneID, channelNumber, channelName, unused, lineID, guid)
    if flags == "GM" or flags == "DEV" then return false end
    local myName = UnitName("player")
    local senderShort = string.match(sender, "(.*)-") or sender
    if sender == myName or senderShort == myName then return false end

    if ShouldBlockWhisper(sender, guid) then
        local now = GetTime()
        -- Store both the sender AND the message so our C-level TTS failsafe catches it
        -- even if the user has "Read sender names" disabled in TTS settings.
        recentBlockedWhispers[sender] = { time = now, msg = msg }
        recentBlockedWhispers[senderShort] = { time = now, msg = msg }

        if WhysperConfig.sendIgnoredMessage then
            if not replyCooldowns[sender] or (now - replyCooldowns[sender] > 10) then
                replyCooldowns[sender] = now

                local customMsg = WhysperConfig.ignoredMessageText or "You are currently being ignored by the user."
                if customMsg:match("^%s*$") then customMsg = "You are currently being ignored by the user." end

                -- Mark this sender so we know to hide the outgoing message
                if WhysperConfig.hideAutoReply then
                    recentAutoReplies[sender] = now
                end

                SendChatMessage(customMsg, "WHISPER", nil, sender)
            end
        end
        return true
    end
    return false
end

-- Intercept outgoing whispers to hide our automated reply and prevent the tab from opening
local function FilterOutgoingWhispers(self, event, msg, sender, language, channelString, target, flags, zoneID, channelNumber, channelName, unused, lineID, guid)
    if WhysperConfig.hideAutoReply then
        local now = GetTime()
        local timeSent = recentAutoReplies[target]
        -- If we just sent an auto-reply to this target within the last 2 seconds, consume the event
        if timeSent and (now - timeSent < 2) then
            return true
        end
    end
    return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", FilterIncomingWhispers)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", FilterOutgoingWhispers)

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

-- Custom Auto-Reply Message Text Box
local replyEditBox = CreateFrame("EditBox", nil, optionsFrame, "InputBoxTemplate")
replyEditBox:SetSize(300, 20)
replyEditBox:SetPoint("TOPLEFT", cbReply, "BOTTOMLEFT", 15, -20)
replyEditBox:SetAutoFocus(false)
replyEditBox:SetMaxLetters(255)

local replyLabel = replyEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
replyLabel:SetPoint("BOTTOMLEFT", replyEditBox, "TOPLEFT", -5, 5)
replyLabel:SetText("Custom Auto-Reply Message:")

replyEditBox:SetScript("OnShow", function(self)
    self:SetText(WhysperConfig.ignoredMessageText or "You are currently being ignored by the user.")
end)

replyEditBox:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        WhysperConfig.ignoredMessageText = self:GetText()
    end
end)

-- Checkbox to hide the auto-reply from the user's own chat
local cbHideReply = CreateCheckbox("Hide auto-reply from my chat window (prevents tab opening)", -15, "hideAutoReply", nil)
cbHideReply:SetPoint("TOPLEFT", replyEditBox, "BOTTOMLEFT", -15, -15)

-- Visually toggle the EditBox and Hide Checkbox based on the Auto-Reply status
local function UpdateEditBoxState()
    if WhysperConfig.sendIgnoredMessage then
        replyEditBox:Enable()
        replyEditBox:SetAlpha(1)
        cbHideReply:Enable()
        cbHideReply:SetAlpha(1)
    else
        replyEditBox:Disable()
        replyEditBox:SetAlpha(0.5)
        cbHideReply:Disable()
        cbHideReply:SetAlpha(0.5)
    end
end

cbReply:HookScript("OnShow", UpdateEditBoxState)
cbReply:HookScript("OnClick", UpdateEditBoxState)

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
        UpdateEditBoxState()
    elseif cmd == "hide" then
        WhysperConfig.hideAutoReply = not WhysperConfig.hideAutoReply
        print("Whysper - Hide Auto-Reply: " .. (WhysperConfig.hideAutoReply and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    else
        print("|cffffff00Whysper Commands:|r")
        print("/why menu     - Open the Interface Settings panel")
        print("/why stranger - Toggle stranger whispers")
        print("/why friend   - Toggle friend whispers")
        print("/why guild    - Toggle guild whispers")
        print("/why party    - Toggle party whispers")
        print("/why raid     - Toggle raid whispers")
        print("/why reply    - Toggle auto-reply to blocked users")
        print("/why hide     - Toggle hiding your automated replies")
    end
end
