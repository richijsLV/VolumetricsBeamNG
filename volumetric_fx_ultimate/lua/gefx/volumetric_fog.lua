-- Volumetric Fog Module - Vulkan Optimized
-- Height-based and ground fog with light interaction

local M = {}

local fogEnabled = true
local fogDensity = 0.002
local heightFalloff = 0.001
local fogColor = {0.7, 0.75, 0.8}
local groundFogEnabled = true
local groundFogHeight = 50
local fogAnimationTime = 0

function M.init()
    log('V', 'VolumetricFog', 'Initializing volumetric fog system')
    M.setupFogParameters()
end

function M.setupFogParameters()
    local config = require('gefx.init').loadConfig()
    if config and config.fog then
        fogEnabled = config.fog.enabled
        fogDensity = config.fog.density or 0.002
        heightFalloff = config.fog.heightFalloff or 0.001
        fogColor = {
            config.fog.colorR or 0.7,
            config.fog.colorG or 0.75,
            config.fog.colorB or 0.8
        }
        groundFogEnabled = config.fog.groundFogEnabled or true
        groundFogHeight = config.fog.groundFogHeight or 50
    end
    
    M.applyFogSettings()
end

function M.applyFogSettings()
    if not fogEnabled then
        M.setFogVisibility(false)
        return
    end
    
    M.setFogVisibility(true)
    
    -- Configure fog rendering parameters for Vulkan pipeline
    M.setFogMaterialParams({
        density = fogDensity,
        heightFalloff = heightFalloff,
        color = fogColor,
        groundFogEnabled = groundFogEnabled,
        groundFogHeight = groundFogHeight
    })
end

function M.update(dt)
    if not fogEnabled then return end
    
    fogAnimationTime = fogAnimationTime + dt * 0.1
    
    -- Subtle fog movement for dynamic effect
    local noiseOffset = math.sin(fogAnimationTime) * 0.02
    M.setNoiseOffset(noiseOffset)
end

function M.setFogMaterialParams(params)
    M.cachedParams = params
    log('D', 'VolumetricFog', 'Fog parameters updated: density=' .. tostring(params.density))
end

function M.setFogVisibility(visible)
    fogEnabled = visible
    log('D', 'VolumetricFog', 'Fog visibility set to: ' .. tostring(visible))
end

function M.setEnabled(enabled)
    fogEnabled = enabled
    M.applyFogSettings()
    
    local config = require('gefx.init').loadConfig()
    config.fog.enabled = enabled
    require('gefx.init').saveConfig(config)
end

function M.setDensity(density)
    fogDensity = math.max(0.0001, math.min(0.01, density))
    M.applyFogSettings()
    
    local config = require('gefx.init').loadConfig()
    config.fog.density = fogDensity
    require('gefx.init').saveConfig(config)
end

function M.setHeightFalloff(falloff)
    heightFalloff = math.max(0.0001, math.min(0.01, falloff))
    M.applyFogSettings()
    
    local config = require('gefx.init').loadConfig()
    config.fog.heightFalloff = heightFalloff
    require('gefx.init').saveConfig(config)
end

function M.setColor(r, g, b)
    fogColor = {r, g, b}
    M.applyFogSettings()
    
    local config = require('gefx.init').loadConfig()
    config.fog.colorR = r
    config.fog.colorG = g
    config.fog.colorB = b
    require('gefx.init').saveConfig(config)
end

function M.setGroundFogEnabled(enabled)
    groundFogEnabled = enabled
    M.applyFogSettings()
    
    local config = require('gefx.init').loadConfig()
    config.fog.groundFogEnabled = groundFogEnabled
    require('gefx.init').saveConfig(config)
end

function M.setGroundFogHeight(height)
    groundFogHeight = math.max(10, math.min(200, height))
    M.applyFogSettings()
    
    local config = require('gefx.init').loadConfig()
    config.fog.groundFogHeight = groundFogHeight
    require('gefx.init').saveConfig(config)
end

function M.setNoiseOffset(offset)
    -- This would update the fog shader noise uniforms
    M.noiseOffset = offset
end

function M.getState()
    return {
        enabled = fogEnabled,
        density = fogDensity,
        heightFalloff = heightFalloff,
        color = fogColor,
        groundFogEnabled = groundFogEnabled,
        groundFogHeight = groundFogHeight,
        animationTime = fogAnimationTime,
        noiseOffset = M.noiseOffset,
        cachedParams = M.cachedParams
    }
end

return M
