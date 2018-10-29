
local GetTime = GetTime

-- uppercase means final, wont be changed at any point --
local ADDON_NAME = "AmGetGleb"
local ADDON_VERSION = 0.1
local ITEM_WARGLAIVE_MAINHAND = 32837
local ITEM_WARGLAIVE_OFFHAND = 32838
local TEXTURE_WARGLAIVE_MAINHAND = select(10,GetItemInfo(ITEM_WARGLAIVE_MAINHAND))
local SPELL_PROC_ID = 41434
local SPELL_PROC_NAME = "The Twin Blades of Azzinoth"
local SPELL_PROC_ICD = 45
local DEFAULT_SETTINGS = {
    ["MainFrame_frameSize"] = 50,
    ["MainFrame_point"] = "TOPLEFT",
    ["MainFrame_relativePoint"] = "CENTER",
    ["MainFrame_xOfs"] = 0,
    ["MainFrame_yOfs"] = 0,
    ["MainFrame_cooldown"] = true,
}

local AGGo

local function print(...)
    local str = ADDON_NAME
    local nrOfArgs = select("#" , ...)
    for i = 1,nrOfArgs do
        str = str.. ", ".. tostring(select(i, ...))
    end
    DEFAULT_CHAT_FRAME:AddMessage(str)
end

local function tableHasKey(table,key)
    return table[key] ~= nil
end


local MainFrame = CreateFrame("frame", ADDON_NAME.."_MainFrame", UIParent)

local function addEvent(eventTable, event, eventFunc, isFrame)
    print(event)
    if type(event) == "string" and type(eventFunc) == "function" and type(eventTable) == "table" then
        eventTable[event] = eventFunc
        if isFrame then
            eventTable:RegisterEvent(event)
            print(event.." added to "..eventTable:GetName())
        end
        return true
    end
    return false
end

MainFrame.texture = MainFrame:CreateTexture(MainFrame:GetName().."_Texture", "BACKGROUND")
MainFrame.texture:SetTexture(TEXTURE_WARGLAIVE_MAINHAND)
MainFrame.texture:SetAllPoints()
MainFrame.cooldown = CreateFrame("cooldown", MainFrame:GetName().."_Cooldown", MainFrame)
MainFrame.cooldown:SetAllPoints()

local function MainFrame_OnLoad(self)
    MainFrame:UnregisterEvent("VARIABLES_LOADED")
    if not AGG_SV then
        AGG_SV = DEFAULT_SETTINGS
    end
    AGGo = AGG_SV
    MainFrame:SetWidth(AGGo.MainFrame_frameSize)
    MainFrame:SetHeight(AGGo.MainFrame_frameSize)
    MainFrame:SetPoint(AGGo.MainFrame_point, UIParent, AGGo.MainFrame_relativePoint, AGGo.MainFrame_xOfs, AGGo.MainFrame_yOfs)

    print("Addon loaded")
end
addEvent(MainFrame, "VARIABLES_LOADED", MainFrame_OnLoad, true)

local function MainFrame_OnLeave(self)
    local point, relativeTo, relativePoint, xOfs, yOfs = MyRegion:GetPoint()
    AGGo.point = point
    AGGo.relativePoint = relativePoint
    AGGo.xOfs = xOfs
    AGGo.yOfs = yOfs
end
addEvent(MainFrame, "PLAYER_LOGOUT", MainFrame_OnLeave, true)

local MainFrame_OnCombatLogEvent = function(self, event, ...)
    if event == "SPELL_AURA_APPLIED" then
        local now = GetTime()
        local down, up, latency = GetNetStats()
        local guid0, _, negnr, playerGUID, playerName, _, auraID, auraName, auraType = ...
        if auraName == SPELL_PROC_ID then
            AGGo.ICD = SPELL_PROC_ICD
            AGGo.ICDstart = GetTime()
            self.cooldown:SetCooldown(now - latency/1000, SPELL_PROC_ICD)
        end
    end
end

addEvent(MainFrame, "COMBAT_LOG_EVENT_UNFILTERED", MainFrame_OnCombatLogEvent, true)

MainFrame:SetScript("OnEvent", function(self, event, ...) 
    if tableHasKey(self,event) then
        self[event](...) 
    end
end)