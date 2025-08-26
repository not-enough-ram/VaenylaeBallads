-- VaenylaeBard - XML-based Version for Classic WoW
-- UI frames are defined in VaenylaeBard.xml

-- Global variables
VaenylaeBardSongs = VaenylaeBardSongs or {}
VaenylaeBardSelectedSong = nil
VaenylaeBardSelectedLine = nil

-- Diagnostic function
local function DiagnoseFrames()
    local frames = {
        "VaenylaeBardMainFrame",
        "VaenylaeBardMainFrameAddSongButton", 
        "VaenylaeBardMainFrameRemoveSongButton",
        "VaenylaeBardMainFrameCloseButton",
        "VaenylaeBardAddSongDialog",
        "VaenylaeBardAddSongEditBox",
        "VaenylaeBardAddSongDialogAddButton",
        "VaenylaeBardAddSongDialogCancelButton",
        "VaenylaeBardSongList",
        "VaenylaeBardMainFrameSongScroll",
        "VaenylaeBardLineEditorFrame",
        "VaenylaeBardLineEditorFrameCloseButton",
        "VaenylaeBardLineEditorFrameAddLineButton",
        "VaenylaeBardLineEditorFrameUpButton",
        "VaenylaeBardLineEditorFrameDownButton",
        "VaenylaeBardLineEditorFrameDeleteButton",
        "VaenylaeBardLineTextBox",
        "VaenylaeBardLineEmoteBox", 
        "VaenylaeBardLineDelayBox"
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

-- Create main frame buttons dynamically
local function CreateMainFrameButtons()
    -- Check if main frame exists
    if not VaenylaeBardMainFrame then
        print("ERROR: VaenylaeBardMainFrame not found!")
        return false
    end
    
    -- Check if buttons already exist (avoid duplicates)
    if VaenylaeBardMainFrameAddSongButton then
        print("Buttons already exist, skipping creation.")
        return true
    end
    
    -- Create Add Song Button
    local addButton = CreateFrame("Button", "VaenylaeBardMainFrameAddSongButton", VaenylaeBardMainFrame, "UIPanelButtonTemplate")
    addButton:SetWidth(100)
    addButton:SetHeight(25)
    addButton:SetPoint("BOTTOMLEFT", VaenylaeBardMainFrame, "BOTTOMLEFT", 20, 45)
    addButton:SetText("Add Song")
    
    -- Create Remove Song Button  
    local removeButton = CreateFrame("Button", "VaenylaeBardMainFrameRemoveSongButton", VaenylaeBardMainFrame, "UIPanelButtonTemplate")
    removeButton:SetWidth(100)
    removeButton:SetHeight(25)
    removeButton:SetPoint("BOTTOMRIGHT", VaenylaeBardMainFrame, "BOTTOMRIGHT", -20, 45)
    removeButton:SetText("Remove Song")
    
    -- Create Close Button
    local closeButton = CreateFrame("Button", "VaenylaeBardMainFrameCloseButton", VaenylaeBardMainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", VaenylaeBardMainFrame, "TOPRIGHT", -5, -5)
    
    print("Buttons created successfully!")
    return true
end

-- Create song list area dynamically
local function CreateSongListArea()
    -- Check if main frame exists
    if not VaenylaeBardMainFrame then
        print("ERROR: VaenylaeBardMainFrame not found for song list creation!")
        return false
    end
    
    -- Check if already exists
    if VaenylaeBardSongList then
        print("Song list area already exists, skipping creation.")
        return true
    end
    
    -- Create the song list frame directly (skip ScrollFrame for now to simplify)
    local songList = CreateFrame("Frame", "VaenylaeBardSongList", VaenylaeBardMainFrame)
    songList:SetWidth(300)
    songList:SetHeight(280)
    songList:SetPoint("TOP", VaenylaeBardMainFrame, "TOP", 0, -45)
    
    -- Add a simple border/background for visibility (optional)
    songList:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    songList:Show()
    print("Song list area created successfully!")
    return true
end

-- Create Add Song Dialog buttons dynamically
local function CreateDialogButtons()
    -- Check if dialog exists
    if not VaenylaeBardAddSongDialog then
        print("ERROR: VaenylaeBardAddSongDialog not found!")
        return false
    end
    
    -- Create EditBox first (this is what was missing!)
    if not VaenylaeBardAddSongEditBox then
        local editBox = CreateFrame("EditBox", "VaenylaeBardAddSongEditBox", VaenylaeBardAddSongDialog, "InputBoxTemplate")
        editBox:SetWidth(250)
        editBox:SetHeight(32)
        editBox:SetPoint("TOP", VaenylaeBardAddSongDialog, "TOP", 0, -70)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(ChatFontNormal)
        print("EditBox created successfully!")
    end
    
    -- Check if buttons already exist (after creating EditBox)
    if VaenylaeBardAddSongDialogAddButton then
        print("Dialog buttons already exist, skipping creation.")
        return true
    end
    
    -- Create Add Button
    local addBtn = CreateFrame("Button", "VaenylaeBardAddSongDialogAddButton", VaenylaeBardAddSongDialog, "UIPanelButtonTemplate")
    addBtn:SetWidth(80)
    addBtn:SetHeight(25)
    addBtn:SetPoint("BOTTOM", VaenylaeBardAddSongDialog, "BOTTOM", -45, 15)
    addBtn:SetText("Add")
    
    -- Create Cancel Button
    local cancelBtn = CreateFrame("Button", "VaenylaeBardAddSongDialogCancelButton", VaenylaeBardAddSongDialog, "UIPanelButtonTemplate")
    cancelBtn:SetWidth(80)
    cancelBtn:SetHeight(25)
    cancelBtn:SetPoint("BOTTOM", VaenylaeBardAddSongDialog, "BOTTOM", 45, 15)
    cancelBtn:SetText("Cancel")
    
    print("Dialog components created successfully!")
    return true
end

-- Create line editor buttons dynamically
local function CreateLineEditorButtons()
    -- Check if line editor frame exists
    if not VaenylaeBardLineEditorFrame then
        print("ERROR: VaenylaeBardLineEditorFrame not found!")
        return false
    end
    
    -- Create EditBoxes first (these are missing from XML too!)
    if not VaenylaeBardLineTextBox then
        local textBox = CreateFrame("EditBox", "VaenylaeBardLineTextBox", VaenylaeBardLineEditorFrame, "InputBoxTemplate")
        textBox:SetWidth(280)
        textBox:SetHeight(32)
        textBox:SetPoint("TOP", VaenylaeBardLineEditorFrame, "TOP", 0, -200)
        textBox:SetAutoFocus(false)
        textBox:SetFontObject(ChatFontNormal)
        print("Line text EditBox created!")
    end
    
    if not VaenylaeBardLineEmoteBox then
        local emoteBox = CreateFrame("EditBox", "VaenylaeBardLineEmoteBox", VaenylaeBardLineEditorFrame, "InputBoxTemplate")
        emoteBox:SetWidth(280)
        emoteBox:SetHeight(32)
        emoteBox:SetPoint("TOP", VaenylaeBardLineEditorFrame, "TOP", 0, -260)
        emoteBox:SetAutoFocus(false)
        emoteBox:SetFontObject(ChatFontNormal)
        print("Line emote EditBox created!")
    end
    
    if not VaenylaeBardLineDelayBox then
        local delayBox = CreateFrame("EditBox", "VaenylaeBardLineDelayBox", VaenylaeBardLineEditorFrame, "InputBoxTemplate")
        delayBox:SetWidth(100)
        delayBox:SetHeight(32)
        delayBox:SetPoint("TOP", VaenylaeBardLineEditorFrame, "TOP", 0, -320)
        delayBox:SetAutoFocus(false)
        delayBox:SetFontObject(ChatFontNormal)
        delayBox:SetText("3")
        print("Line delay EditBox created!")
    end
    
    -- Check if buttons already exist
    if VaenylaeBardLineEditorFrameCloseButton then
        print("Line editor buttons already exist, skipping creation.")
        return true
    end
    
    -- Create Close Button
    local closeBtn = CreateFrame("Button", "VaenylaeBardLineEditorFrameCloseButton", VaenylaeBardLineEditorFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", VaenylaeBardLineEditorFrame, "TOPRIGHT", -5, -5)
    
    -- Create Add New Line Button
    local addLineBtn = CreateFrame("Button", "VaenylaeBardLineEditorFrameAddLineButton", VaenylaeBardLineEditorFrame, "UIPanelButtonTemplate")
    addLineBtn:SetWidth(120)
    addLineBtn:SetHeight(25)
    addLineBtn:SetPoint("BOTTOM", VaenylaeBardLineEditorFrame, "BOTTOM", 65, 20)
    addLineBtn:SetText("Add New Line")
    
    -- Create Up Button
    local upBtn = CreateFrame("Button", "VaenylaeBardLineEditorFrameUpButton", VaenylaeBardLineEditorFrame, "UIPanelButtonTemplate")
    upBtn:SetWidth(50)
    upBtn:SetHeight(20)
    upBtn:SetPoint("TOPLEFT", VaenylaeBardLineEditorFrame, "TOPLEFT", 20, -190)
    upBtn:SetText("Up")
    
    -- Create Down Button
    local downBtn = CreateFrame("Button", "VaenylaeBardLineEditorFrameDownButton", VaenylaeBardLineEditorFrame, "UIPanelButtonTemplate")
    downBtn:SetWidth(50)
    downBtn:SetHeight(20)
    downBtn:SetPoint("TOPLEFT", VaenylaeBardLineEditorFrame, "TOPLEFT", 80, -190)
    downBtn:SetText("Down")
    
    -- Create Delete Button
    local delBtn = CreateFrame("Button", "VaenylaeBardLineEditorFrameDeleteButton", VaenylaeBardLineEditorFrame, "UIPanelButtonTemplate")
    delBtn:SetWidth(50)
    delBtn:SetHeight(20)
    delBtn:SetPoint("TOPLEFT", VaenylaeBardLineEditorFrame, "TOPLEFT", 140, -190)
    delBtn:SetText("Del")
    
    print("Line editor buttons created successfully!")
    return true
end
local function CreateDialogButtons()
    -- Check if dialog exists
    if not VaenylaeBardAddSongDialog then
        print("ERROR: VaenylaeBardAddSongDialog not found!")
        return false
    end
    
    -- Create EditBox first (this is what was missing!)
    if not VaenylaeBardAddSongEditBox then
        local editBox = CreateFrame("EditBox", "VaenylaeBardAddSongEditBox", VaenylaeBardAddSongDialog, "InputBoxTemplate")
        editBox:SetWidth(250)
        editBox:SetHeight(32)
        editBox:SetPoint("TOP", VaenylaeBardAddSongDialog, "TOP", 0, -70)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(ChatFontNormal)
        print("EditBox created successfully!")
    end
    
    -- Check if buttons already exist (after creating EditBox)
    if VaenylaeBardAddSongDialogAddButton then
        print("Dialog buttons already exist, skipping creation.")
        return true
    end
    
    -- Create Add Button
    local addBtn = CreateFrame("Button", "VaenylaeBardAddSongDialogAddButton", VaenylaeBardAddSongDialog, "UIPanelButtonTemplate")
    addBtn:SetWidth(80)
    addBtn:SetHeight(25)
    addBtn:SetPoint("BOTTOM", VaenylaeBardAddSongDialog, "BOTTOM", -45, 15)
    addBtn:SetText("Add")
    
    -- Create Cancel Button
    local cancelBtn = CreateFrame("Button", "VaenylaeBardAddSongDialogCancelButton", VaenylaeBardAddSongDialog, "UIPanelButtonTemplate")
    cancelBtn:SetWidth(80)
    cancelBtn:SetHeight(25)
    cancelBtn:SetPoint("BOTTOM", VaenylaeBardAddSongDialog, "BOTTOM", 45, 15)
    cancelBtn:SetText("Cancel")
    
    print("Dialog components created successfully!")
    return true
end

-- Initialize addon
local function InitializeAddon()
    print("|cff00ffff[Vaenylae Bard]|r Manager loaded! Type /vbard to open.")
    
    -- Initialize saved variables
    if not VaenylaeBardDB then
        VaenylaeBardDB = { songs = {} }
    end
    VaenylaeBardSongs = VaenylaeBardDB.songs
    
    print("=== Starting Initialization ===")
    
    -- Create main frame buttons first - don't let dialog button failures block this
    local mainButtonsOK = CreateMainFrameButtons()
    print("Main buttons result: " .. tostring(mainButtonsOK))
    
    -- Create song list area
    local songListOK = CreateSongListArea()
    print("Song list result: " .. tostring(songListOK))
    
    -- Try to create dialog buttons (don't fail if this doesn't work)
    local dialogButtonsOK = CreateDialogButtons()
    print("Dialog buttons result: " .. tostring(dialogButtonsOK))
    
    -- Create line editor buttons
    local lineEditorOK = CreateLineEditorButtons()
    print("Line editor buttons result: " .. tostring(lineEditorOK))
    
    -- Always try to set up handlers if main buttons and song list exist
    if mainButtonsOK and songListOK then
        print("Setting up event handlers...")
        local handlersOK = SetupEventHandlers()
        print("Event handlers result: " .. tostring(handlersOK))
        
        print("Calling UpdateSongList...")
        UpdateSongList()
        print("=== Initialization Complete ===")
    else
        print("Main components failed - entering retry mode...")
        -- Retry logic for main buttons and song list
        local retryTimer = CreateFrame("Frame")
        local attempts = 0
        retryTimer:SetScript("OnUpdate", function()
            attempts = attempts + 1
            print("Retry attempt " .. attempts)
            local mainOK = CreateMainFrameButtons()
            local listOK = CreateSongListArea()
            if (mainOK and listOK) or attempts > 10 then
                retryTimer:SetScript("OnUpdate", nil)
                if attempts <= 10 then
                    CreateDialogButtons() -- Try dialog buttons again
                    -- Don't block on line editor buttons - create on demand
                    local handlersOK = SetupEventHandlers()
                    print("Retry - Event handlers result: " .. tostring(handlersOK))
                    UpdateSongList()
                    print("Retry successful after " .. attempts .. " attempts")
                else
                    print("ERROR: Failed to create main components after multiple attempts!")
                end
            end
        end)
    end
end

-- Setup dialog event handlers separately
-- Setup dialog event handlers separately  
function SetupDialogEventHandlers()
    -- Add song dialog buttons (with existence checks)
    if VaenylaeBardAddSongDialogAddButton then
        VaenylaeBardAddSongDialogAddButton:SetScript("OnClick", function()
            local songName = VaenylaeBardAddSongEditBox and VaenylaeBardAddSongEditBox:GetText() or ""
            if songName and songName ~= "" then
                if VaenylaeBardSongs[songName] then
                    print("Song with that name already exists!")
                    return
                end
                VaenylaeBardSongs[songName] = {}
                UpdateSongList()
                print("Song '" .. songName .. "' added.")
                if VaenylaeBardAddSongEditBox then VaenylaeBardAddSongEditBox:SetText("") end
                VaenylaeBardAddSongDialog:Hide()
            else
                print("Please enter a song name.")
            end
        end)
    end
    
    if VaenylaeBardAddSongDialogCancelButton then
        VaenylaeBardAddSongDialogCancelButton:SetScript("OnClick", function()
            if VaenylaeBardAddSongEditBox then VaenylaeBardAddSongEditBox:SetText("") end
            VaenylaeBardAddSongDialog:Hide()
        end)
    end
    
    -- Enter key support (with existence checks)
    if VaenylaeBardAddSongEditBox then
        VaenylaeBardAddSongEditBox:SetScript("OnEnterPressed", function()
            if VaenylaeBardAddSongDialogAddButton then
                VaenylaeBardAddSongDialogAddButton:GetScript("OnClick")()
            end
        end)
        
        VaenylaeBardAddSongEditBox:SetScript("OnEscapePressed", function()
            if VaenylaeBardAddSongDialogCancelButton then
                VaenylaeBardAddSongDialogCancelButton:GetScript("OnClick")()
            end
        end)
    end
end
-- Setup line editor event handlers separately
function SetupLineEditorEventHandlers()
    -- Check if line editor components exist before setting up their handlers
    if VaenylaeBardLineEditorFrameCloseButton then
        VaenylaeBardLineEditorFrameCloseButton:SetScript("OnClick", function()
            VaenylaeBardLineEditorFrame:Hide()
            VaenylaeBardSelectedLine = nil
        end)
    end
    
    if VaenylaeBardSaveLineButton then
        VaenylaeBardSaveLineButton:SetScript("OnClick", SaveLine)
    end
    
    if VaenylaeBardLineEditorFrameAddLineButton then
        VaenylaeBardLineEditorFrameAddLineButton:SetScript("OnClick", function()
            VaenylaeBardSelectedLine = nil
            VaenylaeBardLineTextBox:SetText("")
            VaenylaeBardLineEmoteBox:SetText("")
            VaenylaeBardLineDelayBox:SetText("3")
            VaenylaeBardLineTextBox:SetFocus()
        end)
    end
    
    -- Line management buttons (with existence checks)
    if VaenylaeBardLineEditorFrameUpButton then
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
    end
    
    if VaenylaeBardLineEditorFrameDownButton then
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
    end
    
    if VaenylaeBardLineEditorFrameDeleteButton then
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
    end
    
    print("Line editor event handlers configured!")
end

-- Setup event handlers for all buttons
function SetupEventHandlers()
    print("SetupEventHandlers called...")
    
    -- Verify main frame buttons exist
    if not VaenylaeBardMainFrameCloseButton or not VaenylaeBardMainFrameAddSongButton then
        print("ERROR: Main frame buttons not ready for event handler setup!")
        print("Close button exists: " .. tostring(VaenylaeBardMainFrameCloseButton ~= nil))
        print("Add button exists: " .. tostring(VaenylaeBardMainFrameAddSongButton ~= nil))
        return false
    end
    
    print("Setting up main frame button handlers...")
    
    -- Main frame close button
    VaenylaeBardMainFrameCloseButton:SetScript("OnClick", function()
        print("Close button clicked!")
        VaenylaeBardMainFrame:Hide()
    end)
    
    -- Add song button
    VaenylaeBardMainFrameAddSongButton:SetScript("OnClick", function()
        print("Add Song button clicked!")
        VaenylaeBardAddSongDialog:Show()
        
        -- Try to focus the EditBox
        if VaenylaeBardAddSongEditBox then
            VaenylaeBardAddSongEditBox:SetFocus()
        else
            print("WARNING: EditBox still not found after creation attempt")
        end
    end)
    
    -- Remove song button
    VaenylaeBardMainFrameRemoveSongButton:SetScript("OnClick", function()
        print("Remove Song button clicked!")
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
    
    print("Setting up dialog event handlers...")
    -- Add song dialog handlers (call separate function)
    SetupDialogEventHandlers()
    
    -- Try to set up line editor handlers if buttons exist
    if VaenylaeBardLineEditorFrameCloseButton then
        print("Setting up line editor handlers...")
        SetupLineEditorEventHandlers()
    else
        print("Line editor buttons not ready - will set up on-demand")
    end
    
    print("Setting up line editor input handlers...")
    -- Enter key navigation in line editor (with existence checks)
    if VaenylaeBardLineTextBox then
        VaenylaeBardLineTextBox:SetScript("OnEnterPressed", function()
            if VaenylaeBardLineEmoteBox then
                VaenylaeBardLineEmoteBox:SetFocus()
            end
        end)
    end
    
    if VaenylaeBardLineEmoteBox then
        VaenylaeBardLineEmoteBox:SetScript("OnEnterPressed", function()
            if VaenylaeBardLineDelayBox then
                VaenylaeBardLineDelayBox:SetFocus()
            end
        end)
    end
    
    if VaenylaeBardLineDelayBox then
        VaenylaeBardLineDelayBox:SetScript("OnEnterPressed", function()
            SaveLine()
        end)
    end
    
    print("Main event handlers configured successfully!")
    return true
end

-- Create click handler for song buttons (avoids closure issues)
local function CreateSongClickHandler(capturedSongName)
    return function()
        VaenylaeBardSelectedSong = capturedSongName
        
        -- Create line editor buttons on-demand if they don't exist
        if not VaenylaeBardLineEditorFrameCloseButton then
            print("Creating line editor buttons on-demand...")
            if CreateLineEditorButtons() then
                -- Set up line editor event handlers now
                SetupLineEditorEventHandlers()
            else
                print("WARNING: Failed to create line editor buttons on-demand!")
            end
        end
        
        VaenylaeBardLineEditorFrame:Show()
        UpdateLineList()
        print("Selected song: " .. capturedSongName)
    end
end

-- Update song list display
function UpdateSongList()
    print("UpdateSongList called...")
    
    local songList = VaenylaeBardSongList
    if not songList then 
        print("ERROR: VaenylaeBardSongList not found!")
        return 
    end
    print("Song list frame found: " .. tostring(songList:GetName()))
    
    -- Count songs first
    local songCount = 0
    for _ in pairs(VaenylaeBardSongs) do
        songCount = songCount + 1
    end
    print("Found " .. songCount .. " songs to display")
    
    -- Clear existing buttons
    if songList.buttons then
        print("Clearing existing buttons...")
        for _, btn in pairs(songList.buttons) do
            btn:Hide()
        end
    else
        songList.buttons = {}
        print("Initialized empty buttons table")
    end
    
    local y = 0
    local buttonIndex = 1
    
    for songName, songData in pairs(VaenylaeBardSongs) do
        print("Processing song: " .. songName)
        
        local btn = songList.buttons[buttonIndex]
        if not btn then
            btn = CreateFrame("Button", nil, songList, "UIPanelButtonTemplate")
            btn:SetWidth(280)
            btn:SetHeight(25)
            songList.buttons[buttonIndex] = btn
            print("Created new button " .. buttonIndex)
        else
            print("Reusing button " .. buttonIndex)
        end
        
        btn:SetPoint("TOP", songList, "TOP", 0, -y)
        local lineCount = songData and table.getn(songData) or 0
        local buttonText = songName .. " (" .. lineCount .. " lines)"
        btn:SetText(buttonText)
        btn:SetScript("OnClick", CreateSongClickHandler(songName))
        btn:Show()
        
        print("Button " .. buttonIndex .. " configured: '" .. buttonText .. "' at y=" .. y)
        
        y = y + 30
        buttonIndex = buttonIndex + 1
    end
    
    print("UpdateSongList completed - processed " .. (buttonIndex - 1) .. " songs")
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
    if msg == "debug" then
        print("=== VaenylaeBard Debug Info ===")
        DiagnoseFrames()
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