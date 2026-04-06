-------------------------------------------------------------------------------
-- wow_mock.lua
-- Lightweight WoW API mock for DragonWidgets busted unit tests
-------------------------------------------------------------------------------

local M = {}

-- luacheck: push ignore 121 122

-------------------------------------------------------------------------------
-- GameTooltip stub
-------------------------------------------------------------------------------

GameTooltip = {
    SetOwner = function() end,
    SetText = function() end,
    Show = function() end,
    Hide = function() end,
}

-------------------------------------------------------------------------------
-- UISpecialFrames (used by CreateOptionsPanel)
-------------------------------------------------------------------------------

UISpecialFrames = {}

-------------------------------------------------------------------------------
-- LibStub mock (returns nil - LSM is soft-loaded)
-------------------------------------------------------------------------------

function LibStub()
    return nil
end

-------------------------------------------------------------------------------
-- Sound / misc WoW API stubs
-------------------------------------------------------------------------------

function PlaySound() end

SOUNDKIT = {}

UIParent = nil -- set after CreateFrame is defined

-------------------------------------------------------------------------------
-- Mock texture
-------------------------------------------------------------------------------

local function CreateMockTexture()
    local tex = {
        _shown = true,
    }

    function tex.SetTexture() end
    function tex.SetPoint() end
    function tex.SetSize() end
    function tex.SetAllPoints() end
    function tex.SetTexCoord() end
    function tex.SetVertexColor() end
    function tex.SetColorTexture() end

    function tex:Hide()
        self._shown = false
    end

    function tex:Show()
        self._shown = true
    end

    function tex:SetShown(isShown)
        self._shown = not not isShown
    end

    function tex:IsShown()
        return self._shown
    end

    return tex
end

-------------------------------------------------------------------------------
-- Mock font string
-------------------------------------------------------------------------------

local function CreateMockFontString()
    local fs = {
        _text = "",
        _font = nil,
        _fontSize = 12,
    }

    function fs.SetFont(_, font, size)
        fs._font = font
        fs._fontSize = size
    end

    function fs.SetTextColor() end
    function fs.SetPoint() end
    function fs.SetJustifyH() end
    function fs.SetJustifyV() end
    function fs.SetWordWrap() end
    function fs.SetWidth() end

    function fs:SetText(text)
        self._text = text or ""
    end

    function fs:GetText()
        return self._text
    end

    function fs:GetStringWidth()
        return #self._text * 7
    end

    return fs
end

-------------------------------------------------------------------------------
-- Mock frame
-------------------------------------------------------------------------------

local function CreateMockFrame()
    local frame = {
        _points = {},
        _shown = false,
        _size = { w = 0, h = 0 },
        _scripts = {},
        _alpha = 1,
        _backdrop = nil,
        _backdropColor = nil,
        _backdropBorderColor = nil,
    }

    function frame:SetPoint(point, relativeTo, relativePoint, x, y)
        self._points[#self._points + 1] = {
            point = point,
            relativeTo = relativeTo,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end

    function frame:ClearAllPoints()
        self._points = {}
    end

    function frame:Show()
        self._shown = true
    end

    function frame:Hide()
        self._shown = false
    end

    function frame:IsShown()
        return self._shown
    end

    function frame:SetSize(w, h)
        self._size = { w = w, h = h }
    end

    function frame:SetHeight(h)
        self._size.h = h
    end

    function frame:SetWidth(w)
        self._size.w = w
    end

    function frame:GetWidth()
        return self._size.w
    end

    function frame:GetHeight()
        return self._size.h
    end

    function frame:SetAlpha(a)
        self._alpha = a
    end

    function frame:GetAlpha()
        return self._alpha
    end

    function frame:SetBackdrop(bd)
        self._backdrop = bd
    end

    function frame:SetBackdropColor(r, g, b, a)
        self._backdropColor = { r, g, b, a }
    end

    function frame:SetBackdropBorderColor(r, g, b, a)
        self._backdropBorderColor = { r, g, b, a }
    end

    function frame.EnableMouse() end
    function frame.SetMovable() end
    function frame.SetClampedToScreen() end
    function frame.StartMoving() end
    function frame.StopMovingOrSizing() end
    function frame.SetFrameStrata() end
    function frame.SetFrameLevel() end
    function frame.RegisterForDrag() end

    function frame:CreateTexture() -- luacheck: ignore 212/self
        return CreateMockTexture()
    end

    function frame:CreateFontString() -- luacheck: ignore 212/self
        return CreateMockFontString()
    end

    function frame:SetScript(event, handler)
        self._scripts[event] = handler
    end

    return frame
end

function CreateFrame(_, _, _, _)
    return CreateMockFrame()
end

UIParent = CreateMockFrame()

-- luacheck: pop

-------------------------------------------------------------------------------
-- Shared file loader
-------------------------------------------------------------------------------

local function load(path)
    local chunk, err = loadfile(path)
    if not chunk then error("Failed to load " .. path .. ": " .. (err or "unknown")) end
    chunk()
end

-------------------------------------------------------------------------------
-- Module loader
-------------------------------------------------------------------------------

function M.LoadDragonWidgets()
    -- Must set DragonWidgetsNS global before loading any widget file
    DragonWidgetsNS = { Widgets = {} } -- luacheck: ignore 111 112

    load("DragonWidgets/DragonWidgets.lua")
    load("DragonWidgets/Widgets/WidgetConstants.lua")
    return DragonWidgetsNS -- luacheck: ignore 113
end

function M.LoadWidget(widgetFile)
    load("DragonWidgets/Widgets/" .. widgetFile)
    return DragonWidgetsNS.Widgets -- luacheck: ignore 113
end

-------------------------------------------------------------------------------
-- Reload (clears event bus by re-executing DragonWidgets.lua)
-------------------------------------------------------------------------------

function M.Reload()
    return M.LoadDragonWidgets()
end

return M
