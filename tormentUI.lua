local uiFrame = nil

uiFrame = CreateFrame("Frame", "TormentUI", UIParent, "BasicFrameTemplateWithInset")
uiFrame:SetSize(600, 300) 
uiFrame:SetPoint("CENTER")
uiFrame:SetMovable(true)
uiFrame:EnableMouse(true)
uiFrame:RegisterForDrag("LeftButton")
uiFrame:SetScript("OnDragStart", uiFrame.StartMoving)
uiFrame:SetScript("OnDragStop", uiFrame.StopMovingOrSizing)

local title = uiFrame:CreateFontString(nil, "OVERLAY")
title:SetFontObject("GameFontHighlight")
title:SetPoint("TOP", uiFrame, "TOP", 0, -7)
title:SetText("Torment")

local clearButton = CreateFrame("Button", "ClearButton", uiFrame, "GameMenuButtonTemplate")
clearButton:SetPoint("TOPLEFT", 10, -5)
clearButton:SetSize(65, 18)
clearButton:SetText("Clear")

clearButton:SetScript("OnClick", function()
    CombatInteractions = {}
    ShowCombatDataUI()
end)
uiFrame:Hide()

SLASH_TORMENT1 = '/torment'
SlashCmdList.TORMENT = function()
    if uiFrame:IsShown() then
        uiFrame:Hide()
    else
        uiFrame:Show()
        ShowCombatDataUI()
    end
end

function ShowCombatDataUI()
    local scrollFrame = CreateFrame("ScrollFrame", nil, uiFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetSize(580, 260)


    if uiFrame.content then
        for i, child in ipairs({uiFrame.content:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end
    else
        uiFrame.content = CreateFrame("Frame", nil, uiFrame)
    end

    local content = uiFrame.content
    content:SetSize(580, 260)

    local totalHeight = 0

    for _, combatData in ipairs(CombatInteractions) do
        local baseYOffset = -5 - totalHeight
        local yOffsetActive = baseYOffset
        local yOffsetInactive = baseYOffset
        local yOffsetReducer = baseYOffset

        local encounterText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        encounterText:SetPoint("TOPLEFT", 5, baseYOffset)
        encounterText:SetText("Encounter: " .. combatData.encounterName)
        yOffsetActive = yOffsetActive - 20
        yOffsetInactive = yOffsetInactive - 20
        yOffsetReducer = yOffsetReducer - 20

        -- Display Buff Inactive Data Instances
        for _, inactiveInstance in ipairs(combatData.buffInactiveData) do
            local inactiveText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            inactiveText:SetPoint("TOPLEFT", 225, yOffsetInactive) -- Positioned beside the active column
            inactiveText:SetText("Spells Cast: " .. inactiveInstance.spellCounts ..
                                    "  -  Uptime: " .. inactiveInstance.uptime .. "s")
            yOffsetInactive = yOffsetInactive - 15
        end

        -- Display Buff Active Data Instances
        for _, activeInstance in ipairs(combatData.buffActiveData) do
            local activeText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            activeText:SetPoint("TOPLEFT", 5, yOffsetActive)
            activeText:SetText("Covenant Spells Cast: " .. activeInstance.spellCounts ..
                               "  -  Uptime: " .. activeInstance.uptime .. "s")
            yOffsetActive = yOffsetActive - 15
        end

        -- Display All Reducer Casts Instances
        local reducerText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        reducerText:SetPoint("TOPLEFT", 425, yOffsetReducer) -- Positioned beside the inactive column
        reducerText:SetText("Reducer Casts: " .. combatData.allReducerCasts)
        yOffsetReducer = yOffsetReducer - 15

        local lowestYOffset = math.min(yOffsetActive, yOffsetInactive, yOffsetReducer)
        totalHeight = totalHeight - lowestYOffset + 10
    end

    content:SetSize(380, totalHeight)
    scrollFrame:SetScrollChild(content)
end