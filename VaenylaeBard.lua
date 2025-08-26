-- VaenylaeBard - XML-based Version for Classic WoW
-- UI frames are defined in VaenylaeBard.xml

-- Global variables
VaenylaeBardSongs = VaenylaeBardSongs or {}
VaenylaeBardSelectedSong = nil
VaenylaeBardSelectedLine = nil

-- Initialize addon
local function InitializeAddon()
    print("|cff00ffff[Vaenylae Bard]|r Manager loaded! Type /vbard to open.")
    
    -- Initialize saved variables
    if not VaenylaeBardDB then
        VaenylaeBardDB = { songs = {} }
    end
    VaenylaeBardSongs = VaenylaeBardDB.songs
    
    -- Create buttons first
    CreateMainFrameButtons()
    
    -- Then setup event handlers
    SetupEventHandlers()
    
    -- Update song list
    UpdateSongList()
end

local function DiagnoseFrames()
    local frames = {
        "VaenylaeBardMainFrame",
        "VaenylaeBardMainFrameAddSongButton", 
        "VaenylaeBardMainFrameRemoveSongButton",
        "VaenylaeBardMainFrameCloseButton"
    }
    
    for _, frameName in ipairs(frames) do
        local frame = getglobal(frameName)
        if frame then
            print(frameName .. ": EXISTS, Visible=" .. tostring(frame:IsVisible()))
        else
            print(frameName .. ": NIL - NOT LOADED")
        end
    end
end

local function CreateMainFrameButtons()
    -- Create Add Song Button
    local addButton = CreateFrame("Button", "VaenylaeBardMainFrameAddSongButton", VaenylaeBardMainFrame, "UIPanelButtonTemplate")
    addButton:SetSize(100, 25)
    addButton:SetPoint("BOTTOMLEFT", VaenylaeBardMainFrame, "BOTTOMLEFT", 20, 45)
    addButton:SetText("Add Song")
    
    -- Create Remove Song Button  
    local removeButton = CreateFrame("Button", "VaenylaeBardMainFrameRemoveSongButton", VaenylaeBardMainFrame, "UIPanelButtonTemplate")
    removeButton:SetSize(100, 25)
    removeButton:SetPoint("BOTTOMRIGHT", VaenylaeBardMainFrame, "BOTTOMRIGHT", -20, 45)
    removeButton:SetText("Remove Song")
    
    -- Create Close Button (if it doesn't exist)
    if not VaenylaeBardMainFrameCloseButton then
        local closeButton = CreateFrame("Button", "VaenylaeBardMainFrameCloseButton", VaenylaeBardMainFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", VaenylaeBardMainFrame, "TOPRIGHT", -5, -5)
    end
    
    print("Buttons created successfully!")
end

-- Setup event handlers for XML-defined buttons
function SetupEventHandlers()
    -- Main frame close button
    VaenylaeBardMainFrameCloseButton:SetScript("OnClick", function()
        VaenylaeBardMainFrame:Hide()
    end)
    
    -- Add song button
    VaenylaeBardMainFrameAddSongButton:SetScript("OnClick", function()
        VaenylaeBardAddSongDialog:Show()
        VaenylaeBardAddSongEditBox:SetFocus()
    end)
    
    -- Remove song button
    VaenylaeBardMainFrameRemoveSongButton:SetScript("OnClick", function()
        if VaenylaeBardSelectedSong then
            VaenylaeBardSongs[VaenylaeBardSelectedSong] = nil
            VaenylaeBardSelectedSong = nil
            UpdateSongList()
            VaenylaeBardLineEditorFrame:Hide()
            print("Song removed.")
        else
            print("No song selected to remove.")
        end
    end)
    
    -- Line editor close button
    VaenylaeBardLineEditorFrameCloseButton:SetScript("OnClick", function()
        VaenylaeBardLineEditorFrame:Hide()
        VaenylaeBardSelectedLine = nil
    end)
    
    -- Save line button
    VaenylaeBardSaveLineButton:SetScript("OnClick", SaveLine)
    
    -- Add new line button
    VaenylaeBardLineEditorFrameAddLineButton:SetScript("OnClick", function()
        VaenylaeBardSelectedLine = nil
        VaenylaeBardLineTextBox:SetText("")
        VaenylaeBardLineEmoteBox:SetText("")
        VaenylaeBardLineDelayBox:SetText("3")
        VaenylaeBardLineTextBox:SetFocus()
    end)
    
    -- Line management buttons
    VaenylaeBardLineEditorFrameUpButton:SetScript("OnClick", function()
        if not VaenylaeBardSelectedSong or not VaenylaeBardSelectedLine then return end
        local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
        local i = VaenylaeBardSelectedLine
        if i and i > 1 then
            song[i], song[i-1] = song[i-1], song[i]
            VaenylaeBardSelectedLine = i-1
            UpdateLineList()
        end
    end)
    
    VaenylaeBardLineEditorFrameDownButton:SetScript("OnClick", function()
        if not VaenylaeBardSelectedSong or not VaenylaeBardSelectedLine then return end
        local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
        local i = VaenylaeBardSelectedLine
        if i and i < table.getn(song) then
            song[i], song[i+1] = song[i+1], song[i]
            VaenylaeBardSelectedLine = i+1
            UpdateLineList()
        end
    end)
    
    VaenylaeBardLineEditorFrameDeleteButton:SetScript("OnClick", function()
        if not VaenylaeBardSelectedSong or not VaenylaeBardSelectedLine then return end
        local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
        local i = VaenylaeBardSelectedLine
        if i then
            table.remove(song, i)
            VaenylaeBardSelectedLine = nil
            VaenylaeBardLineTextBox:SetText("")
            VaenylaeBardLineEmoteBox:SetText("")
            VaenylaeBardLineDelayBox:SetText("3")
            UpdateLineList()
            UpdateSongList()
        end
    end)
    
    -- Add song dialog buttons
    VaenylaeBardAddSongDialogAddButton:SetScript("OnClick", function()
        local songName = VaenylaeBardAddSongEditBox:GetText()
        if songName and songName ~= "" then
            if VaenylaeBardSongs[songName] then
                print("Song with that name already exists!")
                return
            end
            VaenylaeBardSongs[songName] = {}
            UpdateSongList()
            print("Song '" .. songName .. "' added.")
            VaenylaeBardAddSongEditBox:SetText("")
            VaenylaeBardAddSongDialog:Hide()
        else
            print("Please enter a song name.")
        end
    end)
    
    VaenylaeBardAddSongDialogCancelButton:SetScript("OnClick", function()
        VaenylaeBardAddSongEditBox:SetText("")
        VaenylaeBardAddSongDialog:Hide()
    end)
    
    -- Enter key support for add song dialog
    VaenylaeBardAddSongEditBox:SetScript("OnEnterPressed", function()
        VaenylaeBardAddSongDialogAddButton:GetScript("OnClick")()
    end)
    
    -- Escape key support
    VaenylaeBardAddSongEditBox:SetScript("OnEscapePressed", function()
        VaenylaeBardAddSongDialogCancelButton:GetScript("OnClick")()
    end)
    
    -- Enter key navigation in line editor
    VaenylaeBardLineTextBox:SetScript("OnEnterPressed", function()
        VaenylaeBardLineEmoteBox:SetFocus()
    end)
    
    VaenylaeBardLineEmoteBox:SetScript("OnEnterPressed", function()
        VaenylaeBardLineDelayBox:SetFocus()
    end)
    
    VaenylaeBardLineDelayBox:SetScript("OnEnterPressed", function()
        SaveLine()
    end)
end

-- Create click handler for song buttons (avoids closure issues)
local function CreateSongClickHandler(capturedSongName)
    return function()
        VaenylaeBardSelectedSong = capturedSongName
        VaenylaeBardLineEditorFrame:Show()
        UpdateLineList()
        print("Selected song: " .. capturedSongName)
    end
end

-- Update song list display
function UpdateSongList()
    local songList = VaenylaeBardSongList
    if not songList then return end
    
    -- Clear existing buttons
    if songList.buttons then
        for _, btn in pairs(songList.buttons) do
            btn:Hide()
        end
    else
        songList.buttons = {}
    end
    
    local y = 0
    local buttonIndex = 1
    
    for songName, songData in pairs(VaenylaeBardSongs) do
        local btn = songList.buttons[buttonIndex]
        if not btn then
            btn = CreateFrame("Button", nil, songList, "UIPanelButtonTemplate")
            btn:SetWidth(280)
            btn:SetHeight(25)
            songList.buttons[buttonIndex] = btn
        end
        
        btn:SetPoint("TOP", songList, "TOP", 0, -y)
        local lineCount = songData and table.getn(songData) or 0
        btn:SetText(songName .. " (" .. lineCount .. " lines)")
        btn:SetScript("OnClick", CreateSongClickHandler(songName))
        btn:Show()
        
        y = y + 30
        buttonIndex = buttonIndex + 1
    end
end

-- Update line list display
function UpdateLineList()
    local parent = VaenylaeBardLineList
    if not parent then return end
    
    -- Clear existing children
    local children = {parent:GetChildren()}
    for _, child in pairs(children) do
        child:Hide()
    end
    
    local y = 0
    local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
    if not song then return end
    
    for i, line in ipairs(song) do
        if line and type(line) == "table" then
            local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
            btn:SetWidth(260)
            btn:SetHeight(25)
            btn:SetPoint("TOP", parent, "TOP", 0, -y)
            
            local lineText = line.text or "Empty line"
            btn:SetText(i .. ". " .. lineText)
            
            btn:SetScript("OnClick", function()
                VaenylaeBardSelectedLine = i
                VaenylaeBardLineTextBox:SetText(line.text or "")
                VaenylaeBardLineEmoteBox:SetText(line.emote or "")
                VaenylaeBardLineDelayBox:SetText(tostring(line.delay or 3))
            end)
            y = y + 30
        end
    end
    parent:Show()
end

-- Save line function
function SaveLine()
    if not VaenylaeBardSelectedSong then 
        print("No song selected")
        return 
    end
    
    local text = VaenylaeBardLineTextBox:GetText()
    if not text or text == "" then
        print("Please enter line text.")
        return
    end
    
    local emote = VaenylaeBardLineEmoteBox:GetText() or ""
    local delay = tonumber(VaenylaeBardLineDelayBox:GetText()) or 3
    local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]

    if VaenylaeBardSelectedLine then
        song[VaenylaeBardSelectedLine] = {text=text, emote=emote, delay=delay}
        print("Line updated.")
    else
        table.insert(song, {text=text, emote=emote, delay=delay})
        print("Line added.")
    end
    
    VaenylaeBardSelectedLine = nil
    VaenylaeBardLineTextBox:SetText("")
    VaenylaeBardLineEmoteBox:SetText("")
    VaenylaeBardLineDelayBox:SetText("3")
    UpdateLineList()
    UpdateSongList()
end

-- Event handling for addon loading
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "VaenylaeBard" then
        InitializeAddon()
    elseif event == "PLAYER_LOGOUT" then
        if VaenylaeBardDB then
            VaenylaeBardDB.songs = VaenylaeBardSongs
        end
    end
end)

-- Slash commands
SLASH_VBARD1 = "/vbard"
SLASH_VBARD2 = "/vaenylaebard"
SlashCmdList["VBARD"] = function(msg)
    DiagnoseFrames()
    if msg == "debug" then
        print("=== VaenylaeBard Debug Info ===")
        local count = 0
        for name, data in pairs(VaenylaeBardSongs) do
            count = count + 1
            print("- " .. name .. " (" .. table.getn(data) .. " lines)")
        end
        print("Total songs: " .. count)
        return
    end
    
    -- Toggle main window
    if VaenylaeBardMainFrame:IsShown() then
        VaenylaeBardMainFrame:Hide()
        print("Vaenylae Bard: Hidden")
    else
        VaenylaeBardMainFrame:Show()
        print("Vaenylae Bard: Opened")
    end
end

print("VaenylaeBard: Loaded! Type /vbard to open.")