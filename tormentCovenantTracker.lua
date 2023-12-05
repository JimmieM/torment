local trackedBuffID = 322105 -- Shadow Covenant
local trackedBuffSpellIDs = {8092, 47540, 32379} -- Spell IDs to track when Shadow Covenant is active
local trackedNoBuffSpellIDs = {585, 47540} -- Spell IDs to track when Shadow Covenant is not active
local trackedAllReducerSpellIDs = {585, 47540} -- Spell IDs to track regardless of Shadow Covenant status

local combatStartTime = nil
local inCombat = false
local buffActive = false
local currentCombatData = {}

if not CombatInteractions then
    CombatInteractions = {}
end

local function tContains(table, item)
    for _, value in pairs(table) do
        if value == item then
            return true
        end
    end
    return false
end


local function checkForBuff(buffID)
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        if spellId == buffID then
            return true
        end
    end
    return false
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Enters combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Leaves combat
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:RegisterEvent("UNIT_AURA")

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        buffActive = false
        combatStartTime = GetTime()
        currentCombatData = {
            encounterName = UnitName("target") or "Unknown",
            buffActiveData = {},
            buffInactiveData = {},
            combatStartTime = combatStartTime,
            allReducerCasts = 0,
            lastBuffChange = GetTime()
        }

        -- Initial entry for the inactive period
        table.insert(currentCombatData.buffInactiveData, { spellCounts = 0, uptime = 0 })
    elseif event == "PLAYER_REGEN_ENABLED" then
        local currentSegment = buffActive and currentCombatData.buffActiveData or currentCombatData.buffInactiveData
        local latestSegment = currentSegment[#currentSegment]

        latestSegment.uptime = math.floor(GetTime() - currentCombatData.lastBuffChange)
        table.insert(CombatInteractions, currentCombatData)

        currentCombatData = {}
        combatStartTime = nil 

        ShowCombatDataUI()
    elseif inCombat and event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit == "player" then
            -- Count all reducer spell casts
            if tContains(trackedAllReducerSpellIDs, spellID) then
                currentCombatData.allReducerCasts = currentCombatData.allReducerCasts + 1
            end
    
            -- Count spells based on whether the buff is active or not
            local currentSegment = buffActive and currentCombatData.buffActiveData or currentCombatData.buffInactiveData
            if #currentSegment == 0 then
                -- If no segment exists, start a new segment
                table.insert(currentSegment, { spellCounts = 0, uptime = 0, startTime = currentCombatData.lastBuffChange or GetTime() })
            end
            local latestSegment = currentSegment[#currentSegment]
    
            if (buffActive and tContains(trackedBuffSpellIDs, spellID)) or
               (not buffActive and tContains(trackedNoBuffSpellIDs, spellID)) then
                latestSegment.spellCounts = latestSegment.spellCounts + 1
            end
        end
    elseif inCombat and event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            local hasBuff = checkForBuff(trackedBuffID)
            if hasBuff ~= buffActive then
                -- Finalize the current segment
                local currentSegment = buffActive and currentCombatData.buffActiveData or currentCombatData.buffInactiveData
                if #currentSegment > 0 then
                    local latestSegment = currentSegment[#currentSegment]
                    latestSegment.uptime = latestSegment.startTime and math.floor(GetTime() - latestSegment.startTime) or (combatStartTime and math.floor(GetTime() - combatStartTime) or 0)
                end
    
                -- Start a new segment
                buffActive = hasBuff
                local newSegmentData = { spellCounts = 0, uptime = 0, startTime = GetTime() }
                local targetSegment = buffActive and currentCombatData.buffActiveData or currentCombatData.buffInactiveData
                table.insert(targetSegment, newSegmentData)
                currentCombatData.lastBuffChange = GetTime()
            end
        end
    end
end)
