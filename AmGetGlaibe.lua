
local GetTime = GetTime

-- uppercase means final, wont be changed at any point --
local ADDON_NAME = "AmGetGlaibe"
local ADDON_VERSION = 0.1
local ITEM_WARGLAIVE_MAINHAND = 32837
local ITEM_WARGLAIVE_OFFHAND = 32838
local TEXTURE_WARGLAIVE_MAINHAND = select(10,GetItemInfo(ITEM_WARGLAIVE_MAINHAND))
local TEXTURE_GLOW = "Interface\\Addons\\"..ADDON_NAME.."\\Textures\\glowTex.tga"
local TEXTURE_BAR = "Interface\\Addons\\"..ADDON_NAME.."\\Textures\\Runes.tga"
local FONT_BOLD = "Interface\\Addons\\"..ADDON_NAME.."\\Fonts\\BF.ttf"
local COLOR_GOLDEN = {1, 0.84, 0, 1}
local COLOR_BLUE = {0.1,0.1,0.7,0.9}
local COLOR_BLUE2 = {0,0.8,1,1}
local COLOR_BLACK = {0,0,0,1}
local SPELL_PROC_ID = 41435
local SPELL_PROC_NAME = "The Twin Blades of Azzinoth"
local SPELL_PROC_ICD = 45
local DEFAULT_SETTINGS = {
    ["MainFrame_frameSize"] = 50,
    ["MainFrame_point"] = "TOPLEFT",
    ["MainFrame_relativePoint"] = "CENTER",
    ["MainFrame_xOfs"] = 0,
    ["MainFrame_yOfs"] = 0,
    ["MainFrame_cooldown"] = true,
    ["StatusBarFrame_Insert"] = 3,
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
MainFrame:SetScript("OnEvent", function(self, event, ...) 
    print(self:GetName().. ": "..event)
    if tableHasKey(self,event) then
        self[event](self,event,...) 
    end
end)
MainFrame:SetMovable(true)
MainFrame:EnableMouse(true)
MainFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.isMoving then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end
end)
MainFrame:SetScript("OnHide", function(self)
    if ( self.isMoving ) then
        self:StopMovingOrSizing();
        self.isMoving = false;
    end
end)
MainFrame.menuFrame = CreateFrame("Frame", "ExampleMenuFrame", UIParent, "UIDropDownMenuTemplate")
MainFrame.texture = MainFrame:CreateTexture(MainFrame:GetName().."_Texture", "BACKGROUND")
MainFrame.texture:SetTexture(TEXTURE_WARGLAIVE_MAINHAND)
MainFrame.texture:SetAllPoints()
MainFrame.cooldown = CreateFrame("cooldown", MainFrame:GetName().."_Cooldown", MainFrame)
MainFrame.cooldown:SetAllPoints()
MainFrame.centerText = MainFrame.cooldown:CreateFontString(MainFrame.cooldown:GetName().."_Text", "OVERLAY", GameFontNormalLarge)
MainFrame.centerText:SetPoint("CENTER")
MainFrame.centerText:SetFont(FONT_BOLD, 30, "THINOUTLINE")
MainFrame.Glow = MainFrame:CreateTexture("frame", ADDON_NAME.."_GlowFrame", MainFrame)
MainFrame.menu = {
    {text = ADDON_NAME.. " menu", isTitle = true},
    {text = "Option 1"}
}

--MainFrame.Glow:SetTexture(TEXTURE_GLOW)

local StatusBarFrame = CreateFrame("frame", ADDON_NAME.."_StatusBar", MainFrame)
StatusBarFrame.background = StatusBarFrame:CreateTexture(StatusBarFrame:GetName().."_Background", "BACKGROUND")
StatusBarFrame.background:SetAllPoints()
StatusBarFrame.background:SetTexture(unpack(COLOR_BLACK))
StatusBarFrame.bar = CreateFrame("statusbar", StatusBarFrame:GetName().."_Bar", StatusBarFrame)

StatusBarFrame.bar:SetStatusBarTexture(TEXTURE_BAR)
StatusBarFrame.bar:SetMinMaxValues(0,SPELL_PROC_ICD)
StatusBarFrame.bar:SetValue(0)
StatusBarFrame.bar:SetOrientation("HORIZONTAL")
StatusBarFrame.bar:SetStatusBarColor(unpack(COLOR_BLUE2))
StatusBarFrame.bar:SetScript("OnEvent", function(self, event, ...) 
    print(self:GetName().. ": "..event)
    if tableHasKey(self,event) then
        self[event](self,event,...) 
    end
end)

local function addEvent(eventTable, event, eventFunc, isFrame)
    if type(event) == "string" and type(eventFunc) == "function" and type(eventTable) == "table" then
        eventTable[event] = eventFunc
        if isFrame then
            eventTable:RegisterEvent(event)
            print(event.." added to "..eventTable:GetName().."\n")
        end
        return true
    end
    return false
end

local MainFrame_OnMouseDown = function(self, button, down)
    print(button)
    if button == "RightButton" then
        EasyMenu(self.menu, self.menuFrame, "cursor", 0 , 0, "MENU")
    end
    if button == "LeftButton" and not self.isMoving then
        self:StartMoving();
        self.isMoving = true;
    end
end
MainFrame:SetScript("OnMouseDown", MainFrame_OnMouseDown)

local function MainFrame_OnLoad(self)
    MainFrame:UnregisterEvent("VARIABLES_LOADED")
    if not AGG_SV then
        AGG_SV = DEFAULT_SETTINGS
    end
    AGGo = AGG_SV
    MainFrame:SetWidth(AGGo.MainFrame_frameSize)
    MainFrame:SetHeight(AGGo.MainFrame_frameSize)
    MainFrame:SetPoint(AGGo.MainFrame_point, UIParent, AGGo.MainFrame_relativePoint, AGGo.MainFrame_xOfs, AGGo.MainFrame_yOfs)
    MainFrame.Glow:SetAllPoints()
    StatusBarFrame:SetPoint("TOPLEFT", StatusBarFrame:GetParent(), "BOTTOMLEFT", 0, -5)
    StatusBarFrame:SetWidth(104)
    StatusBarFrame:SetHeight(24)
    StatusBarFrame.bar:SetPoint("TOPLEFT", 3,-3)
    StatusBarFrame.bar:SetPoint("BOTTOMRIGHT", -3,3)
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
    local timestamp, event, guid0, _, negnr, playerGUID, playerName, _, auraID, auraName, auraType = ...
    local now = GetTime()
    local down, up, latency = GetNetStats()
    if event == "SPELL_AURA_APPLIED" then
        if auraID == SPELL_PROC_ID then
            AGGo.ICD = SPELL_PROC_ICD
            AGGo.ICDstart = GetTime()
            self:SetScript("OnUpdate", function(self, elapsed)
                if (AGGo.ICD - elapsed) > 0 then
                    AGGo.ICD = AGGo.ICD - elapsed
                    MainFrame.centerText:SetText(ceil(AGGo.ICD))
                    if AGGo.ICD < 5 then
                        self.Glow:Show()
                    end
                else
                    AGGo.ICD = 0 
                    self:SetScript("OnUpdate", nil)
                end
                StatusBarFrame.bar:SetValue(AGGo.ICD)
            end)
            self.cooldown:SetCooldown(now, SPELL_PROC_ICD)
        end
    end
end
addEvent(MainFrame, "COMBAT_LOG_EVENT_UNFILTERED", MainFrame_OnCombatLogEvent, true)

local StatusBar_OnCombatLogEvent = function(self, event, ...)
    local timestamp, event, guid0, _, negnr, playerGUID, playerName, _, auraID, auraName, auraType = ...
    if event == "SPELL_AURA_APPLIED" and auraID == SPELL_PROC_ID then
        self:Show()
        self.glowing = false
        self.background:SetTexture(unpack(COLOR_BLACK))
        self:SetValue(SPELL_PROC_ICD)
        self:SetScript("OnUpdate", function(self, elapsed)
           
            if self:GetValue() - elapsed > 0 then
                self:SetValue(self:GetValue() - elapsed)
                if self:GetValue() < 5 and not(self.glowing) then
                    print(self:GetValue())
                    self.glowing = true
                    self.background:SetTexture(unpack(COLOR_GOLDEN))
                end
            else
                self:Hide()
                self:SetValue(0)
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
end
addEvent(StatusBarFrame, "COMBAT_LOG_EVENT_UNFILTERED", StatusBar_OnCombatLogEvent, true)