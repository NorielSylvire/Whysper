-- Whysper_WIM.lua
-- WIM (WoW Instant Messenger) compatibility module for Whysper
-- This module only activates if WIM is installed and loaded.

local addonName, ns = ...

-- Check if WIM exists
local function IsWIMLoaded()
    return WIM and WIM.modules and WIM.modules.WhisperEngine
end

-- Wait for WIM to fully initialize, then install our hooks
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Give WIM time to initialize (it also hooks on PLAYER_LOGIN)
        C_Timer.After(0.1, function()
            if IsWIMLoaded() then
                ns.InstallWIMHooks()
            end
        end)
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)

-- Helper functions that mirror core.lua logic
local function NormalizeName(name)
    return name and (string.match(name, "(.*)%-") or name) or nil
end

local function GetSenderCategory(sender, guid)
    -- Check friends via guid
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

    -- Check guild (need to access the guild member cache from core.lua)
    -- Since we can't easily share the cache, we re-check guild membership
    if IsInGuild() then
        for i = 1, GetNumGuildMembers() do
            local name = GetGuildRosterInfo(i)
            if name then
                local guildShort = NormalizeName(name)
                if name == sender or guildShort == senderShort then
                    return "guildie"
                end
            end
        end
    end

    -- Check raid
    if UnitInRaid(sender) or (senderShort and UnitInRaid(senderShort)) then
        return "raid"
    end

    -- Check party
    if UnitInParty(sender) or (senderShort and UnitInParty(senderShort)) then
        return "party"
    end

    return "stranger"
end

-- Helper to check if we should block (reusing Whysper's logic)
local function ShouldBlockForWIM(sender, guid)
    -- Access Whysper's blocking logic via the global config
    if not WhysperConfig then return false end

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
        return not WhysperConfig.allowStrangers
    end

    return false
end

-- Install hooks into WIM's whisper handling
function ns.InstallWIMHooks()
    if ns.WIMHooksInstalled then return end
    ns.WIMHooksInstalled = true

    local WhisperEngine = WIM.modules.WhisperEngine

    -- Store original event handlers
    local originalWhisperHandler = WhisperEngine.CHAT_MSG_WHISPER
    local originalWhisperInformHandler = WhisperEngine.CHAT_MSG_WHISPER_INFORM
    local originalBNWhisperHandler = WhisperEngine.CHAT_MSG_BN_WHISPER
    local originalBNWhisperInformHandler = WhisperEngine.CHAT_MSG_BN_WHISPER_INFORM

    -- Hook CHAT_MSG_WHISPER - block BEFORE WIM creates a window
    WhisperEngine.CHAT_MSG_WHISPER = function(self, ...)
        local msg, sender, _, _, _, flags, _, _, _, _, _, guid = ...

        -- Never block GMs or developers
        if flags == "GM" or flags == "DEV" then
            return originalWhisperHandler(self, ...)
        end

        -- Don't block our own messages
        local myName = UnitName("player")
        local senderShort = NormalizeName(sender)
        if sender == myName or senderShort == myName then
            return originalWhisperHandler(self, ...)
        end

        -- Check if this whisper should be blocked
        if ShouldBlockForWIM(sender, guid) then
            -- Blocked - don't let WIM process it at all
            return true
        end

        -- Not blocked - let WIM handle it normally
        return originalWhisperHandler(self, ...)
    end

    -- Hook CHAT_MSG_WHISPER_INFORM - block auto-reply display in WIM
    WhisperEngine.CHAT_MSG_WHISPER_INFORM = function(self, ...)
        local msg, target = ...

        -- Check if this is an auto-reply we want to hide
        if WhysperConfig and WhysperConfig.hideAutoReply then
            local short = NormalizeName(target)
            -- ns.recentAutoReplies is shared from core.lua
            if ns.recentAutoReplies and ns.recentAutoReplies[short] then
                local sent = ns.recentAutoReplies[short]
                if (GetTime() - sent) < 5 then
                    -- This is our auto-reply, block it from WIM
                    return true
                end
            end
        end

        return originalWhisperInformHandler(self, ...)
    end

    -- Hook BN_WHISPER for Battle.net whispers
    if originalBNWhisperHandler then
        WhisperEngine.CHAT_MSG_BN_WHISPER = function(self, ...)
            -- For BNet whispers, check if we can determine the character
            -- BNet friends are typically allowed, but respect the friend setting
            if WhysperConfig and not WhysperConfig.allowFriends then
                return true -- Block BNet whisper if friends are blocked
            end

            return originalBNWhisperHandler(self, ...)
        end
    end

    -- Hook BN_WHISPER_INFORM for outgoing BNet whispers
    if originalBNWhisperInformHandler then
        WhisperEngine.CHAT_MSG_BN_WHISPER_INFORM = function(self, ...)
            -- Let BNet outgoing messages through (we don't auto-reply to BNet)
            return originalBNWhisperInformHandler(self, ...)
        end
    end

    -- Print confirmation that WIM integration is active (only in debug mode)
    if WhysperConfig and WhysperConfig.debug then
        print("|cff00ff00Whysper:|r WIM compatibility module loaded.")
    end
end
