-- Whysper core.lua for WoW Retail 12.0.7
-- Updated to fully suppress blocked whispers, prevent TTS from triggering,
-- hide outgoing auto-replies, and prevent whisper tabs/conversations from opening.

local addonName, ns = ...

WhysperConfig = WhysperConfig or {}

local frame = CreateFrame("Frame")
local guildMembers = {}
local recentAutoReplies = {}
local suppressConversations = {}
local repliedToMessages = {}
local loginTime = nil

-- Share auto-reply tracking with the WIM compatibility module
ns.recentAutoReplies = recentAutoReplies

local function NormalizeName(name)
    return name and (string.match(name, "(.*)%-") or name) or nil
end

local function UpdateGuildRoster()
    wipe(guildMembers)
    if IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local name = GetGuildRosterInfo(i)
            if name then
                guildMembers[name] = true
                local shortName = NormalizeName(name)
                if shortName then
                    guildMembers[shortName] = true
                end
            end
        end
    end
end

local function GetSenderCategory(sender, guid)
    if guid then
        if C_FriendList and C_FriendList.IsFriend and C_FriendList.IsFriend(guid) then
            return "friend"
        end

        if C_BattleNet and C_BattleNet.GetAccountInfoByGUID then
            local bnetInfo = C_BattleNet.GetAccountInfoByGUID(guid)
            if bnetInfo and bnetInfo.isFriend then
                return "friend"
            end
        end
    end

    local senderShort = NormalizeName(sender)

    if guildMembers[sender] or guildMembers[senderShort] then
        return "guildie"
    end

    if UnitInRaid(sender) or UnitInRaid(senderShort) then
        return "raid"
    end

    if UnitInParty(sender) or UnitInParty(senderShort) then
        return "party"
    end

    return "stranger"
end

local function ShouldBlockWhisper(sender, guid)
    local category = GetSenderCategory(sender, guid)

    if category == "friend" then
        return not WhysperConfig.allowFriends
    elseif category == "guildie" then
        return not WhysperConfig.allowGuildies
    elseif category == "raid" then
        return not WhysperConfig.allowRaid
    elseif category == "party" then
        return not WhysperConfig.allowParty
    elseif category == "stranger" then
        -- Check realm blacklist for strangers
        if ns.IsRealmBlacklisted and ns.GetRealmFromName then
            local realm = ns.GetRealmFromName(sender)
            if realm and ns.IsRealmBlacklisted(realm) then
                return true
            end
        end
        return not WhysperConfig.allowStrangers
    end

    return false
end

-- =========================================================
-- HARD WHISPER UI SUPPRESSION
-- =========================================================

local function CloseWhisperUI(name)
    if not name then return end

    local short = NormalizeName(name)
    suppressConversations[short] = GetTime() + 5

    -- Modern retail conversation API
    if C_ChatInfo and C_ChatInfo.CloseChatConversation then
        pcall(C_ChatInfo.CloseChatConversation, short)
        pcall(C_ChatInfo.CloseChatConversation, name)
    end

    -- Close any temporary whisper tabs that may have been created
    if FCF_Close then
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame"..i]
            if chatFrame and chatFrame.isTemporary then
                local target = chatFrame.whisperTarget or chatFrame.tellTarget
                if target and NormalizeName(target) == short then
                    pcall(FCF_Close, chatFrame)
                end
            end
        end
    end
end

-- =========================================================
-- TTS AND WHISPER TAB PREVENTION
-- =========================================================
-- We hook into key UI systems to block events at the source.
-- Message filters alone only hide chat text; TTS and the floating
-- chat frame manager process events independently.

local function ShouldBlockIncomingMessage(sender, flags, guid)
    -- Never block GMs or developers
    if flags == "GM" or flags == "DEV" then
        return false
    end

    local myName = UnitName("player")
    local senderShort = NormalizeName(sender)

    -- Don't block our own messages
    if sender == myName or senderShort == myName then
        return false
    end

    return ShouldBlockWhisper(sender, guid)
end

local function ShouldBlockOutgoingMessage(target)
    if not WhysperConfig.hideAutoReply then
        return false
    end

    local short = NormalizeName(target)
    local sent = recentAutoReplies[short]

    return sent and (GetTime() - sent) < 5
end

local function InstallTTSHook()
    if WhysperTTSHookInstalled then return end
    WhysperTTSHookInstalled = true

    -- The key insight: TTS for chat messages is NOT triggered by TextToSpeechFrame's
    -- OnEvent handler. Instead, ChatFrameMixin:MessageEventHandler calls
    -- TextToSpeechFrame_MessageEventHandler BEFORE message filters run.
    -- We must hook that global function to intercept TTS.

    if TextToSpeechFrame_MessageEventHandler then
        local originalTTSHandler = TextToSpeechFrame_MessageEventHandler
        TextToSpeechFrame_MessageEventHandler = function(frame, event, ...)
            if event == "CHAT_MSG_WHISPER" then
                local _, sender, _, _, _, flags, _, _, _, _, _, guid = ...
                if ShouldBlockIncomingMessage(sender, flags, guid) then
                    return -- Block TTS for this message
                end
            elseif event == "CHAT_MSG_WHISPER_INFORM" then
                local _, target = ...
                if ShouldBlockOutgoingMessage(target) then
                    return -- Block TTS for our auto-reply
                end
            end
            return originalTTSHandler(frame, event, ...)
        end
    end
end

local function InstallFloatingChatFrameManagerHook()
    if WhysperFCFManagerHookInstalled then return end
    WhysperFCFManagerHookInstalled = true

    -- Hook the FloatingChatFrameManager to prevent whisper tabs from opening
    if FloatingChatFrameManager then
        local originalOnEvent = FloatingChatFrameManager:GetScript("OnEvent")
        if originalOnEvent then
            FloatingChatFrameManager:SetScript("OnEvent", function(self, event, ...)
                if event == "CHAT_MSG_WHISPER" then
                    local _, sender, _, _, _, flags, _, _, _, _, _, guid = ...
                    if ShouldBlockIncomingMessage(sender, flags, guid) then
                        return -- Don't open a whisper tab
                    end
                elseif event == "CHAT_MSG_WHISPER_INFORM" then
                    local _, target = ...
                    if ShouldBlockOutgoingMessage(target) then
                        return -- Don't open a whisper tab for our auto-reply
                    end
                end
                return originalOnEvent(self, event, ...)
            end)
        end
    end
end

local function InstallTemporaryWindowHook()
    if WhysperTempWindowHookInstalled then return end
    WhysperTempWindowHookInstalled = true

    -- Also hook FCF_OpenTemporaryWindow as a safety net
    if FCF_OpenTemporaryWindow then
        hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType, target)
            if chatType == "WHISPER" and target then
                local short = NormalizeName(target)
                local untilTime = suppressConversations[short]
                if untilTime and untilTime > GetTime() then
                    -- Close it immediately on next frame
                    C_Timer.After(0, function()
                        CloseWhisperUI(target)
                    end)
                end
            end
        end)
    end
end

-- =========================================================
-- EVENT SETUP
-- =========================================================

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
            hideAutoReply = false,
            realmBlacklist = {},
        }

        for k, v in pairs(defaults) do
            if WhysperConfig[k] == nil then
                WhysperConfig[k] = v
            end
        end

    elseif event == "PLAYER_LOGIN" then
        -- Record login time to ignore cached whisper events
        loginTime = GetTime()

        if IsInGuild() and C_GuildInfo and C_GuildInfo.GuildRoster then
            C_GuildInfo.GuildRoster()
        end

        -- Install hooks to block TTS and whisper tabs
        InstallTTSHook()
        InstallFloatingChatFrameManagerHook()
        InstallTemporaryWindowHook()

    elseif event == "GUILD_ROSTER_UPDATE" then
        UpdateGuildRoster()
    end
end)

-- =========================================================
-- MESSAGE FILTERS (for hiding text in chat frames)
-- =========================================================
-- These filters hide messages from chat frames.

local function FilterIncomingWhispers(self, event, msg, sender, language, channelString,
    target, flags, zoneID, channelNumber, channelName, unused, lineID, guid)

    if ShouldBlockIncomingMessage(sender, flags, guid) then
        local senderShort = NormalizeName(sender)

        -- Mark this sender for conversation suppression
        suppressConversations[senderShort] = GetTime() + 5

        -- Close any UI that might have opened
        CloseWhisperUI(sender)

        -- Optional auto-reply (only once per unique message)
        -- Skip if we just logged in (to avoid replying to cached/replayed events)
        if WhysperConfig.sendIgnoredMessage and lineID then
            local now = GetTime()
            if not repliedToMessages[lineID] and loginTime and (now - loginTime) > 2 then
                repliedToMessages[lineID] = true

                local customMsg = WhysperConfig.ignoredMessageText
                if not customMsg or customMsg:match("^%s*$") then
                    customMsg = "You are currently being ignored by the user."
                end

                if WhysperConfig.hideAutoReply then
                    recentAutoReplies[senderShort] = now
                end

                SendChatMessage(customMsg, "WHISPER", nil, sender)

                -- Cleanup after the send
                if WhysperConfig.hideAutoReply then
                    C_Timer.After(0, function()
                        CloseWhisperUI(sender)
                    end)
                end
            end
        end

        return true -- Hide the message
    end

    return false
end

local function FilterOutgoingWhispers(self, event, msg, target, language, channelString,
    unused1, flags, zoneID, channelNumber, channelName, unused2, lineID, guid)

    if ShouldBlockOutgoingMessage(target) then
        local short = NormalizeName(target)

        -- Mark for conversation suppression
        suppressConversations[short] = GetTime() + 5

        C_Timer.After(0, function()
            CloseWhisperUI(short)
        end)

        return true -- Hide our auto-reply message
    end

    return false
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", FilterIncomingWhispers)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", FilterOutgoingWhispers)

-- =========================================================
-- OPTIONS UI
-- =========================================================

local optionsFrame = CreateFrame("Frame", "WhysperOptionsFrame", UIParent)
optionsFrame.name = "Whysper"

-- Create a scroll frame to contain all options
local scrollFrame = CreateFrame("ScrollFrame", "WhysperOptionsScrollFrame", optionsFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 0, 0)
scrollFrame:SetPoint("BOTTOMRIGHT", -26, 0)

-- Create the scroll child that will hold all the content
local scrollChild = CreateFrame("Frame", "WhysperOptionsScrollChild", scrollFrame)
scrollChild:SetSize(550, 600) -- Width and initial height (height will be adjusted)
scrollFrame:SetScrollChild(scrollChild)

-- Enable mouse wheel scrolling
scrollFrame:EnableMouseWheel(true)
scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local scrollBar = _G["WhysperOptionsScrollFrameScrollBar"]
    local current = scrollBar:GetValue()
    local minVal, maxVal = scrollBar:GetMinMaxValues()
    local step = 40
    
    if delta > 0 then
        scrollBar:SetValue(math.max(current - step, minVal))
    else
        scrollBar:SetValue(math.min(current + step, maxVal))
    end
end)

local title = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Whysper Configuration")

local function CreateCheckbox(label, yOffset, configKey, parentNode)
    local cb = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")

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

local cbFriends   = CreateCheckbox("Allow whispers from friends", -20, "allowFriends")
local cbGuild     = CreateCheckbox("Allow whispers from guildies", -10, "allowGuildies", cbFriends)
local cbParty     = CreateCheckbox("Allow whispers from party members", -10, "allowParty", cbGuild)
local cbRaid      = CreateCheckbox("Allow whispers from raid members", -10, "allowRaid", cbParty)
local cbStrangers = CreateCheckbox("Allow whispers from strangers", -10, "allowStrangers", cbRaid)
local cbReply     = CreateCheckbox("Send ignored message to blocked senders", -30, "sendIgnoredMessage", cbStrangers)

local replyEditBox = CreateFrame("EditBox", nil, scrollChild, "InputBoxTemplate")
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

local cbHideReply = CreateCheckbox(
    "Hide auto-reply from my chat window (prevents tab opening)",
    -15,
    "hideAutoReply"
)
cbHideReply:SetPoint("TOPLEFT", replyEditBox, "BOTTOMLEFT", -15, -15)

local function UpdateEditBoxState()
    local enabled = WhysperConfig.sendIgnoredMessage

    replyEditBox:SetEnabled(enabled)
    replyEditBox:SetAlpha(enabled and 1 or 0.5)

    cbHideReply:SetEnabled(enabled)
    cbHideReply:SetAlpha(enabled and 1 or 0.5)
end

cbReply:HookScript("OnShow", UpdateEditBoxState)
cbReply:HookScript("OnClick", UpdateEditBoxState)

-- Add realm blacklist UI (pass scrollChild instead of optionsFrame)
if ns.CreateRealmBlacklistUI then
    ns.CreateRealmBlacklistUI(scrollChild, cbHideReply)
end

local category = Settings.RegisterCanvasLayoutCategory(optionsFrame, "Whysper")
Settings.RegisterAddOnCategory(category)

-- =========================================================
-- SLASH COMMANDS
-- =========================================================

SLASH_WHYSPER1 = "/why"

SlashCmdList["WHYSPER"] = function(msg)
    local cmd, args = msg:match("^%s*(%w+)%s*(.*)$")
    cmd = cmd and cmd:lower() or ""

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
    elseif cmd == "realm" then
        if ns.HandleRealmCommand and ns.HandleRealmCommand(args) then
            return
        end
        -- If no valid subcommand, show realm help
        if ns.PrintRealmHelp then
            ns.PrintRealmHelp()
        end
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
        print("/why realm    - Manage realm blacklist (add/remove/list/clear)")
    end
end
