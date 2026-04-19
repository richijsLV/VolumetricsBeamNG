-- Volumetric Sky Module - Vulkan Optimized
-- Advanced atmospheric scattering with customizable sunset/night effects

local M = {}

local skyEnabled = true
local skyIntensity = 1.0
local sunsetColor = {1.0, 0.4, 0.2}
local nightIntensity = 0.3
local starBrightness = 0.8
local currentHour = 12.0

function M.init()
    log('V', 'VolumetricSky', 'Initializing volumetric sky system')
    M.setupSkyParameters()
end

function M.setupSkyParameters()
    -- Configure Vulkan-compatible sky rendering parameters
    local config = require('gefx.init').loadConfig()
    if config and config.sky then
        skyEnabled = config.sky.enabled
        skyIntensity = config.sky.intensity or 1.0
        sunsetColor = {
            config.sky.sunsetColorR or 1.0,
            config.sky.sunsetColorG or 0.4,
            config.sky.sunsetColorB or 0.2
        }
        nightIntensity = config.sky.nightIntensity or 0.3
        starBrightness = config.sky.starBrightness or 0.8
    end
    
    M.applySkySettings()
end

function M.applySkySettings()
    if not skyEnabled then
        M.setSkyVisibility(false)
        return
    end
    
    M.setSkyVisibility(true)
    
    -- Apply atmospheric scattering parameters
    -- These would interface with BeamNG's rendering pipeline
    local timeOfDay = M.getCurrentTime()
    local sunAngle = M.calculateSunAngle(timeOfDay)
    
    -- Dynamic color interpolation based on sun angle
    local skyColor = M.interpolateSkyColor(sunAngle)
    
    -- Set sky material parameters (would be passed to shader)
    M.setSkyMaterialParams({
        intensity = skyIntensity,
        baseColor = skyColor,
        sunAngle = sunAngle,
        starBrightness = starBrightness,
        nightIntensity = nightIntensity
    })
end

function M.getCurrentTime()
    -- Get simulation time of day (0-24 hours)
    -- In actual implementation, this would hook into BeamNG's time system
    return currentHour
end

function M.setTime(hour)
    currentHour = hour
    M.applySkySettings()
end

function M.calculateSunAngle(hour)
    -- Convert hour to sun angle (-90 to 90 degrees)
    -- 6am = -90, 12pm = 0, 6pm = 90
    local angle = (hour - 12) * 15
    return math.max(-90, math.min(90, angle))
end

function M.interpolateSkyColor(sunAngle)
    -- Interpolate between day, sunset, and night colors
    local dayColor = {0.4, 0.6, 0.9}  -- Blue sky
    local sunsetCol = sunsetColor
    local nightColor = {0.02, 0.02, 0.05}  -- Dark blue/black
    
    if sunAngle > 30 then
        -- Full day
        return dayColor
    elseif sunAngle > 5 then
        -- Transition to sunset
        local t = (sunAngle - 5) / 25
        return {
            dayColor[1] * t + sunsetCol[1] * (1 - t),
            dayColor[2] * t + sunsetCol[2] * (1 - t),
            dayColor[3] * t + sunsetCol[3] * (1 - t)
        }
    elseif sunAngle > -5 then
        -- Sunset/sunrise
        return sunsetCol
    elseif sunAngle > -20 then
        -- Transition to night
        local t = (sunAngle + 5) / 15
        return {
            sunsetCol[1] * (1 - t) + nightColor[1] * t,
            sunsetCol[2] * (1 - t) + nightColor[2] * t,
            sunsetCol[3] * (1 - t) + nightColor[3] * t
        }
    else
        -- Full night
        return nightColor
    end
end

function M.setSkyMaterialParams(params)
    -- This would interface with the actual rendering system
    -- For now, we store the parameters for the UI to access
    M.cachedParams = params
    log('D', 'VolumetricSky', 'Sky parameters updated: intensity=' .. tostring(params.intensity))
end

function M.setSkyVisibility(visible)
    skyEnabled = visible
    log('D', 'VolumetricSky', 'Sky visibility set to: ' .. tostring(visible))
end

function M.setEnabled(enabled)
    skyEnabled = enabled
    M.applySkySettings()
    
    -- Save configuration
    local config = require('gefx.init').loadConfig()
    config.sky.enabled = enabled
    require('gefx.init').saveConfig(config)
end

function M.setIntensity(intensity)
    skyIntensity = math.max(0, math.min(2.0, intensity))
    M.applySkySettings()
    
    local config = require('gefx.init').loadConfig()
    config.sky.intensity = skyIntensity
    require('gefx.init').saveConfig(config)
end

function M.setSunsetColors(r, g, b)
    sunsetColor = {r, g, b}
    M.applySkySettings()
    
    local config = require('gefx.init').loadConfig()
    config.sky.sunsetColorR = r
    config.sky.sunsetColorG = g
    config.sky.sunsetColorB = b
    require('gefx.init').saveConfig(config)
end

function M.setNightIntensity(intensity)
    nightIntensity = math.max(0, math.min(1.0, intensity))
    M.applySkySettings()
    
    local config = require('gefx.init').loadConfig()
    config.sky.nightIntensity = nightIntensity
    require('gefx.init').saveConfig(config)
end

function M.setStarBrightness(brightness)
    starBrightness = math.max(0, math.min(1.0, brightness))
    M.applySkySettings()
    
    local config = require('gefx.init').loadConfig()
    config.sky.starBrightness = starBrightness
    require('gefx.init').saveConfig(config)
end

function M.getState()
    return {
        enabled = skyEnabled,
        intensity = skyIntensity,
        sunsetColor = sunsetColor,
        nightIntensity = nightIntensity,
        starBrightness = starBrightness,
        currentHour = currentHour,
        cachedParams = M.cachedParams
    }
end

return M
