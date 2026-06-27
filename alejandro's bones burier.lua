--------------------------------------------------
-- Script Information
--------------------------------------------------

ScriptName = "Bones Burier"
Author = "Alejandro"
ScriptVersion = "1.0.0"
ReleaseDate = "06-27-2026"

--[[
Changelog:
v1.0.0 - 06-27-2026
    - Initial release.
    - Automatically loads the last bank preset.
    - Detects any inventory item containing "bones" in its name.
    - Buries bones using Action Bar keybind (Key 1).
    - Automatically maintains buff uptime.
    - Reactivates the buff only after it expires to avoid wasting duration.
    - Stops the script if the buff cannot be activated.
    - Supports Banker, Bank chest and Bank booth.
]]

local API = require("api")
local UTILS = require("utils")

API.SetDrawTrackedSkills(true)

--------------------------------------------------
-- Constants
--------------------------------------------------

local BUFF_ID = 52805
local ACTION_BAR_KEY = 49 -- Keyboard key "1"

--------------------------------------------------
-- Functions
--------------------------------------------------

local function HasBones()

    for _, item in ipairs(Inventory:GetItems()) do
        if item.name:lower():find("bones") then
            return true
        end
    end

    return false
end

--------------------------------------------------

local function MaintainBuff()

    if API.Buffbar_GetIDstatus(BUFF_ID).found then
        return true
    end

    API.printlua("[INFO] Buff expired. Activating...", 1)

    API.DoAction_Inventory1(
        BUFF_ID,
        0,
        1,
        API.OFF_ACT_GeneralInterface_route
    )

    UTILS.SleepUntil(function()
        return API.Buffbar_GetIDstatus(BUFF_ID).found
    end, 3, "activate buff")

    if not API.Buffbar_GetIDstatus(BUFF_ID).found then
        API.printlua("[ERROR] No powder of burials found!!", 1)
        API.Write_LoopyLoop(false)
        return false
    end

    API.printlua("[INFO] Buff activated.", 1)

    return true
end

--------------------------------------------------

local function LoadPreset()

    API.printlua("[INFO] Loading last bank preset...", 1)

    if Interact:NPC("Banker", "Load Last Preset from") then
    elseif Interact:Object("Bank chest", "Load Last Preset from") then
    elseif Interact:Object("Bank booth", "Load Last Preset from") then
    else
        API.printlua("[ERROR] No supported bank nearby.", 1)
        return false
    end

    UTILS.SleepUntil(function()
        return HasBones()
    end, 3, "load preset")

    if not HasBones() then
        API.printlua("[ERROR] OUT OF BONES!!", 1)
        API.Write_LoopyLoop(false)
        return false
    end

    return true
end

--------------------------------------------------

local function BuryBones()

    API.printlua("[INFO] Burying bones...", 1)

    while API.Read_LoopyLoop() and HasBones() do

        if not MaintainBuff() then
            return false
        end

        API.KeyboardPress4(49)

        API.RandomSleep2(80, 20, 120)

    end

    API.printlua("[INFO] Finished burying bones.", 1)

    return true
end

--------------------------------------------------
-- Main
--------------------------------------------------

while API.Read_LoopyLoop() do

    UTILS:antiIdle()

    if not LoadPreset() then
        break
    end

    if not MaintainBuff() then
        break
    end

    if not BuryBones() then
        break
    end

    API.RandomSleep2(600, 200, 1000)

end

API.Write_LoopyLoop(false)