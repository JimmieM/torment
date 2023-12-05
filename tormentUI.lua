UIFrame = CreateFrame("Frame", "TormentUI", UIParent, "BasicFrameTemplateWithInset")
UIFrame:SetSize(500, 300) 
UIFrame:SetPoint("CENTER")
UIFrame:SetMovable(true)
UIFrame:EnableMouse(true)
UIFrame:RegisterForDrag("LeftButton")
UIFrame:SetScript("OnDragStart", UIFrame.StartMoving)
UIFrame:SetScript("OnDragStop", UIFrame.StopMovingOrSizing)

local title = UIFrame:CreateFontString(nil, "OVERLAY")
title:SetFontObject("GameFontHighlight")
title:SetPoint("TOP", UIFrame, "TOP", 0, -7)
title:SetText("Torment")

local clearButton = CreateFrame("Button", "ClearButton", UIFrame, "GameMenuButtonTemplate")
clearButton:SetPoint("TOPLEFT", 10, -5)
clearButton:SetSize(65, 18)
clearButton:SetText("Clear")

clearButton:SetScript("OnClick", function()
    CombatInteractions = {}
    ShowCombatDataUI()
end)
UIFrame:Hide()

function ShowCombatDataUI()
    local scrollFrame = CreateFrame("ScrollFrame", nil, UIFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetSize(460, 260)

    if UIFrame.content then
        for i, child in ipairs({UIFrame.content:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end
    else
        UIFrame.content = CreateFrame("Frame", nil, UIFrame)
    end

    local content = UIFrame.content
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

         -- headers
        local activeSummaryText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        activeSummaryText:SetPoint("TOPLEFT", 5, yOffsetActive)
        activeSummaryText:SetText("Shadow casts / uptime")

        local inactiveSummaryText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        inactiveSummaryText:SetPoint("TOPLEFT", 275, yOffsetActive)
        inactiveSummaryText:SetText("Holy casts / downtime")
               

        -- Display Buff Active Data Instances
        for _, activeInstance in ipairs(combatData.buffActiveData) do
            local activeText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            activeText:SetPoint("TOPLEFT", 5, yOffsetActive - 15)
            activeText:SetText(activeInstance.spellCounts ..
                                " / " .. activeInstance.uptime .. "s")
            yOffsetActive = yOffsetActive - 15
        end

        -- Display Buff Inactive Data Instances
        for _, inactiveInstance in ipairs(combatData.buffInactiveData) do
            local inactiveText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            inactiveText:SetPoint("TOPLEFT", 275, yOffsetInactive - 15) -- Positioned beside the active column
            inactiveText:SetText(inactiveInstance.spellCounts ..
                                    " / " .. inactiveInstance.uptime .. "s")
            yOffsetInactive = yOffsetInactive - 15
        end

        local totalActiveSpells = 0
        local totalActiveUptime = 0
        local totalInactiveSpells = 0
        local totalInactiveUptime = 0

        -- Calculate sums and total uptime for active and inactive segments
        for _, activeInstance in ipairs(combatData.buffActiveData) do
            totalActiveSpells = totalActiveSpells + activeInstance.spellCounts
            totalActiveUptime = totalActiveUptime + activeInstance.uptime
        end
        for _, inactiveInstance in ipairs(combatData.buffInactiveData) do
            totalInactiveSpells = totalInactiveSpells + inactiveInstance.spellCounts
            totalInactiveUptime = totalInactiveUptime + inactiveInstance.uptime
        end
    
        -- Calculate total combat duration and buff uptime percentage
        local totalCombatDuration = combatData.combatStartTime and (GetTime() - combatData.combatStartTime) or 0
        local buffUptimePercentage = totalCombatDuration > 0 and (totalActiveUptime / totalCombatDuration * 100) or 0

        yOffsetReducer = yOffsetReducer - 15

        local lowestYOffset = math.min(yOffsetActive, yOffsetInactive, yOffsetReducer)
        totalHeight = totalHeight - lowestYOffset + 10

         -- Create a summary text for active data
        local activeSummaryText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        activeSummaryText:SetPoint("TOPLEFT", 5, lowestYOffset - 20)
        activeSummaryText:SetText("Total shadow casts " .. totalActiveSpells ..
                                " / " .. totalActiveUptime .. "s")

        -- Create a summary text for inactive data
        local inactiveSummaryText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        inactiveSummaryText:SetPoint("TOPLEFT", 165, lowestYOffset - 20)
        inactiveSummaryText:SetText("Total holy casts " .. totalInactiveSpells ..
                                    " / " .. totalInactiveUptime .. "s" .. " -s " .. string.format("%.2f", buffUptimePercentage) .. "%")

        local inactiveSummaryText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        inactiveSummaryText:SetPoint("TOPLEFT", 355, lowestYOffset - 20)
        inactiveSummaryText:SetText("Total Smite/Penance: " .. combatData.allReducerCasts)
    end

    content:SetSize(380, totalHeight)
    scrollFrame:SetScrollChild(content)
end