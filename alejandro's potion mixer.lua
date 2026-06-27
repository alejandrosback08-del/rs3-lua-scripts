--------------------------------------------------
-- Script Information
--------------------------------------------------

ScriptName = "Potion Mixer"
Author = "Alejandro"
ScriptVersion = "1.0.0"
ReleaseDate = "06-25-2026"

--[[
Changelog:
v1.0.0 - 06-25-2026
    - Initial release.
    - Loads the last bank preset automatically.
    - Detects missing ingredients and stops safely.
    - Uses the first inventory ingredient automatically.
    - Starts mixing through the crafting interface.
    - Waits for the mixing animation to finish.
    - Includes anti-idle support.
    - Displays tracked skills.
]]

local API = require("api")
local UTILS = require("utils")

local HERB_ANIM = 24896

API.SetDrawTrackedSkills(true)

--------------------------------------------------
-- Functions
--------------------------------------------------


local function LoadPreset()

    API.printlua("[INFO] Loading last bank preset...", 1)

    if Interact:NPC("Banker", "Load Last Preset from") then
        -- ok
    elseif Interact:Object("Bank chest", "Load Last Preset from") then
        -- ok
    elseif Interact:Object("Bank booth", "Load Last Preset from") then
        -- ok
    else
        API.printlua("[ERROR] No supported bank nearby.", 1)
        return false
    end

    UTILS.SleepUntil(function()
        return Inventory:IsFull()
    end, 3, "load preset")

    if not Inventory:IsFull() then
        API.printlua("[ERROR] Preset is incomplete.", 1)
        API.Write_LoopyLoop(false)
        return false
    end

    return true
end

local function UseFirstIngredient()

    API.printlua("[INFO] Using first ingredient...", 1)

    API.DoAction_Interface(0x24,0x5b,1,1473,5,0,API.OFF_ACT_GeneralInterface_route)

end

local function StartMixing()

    API.printlua("[INFO] Starting mixing...", 1)

    API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,API.OFF_ACT_GeneralInterface_Choose_option)

    local start = os.clock()

    while API.ReadPlayerAnim() ~= HERB_ANIM and API.Read_LoopyLoop() do

        -- Retry if mixing hasn't started after 900ms
        if os.clock() - start > 0.9 then

            API.printlua("[WARN] Retrying Mix button...", 1)

            API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,API.OFF_ACT_GeneralInterface_Choose_option)

            start = os.clock()
        end

        API.RandomSleep2(40, 0, 10)

    end

    API.printlua("[INFO] Mixing started.", 1)

end

local function WaitForMixing()

    API.printlua("[INFO] Waiting for mixing to finish...", 1)

    local idle = 0

    while idle < 20 and API.Read_LoopyLoop() do

        if API.ReadPlayerAnim() == HERB_ANIM then
            idle = 0
        else
            idle = idle + 1
        end

        API.RandomSleep2(60, 10, 20)

    end

    API.printlua("[INFO] Mixing finished.", 1)

end

--------------------------------------------------
-- Main Loop
--------------------------------------------------

API.printlua("[INFO] Potion mixer started.", 1)

while API.Read_LoopyLoop() do

    UTILS:antiIdle()

    if not LoadPreset() then
        break
    end

    UseFirstIngredient()
    StartMixing()
    WaitForMixing()

end

API.printlua("[INFO] Script stopped.", 1)