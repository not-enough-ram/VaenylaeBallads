-- VaenylaeBard - Clean XML-based Version for Classic WoW
-- All UI elements are now defined in VaenylaeBard.xml

-- Global variables
VaenylaeBardSongs = VaenylaeBardSongs or {}
VaenylaeBardSelectedSong = nil
VaenylaeBardSelectedLine = nil

-- Easy access to UI elements (all exist thanks to XML)
local MainFrame = VaenylaeBardMainFrame
local LineEditorFrame = VaenylaeBardLineEditorFrame
local AddSongDialog = VaenylaeBardAddSongDialog

-- UI element references (using proper global names)
local MainFrameCloseButton = VaenylaeBardMainFrameCloseButton
local MainFrameAddSongButton = VaenylaeBardMainFrameAddSongButton
local MainFrameRemoveSongButton = VaenylaeBardMainFrameRemoveSongButton
local MainFramePlaySongButton = VaenylaeBardMainFramePlaySongButton
local MainFrameSongScroll = VaenylaeBardMainFrameSongScroll

local AddSongDialogEditBox = VaenylaeBardAddSongDialogEditBox
local AddSongDialogAddButton = VaenylaeBardAddSongDialogAddButton
local AddSongDialogCancelButton = VaenylaeBardAddSongDialogCancelButton

local LineEditorCloseButton = VaenylaeBardLineEditorFrameCloseButton
local LineEditorUpButton = VaenylaeBardLineEditorFrameUpButton
local LineEditorDownButton = VaenylaeBardLineEditorFrameDownButton
local LineEditorDeleteButton = VaenylaeBardLineEditorFrameDeleteButton
local LineEditorAddLineButton = VaenylaeBardLineEditorFrameAddLineButton
local LineEditorSaveLineButton = VaenylaeBardLineEditorFrameSaveLineButton
local LineEditorClearButton = VaenylaeBardLineEditorFrameClearButton
local LineEditorLineTextBox = VaenylaeBardLineEditorFrameLineTextBox
local LineEditorEmoteBox = VaenylaeBardLineEditorFrameEmoteBox
local LineEditorDelayBox = VaenylaeBardLineEditorFrameDelayBox
local LineEditorTitle = VaenylaeBardLineEditorFrameTitle
local LineEditorLineScroll = VaenylaeBardLineEditorFrameLineScroll

-- Debug function to check what UI elements exist
local function DebugUIElements()
    print("=== Debugging UI Elements ===")
    
    local elements = {
        -- Main frame elements
        "VaenylaeBardMainFrame",
        "VaenylaeBardMainFrameCloseButton", 
        "VaenylaeBardMainFrameAddSongButton",
        "VaenylaeBardMainFrameRemoveSongButton",
        "VaenylaeBardMainFramePlaySongButton",
        "VaenylaeBardMainFrameSongScroll",
        "VaenylaeBardMainFrameSongList",
        
        -- Dialog elements
        "VaenylaeBardAddSongDialog",
        "VaenylaeBardAddSongDialogEditBox",
        "VaenylaeBardAddSongDialogAddButton",
        "VaenylaeBardAddSongDialogCancelButton",
        
        -- Line editor elements
        "VaenylaeBardLineEditorFrame",
        "VaenylaeBardLineEditorFrameCloseButton",
        "VaenylaeBardLineEditorFrameLineTextBox",
        "VaenylaeBardLineEditorFrameEmoteBox",
        "VaenylaeBardLineEditorFrameDelayBox",
        "VaenylaeBardLineEditorFrameLineScroll",
        "VaenylaeBardLineEditorFrameLineList",
        "VaenylaeBardLineEditorFrameSaveLineButton",
        "VaenylaeBardLineEditorFrameClearButton"
    }
    
    for _, elementName in ipairs(elements) do
        local element = getglobal(elementName)
        if element then
            print("✓ " .. elementName .. " exists")
        else
            print("✗ " .. elementName .. " is NIL")
        end
    end
    
    -- Special check for scroll frame children
    print("=== ScrollFrame Child Check ===")
    local mainScroll = getglobal("VaenylaeBardMainFrameSongScroll")
    if mainScroll then
        local child = mainScroll:GetScrollChild()
        print("MainFrame ScrollChild: " .. tostring(child))
    end
    
    local lineScroll = getglobal("VaenylaeBardLineEditorFrameLineScroll")
    if lineScroll then
        local child = lineScroll:GetScrollChild()
        print("LineEditor ScrollChild: " .. tostring(child))
    end
    
    print("=== End Debug ===")
end

-- Initialize addon with proper error checking
local function InitializeAddon()
    print("|cff00ffff[Vaenylae Bard]|r Manager loaded! Type /vbard to open.")
    
    -- Debug what elements exist
    DebugUIElements()
    
    -- Initialize saved variables
    if not VaenylaeBardDB then
        VaenylaeBardDB = { songs = {} }
    end
    VaenylaeBardSongs = VaenylaeBardDB.songs
    
    -- Check if main frame exists before proceeding
    if not MainFrame then
        print("ERROR: Main frame not found! UI loading failed.")
        return
    end
    
    -- Set up all event handlers with error checking
    local success = pcall(SetupEventHandlers)
    if not success then
        print("ERROR: Failed to set up event handlers. Some UI elements may be missing.")
        return
    end
    
    -- Update displays
    UpdateSongList()
    
    print("Vaenylae Bard: Initialization complete!")
end

-- Setup all event handlers with proper error checking
function SetupEventHandlers()
    print("Setting up event handlers...")
    
    -- Main Frame Handlers (with nil checks)
    if MainFrameCloseButton then
        MainFrameCloseButton:SetScript("OnClick", function()
            MainFrame:Hide()
        end)
        print("✓ Main frame close button handler set")
    else
        print("✗ MainFrameCloseButton is nil - skipping")
    end
    
    if MainFrameAddSongButton then
        MainFrameAddSongButton:SetScript("OnClick", function()
            AddSongDialog:Show()
            if AddSongDialogEditBox then
                AddSongDialogEditBox:SetFocus()
            end
        end)
        print("✓ Add song button handler set")
    else
        print("✗ MainFrameAddSongButton is nil - skipping")
    end
    
    if MainFrameRemoveSongButton then
        MainFrameRemoveSongButton:SetScript("OnClick", function()
            if VaenylaeBardSelectedSong then
                VaenylaeBardSongs[VaenylaeBardSelectedSong] = nil
                VaenylaeBardSelectedSong = nil
                UpdateSongList()
                LineEditorFrame:Hide()
                print("Song removed.")
            else
                print("No song selected to remove.")
            end
        end)
        print("✓ Remove song button handler set")
    else
        print("✗ MainFrameRemoveSongButton is nil - skipping")
    end
    
    if MainFramePlaySongButton then
        MainFramePlaySongButton:SetScript("OnClick", function()
            if VaenylaeBardSelectedSong then
                PlaySong(VaenylaeBardSelectedSong)
            else
                print("No song selected to play.")
            end
        end)
        print("✓ Play song button handler set")
    else
        print("✗ MainFramePlaySongButton is nil - skipping")
    end
    
    -- Add Song Dialog Handlers
    if AddSongDialogAddButton then
        AddSongDialogAddButton:SetScript("OnClick", function()
            local songName = AddSongDialogEditBox and AddSongDialogEditBox:GetText() or ""
            if songName and songName ~= "" then
                if VaenylaeBardSongs[songName] then
                    print("Song with that name already exists!")
                    return
                end
                VaenylaeBardSongs[songName] = {}
                UpdateSongList()
                print("Song '" .. songName .. "' added.")
                if AddSongDialogEditBox then AddSongDialogEditBox:SetText("") end
                AddSongDialog:Hide()
            else
                print("Please enter a song name.")
            end
        end)
        print("✓ Add song dialog button handler set")
    else
        print("✗ AddSongDialogAddButton is nil - skipping")
    end
    
    if AddSongDialogCancelButton then
        AddSongDialogCancelButton:SetScript("OnClick", function()
            if AddSongDialogEditBox then AddSongDialogEditBox:SetText("") end
            AddSongDialog:Hide()
        end)
        print("✓ Cancel dialog button handler set")
    else
        print("✗ AddSongDialogCancelButton is nil - skipping")
    end
    
    -- Enter/Escape key support for dialog
    if AddSongDialogEditBox then
        AddSongDialogEditBox:SetScript("OnEnterPressed", function()
            if AddSongDialogAddButton then
                AddSongDialogAddButton:GetScript("OnClick")()
            end
        end)
        
        AddSongDialogEditBox:SetScript("OnEscapePressed", function()
            if AddSongDialogCancelButton then
                AddSongDialogCancelButton:GetScript("OnClick")()
            end
        end)
        print("✓ Dialog editbox key handlers set")
    else
        print("✗ AddSongDialogEditBox is nil - skipping key handlers")
    end
    
    -- Line Editor Handlers - only set up if elements exist
    if LineEditorCloseButton then
        LineEditorCloseButton:SetScript("OnClick", function()
            LineEditorFrame:Hide()
            VaenylaeBardSelectedLine = nil
        end)
        print("✓ Line editor close button handler set")
    else
        print("✗ LineEditorCloseButton is nil - skipping")
    end
    
    -- Set up other line editor handlers only if elements exist
    if LineEditorSaveLineButton then
        LineEditorSaveLineButton:SetScript("OnClick", SaveLine)
        print("✓ Save line button handler set")
    else
        print("✗ LineEditorSaveLineButton is nil - skipping")
    end
    
    -- Continue with other handlers only if they exist...
    if LineEditorClearButton then
        LineEditorClearButton:SetScript("OnClick", function()
            VaenylaeBardSelectedLine = nil
            if LineEditorLineTextBox then LineEditorLineTextBox:SetText("") end
            if LineEditorEmoteBox then LineEditorEmoteBox:SetText("") end
            if LineEditorDelayBox then LineEditorDelayBox:SetText("3") end
            if LineEditorLineTextBox then LineEditorLineTextBox:SetFocus() end
        end)
        print("✓ Clear button handler set")
    else
        print("✗ LineEditorClearButton is nil - skipping")
    end
    
    print("Event handler setup completed with available elements")
end

-- Update song list display using ScrollFrame
function UpdateSongList()
    print("UpdateSongList called...")
    
    -- Check if scroll frame exists, otherwise use fallback
    local songList = nil
    if MainFrameSongScroll then
        print("Using ScrollFrame method...")
        songList = MainFrameSongScroll:GetScrollChild()
        if not songList then
            print("ScrollFrame exists but GetScrollChild() returned nil")
            -- Try to get the child directly by name
            songList = getglobal("VaenylaeBardMainFrameSongScrollScrollChild") or getglobal("VaenylaeBardMainFrameSongList")
        end
    else
        print("MainFrameSongScroll is nil - using fallback method")
        -- Fallback: try to get the song list frame directly
        songList = getglobal("VaenylaeBardMainFrameSongList")
    end
    
    if not songList then 
        print("ERROR: Could not find song list container at all!")
        print("Available options:")
        print("- MainFrameSongScroll: " .. tostring(MainFrameSongScroll))
        print("- VaenylaeBardMainFrameSongList: " .. tostring(getglobal("VaenylaeBardMainFrameSongList")))
        
        -- Create a simple fallback container
        if MainFrame then
            print("Creating emergency fallback song list...")
            songList = CreateFrame("Frame", "VBEmergencySongList", MainFrame)
            songList:SetWidth(350)
            songList:SetHeight(280)
            songList:SetPoint("TOP", MainFrame, "TOP", 0, -45)
            print("Emergency song list created!")
        else
            print("Even MainFrame is nil - cannot continue")
            return
        end
    else
        print("Song list container found successfully!")
    end
    
    -- Clear existing buttons
    local children = {songList:GetChildren()}
    for _, child in pairs(children) do
        child:Hide()
    end
    
    -- Count songs and create buttons
    local songCount = 0
    local y = 0
    local buttonHeight = 25
    local spacing = 5
    
    for songName, songData in pairs(VaenylaeBardSongs) do
        songCount = songCount + 1
        
        -- Create or reuse button
        local buttonName = "VBSongButton" .. songCount
        local btn = getglobal(buttonName) or CreateFrame("Button", buttonName, songList, "UIPanelButtonTemplate")
        
        btn:SetWidth(340)
        btn:SetHeight(buttonHeight)
        btn:SetPoint("TOP", songList, "TOP", 0, -y)
        
        local lineCount = songData and table.getn(songData) or 0
        local buttonText = songName .. " (" .. lineCount .. " lines)"
        btn:SetText(buttonText)
        
        -- Create click handler (avoid closure issues)
        btn:SetScript("OnClick", CreateSongClickHandler(songName))
        btn:Show()
        
        y = y + buttonHeight + spacing
    end
    
    -- Update scroll frame height if it's a scroll frame
    if songList.SetHeight then
        songList:SetHeight(math.max(y, 300))
    end
    
    print("Song list updated - " .. songCount .. " songs displayed")
end

-- Create click handler for song buttons
local function CreateSongClickHandler(capturedSongName)
    return function()
        VaenylaeBardSelectedSong = capturedSongName
        LineEditorFrame:Show()
        LineEditorTitle:SetText("Editing: " .. capturedSongName)
        UpdateLineList()
        print("Selected song: " .. capturedSongName)
    end
end

-- Update line list display using ScrollFrame
function UpdateLineList()
    print("UpdateLineList called...")
    
    -- Check if line scroll frame exists, otherwise use fallback
    local lineList = nil
    if LineEditorLineScroll then
        print("Using LineEditor ScrollFrame method...")
        lineList = LineEditorLineScroll:GetScrollChild()
        if not lineList then
            print("LineEditor ScrollFrame exists but GetScrollChild() returned nil")
            -- Try to get the child directly by name
            lineList = getglobal("VaenylaeBardLineEditorFrameLineScrollScrollChild") or getglobal("VaenylaeBardLineEditorFrameLineList")
        end
    else
        print("LineEditorLineScroll is nil - using fallback method")
        -- Fallback: try to get the line list frame directly
        lineList = getglobal("VaenylaeBardLineEditorFrameLineList")
    end
    
    if not lineList then
        print("ERROR: Could not find line list container!")
        print("LineEditorLineScroll: " .. tostring(LineEditorLineScroll))
        
        -- Create a simple fallback container
        if LineEditorFrame then
            print("Creating emergency fallback line list...")
            lineList = CreateFrame("Frame", "VBEmergencyLineList", LineEditorFrame)
            lineList:SetWidth(400)
            lineList:SetHeight(180)
            lineList:SetPoint("TOP", LineEditorFrame, "TOP", 0, -50)
            print("Emergency line list created!")
        else
            print("LineEditorFrame is nil - cannot continue")
            return
        end
    else
        print("Line list container found successfully!")
    end
    
    -- Clear existing children
    local children = {lineList:GetChildren()}
    for _, child in pairs(children) do
        child:Hide()
    end
    
    local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
    if not song then 
        print("No selected song for line list")
        return 
    end
    
    local y = 0
    local buttonHeight = 25
    local spacing = 3
    
    for i, line in ipairs(song) do
        if line and type(line) == "table" then
            local buttonName = "VBLineButton" .. i
            local btn = getglobal(buttonName) or CreateFrame("Button", buttonName, lineList, "UIPanelButtonTemplate")
            
            btn:SetWidth(380)
            btn:SetHeight(buttonHeight)
            btn:SetPoint("TOP", lineList, "TOP", 0, -y)
            
            local lineText = line.text or "Empty line"
            local displayText = i .. ". " .. lineText
            if string.len(displayText) > 50 then
                displayText = string.sub(displayText, 1, 47) .. "..."
            end
            btn:SetText(displayText)
            
            -- Create click handler for line selection
            btn:SetScript("OnClick", function()
                SelectLine(i)
            end)
            
            btn:Show()
            y = y + buttonHeight + spacing
        end
    end
    
    -- Update scroll frame height if it supports it
    if lineList.SetHeight then
        lineList:SetHeight(math.max(y, 180))
    end
    
    print("Line list updated - " .. table.getn(song) .. " lines processed")
end

-- Select a line for editing
function SelectLine(lineIndex)
    VaenylaeBardSelectedLine = lineIndex
    local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
    local line = song[lineIndex]
    
    if line then
        LineEditorLineTextBox:SetText(line.text or "")
        LineEditorEmoteBox:SetText(line.emote or "")
        LineEditorDelayBox:SetText(tostring(line.delay or 3))
    end
    
    print("Selected line " .. lineIndex .. " for editing")
end

-- Save line function
function SaveLine()
    if not VaenylaeBardSelectedSong then 
        print("No song selected")
        return 
    end
    
    local text = LineEditorLineTextBox:GetText()
    if not text or text == "" then
        print("Please enter line text.")
        LineEditorLineTextBox:SetFocus()
        return
    end
    
    local emote = LineEditorEmoteBox:GetText() or ""
    local delay = tonumber(LineEditorDelayBox:GetText()) or 3
    local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]

    if VaenylaeBardSelectedLine then
        song[VaenylaeBardSelectedLine] = {text=text, emote=emote, delay=delay}
        print("Line " .. VaenylaeBardSelectedLine .. " updated.")
    else
        table.insert(song, {text=text, emote=emote, delay=delay})
        print("New line added.")
    end
    
    -- Clear form and update displays
    VaenylaeBardSelectedLine = nil
    LineEditorLineTextBox:SetText("")
    LineEditorEmoteBox:SetText("")
    LineEditorDelayBox:SetText("3")
    UpdateLineList()
    UpdateSongList()
end

-- Move line up
function MoveLineUp()
    if not VaenylaeBardSelectedSong or not VaenylaeBardSelectedLine then
        print("No line selected.")
        return
    end
    
    local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
    local i = VaenylaeBardSelectedLine
    
    if i > 1 then
        song[i], song[i-1] = song[i-1], song[i]
        VaenylaeBardSelectedLine = i-1
        UpdateLineList()
        SelectLine(VaenylaeBardSelectedLine)
        print("Line moved up.")
    else
        print("Line is already at the top.")
    end
end

-- Move line down
function MoveLineDown()
    if not VaenylaeBardSelectedSong or not VaenylaeBardSelectedLine then
        print("No line selected.")
        return
    end
    
    local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
    local i = VaenylaeBardSelectedLine
    
    if i < table.getn(song) then
        song[i], song[i+1] = song[i+1], song[i]
        VaenylaeBardSelectedLine = i+1
        UpdateLineList()
        SelectLine(VaenylaeBardSelectedLine)
        print("Line moved down.")
    else
        print("Line is already at the bottom.")
    end
end

-- Delete line
function DeleteLine()
    if not VaenylaeBardSelectedSong or not VaenylaeBardSelectedLine then
        print("No line selected.")
        return
    end
    
    local song = VaenylaeBardSongs[VaenylaeBardSelectedSong]
    local i = VaenylaeBardSelectedLine
    
    table.remove(song, i)
    VaenylaeBardSelectedLine = nil
    LineEditorLineTextBox:SetText("")
    LineEditorEmoteBox:SetText("")
    LineEditorDelayBox:SetText("3")
    UpdateLineList()
    UpdateSongList()
    print("Line deleted.")
end

-- Play song function (basic implementation)
function PlaySong(songName)
    local song = VaenylaeBardSongs[songName]
    if not song or table.getn(song) == 0 then
        print("Song is empty or doesn't exist.")
        return
    end
    
    print("Playing song: " .. songName)
    PlaySongLines(song, 1)
end

-- Recursive function to play song lines with delays
function PlaySongLines(song, lineIndex)
    if lineIndex > table.getn(song) then
        print("Song finished.")
        return
    end
    
    local line = song[lineIndex]
    if not line then
        return
    end
    
    -- Send the line text
    if line.text and line.text ~= "" then
        SendChatMessage(line.text, "SAY")
    end
    
    -- Do emote if specified
    if line.emote and line.emote ~= "" then
        DoEmote(line.emote)
    end
    
    -- Schedule next line
    local delay = line.delay or 3
    local timer = CreateFrame("Frame")
    local timeElapsed = 0
    timer:SetScript("OnUpdate", function()
        timeElapsed = timeElapsed + arg1
        if timeElapsed >= delay then
            timer:SetScript("OnUpdate", nil)
            PlaySongLines(song, lineIndex + 1)
        end
    end)
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
        DebugUIElements()
        local count = 0
        for name, data in pairs(VaenylaeBardSongs) do
            count = count + 1
            print("- " .. name .. " (" .. table.getn(data) .. " lines)")
        end
        print("Total songs: " .. count)
        print("Selected song: " .. tostring(VaenylaeBardSelectedSong))
        print("Selected line: " .. tostring(VaenylaeBardSelectedLine))
        return
    end
    
    -- Toggle main window
    if MainFrame and MainFrame:IsShown() then
        MainFrame:Hide()
        print("Vaenylae Bard: Hidden")
    elseif MainFrame then
        MainFrame:Show()
        print("Vaenylae Bard: Opened")
    else
        print("ERROR: Main frame not found!")
    end
end

print("VaenylaeBard: XML-based version loaded! Type /vbard to open.")