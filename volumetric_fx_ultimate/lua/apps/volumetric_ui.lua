-- Volumetric FX Ultimate UI App
-- Professional minimalistic interface for configuring all volumetric effects

local M = {}

local appWindow = nil
local currentTab = "sky"
local config = {}

-- Tab definitions with icons
local tabs = {
    {id = "sky", name = "Sky", icon = "sky_icon"},
    {id = "clouds", name = "Clouds", icon = "cloud_icon"},
    {id = "fog", name = "Fog", icon = "fog_icon"},
    {id = "backfire", name = "Fire", icon = "fire_icon"},
    {id = "settings", name = "Settings", icon = "settings_icon"}
}

function M.init()
    log('V', 'VolumetricUI', 'Initializing UI application')
    config = require('gefx.init').loadConfig()
end

function M.create()
    -- Create the main app window
    appWindow = ui_app_create("volumetric_fx_ultimate", {
        title = "Volumetric FX Ultimate",
        size = {420, 520},
        position = {100, 100},
        resizable = true,
        minWidth = 380,
        minHeight = 480
    })
    
    if not appWindow then
        log('E', 'VolumetricUI', 'Failed to create UI window')
        return
    end
    
    M.render()
end

function M.destroy()
    if appWindow then
        ui_app_destroy(appWindow)
        appWindow = nil
    end
end

function M.render()
    if not appWindow then return end
    
    local ui = ui_app_get_context(appWindow)
    
    ui:begin("VolumetricFX", nil, ui.WindowFlags_NoTitleBar + ui.WindowFlags_NoResize + ui.WindowFlags_NoMove + ui.WindowFlags_NoCollapse)
    
    -- Header with logo/title
    M.renderHeader(ui)
    
    -- Tab bar
    M.renderTabBar(ui)
    
    -- Tab content
    if currentTab == "sky" then
        M.renderSkyTab(ui)
    elseif currentTab == "clouds" then
        M.renderCloudsTab(ui)
    elseif currentTab == "fog" then
        M.renderFogTab(ui)
    elseif currentTab == "backfire" then
        M.renderBackfireTab(ui)
    elseif currentTab == "settings" then
        M.renderSettingsTab(ui)
    end
    
    -- Footer
    M.renderFooter(ui)
    
    ui:end()
end

function M.renderHeader(ui)
    -- Gradient background effect using colors
    local drawList = ui:getForegroundDrawList()
    local pos = ui:getCursorScreenPos()
    local size = ui:getContentRegionAvail()
    
    -- Title
    ui:pushStyleColor(ui.Col_Text, {1, 1, 1, 1})
    ui:text("VOLUMETRIC FX")
    ui:sameLine()
    ui:pushFont(ui.Font_Small)
    ui:text("ULTIMATE")
    ui:popFont()
    ui:popStyleColor()
    
    ui:separator()
    ui:spacing()
end

function M.renderTabBar(ui)
    local availableWidth = ui:getContentRegionAvail().x
    local tabWidth = (availableWidth - 20) / #tabs
    
    ui:pushStyleVar(ui.StyleVar_ItemSpacing, {2, 2})
    
    for i, tab in ipairs(tabs) do
        ui:pushStyleColor(ui.Col_Button, currentTab == tab.id and {0.2, 0.5, 0.9, 1} or {0.15, 0.15, 0.15, 1})
        ui:pushStyleColor(ui.Col_ButtonHovered, currentTab == tab.id and {0.25, 0.55, 0.95, 1} or {0.2, 0.2, 0.2, 1})
        
        -- Button with icon placeholder
        local buttonLabel = tab.name
        if ui:button(buttonLabel, {tabWidth, 32}) then
            currentTab = tab.id
        end
        
        ui:popStyleColor(2)
        ui:sameLine()
    end
    
    ui:popStyleVar()
    ui:newLine()
    ui:separator()
    ui:spacing()
end

function M.renderSkyTab(ui)
    local skyConfig = config.sky or {}
    
    -- Enable toggle
    ui:pushStyleColor(ui.Col_Text, skyConfig.enabled and {1, 1, 1, 1} or {0.7, 0.7, 0.7, 1})
    local enabled = ui:checkbox("Enable Sky Effects", skyConfig.enabled)
    if enabled ~= skyConfig.enabled then
        skyConfig.enabled = enabled
        require('gefx.volumetric_sky').setEnabled(enabled)
        M.saveConfig()
    end
    ui:popStyleColor()
    
    if not skyConfig.enabled then
        ui:pushStyleColor(ui.Col_Text, {0.5, 0.5, 0.5, 1})
        ui:text("Sky effects are disabled")
        ui:popStyleColor()
        return
    end
    
    ui:spacing()
    
    -- Intensity slider
    ui:text("Intensity")
    local intensity = ui:sliderFloat("##intensity", skyConfig.intensity or 1.0, 0.0, 2.0)
    if intensity ~= skyConfig.intensity then
        skyConfig.intensity = intensity
        require('gefx.volumetric_sky').setIntensity(intensity)
        M.saveConfig()
    end
    
    -- Sunset color picker
    ui:text("Sunset Color")
    local sunsetCol = {
        skyConfig.sunsetColorR or 1.0,
        skyConfig.sunsetColorG or 0.4,
        skyConfig.sunsetColorB or 0.2
    }
    local newCol = ui:colorEdit3("##sunsetColor", sunsetCol)
    if newCol then
        skyConfig.sunsetColorR = newCol[1]
        skyConfig.sunsetColorG = newCol[2]
        skyConfig.sunsetColorB = newCol[3]
        require('gefx.volumetric_sky').setSunsetColors(newCol[1], newCol[2], newCol[3])
        M.saveConfig()
    end
    
    -- Night intensity
    ui:text("Night Intensity")
    local nightInt = ui:sliderFloat("##nightInt", skyConfig.nightIntensity or 0.3, 0.0, 1.0)
    if nightInt ~= skyConfig.nightIntensity then
        skyConfig.nightIntensity = nightInt
        require('gefx.volumetric_sky').setNightIntensity(nightInt)
        M.saveConfig()
    end
    
    -- Star brightness
    ui:text("Star Brightness")
    local starBright = ui:sliderFloat("##starBright", skyConfig.starBrightness or 0.8, 0.0, 1.0)
    if starBright ~= skyConfig.starBrightness then
        skyConfig.starBrightness = starBright
        require('gefx.volumetric_sky').setStarBrightness(starBright)
        M.saveConfig()
    end
end

function M.renderCloudsTab(ui)
    local cloudConfig = config.clouds or {}
    
    -- Enable toggle
    ui:pushStyleColor(ui.Col_Text, cloudConfig.enabled and {1, 1, 1, 1} or {0.7, 0.7, 0.7, 1})
    local enabled = ui:checkbox("Enable Cloud System", cloudConfig.enabled)
    if enabled ~= cloudConfig.enabled then
        cloudConfig.enabled = enabled
        require('gefx.volumetric_clouds').setEnabled(enabled)
        M.saveConfig()
    end
    ui:popStyleColor()
    
    if not cloudConfig.enabled then
        ui:pushStyleColor(ui.Col_Text, {0.5, 0.5, 0.5, 1})
        ui:text("Cloud system is disabled")
        ui:popStyleColor()
        return
    end
    
    ui:spacing()
    
    -- Density slider
    ui:text("Cloud Density")
    local density = ui:sliderFloat("##density", cloudConfig.density or 0.6, 0.1, 1.0)
    if density ~= cloudConfig.density then
        cloudConfig.density = density
        require('gefx.volumetric_clouds').setDensity(density)
        M.saveConfig()
    end
    
    -- Coverage slider
    ui:text("Cloud Coverage")
    local coverage = ui:sliderFloat("##coverage", cloudConfig.coverage or 0.5, 0.0, 1.0)
    if coverage ~= cloudConfig.coverage then
        cloudConfig.coverage = coverage
        require('gefx.volumetric_clouds').setCoverage(coverage)
        M.saveConfig()
    end
    
    -- Speed slider
    ui:text("Animation Speed")
    local speed = ui:sliderFloat("##speed", cloudConfig.speed or 0.02, 0.0, 0.1)
    if speed ~= cloudConfig.speed then
        cloudConfig.speed = speed
        require('gefx.volumetric_clouds').setSpeed(speed)
        M.saveConfig()
    end
    
    -- Height slider
    ui:text("Cloud Height")
    local height = ui:sliderFloat("##height", cloudConfig.height or 2000, 500, 5000)
    if height ~= cloudConfig.height then
        cloudConfig.height = height
        require('gefx.volumetric_clouds').setHeight(height)
        M.saveConfig()
    end
    
    -- Cloud type selector
    ui:text("Cloud Type")
    local cloudTypes = {"cumulus", "stratus", "cirrus", "storm"}
    local currentIndex = 1
    for i, t in ipairs(cloudTypes) do
        if t == (cloudConfig.type or "cumulus") then
            currentIndex = i
            break
        end
    end
    
    local changed, newIndex = ui:combo("##cloudType", currentIndex, cloudTypes)
    if changed then
        cloudConfig.type = cloudTypes[newIndex]
        require('gefx.volumetric_clouds').setType(cloudTypes[newIndex])
        M.saveConfig()
    end
    
    -- Volumetric lighting toggle
    local volLight = ui:checkbox("Volumetric Lighting", cloudConfig.volumetricLighting or true)
    if volLight ~= cloudConfig.volumetricLighting then
        cloudConfig.volumetricLighting = volLight
        require('gefx.volumetric_clouds').setVolumetricLighting(volLight)
        M.saveConfig()
    end
end

function M.renderFogTab(ui)
    local fogConfig = config.fog or {}
    
    -- Enable toggle
    ui:pushStyleColor(ui.Col_Text, fogConfig.enabled and {1, 1, 1, 1} or {0.7, 0.7, 0.7, 1})
    local enabled = ui:checkbox("Enable Fog System", fogConfig.enabled)
    if enabled ~= fogConfig.enabled then
        fogConfig.enabled = enabled
        require('gefx.volumetric_fog').setEnabled(enabled)
        M.saveConfig()
    end
    ui:popStyleColor()
    
    if not fogConfig.enabled then
        ui:pushStyleColor(ui.Col_Text, {0.5, 0.5, 0.5, 1})
        ui:text("Fog system is disabled")
        ui:popStyleColor()
        return
    end
    
    ui:spacing()
    
    -- Density slider
    ui:text("Fog Density")
    local density = ui:sliderFloat("##fogDensity", fogConfig.density or 0.002, 0.0001, 0.01)
    if density ~= fogConfig.density then
        fogConfig.density = density
        require('gefx.volumetric_fog').setDensity(density)
        M.saveConfig()
    end
    
    -- Height falloff
    ui:text("Height Falloff")
    local falloff = ui:sliderFloat("##falloff", fogConfig.heightFalloff or 0.001, 0.0001, 0.01)
    if falloff ~= fogConfig.heightFalloff then
        fogConfig.heightFalloff = falloff
        require('gefx.volumetric_fog').setHeightFalloff(falloff)
        M.saveConfig()
    end
    
    -- Fog color picker
    ui:text("Fog Color")
    local fogCol = {
        fogConfig.colorR or 0.7,
        fogConfig.colorG or 0.75,
        fogConfig.colorB or 0.8
    }
    local newCol = ui:colorEdit3("##fogColor", fogCol)
    if newCol then
        fogConfig.colorR = newCol[1]
        fogConfig.colorG = newCol[2]
        fogConfig.colorB = newCol[3]
        require('gefx.volumetric_fog').setColor(newCol[1], newCol[2], newCol[3])
        M.saveConfig()
    end
    
    -- Ground fog toggle
    local groundFog = ui:checkbox("Ground Fog", fogConfig.groundFogEnabled or true)
    if groundFog ~= fogConfig.groundFogEnabled then
        fogConfig.groundFogEnabled = groundFog
        require('gefx.volumetric_fog').setGroundFogEnabled(groundFog)
        M.saveConfig()
    end
    
    -- Ground fog height
    if fogConfig.groundFogEnabled then
        ui:indent()
        ui:text("Ground Fog Height")
        local gfHeight = ui:sliderFloat("##gfHeight", fogConfig.groundFogHeight or 50, 10, 200)
        if gfHeight ~= fogConfig.groundFogHeight then
            fogConfig.groundFogHeight = gfHeight
            require('gefx.volumetric_fog').setGroundFogHeight(gfHeight)
            M.saveConfig()
        end
        ui:unindent()
    end
end

function M.renderBackfireTab(ui)
    local backfireConfig = config.backfire or {}
    
    -- Enable toggle
    ui:pushStyleColor(ui.Col_Text, backfireConfig.enabled and {1, 1, 1, 1} or {0.7, 0.7, 0.7, 1})
    local enabled = ui:checkbox("Enable Backfire Effects", backfireConfig.enabled)
    if enabled ~= backfireConfig.enabled then
        backfireConfig.enabled = enabled
        require('gefx.backfire_system').setEnabled(enabled)
        M.saveConfig()
    end
    ui:popStyleColor()
    
    if not backfireConfig.enabled then
        ui:pushStyleColor(ui.Col_Text, {0.5, 0.5, 0.5, 1})
        ui:text("Backfire effects are disabled")
        ui:popStyleColor()
        return
    end
    
    ui:spacing()
    
    -- Intensity slider
    ui:text("Flame Intensity")
    local intensity = ui:sliderFloat("##bfIntensity", backfireConfig.intensity or 1.0, 0.1, 2.0)
    if intensity ~= backfireConfig.intensity then
        backfireConfig.intensity = intensity
        require('gefx.backfire_system').setIntensity(intensity)
        M.saveConfig()
    end
    
    -- Particle count
    ui:text("Particle Count")
    local pCount = ui:sliderInt("##pCount", backfireConfig.particleCount or 30, 10, 100)
    if pCount ~= backfireConfig.particleCount then
        backfireConfig.particleCount = pCount
        require('gefx.backfire_system').setParticleCount(pCount)
        M.saveConfig()
    end
    
    -- Flame size
    ui:text("Flame Size")
    local fSize = ui:sliderFloat("##fSize", backfireConfig.flameSize or 1.5, 0.5, 3.0)
    if fSize ~= backfireConfig.flameSize then
        backfireConfig.flameSize = fSize
        require('gefx.backfire_system').setFlameSize(fSize)
        M.saveConfig()
    end
    
    -- Duration
    ui:text("Flame Duration")
    local duration = ui:sliderFloat("##duration", backfireConfig.duration or 0.3, 0.1, 1.0)
    if duration ~= backfireConfig.duration then
        backfireConfig.duration = duration
        require('gefx.backfire_system').setDuration(duration)
        M.saveConfig()
    end
    
    -- Screen shake toggle
    local shake = ui:checkbox("Screen Shake", backfireConfig.screenShake or true)
    if shake ~= backfireConfig.screenShake then
        backfireConfig.screenShake = shake
        require('gefx.backfire_system').setScreenShake(shake)
        M.saveConfig()
    end
    
    -- Sound toggle
    local sound = ui:checkbox("Sound Effects", backfireConfig.soundEnabled or true)
    if sound ~= backfireConfig.soundEnabled then
        backfireConfig.soundEnabled = sound
        require('gefx.backfire_system').setSoundEnabled(sound)
        M.saveConfig()
    end
end

function M.renderSettingsTab(ui)
    -- Quality preset selector
    ui:text("Quality Preset")
    local qualityLevels = {"low", "medium", "high", "ultra"}
    local currentIndex = 1
    for i, q in ipairs(qualityLevels) do
        if q == (config.quality or "high") then
            currentIndex = i
            break
        end
    end
    
    local changed, newIndex = ui:combo("##quality", currentIndex, qualityLevels)
    if changed then
        config.quality = qualityLevels[newIndex]
        M.saveConfig()
        log('V', 'VolumetricUI', 'Quality preset changed to: ' .. qualityLevels[newIndex])
    end
    
    ui:spacing()
    ui:separator()
    ui:spacing()
    
    -- Reset to defaults button
    if ui:button("Reset to Defaults", {-1, 35}) then
        M.resetToDefaults()
    end
    
    ui:spacing()
    
    -- Version info
    ui:pushStyleColor(ui.Col_Text, {0.5, 0.5, 0.5, 1})
    ui:text("Volumetric FX Ultimate v1.0.0")
    ui:text("Vulkan API Optimized")
    ui:popStyleColor()
end

function M.renderFooter(ui)
    ui:spacing()
    ui:separator()
    ui:spacing()
    
    -- Status indicators
    local skyState = require('gefx.volumetric_sky').getState()
    local cloudState = require('gefx.volumetric_clouds').getState()
    local fogState = require('gefx.volumetric_fog').getState()
    local backfireState = require('gefx.backfire_system').getState()
    
    ui:pushStyleColor(ui.Col_Text, skyState.enabled and {0.4, 0.8, 0.4, 1} or {0.8, 0.4, 0.4, 1})
    ui:text(skyState.enabled and "[OK] Sky" or "[OFF] Sky")
    ui:popStyleColor()
    ui:sameLine()
    
    ui:pushStyleColor(ui.Col_Text, cloudState.enabled and {0.4, 0.8, 0.4, 1} or {0.8, 0.4, 0.4, 1})
    ui:text(cloudState.enabled and "[OK] Clouds" or "[OFF] Clouds")
    ui:popStyleColor()
    ui:sameLine()
    
    ui:pushStyleColor(ui.Col_Text, fogState.enabled and {0.4, 0.8, 0.4, 1} or {0.8, 0.4, 0.4, 1})
    ui:text(fogState.enabled and "[OK] Fog" or "[OFF] Fog")
    ui:popStyleColor()
    ui:sameLine()
    
    ui:pushStyleColor(ui.Col_Text, backfireState.enabled and {0.4, 0.8, 0.4, 1} or {0.8, 0.4, 0.4, 1})
    ui:text(backfireState.enabled and "[OK] Fire" or "[OFF] Fire")
    ui:popStyleColor()
end

function M.saveConfig()
    require('gefx.init').saveConfig(config)
end

function M.resetToDefaults()
    config = require('gefx.init').loadConfig()
    
    -- Re-initialize all modules with default settings
    require('gefx.volumetric_sky').init()
    require('gefx.volumetric_clouds').init()
    require('gefx.volumetric_fog').init()
    require('gefx.backfire_system').init()
    
    M.saveConfig()
    log('V', 'VolumetricUI', 'Configuration reset to defaults')
end

return M
