--------------------------------------------------------------------------------
-- PlayerBot Control v1.0.0
-- Аддон для управления ботами mod-playerbots (WoW 3.3.5a).
-- Кнопка у миникарты открывает/скрывает окно управления в близардовском
-- стиле с тёмным фоном. Команды ботам отправляются в чат группы/рейда.
--------------------------------------------------------------------------------

local ADDON_NAME = "PlayerBotControl"
local ADDON_VERSION = "1.0.0"

-- Хранение позиции окна между сессиями
local db = PlayerBotControlDB or {}
PlayerBotControlDB = db

--------------------------------------------------------------------------------
-- Окно управления
--------------------------------------------------------------------------------

local frame = CreateFrame("Frame", "PlayerBotControlFrame", UIParent)
frame:SetFrameStrata("TOOLTIP")              -- самый высокий уровень оверлея
frame:SetFrameLevel(128)
frame:SetWidth(240)
frame:SetHeight(110)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
frame:Hide()

-- Тёмный фон в близардовском стиле
local backdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 11, top = 12, bottom = 11 },
}
frame:SetBackdrop(backdrop)

-- Заголовок
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -14)
title:SetText("PlayerBot Control")

-- Подзаголовок (текущее состояние)
local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
statusText:SetPoint("TOP", title, "BOTTOM", 0, -4)
statusText:SetTextColor(0.7, 0.7, 0.7)
statusText:SetText("Команды ботам отправляются в чат группы")

-- Перетаскивание окна за фон
frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
frame:SetScript("OnMouseUp", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    db.posX, db.posY = x, y
end)

-- Закрытие по Escape
tinsert(UISpecialFrames, "PlayerBotControlFrame")

--------------------------------------------------------------------------------
-- Кнопка Follow
--------------------------------------------------------------------------------

local followBtn = CreateFrame("Button", "PlayerBotControlFollowButton", frame, "UIPanelButtonTemplate")
followBtn:SetWidth(180)
followBtn:SetHeight(28)
followBtn:SetPoint("TOP", statusText, "BOTTOM", 0, -14)
followBtn:SetText("Follow — все боты за мной")

followBtn:SetScript("OnClick", function()
    -- Команда из мануала: "follow" (/p или /r для всей группы/рейда)
    if GetNumRaidMembers() > 0 then
        SendChatMessage("follow", "RAID")
    elseif GetNumPartyMembers() > 0 then
        SendChatMessage("follow", "PARTY")
    else
        print("|cffff7d00PlayerBot Control:|r вы не в группе — команда не отправлена.")
    end
end)

-- Подсказка при наведении
followBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Follow")
    GameTooltip:AddLine("Отправляет в /p или /r команду \"follow\":\nвсе боты последуют за вами.", 1, 1, 1, 1)
    GameTooltip:Show()
end)
followBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Версия внизу окна
local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
versionText:SetPoint("BOTTOM", 0, 14)
versionText:SetText("v" .. ADDON_VERSION)

--------------------------------------------------------------------------------
-- Кнопка у миникарты (с перетаскиванием по кругу)
--------------------------------------------------------------------------------

local minimapBtn = CreateFrame("Button", "PlayerBotControlMinimapButton", Minimap)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetWidth(31)
minimapBtn:SetHeight(31)
minimapBtn:SetFrameLevel(8)
minimapBtn:RegisterForClicks("anyUp")
minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetClampedToScreen(true)

local btnBg = minimapBtn:CreateTexture(nil, "BACKGROUND")
btnBg:SetWidth(20)
btnBg:SetHeight(20)
btnBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
btnBg:SetTexCoord(0.5, 0.85, 0.5, 0.85)
btnBg:SetPoint("CENTER", 0, 0)

local btnBorder = minimapBtn:CreateTexture(nil, "OVERLAY")
btnBorder:SetWidth(54)
btnBorder:SetHeight(54)
btnBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
btnBorder:SetPoint("TOPLEFT")

local btnIcon = minimapBtn:CreateTexture(nil, "ARTWORK")
btnIcon:SetWidth(17)
btnIcon:SetHeight(17)
btnIcon:SetTexture("Interface\\Icons\\Ability_Warrior_CommandingShout")
btnIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
btnIcon:SetPoint("CENTER", 0, 0)

-- Позиция кнопки на миникарте
local MINIMAP_RADIUS = 80
local storedAngle = db.minimapAngle

local function UpdateMinimapPosition()
    local angle = storedAngle or math.rad(45)
    local x = math.cos(angle) * MINIMAP_RADIUS
    local y = math.sin(angle) * MINIMAP_RADIUS
    minimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local dragging = false

minimapBtn:SetScript("OnDragStart", function() dragging = true end)
minimapBtn:SetScript("OnDragStop", function()
    dragging = false
    local angle = math.atan2(select(2, minimapBtn:GetCenter()) - select(2, Minimap:GetCenter()),
                             select(1, minimapBtn:GetCenter()) - select(1, Minimap:GetCenter()))
    -- 3.3.5: atan2(y, x) в Lua 5.1
    storedAngle = angle
    db.minimapAngle = angle
    UpdateMinimapPosition()
end)

minimapBtn:SetScript("OnUpdate", function()
    if dragging then
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        cx, cy = cx / scale, cy / scale
        storedAngle = math.atan2(cy - my, cx - mx)
        UpdateMinimapPosition()
    end
end)

-- Клики: левый — открыть/закрыть окно
minimapBtn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if frame:IsShown() then
            frame:Hide()
        else
            if db.posX then
                frame:ClearAllPoints()
                frame:SetPoint("CENTER", UIParent, "CENTER", db.posX, db.posY)
            end
            frame:Show()
        end
    end
end)

minimapBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:SetText("PlayerBot Control")
    GameTooltip:AddLine("ЛКМ — открыть/скрыть окно управления", 1, 1, 1, 1)
    GameTooltip:AddLine("Перетащите, чтобы переместить кнопку", 0.7, 0.7, 0.7, 1)
    GameTooltip:Show()
end)
minimapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

UpdateMinimapPosition()

--------------------------------------------------------------------------------
-- Slash-команды
--------------------------------------------------------------------------------

SLASH_PLAYERBOTCONTROL1 = "/pbc"
SLASH_PLAYERBOTCONTROL2 = "/playerbotcontrol"
SlashCmdList["PLAYERBOTCONTROL"] = function(msg)
    msg = (msg or ""):lower()
    if msg == "follow" then
        followBtn:Click()
        return
    end
    if frame:IsShown() then
        frame:Hide()
    else
        if db.posX then
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER", db.posX, db.posY)
        end
        frame:Show()
    end
end

print("|cff33ff99PlayerBot Control v" .. ADDON_VERSION .. "|r загружен. Открыть окно: /pbc или кнопка у миникарты.")
