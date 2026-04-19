
-- Volumetric FX Ultimate - Main Initialization
-- Author: GefX Studios
-- API: DX11 Optimized

local M = {}
local configPath = "gefx_volumetric_config.json"
local loaded = false

-- Default Configuration
M.config = {
    enabled = true,
    sky = { intensity = 1.0, sunsetBoost = 1.5, starsVisible = true },
    clouds = { density = 0.6, coverage = 0.5, speed = 0.05, type = "cumulus" },
    fog = { density = 0.002, height = 50, color = {0.8, 0.9, 1.0} },
    backfire = { enabled = true, intensity = 1.2, scale = 1.0, colorShift = 0 }
}

-- Load Config
local function loadConfig()
    local success, data = pcall(serialize.readJson, configPath)
    if success and data then
        M.config = data
    end
end

-- Save Config
local function saveConfig()
    serialize.writeJson(configPath, M.config)
end

-- Apply Effects based on Config
function M.applyEffects()
    if not M.config.enabled then
        M.disableAll()
        return
    end

    -- Sky
    SkyBox:setSunIntensity(M.config.sky.intensity)
    SkyBox:setAtmosphereDensity(1.0 - (M.config.fog.density * 100)) 
    
    -- Clouds (Handled via material uniform updates in the app loop usually, but we trigger initial state)
    -- Note: In BeamNG, dynamic material updates often require specific manager calls. 
    -- For this mod, we rely on the UI App to push uniforms every frame or on change.
    
    -- Fog
    Environment:setFogDensity(M.config.fog.density)
    Environment:setFogColor(unpack(M.config.fog.color))
    
    -- Backfire Particles
    if M.config.backfire.enabled then
        ParticleSystem:enableEmitter("backfire_main")
        ParticleSystem:setScale("backfire_main", M.config.backfire.scale)
    else
        ParticleSystem:disableEmitter("backfire_main")
    end
    
    log("gefx", "Volumetric FX Applied: Sky=" .. tostring(M.config.sky.intensity) .. " Fog=" .. tostring(M.config.fog.density))
end

function M.disableAll()
    Environment:setFogDensity(0.0005) -- Default low fog
    ParticleSystem:disableEmitter("backfire_main")
end

function M.onScriptMount()
    log("gefx", "Volumetric FX Ultimate Mounting...")
    loadConfig()
    
    -- Register a custom event for UI updates
    core_modules.registerEvent("gefx_update_config", "onGefxUpdateConfig")
    
    -- Initial apply
    timer.schedule(0.5, function() M.applyEffects() end)
    
    loaded = true
end

function M.onScriptUnmount()
    M.disableAll()
    log("gefx", "Volumetric FX Ultimate Unmounted.")
end

function M.onGefxUpdateConfig(newConfig)
    M.config = newConfig
    saveConfig()
    M.applyEffects()
end

return M
