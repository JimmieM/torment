UIFrame = nil;


function OpenUI()
    UIFrame:Show()
    ShowCombatDataUI()
end

SLASH_TORMENT1 = '/torment'
SlashCmdList.TORMENT = function()
    if UIFrame:IsShown() then
        UIFrame:Hide()
    else
        OpenUI()
    end
end