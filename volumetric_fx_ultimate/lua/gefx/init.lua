-- Volumetric FX Ultimate - Main Initialization Module
-- Provides Vulkan-optimized volumetric effects for BeamNG.drive

local M = {}

local coreModuleLoaded = false

function M.init()
    log('V', 'VolumetricFX', 'Initializing Volumetric FX Ultimate v1.0.0')
    log('V', 'VolumetricFX', 'Vulkan API Support: Enabled')
    
    -- Load core modules
    local success, skyModule = pcall(require, 'gefx.volumetric_sky')
    if success then
        skyModule.init()
        log('V', 'VolumetricFX', 'Sky module loaded successfully')
    else
        log('E', 'VolumetricFX', 'Failed to load sky module: ' .. tostring(skyModule))
    end
    
    local success, cloudModule = pcall(require, 'gefx.volumetric_clouds')
    if success then
        cloudModule.init()
        log('V', 'VolumetricFX', 'Cloud module loaded successfully')
    else
        log('E', 'VolumetricFX', 'Failed to load cloud module: ' .. tostring(cloudModule))
    end
    
    local success, fogModule = pcall(require, 'gefx.volumetric_fog')
    if success then
        fogModule.init()
        log('V', 'VolumetricFX', 'Fog module loaded successfully')
    else
        log('E', 'VolumetricFX', 'Failed to load fog module: ' .. tostring(fogModule))
    end
    
    local success, backfireModule = pcall(require, 'gefx.backfire_system')
    if success then
        backfireModule.init()
        log('V', 'VolumetricFX', 'Backfire module loaded successfully')
    else
        log('E', 'VolumetricFX', 'Failed to load backfire module: ' .. tostring(backfireModule))
    end
    
    -- Register configuration persistence
    M.loadConfig()
    
    coreModuleLoaded = true
    log('V', 'VolumetricFX', 'Volumetric FX Ultimate initialization complete')
end

function M.onVehicleLoaded(vehicle)
    if not coreModuleLoaded then return end
    
    local backfireModule = require('gefx.backfire_system')
    backfireModule.onVehicleLoaded(vehicle)
end

function M.onVehicleUnloaded(vehicle)
    if not coreModuleLoaded then return end
    
    local backfireModule = require('gefx.backfire_system')
    backfireModule.onVehicleUnloaded(vehicle)
end

function M.saveConfig(config)
    local settingsPath = '/settings/volumetric_fx_ultimate.json'
    local file = io.open(settingsPath, 'w')
    if file then
        file:write(json.encode(config, {pretty = true}))
        file:close()
        log('V', 'VolumetricFX', 'Configuration saved')
    end
end

function M.loadConfig()
    local settingsPath = '/settings/volumetric_fx_ultimate.json'
    local file = io.open(settingsPath, 'r')
    if file then
        local content = file:read('*all')
        file:close()
        local config = json.decode(content)
        if config then
            log('V', 'VolumetricFX', 'Configuration loaded from file')
            return config
        end
    end
    
    -- Default configuration
    return {
        sky = {
            enabled = true,
            intensity = 1.0,
            sunsetColorR = 1.0, sunsetColorG = 0.4, sunsetColorB = 0.2,
            nightIntensity = 0.3,
            starBrightness = 0.8
        },
        clouds = {
            enabled = true,
            density = 0.6,
            coverage = 0.5,
            speed = 0.02,
            height = 2000,
            type = "cumulus",
            volumetricLighting = true
        },
        fog = {
            enabled = true,
            density = 0.002,
            heightFalloff = 0.001,
            colorR = 0.7, colorG = 0.75, colorB = 0.8,
            groundFogEnabled = true,
            groundFogHeight = 50
        },
        backfire = {
            enabled = true,
            intensity = 1.0,
            particleCount = 30,
            flameSize = 1.5,
            duration = 0.3,
            screenShake = true,
            soundEnabled = true
        },
        quality = "high"
    }
end

function M.getQualitySettings(qualityLevel)
    local presets = {
        low = {
            cloudSteps = 8,
            fogSteps = 16,
            shadowResolution = 512,
            particleLimit = 50
        },
        medium = {
            cloudSteps = 16,
            fogSteps = 32,
            shadowResolution = 1024,
            particleLimit = 100
        },
        high = {
            cloudSteps = 32,
            fogSteps = 64,
            shadowResolution = 2048,
            particleLimit = 200
        },
        ultra = {
            cloudSteps = 64,
            fogSteps = 128,
            shadowResolution = 4096,
            particleLimit = 500
        }
    }
    return presets[qualityLevel] or presets.high
end

return M
