
local GetTime = GetTime
local function print(...)
    local str = tostring(...)
    local nrOfArgs = select(#,...)
    for i = 1,nrOfArgs do
        str = str.. ", ".. tostring(select(i, ...))
    end
    DEFAULT_CHAT_FRAME:AddMessage(str)
end

-- uppercase means final, wont be changed at any point --
local ADDON_NAME = "AmGetGleb"
local ADDON_VERSION = 0.1
local ITEM_WARGLAIVE_MAINHAND = 32837
local ITEM_WARGLAIVE_OFFHAND = 32838
local TEXTURE_WARGLAIVE_MAINHAND = GetItemInfo(select(10, ITEM_WARGLAIVE_MAINHAND))
local SPELL_PROC_ID = 41434
local SPELL_PROC_NAME = "The Twin Blades of Azzinoth"
local SPELL_PROC_ICD = 45
local DEFAULT_SETTINGS = {
    ["MainFrame_frameSize"] = 50
    ["MainFrame_point"] = "TOPLEFT"
    ["MainFrame_relativeTo"] = UIParent,
    ["MainFrame_relativePoint"] = "CENTER",
    ["MainFrame_xOfs"] = 0,
    ["MainFrame_yOfs"] = 0,
    ["MainFrame_cooldown"] = true,

}
local MAINFRAME_EVENTS = {
    "COMBAT_LOG_EVENT_UNFILTERED",
    "PLAYER_DEAD",
    "PLAYER_ALIVE"
}

local MainFrame = CreateFrame("frame", ADDON_NAME.."_MainFrame", UIParent)
local MainFrame.texture = MainFrame:CreateTexture(MainFrame:GetName().."_Texture", "BACKGROUND")
MainFrame.texture:SetTexture(TEXTURE_WARGLAIVE_MAINHAND)
MainFrame.texture:SetAllPoints()

local MainFrame_OnLoad = function(self)
    if event == "VARIABLES_LOADED" then
        self:UnregisterEvent("VARIABLES_LOADED")
        if not AGG_SV then
            AGG_SV = DEFAULT_SETTINGS
        end
        for k,v in pairs(DEFAULT_SETTINGS) do
            if not AGG_SV.k then
                AGG_SV.k = v
            end
        end
        local o = AGG_SV
        MainFrame:SetWidth(o.MainFrame_frameSize)
        MainFrame:SetHeight(o.MainFrame_frameSize)
        MainFrame:SetPoint(o.MainFrame_point, o.MainFrame_relativeTo, o.MainFrame_relativePoint, o.MainFrame_xOfs, o.MainFrame_yOfs)

        for i,v in ipairs(MAINFRAME_EVENTS) do
            MainFrame:RegisterEvent(v)
        end

    end
end
local MainFrame_OnEvent = function(self, event, ...)
    if event = "COMBAT_LOG_EVENT_UNFILTERED" then
        print(...)
    end
end
MainFrame:SetScript("OnLoad", MainFrame_OnLoad)
MainFrame:SetScript("OnEvent", MainFrame_OnEvent)