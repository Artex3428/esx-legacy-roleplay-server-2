local isProne = false
local isCrouched = false
local isCrawling = false
local inAction = false
local proneType = 'onfront'
local lastKeyPress = 0
local walkstyle = nil
local forceEndProne = false


-- Utils --

---Checks if the player should be able to crawl or not
---@param playerPed number
---@return boolean
local function CanPlayerCrouchCrawl(playerPed)
    if not IsPedOnFoot(playerPed) or IsPedJumping(playerPed) or IsPedFalling(playerPed) or IsPedInjured(playerPed) or IsPedInMeleeCombat(playerPed) or IsPedRagdoll(playerPed) then
        return false
    end

    return true
end

---Load animation dictionary
---@param dict string
local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
		Wait(0)
	end
end

---Loads clipset/walkstyle
---@param clipset string
local function LoadClipSet(clipset)
    RequestClipSet(clipset)
    while not HasClipSetLoaded(clipset) do
        Wait(0)
    end
end

---Sets clipset/walkstyle
---@param clipset string
local function SetPlayerClipset(clipset)
    LoadClipSet(clipset)
    SetPedMovementClipset(PlayerPedId(), clipset, 0.5)
    RemoveClipSet(clipset)
end

---Returns if the ped is aiming a weapon
---@param ped number
---@return boolean
local function IsPedAiming(ped)
    return GetPedConfigFlag(ped, 78, true) == 1 and true or false
end

---Plays an animation on the ped. (Loads an unloads needed anim dict)
---@param ped number
---@param animDict string
---@param animName string
---@param blendInSpeed number|nil
---@param blendOutSpeed number|nil
---@param duration number|nil
---@param startTime number|nil
local function PlayAnimOnce(ped, animDict, animName, blendInSpeed, blendOutSpeed, duration, startTime)
    LoadAnimDict(animDict)
    TaskPlayAnim(ped, animDict, animName, blendInSpeed or 2.0, blendOutSpeed or 2.0, duration or -1, 0, startTime or 0.0, false, false, false)
    RemoveAnimDict(animDict)
end

---Smoothly changes the ped's heading
---@param ped number
---@param amount number
---@param time number ms
local function ChangeHeadingSmooth(ped, amount, time)
    local times = math.abs(amount)
    local test = amount / times
    local wait = time / times

    for _i = 1, times do
        Wait(wait)
        SetEntityHeading(ped, GetEntityHeading(ped) + test)
    end
end


-- Crouching --

---Resets the crouch effect (clipsets etc.)
local function ResetCrouch()
    local playerPed = PlayerPedId()

    ResetPedStrafeClipset(playerPed)
    ResetPedWeaponMovementClipset(playerPed)
    SetPedMaxMoveBlendRatio(playerPed, 1.0)
    SetPedCanPlayAmbientAnims(playerPed, true)

    -- Applies the previous walk style (or resets to default if non had been set)
    if walkstyle ~= nil then
        SetPlayerClipset(walkstyle)
    else
        ResetPedMovementClipset(playerPed, 0.5)
    end

    RemoveAnimSet('move_ped_crouched')
end

---Starts the crouch loop
local function CrouchLoop()
    while isCrouched do
        local playerPed = PlayerPedId()

        -- Checks if the player is falling, in vehicle, dead etc.
        if not CanPlayerCrouchCrawl(playerPed) then
            isCrouched = false
            break
        end

        -- Limit the speed that the player can walk when aiming
        if IsPedAiming(playerPed) then
            SetPedMaxMoveBlendRatio(playerPed, 0.15)
        end

        -- This blocks the ped from standing up and playing idle anims (this needs to be looped)
        SetPedCanPlayAmbientAnims(playerPed, false)

        -- Disables "INPUT_DUCK" and blocks action mode
        DisableControlAction(0, 36, true)
        if IsPedUsingActionMode(playerPed) == 1 then
            SetPedUsingActionMode(playerPed, false, -1, 'DEFAULT_ACTION')
        end

        -- Disable first person
        DisableFirstPersonCamThisFrame()

        Wait(0)
    end

    TriggerEvent('crouch_crawl:onCrouch', false)

    -- Reset walk style and ped variables
    ResetCrouch()
end

---Starts crouching
local function StartCrouch()
    isCrouched = true
    LoadClipSet('move_ped_crouched')
    local playerPed = PlayerPedId()

    -- Force leave stealth mode
    if GetPedStealthMovement(playerPed) == 1 then
        SetPedStealthMovement(playerPed, false, 'DEFAULT_ACTION')
        Wait(100)
    end

    -- Force leave first person view
    if GetFollowPedCamViewMode() == 4 then
        SetFollowPedCamViewMode(0) -- THIRD_PERSON_NEAR
    end

    walkstyle = GetPedWalkstyle(playerPed) or walkstyle
    SetPedMovementClipset(playerPed, 'move_ped_crouched', 0.6)
    SetPedStrafeClipset(playerPed, 'move_ped_crouched_strafing')

    -- For other scripts to use
    TriggerEvent('crouch_crawl:onCrouch', true)

    CreateThread(CrouchLoop)
end

---@param playerPed number
---@return boolean success
local function AttemptCrouch(playerPed)
    if CanPlayerCrouchCrawl(playerPed) and IsPedHuman(playerPed) then
        StartCrouch()
        return true
    else
        return false
    end
end

---Disables a control until it's key has been released
---@param padIndex integer
---@param control integer
local function DisableControlUntilReleased(padIndex, control)
    CreateThread(function()
        while IsDisabledControlPressed(padIndex, control) do
            DisableControlAction(padIndex, control, true)
            Wait(0)
        end
    end)
end

---Called when the crouch key is pressed
local function CrouchKeyPressed()
    -- If we already are doing something, then don't continue
    if inAction then
        return
    end

    -- Don't start/stop crouching if we are in the pause menu or the NUI is in focus
    if IsPauseMenuActive() or IsNuiFocused() then
        return
    end

    -- If crouched then stop crouching
    if isCrouched then
        isCrouched = false
        local crouchKey = GetControlInstructionalButton(0, `+crouch` | 0x80000000, false)
        local lookBehindKey = GetControlInstructionalButton(0, 26, false) -- INPUT_LOOK_BEHIND

        -- Disable look behind if the crouch and look behind keys are the same
        if crouchKey == lookBehindKey then
            DisableControlUntilReleased(0, 26) -- INPUT_LOOK_BEHIND
        end

        return
    end

    -- Get the player ped
    local playerPed = PlayerPedId()

    -- Check if we can actually crouch and check if the player ped is humanoid
    if not CanPlayerCrouchCrawl(playerPed) or not IsPedHuman(playerPed) then
        return
    end

    -- Get +crouch, INPUT_LOOK_BEHIND and INPUT_DUCK controls
    local crouchKey = GetControlInstructionalButton(0, `+crouch` | 0x80000000, false)
    local lookBehindKey = GetControlInstructionalButton(0, 26, false) -- INPUT_LOOK_BEHIND
    local duckKey = GetControlInstructionalButton(0, 36, false) -- INPUT_DUCK

    -- Disable look behind if the crouch and look behind keys are the same
    if crouchKey == lookBehindKey then
        DisableControlUntilReleased(0, 26) -- INPUT_LOOK_BEHIND
    end

    -- If the crouch and duck key are the same
    if crouchKey == duckKey then
        if Config.CrouchOverrideStealthMode then
            DisableControlAction(0, 36, true) -- Disable INPUT_DUCK this frame
        elseif not isProne then
            local timer = GetGameTimer()

            -- If we are in stealth mode and we have already pressed the button in the last second
            if GetPedStealthMovement(playerPed) == 1 and timer - lastKeyPress < 1000 then
                DisableControlAction(0, 36, true) -- Disable INPUT_DUCK this frame
                lastKeyPress = 0
            else
                lastKeyPress = timer
                return
            end
        end
    end

    -- Start to crouch
    StartCrouch()

    -- If we are prone play an animation from prone to crouch
    if isProne then
        inAction = true
        isProne = false
        PlayAnimOnce(playerPed, 'get_up@directional@transition@prone_to_knees@crawl', 'front', nil, nil, 780)
        Wait(780)
        inAction = false
    end
end


-- Crawling --

---@param playerPed number
---@return boolean
local function ShouldPlayerDiveToCrawl(playerPed)
    if IsPedRunning(playerPed) or IsPedSprinting(playerPed) then
        return true
    end

    return false
end

---Stops the player from being prone
---@param force boolean If forced then no exit anim is played
local function stopPlayerProne(force)
    isProne = false
    forceEndProne = force
end

---@param playerPed number
---@param heading number|nil
---@param blendInSpeed number|nil
local function PlayIdleCrawlAnim(playerPed, heading, blendInSpeed)
    local playerCoords = GetEntityCoords(playerPed)
    TaskPlayAnimAdvanced(playerPed, 'move_crawl', proneType..'_fwd', playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, heading or GetEntityHeading(playerPed), blendInSpeed or 2.0, 2.0, -1, 2, 1.0, false, false)
end

---@param forceEnd boolean
local function PlayExitCrawlAnims(forceEnd)
    if not forceEnd then
        inAction = true
        local playerPed = PlayerPedId()

        if proneType == 'onfront' then
            PlayAnimOnce(playerPed, 'get_up@directional@transition@prone_to_knees@crawl', 'front', nil, nil, 780)

            -- Only stand fully up if we are not crouching
            if not isCrouched then
                Wait(780)
                PlayAnimOnce(playerPed, 'get_up@directional@movement@from_knees@standard', 'getup_l_0', nil, nil, 1300)
            end
        else
            PlayAnimOnce(playerPed, 'get_up@directional@transition@prone_to_seated@crawl', 'back', 16.0, nil, 950)

            -- Only stand fully up if we are not crouching
            if not isCrouched then
                Wait(950)
                PlayAnimOnce(playerPed, 'get_up@directional@movement@from_seated@standard', 'get_up_l_0', nil, nil, 1300)
            end
        end
    end
end

---Crawls one "step" forward/backward
---@param playerPed number
---@param type string
---@param direction string
local function Crawl(playerPed, type, direction)
    isCrawling = true

    TaskPlayAnim(playerPed, 'move_crawl', type..'_'..direction, 8.0, -8.0, -1, 2, 0.0, false, false, false)

    local time = {
        ['onfront'] = {
            ['fwd'] = 820,
            ['bwd'] = 990
        },
        ['onback'] = {
            ['fwd'] = 1200,
            ['bwd'] = 1200
        }
    }

    SetTimeout(time[type][direction], function()
        isCrawling = false
    end)
end

---Flips the player when crawling
---@param playerPed number
local function CrawlFlip(playerPed)
    inAction = true
    local heading = GetEntityHeading(playerPed)

    if proneType == 'onfront' then
        proneType = 'onback'

        PlayAnimOnce(playerPed, 'get_up@directional_sweep@combat@pistol@front', 'front_to_prone', 2.0)
        ChangeHeadingSmooth(playerPed, -18.0, 3600)
    else
        proneType = 'onfront'

        PlayAnimOnce(playerPed, 'move_crawlprone2crawlfront', 'back', 2.0, nil, -1)
        ChangeHeadingSmooth(playerPed, 12.0, 1700)
    end

    PlayIdleCrawlAnim(playerPed, heading + 180.0)
    Wait(400)
    inAction = false
end

---The crawl loop
local function CrawlLoop()
    Wait(400)

    while isProne do
        local playerPed = PlayerPedId()

        -- Checks if the player is falling, in vehicle, dead etc.
        if not CanPlayerCrouchCrawl(playerPed) or IsEntityInWater(playerPed) then
            ClearPedTasks(playerPed)
            stopPlayerProne(true)
            break
        end

        -- Handles forwad/backward movement
        local forward, backwards = IsControlPressed(0, 32), IsControlPressed(0, 33) -- INPUT_MOVE_UP_ONLY, INPUT_MOVE_DOWN_ONLY
        if not isCrawling then
            if forward then -- Forward
                Crawl(playerPed, proneType, 'fwd')
            elseif backwards then -- Back
                Crawl(playerPed, proneType, 'bwd')
            end
        end

        -- Moving left/right
        if IsControlPressed(0, 34) then -- INPUT_MOVE_LEFT_ONLY
            if isCrawling then
                local headingDiff = forward and 1.0 or -1.0
                SetEntityHeading(playerPed, GetEntityHeading(playerPed) + headingDiff)
            else
                inAction = true
                if proneType == 'onfront' then
                    local playerCoords = GetEntityCoords(playerPed)
                    TaskPlayAnimAdvanced(playerPed, 'move_crawlprone2crawlfront', 'left', playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, GetEntityHeading(playerPed), 2.0, 2.0, -1, 2, 0.1, false, false)
                    ChangeHeadingSmooth(playerPed, -10.0, 300)
                    Wait(700)
                else
                    PlayAnimOnce(playerPed, 'get_up@directional_sweep@combat@pistol@left', 'left_to_prone')
                    ChangeHeadingSmooth(playerPed, 25.0, 400)
                    PlayIdleCrawlAnim(playerPed)
                    Wait(600)
                end
                inAction = false
            end
        elseif IsControlPressed(0, 35) then -- INPUT_MOVE_RIGHT_ONLY
            if isCrawling then
                local headingDiff = backwards and 1.0 or -1.0
                SetEntityHeading(playerPed, GetEntityHeading(playerPed) + headingDiff)
            else
                inAction = true
                if proneType == 'onfront' then
                    local playerCoords = GetEntityCoords(playerPed)
                    TaskPlayAnimAdvanced(playerPed, 'move_crawlprone2crawlfront', 'right', playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, GetEntityHeading(playerPed), 2.0, 2.0, -1, 2, 0.1, false, false)
                    ChangeHeadingSmooth(playerPed, 10.0, 300)
                    Wait(700)
                else
                    PlayAnimOnce(playerPed, 'get_up@directional_sweep@combat@pistol@right', 'right_to_prone')
                    ChangeHeadingSmooth(playerPed, -25.0, 400)
                    PlayIdleCrawlAnim(playerPed)
                    Wait(600)
                end
                inAction = false
            end
        end

        -- Flipping around
        if not isCrawling then
            if IsControlPressed(0, 22) then -- INPUT_JUMP
                CrawlFlip(playerPed)
            end
        end

        Wait(0)
    end

    TriggerEvent('crouch_crawl:onCrawl', false)

    -- If the crawling wasn't forcefully ended, then play the get up animations
    PlayExitCrawlAnims(forceEndProne)

    -- Reset variabels
    isCrawling = false
    inAction = false
    forceEndProne = false
    proneType = 'onfront'
    SetPedConfigFlag(PlayerPedId(), 48, false) -- CPED_CONFIG_FLAG_BlockWeaponSwitching

    -- Unload animation dictionaries
    RemoveAnimDict('move_crawl')
    RemoveAnimDict('move_crawlprone2crawlfront')
end

---Gets called when the crawl key is pressed
local function CrawlKeyPressed()
    -- If we already are doing something, then don't continue
    if inAction then
        return
    end

    -- Don't start/stop to crawl if we are in the pause menu or the NUI is in focus
    if IsPauseMenuActive() or IsNuiFocused() then
        return
    end

    if not isCrouched then
        return
    end

    -- If already prone, then stop
    if isProne then
        isProne = false
        return
    end

    -- If we are crouching we should stop that first
    local wasCrouched = false
    if isCrouched then
        isCrouched = false
        wasCrouched = true
    end

    local playerPed = PlayerPedId()
    if not CanPlayerCrouchCrawl(playerPed) or IsEntityInWater(playerPed) or not IsPedHuman(playerPed) then
        return
    end
    inAction = true

    -- If we are pointing then stop pointing
    if Pointing then
        Pointing = false
    end

    isProne = true
    SetPedConfigFlag(playerPed, 48, true) -- CPED_CONFIG_FLAG_BlockWeaponSwitching

    -- Force leave stealth mode
    if GetPedStealthMovement(playerPed) == 1 then
        SetPedStealthMovement(playerPed, false, 'DEFAULT_ACTION')
        Wait(100)
    end

    -- Load animations that the crawling is going to use
    LoadAnimDict('move_crawl')
    LoadAnimDict('move_crawlprone2crawlfront')

    if ShouldPlayerDiveToCrawl(playerPed) then
        PlayAnimOnce(playerPed, 'explosions', 'react_blown_forwards', nil, 3.0)
        Wait(1100)
    elseif wasCrouched then
        PlayAnimOnce(playerPed, 'amb@world_human_sunbathe@male@front@enter', 'enter', nil, nil, -1, 0.3)
        Wait(1500)
    else
        PlayAnimOnce(playerPed, 'amb@world_human_sunbathe@male@front@enter', 'enter')
        Wait(3000)
    end

    -- Set the player into the idle position (but only if we can still crawl)
    if CanPlayerCrouchCrawl(playerPed) and not IsEntityInWater(playerPed) then
        PlayIdleCrawlAnim(playerPed, nil, 3.0)
    end

    TriggerEvent('crouch_crawl:onCrawl', true)

    inAction = false
    CreateThread(CrawlLoop)
end


-- Commands & KeyMapping --
if Config.CrouchEnabled then
    if Config.CrouchKeybindEnabled then
        RegisterKeyMapping('+crouch', Config.Localization['crouch_keymapping'], 'keyboard', Config.CrouchKeybind)
        RegisterCommand('+crouch', function() CrouchKeyPressed() end, false)
        RegisterCommand('-crouch', function() end, false) -- This needs to be here to prevent warnings in chat
    end
    RegisterCommand('crouch', function()
        if isCrouched then
            isCrouched = false
            return
        end

        AttemptCrouch(PlayerPedId())
    end, false)
    TriggerEvent('chat:addSuggestion', '/crouch', Config.Localization['crouch_chat_suggestion'])
end

if Config.CrawlEnabled then
    if Config.CrawlKeybindEnabled then

        RegisterKeyMapping('+crawl', Config.Localization['crawl_keymapping'], 'keyboard', Config.CrawlKeybind)
        RegisterCommand('+crawl', function() CrawlKeyPressed() end, false)
        RegisterCommand('-crawl', function() end, false) -- This needs to be here to prevent warnings in chat

    end
    RegisterCommand('crawl', function() CrawlKeyPressed() end, false)
    TriggerEvent('chat:addSuggestion', '/crawl', Config.Localization['crawl_chat_suggestion'])
end


-- Exports --
---Returns if the player is crouched
---@return boolean
local function IsPlayerCrouched()
	return isCrouched
end
exports('IsPlayerCrouched', IsPlayerCrouched)

---Returns if the player is prone (both when laying still and when moving)
---@return boolean
local function IsPlayerProne()
	return isProne
end
exports('IsPlayerProne', IsPlayerProne)

---Returns if the player is crawling (only when moving forward/backward)
---@return boolean
local function IsPlayerCrawling()
	return isCrawling
end
exports('IsPlayerCrawling', IsPlayerCrawling)

---Returns either "onfront" or "onback", this can be used to check if the player is on his back or on his stomach. NOTE: This will still return a string even if the player is not prone. Use IsPlayerProne() to check if the player is prone.
---@return string
local function GetPlayerProneType()
	return proneType
end
exports('GetPlayerProneType', GetPlayerProneType)

-- Usefull to call if hte player gets handcuffed etc.
exports('StopPlayerProne', stopPlayerProne)
