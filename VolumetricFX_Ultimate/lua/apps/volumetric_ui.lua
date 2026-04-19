
-- Volumetric FX Ultimate - UI Application
-- High Quality Minimalistic UI with Custom Icons

local app = {}
local gfx = {}
local config = {}
local tabs = {"sky", "clouds", "fog", "fire", "settings"}
local currentTab = "sky"
local dirty = false

-- Icon Data (SVG paths simplified for rendering or pre-rendered textures)
-- In a real mod, these would be .dds textures. Here we draw simple shapes or use text labels if textures missing.
local icons = {
    sky = "SKY",
    clouds = "CLD",
    fog = "FOG",
    fire = "FIRE",
    settings = "SET"
}

function app.init()
    -- Load initial config from the main module via a hypothetical bridge or default
    -- Since direct lua-to-lua variable sharing across modules in BeamNG apps is tricky without events:
    -- We will assume defaults and let the user save, which triggers the main module.
    config = {
        enabled = true,
        sky = { intensity = 1.0, sunsetBoost = 1.5, starsVisible = true },
        clouds = { density = 0.6, coverage = 0.5, speed = 0.05, type = 1 }, -- 1=cumulus
        fog = { density = 0.002, height = 50, colorR = 0.8, colorG = 0.9, colorB = 1.0 },
        backfire = { enabled = true, intensity = 1.2, scale = 1.0, colorShift = 0 }
    }
    
    -- Try to read config file directly if possible, otherwise rely on defaults until save
    local success, data = pcall(serialize.readJson, "gefx_volumetric_config.json")
    if success and data then config = data end
    
    gfx.bgColor = {0.15, 0.15, 0.18, 0.95}
    gfx.panelColor = {0.25, 0.25, 0.28, 1.0}
    gfx.accentColor = {0.2, 0.6, 0.9, 1.0}
    gfx.textColor = {0.9, 0.9, 0.9, 1.0}
    gfx.textDim = {0.6, 0.6, 0.6, 1.0}
    
    app.windowWidth = 400
    app.windowHeight = 550
end

function app.render()
    local W, H = app.windowWidth, app.windowHeight
    
    -- Background
    gfx.setColor(gfx.bgColor)
    gfx.fillRect(0, 0, W, H)
    
    -- Header
    gfx.setColor(gfx.panelColor)
    gfx.fillRect(0, 0, W, 50)
    
    gfx.setColor(gfx.accentColor)
    gfx.fillRect(0, 48, W, 2) -- Accent line
    
    gfx.setColor(gfx.textColor)
    gfx.setFont("bold", 18)
    gfx.drawText("VOLUMETRIC FX", 20, 15)
    gfx.setFont("normal", 12)
    gfx.setColor(gfx.textDim)
    gfx.drawText("Ultimate Edition v1.0", 20, 35)
    
    -- Tabs
    local tabW = W / 5
    for i, tab in ipairs(tabs) do
        local x = (i-1) * tabW
        local isActive = (tab == currentTab)
        
        if isActive then
            gfx.setColor(gfx.panelColor)
            gfx.fillRect(x, 50, tabW, 40)
            gfx.setColor(gfx.accentColor)
            gfx.fillRect(x, 88, tabW, 2)
        else
            gfx.setColor({0.15, 0.15, 0.18, 0.5})
            gfx.fillRect(x, 50, tabW, 40)
        end
        
        gfx.setColor(isActive and gfx.accentColor or gfx.textDim)
        gfx.setFont("bold", 10)
        -- Simple text icons for robustness
        local label = string.upper(string.sub(tab, 1, 3))
        local tw, th = gfx.getTextSize(label)
        gfx.drawText(label, x + (tabW - tw)/2, 65)
    end
    
    -- Content Area
    local contentY = 100
    local padX = 20
    
    gfx.setColor(gfx.textColor)
    gfx.setFont("bold", 14)
    
    if currentTab == "sky" then
        gfx.drawText("Atmospheric Sky", padX, contentY)
        contentY = contentY + 30
        
        -- Intensity Slider
        gfx.setFont("normal", 12)
        gfx.drawText("Sun Intensity", padX, contentY)
        config.sky.intensity = app.renderSlider(padX, contentY + 5, W - padX*2, config.sky.intensity, 0.5, 2.0)
        contentY = contentY + 50
        
        -- Sunset Boost
        gfx.drawText("Sunset Warmth", padX, contentY)
        config.sky.sunsetBoost = app.renderSlider(padX, contentY + 5, W - padX*2, config.sky.sunsetBoost, 0.5, 3.0)
        contentY = contentY + 50
        
        -- Stars Toggle
        local starText = config.sky.starsVisible and "[ON] Night Stars" or "[OFF] Night Stars"
        if app.renderButton(padX, contentY, 150, 30, starText) then
            config.sky.starsVisible = not config.sky.starsVisible
            dirty = true
        end
        
    elseif currentTab == "clouds" then
        gfx.drawText("Volumetric Clouds", padX, contentY)
        contentY = contentY + 30
        
        gfx.setFont("normal", 12)
        gfx.drawText("Coverage", padX, contentY)
        config.clouds.coverage = app.renderSlider(padX, contentY + 5, W - padX*2, config.clouds.coverage, 0.0, 1.0)
        contentY = contentY + 50
        
        gfx.drawText("Density", padX, contentY)
        config.clouds.density = app.renderSlider(padX, contentY + 5, W - padX*2, config.clouds.density, 0.1, 1.0)
        contentY = contentY + 50
        
        gfx.drawText("Wind Speed", padX, contentY)
        config.clouds.speed = app.renderSlider(padX, contentY + 5, W - padX*2, config.clouds.speed, 0.0, 0.2)
        contentY = contentY + 50
        
    elseif currentTab == "fog" then
        gfx.drawText("Atmospheric Fog", padX, contentY)
        contentY = contentY + 30
        
        gfx.setFont("normal", 12)
        gfx.drawText("Fog Density", padX, contentY)
        config.fog.density = app.renderSlider(padX, contentY + 5, W - padX*2, config.fog.density, 0.0, 0.01)
        contentY = contentY + 50
        
        gfx.drawText("Fog Height", padX, contentY)
        config.fog.height = app.renderSlider(padX, contentY + 5, W - padX*2, config.fog.height, 0, 200)
        contentY = contentY + 50
        
        gfx.drawText("Fog Color (Blue Channel)", padX, contentY)
        config.fog.colorB = app.renderSlider(padX, contentY + 5, W - padX*2, config.fog.colorB, 0.5, 1.0)
        contentY = contentY + 50
        
    elseif currentTab == "fire" then
        gfx.drawText("Backfire System", padX, contentY)
        contentY = contentY + 30
        
        local fireText = config.backfire.enabled and "[ON] Enabled" or "[OFF] Disabled"
        if app.renderButton(padX, contentY, 150, 30, fireText) then
            config.backfire.enabled = not config.backfire.enabled
            dirty = true
        end
        contentY = contentY + 50
        
        if config.backfire.enabled then
            gfx.setFont("normal", 12)
            gfx.drawText("Flame Scale", padX, contentY)
            config.backfire.scale = app.renderSlider(padX, contentY + 5, W - padX*2, config.backfire.scale, 0.5, 2.0)
            contentY = contentY + 50
            
            gfx.drawText("Intensity", padX, contentY)
            config.backfire.intensity = app.renderSlider(padX, contentY + 5, W - padX*2, config.backfire.intensity, 0.5, 3.0)
            contentY = contentY + 50
        end
        
    elseif currentTab == "settings" then
        gfx.drawText("Global Settings", padX, contentY)
        contentY = contentY + 30
        
        local masterText = config.enabled and "[ON] Master Enable" or "[OFF] Master Enable"
        if app.renderButton(padX, contentY, 200, 30, masterText) then
            config.enabled = not config.enabled
            dirty = true
        end
        contentY = contentY + 50
        
        gfx.setFont("normal", 12)
        gfx.setColor(gfx.textDim)
        gfx.drawText("Changes are saved automatically.", padX, contentY)
        contentY = contentY + 20
        gfx.drawText("Requires vehicle reload for particles.", padX, contentY)
    end
    
    -- Save Logic
    if dirty then
        -- Debounce save slightly or save immediately
        serialize.writeJson("gefx_volumetric_config.json", config)
        -- Notify main module
        -- In a real scenario, we'd fire an event. Here we assume the main module polls or we use a specific beamng call
        -- For simplicity in this generated mod, we rely on the file save and the user reloading/toggling
        dirty = false
    end
end

function app.renderSlider(x, y, w, val, min, max)
    -- Draw track
    gfx.setColor({0.3, 0.3, 0.3, 1.0})
    gfx.fillRect(x, y, w, 6)
    
    -- Calculate handle pos
    local range = max - min
    local pct = (val - min) / range
    local hx = x + pct * w
    
    -- Draw handle
    gfx.setColor(gfx.accentColor)
    gfx.fillRect(hx - 8, y - 2, 16, 10)
    
    -- Interaction
    if app.isMouseInRect(x, y, w, 10) and input.isMouseDown(0) then
        local mx, my = input.getMousePos()
        local newPct = (mx - x) / w
        newPct = math.max(0, math.min(1, newPct))
        dirty = true
        return min + (newPct * range)
    end
    return val
end

function app.renderButton(x, y, w, h, text)
    local hovered = app.isMouseInRect(x, y, w, h)
    local pressed = hovered and input.isMouseDown(0)
    
    if pressed then
        gfx.setColor({0.1, 0.4, 0.7, 1.0})
    elseif hovered then
        gfx.setColor({0.3, 0.7, 0.9, 1.0})
    else
        gfx.setColor(gfx.panelColor)
    end
    
    gfx.fillRect(x, y, w, h)
    
    gfx.setColor(gfx.textColor)
    gfx.setFont("bold", 12)
    local tw, th = gfx.getTextSize(text)
    gfx.drawText(text, x + (w-tw)/2, y + (h-th)/2)
    
    if hovered and input.isMouseReleased(0) then
        return true
    end
    return false
end

function app.isMouseInRect(x, y, w, h)
    local mx, my = input.getMousePos()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

return app
