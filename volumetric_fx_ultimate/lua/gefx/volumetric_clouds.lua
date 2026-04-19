-- Volumetric Clouds Module - Vulkan Optimized
-- Advanced cloud rendering with multiple types and volumetric lighting

local M = {}

local cloudsEnabled = true
local cloudDensity = 0.6
local cloudCoverage = 0.5
local cloudSpeed = 0.02
local cloudHeight = 2000
local cloudType = "cumulus"
local volumetricLighting = true
local cloudAnimationTime = 0

-- Cloud type definitions
M.cloudTypes = {
    cumulus = {name = "Cumulus", description = "Fluffy white clouds"},
    stratus = {name = "Stratus", description = "Layered overcast clouds"},
    cirrus = {name = "Cirrus", description = "Thin wispy high clouds"},
    storm = {name = "Storm", description = "Dark heavy storm clouds"}
}

function M.init()
    log('V', 'VolumetricClouds', 'Initializing volumetric cloud system')
    M.setupCloudParameters()
end

function M.setupCloudParameters()
    local config = require('gefx.init').loadConfig()
    if config and config.clouds then
        cloudsEnabled = config.clouds.enabled
        cloudDensity = config.clouds.density or 0.6
        cloudCoverage = config.clouds.coverage or 0.5
        cloudSpeed = config.clouds.speed or 0.02
        cloudHeight = config.clouds.height or 2000
        cloudType = config.clouds.type or "cumulus"
        volumetricLighting = config.clouds.volumetricLighting or true
    end
    
    M.applyCloudSettings()
end

function M.applyCloudSettings()
    if not cloudsEnabled then
        M.setCloudVisibility(false)
        return
    end
    
    M.setCloudVisibility(true)
    
    -- Configure cloud rendering parameters for Vulkan pipeline
    M.setCloudMaterialParams({
        density = cloudDensity,
        coverage = cloudCoverage,
        height = cloudHeight,
        speed = cloudSpeed,
        type = cloudType,
        volumetricLighting = volumetricLighting
    })
end

function M.update(dt)
    if not cloudsEnabled then return end
    
    cloudAnimationTime = cloudAnimationTime + dt * cloudSpeed
    
    -- Update cloud positions based on wind direction
    local windOffset = {
        x = math.sin(cloudAnimationTime) * 0.1,
        y = math.cos(cloudAnimationTime * 0.7) * 0.05
    }
    
    M.setWindOffset(windOffset)
end

function M.setCloudMaterialParams(params)
    M.cachedParams = params
    log('D', 'VolumetricClouds', 'Cloud parameters updated: type=' .. tostring(params.type) .. ', density=' .. tostring(params.density))
end

function M.setCloudVisibility(visible)
    cloudsEnabled = visible
    log('D', 'VolumetricClouds', 'Cloud visibility set to: ' .. tostring(visible))
end

function M.setEnabled(enabled)
    cloudsEnabled = enabled
    M.applyCloudSettings()
    
    local config = require('gefx.init').loadConfig()
    config.clouds.enabled = enabled
    require('gefx.init').saveConfig(config)
end

function M.setDensity(density)
    cloudDensity = math.max(0.1, math.min(1.0, density))
    M.applyCloudSettings()
    
    local config = require('gefx.init').loadConfig()
    config.clouds.density = cloudDensity
    require('gefx.init').saveConfig(config)
end

function M.setCoverage(coverage)
    cloudCoverage = math.max(0.0, math.min(1.0, coverage))
    M.applyCloudSettings()
    
    local config = require('gefx.init').loadConfig()
    config.clouds.coverage = cloudCoverage
    require('gefx.init').saveConfig(config)
end

function M.setSpeed(speed)
    cloudSpeed = math.max(0.0, math.min(0.1, speed))
    M.applyCloudSettings()
    
    local config = require('gefx.init').loadConfig()
    config.clouds.speed = cloudSpeed
    require('gefx.init').saveConfig(config)
end

function M.setHeight(height)
    cloudHeight = math.max(500, math.min(5000, height))
    M.applyCloudSettings()
    
    local config = require('gefx.init').loadConfig()
    config.clouds.height = cloudHeight
    require('gefx.init').saveConfig(config)
end

function M.setType(type)
    if M.cloudTypes[type] then
        cloudType = type
        M.applyCloudSettings()
        
        local config = require('gefx.init').loadConfig()
        config.clouds.type = cloudType
        require('gefx.init').saveConfig(config)
    end
end

function M.setVolumetricLighting(enabled)
    volumetricLighting = enabled
    M.applyCloudSettings()
    
    local config = require('gefx.init').loadConfig()
    config.clouds.volumetricLighting = volumetricLighting
    require('gefx.init').saveConfig(config)
end

function M.setWindOffset(offset)
    -- This would update the cloud shader uniforms
    M.windOffset = offset
end

function M.getCloudTypes()
    return M.cloudTypes
end

function M.getState()
    return {
        enabled = cloudsEnabled,
        density = cloudDensity,
        coverage = cloudCoverage,
        speed = cloudSpeed,
        height = cloudHeight,
        type = cloudType,
        volumetricLighting = volumetricLighting,
        animationTime = cloudAnimationTime,
        windOffset = M.windOffset,
        cachedParams = M.cachedParams
    }
end

return M
