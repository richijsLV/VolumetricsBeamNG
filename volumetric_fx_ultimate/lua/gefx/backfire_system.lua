-- Backfire System Module - Vulkan Optimized
-- Multi-emitter particle system for realistic exhaust backfire effects

local M = {}

local backfireEnabled = true
local backfireIntensity = 1.0
local particleCount = 30
local flameSize = 1.5
local flameDuration = 0.3
local screenShake = true
local soundEnabled = true

local activeVehicles = {}
local activeFlames = {}

function M.init()
    log('V', 'BackfireSystem', 'Initializing backfire particle system')
    M.setupBackfireParameters()
end

function M.setupBackfireParameters()
    local config = require('gefx.init').loadConfig()
    if config and config.backfire then
        backfireEnabled = config.backfire.enabled
        backfireIntensity = config.backfire.intensity or 1.0
        particleCount = config.backfire.particleCount or 30
        flameSize = config.backfire.flameSize or 1.5
        flameDuration = config.backfire.duration or 0.3
        screenShake = config.backfire.screenShake or true
        soundEnabled = config.backfire.soundEnabled or true
    end
end

function M.onVehicleLoaded(vehicle)
    if not backfireEnabled or not vehicle then return end
    
    local vehicleId = vehicle:getID()
    activeVehicles[vehicleId] = {
        vehicle = vehicle,
        lastBackfireTime = 0,
        exhaustPositions = M.getExhaustPositions(vehicle)
    }
    
    log('D', 'BackfireSystem', 'Vehicle loaded: ' .. tostring(vehicleId))
end

function M.onVehicleUnloaded(vehicle)
    if not vehicle then return end
    
    local vehicleId = vehicle:getID()
    activeVehicles[vehicleId] = nil
    
    -- Clean up any active flames for this vehicle
    for i = #activeFlames, 1, -1 do
        if activeFlames[i].vehicleId == vehicleId then
            table.remove(activeFlames, i)
        end
    end
    
    log('D', 'BackfireSystem', 'Vehicle unloaded: ' .. tostring(vehicleId))
end

function M.getExhaustPositions(vehicle)
    -- Get exhaust pipe positions from vehicle
    -- In actual implementation, this would query the vehicle's exhaust nodes
    local positions = {}
    
    -- Default fallback positions (would be replaced by actual vehicle data)
    positions[1] = {x = 0, y = 0.5, z = -2}
    
    return positions
end

function M.triggerBackfire(vehicle, intensity)
    if not backfireEnabled or not vehicle then return end
    
    local vehicleId = vehicle:getID()
    local vehicleData = activeVehicles[vehicleId]
    
    if not vehicleData or not vehicleData.exhaustPositions then return end
    
    local currentTime = timer.getTime()
    
    -- Debounce backfire triggers
    if currentTime - vehicleData.lastBackfireTime < 0.1 then return end
    vehicleData.lastBackfireTime = currentTime
    
    -- Calculate effective intensity
    local effectiveIntensity = math.min(2.0, (intensity or 1.0) * backfireIntensity)
    
    -- Create flame particles at each exhaust position
    for _, position in ipairs(vehicleData.exhaustPositions) do
        M.createFlameParticle(vehicleId, position, effectiveIntensity)
    end
    
    -- Apply screen shake if enabled
    if screenShake and effectiveIntensity > 0.5 then
        M.applyScreenShake(effectiveIntensity)
    end
    
    -- Play backfire sound if enabled
    if soundEnabled then
        M.playBackfireSound(vehicle, effectiveIntensity)
    end
    
    log('D', 'BackfireSystem', 'Backfire triggered with intensity: ' .. tostring(effectiveIntensity))
end

function M.createFlameParticle(vehicleId, position, intensity)
    local flame = {
        vehicleId = vehicleId,
        position = position,
        intensity = intensity,
        age = 0,
        maxAge = flameDuration * (0.8 + math.random() * 0.4),
        size = flameSize * (0.8 + math.random() * 0.4) * intensity,
        velocity = {
            x = (math.random() - 0.5) * 2,
            y = math.random() * 3 + 2,
            z = (math.random() - 0.5) * 2
        },
        color = {
            r = 1.0,
            g = 0.6 + math.random() * 0.4,
            b = 0.2 + math.random() * 0.3
        }
    }
    
    table.insert(activeFlames, flame)
end

function M.update(dt)
    if not backfireEnabled then
        activeFlames = {}
        return
    end
    
    -- Update all active flames
    for i = #activeFlames, 1, -1 do
        local flame = activeFlames[i]
        flame.age = flame.age + dt
        
        -- Update position
        flame.position.x = flame.position.x + flame.velocity.x * dt
        flame.position.y = flame.position.y + flame.velocity.y * dt
        flame.position.z = flame.position.z + flame.velocity.z * dt
        
        -- Apply gravity to velocity
        flame.velocity.y = flame.velocity.y - 9.8 * dt
        
        -- Remove expired flames
        if flame.age >= flame.maxAge then
            table.remove(activeFlames, i)
        end
    end
    
    -- Limit active particles
    local maxParticles = require('gefx.init').getQualitySettings(
        require('gefx.init').loadConfig().quality or "high"
    ).particleLimit
    
    while #activeFlames > maxParticles do
        table.remove(activeFlames, 1)
    end
end

function M.applyScreenShake(intensity)
    -- This would interface with BeamNG's camera shake system
    local shakeMagnitude = intensity * 0.5
    log('D', 'BackfireSystem', 'Screen shake applied: ' .. tostring(shakeMagnitude))
end

function M.playBackfireSound(vehicle, intensity)
    -- This would play the backfire sound through BeamNG's audio system
    local volume = math.min(1.0, intensity * 0.8)
    log('D', 'BackfireSystem', 'Backfire sound played: volume=' .. tostring(volume))
end

function M.setEnabled(enabled)
    backfireEnabled = enabled
    
    if not enabled then
        activeFlames = {}
    end
    
    local config = require('gefx.init').loadConfig()
    config.backfire.enabled = enabled
    require('gefx.init').saveConfig(config)
    
    log('D', 'BackfireSystem', 'Backfire enabled: ' .. tostring(enabled))
end

function M.setIntensity(intensity)
    backfireIntensity = math.max(0.1, math.min(2.0, intensity))
    
    local config = require('gefx.init').loadConfig()
    config.backfire.intensity = backfireIntensity
    require('gefx.init').saveConfig(config)
end

function M.setParticleCount(count)
    particleCount = math.max(10, math.min(100, count))
    
    local config = require('gefx.init').loadConfig()
    config.backfire.particleCount = particleCount
    require('gefx.init').saveConfig(config)
end

function M.setFlameSize(size)
    flameSize = math.max(0.5, math.min(3.0, size))
    
    local config = require('gefx.init').loadConfig()
    config.backfire.flameSize = flameSize
    require('gefx.init').saveConfig(config)
end

function M.setDuration(duration)
    flameDuration = math.max(0.1, math.min(1.0, duration))
    
    local config = require('gefx.init').loadConfig()
    config.backfire.duration = flameDuration
    require('gefx.init').saveConfig(config)
end

function M.setScreenShake(enabled)
    screenShake = enabled
    
    local config = require('gefx.init').loadConfig()
    config.backfire.screenShake = screenShake
    require('gefx.init').saveConfig(config)
end

function M.setSoundEnabled(enabled)
    soundEnabled = enabled
    
    local config = require('gefx.init').loadConfig()
    config.backfire.soundEnabled = soundEnabled
    require('gefx.init').saveConfig(config)
end

function M.getActiveFlameCount()
    return #activeFlames
end

function M.getState()
    return {
        enabled = backfireEnabled,
        intensity = backfireIntensity,
        particleCount = particleCount,
        flameSize = flameSize,
        duration = flameDuration,
        screenShake = screenShake,
        soundEnabled = soundEnabled,
        activeFlameCount = #activeFlames,
        activeVehicleCount = #activeVehicles
    }
end

return M
