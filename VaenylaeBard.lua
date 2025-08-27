-- VaenylaeBard - Following TurtleRP Architecture Pattern
-- Created by Vaenylae, inspired by TurtleRP by Vee/Drixi

-----
-- Global storage (not saved between sessions)
-----
VaenylaeBard = VaenylaeBard or {}

-- Version info
VaenylaeBard.currentVersion = "1.0.0"

-- UI state
VaenylaeBard.selectedSong = nil
VaenylaeBard.selectedLine = nil
VaenylaeBard.isPlaying = nil
VaenylaeBard.playTimer = nil

-- Song buttons (similar to TurtleRP's button management)
VaenylaeBard.songButtons = {}
VaenylaeBard.lineButtons = {}

-----
-- Addon load event (following TurtleRP pattern)
-----
local VaenylaeBard_Parent = CreateFrame("Frame")
VaenylaeBard_Parent:RegisterEvent("ADDON_LOADED")
VaenylaeBard_Parent:RegisterEvent("PLAYER_LOGOUT")

function VaenylaeBard:OnEvent()
  if event == "ADDON_LOADED" and arg1 == "VaenylaeBard" then

    -- Initialize saved variables
    if VaenylaeBardDB == nil then
      VaenylaeBardDB = { songs = {} }
    end
    VaenylaeBardSongs = VaenylaeBardDB.songs

    -- Initialize UI
    VaenylaeBard.InitializeUI()
    
    -- Create song buttons
    VaenylaeBard.CreateSongButtons()
    VaenylaeBard.CreateLineButtons()
    
    -- Update displays
    VaenylaeBard.UpdateSongList()

    -- Success message (following TurtleRP style)
    VaenylaeBard.log("|cff00ffff[Vaenylae Bard]|r Song manager loaded! Type |cff00ffff/vbard|r to open.")

    -- Slash commands
    SLASH_VBARD1 = "/vbard"
    SLASH_VBARD2 = "/vaenylaebard"
    SlashCmdList["VBARD"] = function(msg)
      if msg == "debug" then
        VaenylaeBard.DebugInfo()
      else
        VaenylaeBard.ToggleMainFrame()
      end
    end

  elseif event == "PLAYER_LOGOUT" then
    -- Save data
    if VaenylaeBardDB then
      VaenylaeBardDB.songs = VaenylaeBardSongs
    end
  end
end

VaenylaeBard_Parent:SetScript("OnEvent", VaenylaeBard.OnEvent)

-----
-- Utility functions (following TurtleRP pattern)
-----
function VaenylaeBard.log(message)
  DEFAULT_CHAT_FRAME:AddMessage(message)
end

function VaenylaeBard.DebugInfo()
  VaenylaeBard.log("=== Vaenylae Bard Debug Info ===")
  local songCount = 0
  for name, data in pairs(VaenylaeBardSongs) do
    songCount = songCount + 1
    VaenylaeBard.log("- " .. name .. " (" .. table.getn(data) .. " lines)")
  end
  VaenylaeBard.log("Total songs: " .. songCount)
  VaenylaeBard.log("Selected song: " .. tostring(VaenylaeBard.selectedSong))
  VaenylaeBard.log("Selected line: " .. tostring(VaenylaeBard.selectedLine))
end

-----
-- UI Management (following TurtleRP pattern)
-----
function VaenylaeBard.InitializeUI()
  -- Set up close button scripts
  VaenylaeBardMainFrame_CloseButton:SetScript("OnClick", function()
    VaenylaeBardMainFrame:Hide()
  end)
  
  VaenylaeBardLineEditorFrame_CloseButton:SetScript("OnClick", function()
    VaenylaeBardLineEditorFrame:Hide()
  end)
  
  -- Set up main frame buttons (already defined in XML OnClick)
  -- No additional setup needed thanks to XML event handlers
end

function VaenylaeBard.ToggleMainFrame()
  if VaenylaeBardMainFrame:IsShown() then
    VaenylaeBardMainFrame:Hide()
    VaenylaeBard.log("Vaenylae Bard: Hidden")
  else
    VaenylaeBardMainFrame:Show()
    VaenylaeBard.log("Vaenylae Bard: Opened")
    VaenylaeBard.UpdateSongList()
  end
end

-----
-- Song Button Management (following TurtleRP DirectoryButton pattern)
-----
function VaenylaeBard.CreateSongButtons()
  for i = 1, 15 do -- Create 15 buttons like TurtleRP Directory
    local button = CreateFrame("Button", "VaenylaeBardSongButton" .. i, VaenylaeBardMainFrame_SongScrollBox, "VaenylaeBardSongButtonTemplate")
    button:SetID(i)
    
    if i == 1 then
      button:SetPoint("TOPLEFT", VaenylaeBardMainFrame_SongScrollBox, "TOPLEFT", 5, -5)
    else
      button:SetPoint("TOPLEFT", "VaenylaeBardSongButton" .. (i-1), "BOTTOMLEFT", 0, 0)
    end
    
    VaenylaeBard.songButtons[i] = button
  end
end

function VaenylaeBard.CreateLineButtons()
  for i = 1, 15 do -- Create 15 buttons for lines
    local button = CreateFrame("Button", "VaenylaeBardLineButton" .. i, VaenylaeBardLineEditorFrame_LineScrollBox, "VaenylaeBardLineButtonTemplate")
    button:SetID(i)
    
    if i == 1 then
      button:SetPoint("TOPLEFT", VaenylaeBardLineEditorFrame_LineScrollBox, "TOPLEFT", 5, -5)
    else
      button:SetPoint("TOPLEFT", "VaenylaeBardLineButton" .. (i-1), "BOTTOMLEFT", 0, 0)
    end
    
    VaenylaeBard.lineButtons[i] = button
  end
end

-----
-- Scroll Management (following TurtleRP FauxScrollFrame pattern)
-----
function VaenylaeBard.SongScrollBar_Update()
  local songs = {}
  for name, _ in pairs(VaenylaeBardSongs) do
    table.insert(songs, name)
  end
  table.sort(songs)
  
  local numSongs = table.getn(songs)
  local offset = FauxScrollFrame_GetOffset(VaenylaeBardMainFrame_SongScrollBox)
  
  FauxScrollFrame_Update(VaenylaeBardMainFrame_SongScrollBox, numSongs, 15, 20)
  
  for i = 1, 15 do
    local button = VaenylaeBard.songButtons[i]
    local songIndex = i + offset
    
    if songIndex <= numSongs then
      local songName = songs[songIndex]
      button:SetText(songName)
      button.songName = songName
      button:Show()
      
      -- Highlight selected song
      if songName == VaenylaeBard.selectedSong then
        button:LockHighlight()
      else
        button:UnlockHighlight()
      end
    else
      button:Hide()
    end
  end
end

function VaenylaeBard.LineScrollBar_Update()
  if not VaenylaeBard.selectedSong then
    -- Hide all line buttons if no song selected
    for i = 1, 15 do
      VaenylaeBard.lineButtons[i]:Hide()
    end
    return
  end
  
  local lines = VaenylaeBardSongs[VaenylaeBard.selectedSong] or {}
  local numLines = table.getn(lines)
  local offset = FauxScrollFrame_GetOffset(VaenylaeBardLineEditorFrame_LineScrollBox)
  
  FauxScrollFrame_Update(VaenylaeBardLineEditorFrame_LineScrollBox, numLines, 15, 18)
  
  for i = 1, 15 do
    local button = VaenylaeBard.lineButtons[i]
    local lineIndex = i + offset
    
    if lineIndex <= numLines then
      local line = lines[lineIndex]
      local displayText = lineIndex .. ". "
      if line.text and string.len(line.text) > 0 then
        displayText = displayText .. string.sub(line.text, 1, 40)
        if string.len(line.text) > 40 then
          displayText = displayText .. "..."
        end
      else
        displayText = displayText .. "(empty line)"
      end
      
      button:SetText(displayText)
      button.lineIndex = lineIndex
      button:Show()
      
      -- Highlight selected line
      if lineIndex == VaenylaeBard.selectedLine then
        button:LockHighlight()
      else
        button:UnlockHighlight()
      end
    else
      button:Hide()
    end
  end
end

-----
-- Song Management Functions
-----
function VaenylaeBard.SelectSong(songName)
  VaenylaeBard.selectedSong = songName
  VaenylaeBard.selectedLine = nil
  VaenylaeBard.SongScrollBar_Update()
  
  -- Update status text
  local songData = VaenylaeBardSongs[songName]
  local lineCount = songData and table.getn(songData) or 0
  VaenylaeBardMainFrame_StatusText:SetText("Selected: " .. songName .. " (" .. lineCount .. " lines)")
end

function VaenylaeBard.ShowAddSongDialog()
  VaenylaeBardAddSongDialog:Show()
  VaenylaeBardAddSongDialog_EditBox:SetFocus()
end

function VaenylaeBard.AddNewSong()
  local songName = VaenylaeBardAddSongDialog_EditBox:GetText()
  if not songName or songName == "" then
    VaenylaeBard.log("Please enter a song name.")
    return
  end
  
  if VaenylaeBardSongs[songName] then
    VaenylaeBard.log("A song with that name already exists.")
    return
  end
  
  VaenylaeBardSongs[songName] = {}
  VaenylaeBardAddSongDialog_EditBox:SetText("")
  VaenylaeBardAddSongDialog:Hide()
  VaenylaeBard.UpdateSongList()
  VaenylaeBard.log("Added song: " .. songName)
end

function VaenylaeBard.RemoveSelectedSong()
  if not VaenylaeBard.selectedSong then
    VaenylaeBard.log("No song selected.")
    return
  end
  
  VaenylaeBardSongs[VaenylaeBard.selectedSong] = nil
  VaenylaeBard.log("Removed song: " .. VaenylaeBard.selectedSong)
  VaenylaeBard.selectedSong = nil
  VaenylaeBard.selectedLine = nil
  VaenylaeBard.UpdateSongList()
  VaenylaeBardMainFrame_StatusText:SetText("Select a song from the list above")
end

function VaenylaeBard.UpdateSongList()
  VaenylaeBard.SongScrollBar_Update()
end

function VaenylaeBard.OpenLineEditor()
  if not VaenylaeBard.selectedSong then
    VaenylaeBard.log("Please select a song first.")
    return
  end
  
  VaenylaeBardLineEditorFrame:Show()
  VaenylaeBardLineEditorFrame_Title:SetText("Editing: " .. VaenylaeBard.selectedSong)
  VaenylaeBard.LineScrollBar_Update()
end

function VaenylaeBard.PlaySelectedSong()
  if not VaenylaeBard.selectedSong then
    VaenylaeBard.log("Please select a song first.")
    return
  end
  
  local song = VaenylaeBardSongs[VaenylaeBard.selectedSong]
  if not song or table.getn(song) == 0 then
    VaenylaeBard.log("Song is empty.")
    return
  end
  
  VaenylaeBard.log("Playing song: " .. VaenylaeBard.selectedSong)
  VaenylaeBard.PlaySongLines(song, 1)
end

-----
-- Line Management Functions
-----
function VaenylaeBard.SelectLine(lineIndex)
  VaenylaeBard.selectedLine = lineIndex
  VaenylaeBard.LineScrollBar_Update()
  VaenylaeBard.LoadLineIntoEditor(lineIndex)
end

function VaenylaeBard.LoadLineIntoEditor(lineIndex)
  if not VaenylaeBard.selectedSong or not lineIndex then
    return
  end
  
  local song = VaenylaeBardSongs[VaenylaeBard.selectedSong]
  if not song or not song[lineIndex] then
    VaenylaeBard.ClearEditFields()
    return
  end
  
  local line = song[lineIndex]
  VaenylaeBardLineEditorFrame_EditSection_LineTextScrollBox_LineTextInput:SetText(line.text or "")
  VaenylaeBardLineEditorFrame_EditSection_EmoteInput:SetText(line.emote or "")
  VaenylaeBardLineEditorFrame_EditSection_DelayInput:SetText(tostring(line.delay or 3))
end

function VaenylaeBard.AddNewLine()
  if not VaenylaeBard.selectedSong then
    return
  end
  
  local song = VaenylaeBardSongs[VaenylaeBard.selectedSong]
  table.insert(song, {
    text = "",
    emote = "",
    delay = 3
  })
  
  VaenylaeBard.LineScrollBar_Update()
  VaenylaeBard.log("Added new line to " .. VaenylaeBard.selectedSong)
end

function VaenylaeBard.SaveCurrentLine()
  if not VaenylaeBard.selectedSong or not VaenylaeBard.selectedLine then
    VaenylaeBard.log("Please select a line first.")
    return
  end
  
  local song = VaenylaeBardSongs[VaenylaeBard.selectedSong]
  if not song[VaenylaeBard.selectedLine] then
    VaenylaeBard.log("Invalid line selected.")
    return
  end
  
  local lineText = VaenylaeBardLineEditorFrame_EditSection_LineTextScrollBox_LineTextInput:GetText()
  local emote = VaenylaeBardLineEditorFrame_EditSection_EmoteInput:GetText()
  local delayText = VaenylaeBardLineEditorFrame_EditSection_DelayInput:GetText()
  local delay = tonumber(delayText) or 3
  
  song[VaenylaeBard.selectedLine] = {
    text = lineText,
    emote = emote,
    delay = delay
  }
  
  VaenylaeBard.LineScrollBar_Update()
  VaenylaeBard.log("Line saved.")
end

function VaenylaeBard.ClearEditFields()
  VaenylaeBardLineEditorFrame_EditSection_LineTextScrollBox_LineTextInput:SetText("")
  VaenylaeBardLineEditorFrame_EditSection_EmoteInput:SetText("")
  VaenylaeBardLineEditorFrame_EditSection_DelayInput:SetText("3")
end

function VaenylaeBard.MoveLineUp()
  if not VaenylaeBard.selectedSong or not VaenylaeBard.selectedLine or VaenylaeBard.selectedLine <= 1 then
    return
  end
  
  local song = VaenylaeBardSongs[VaenylaeBard.selectedSong]
  local temp = song[VaenylaeBard.selectedLine]
  song[VaenylaeBard.selectedLine] = song[VaenylaeBard.selectedLine - 1]
  song[VaenylaeBard.selectedLine - 1] = temp
  
  VaenylaeBard.selectedLine = VaenylaeBard.selectedLine - 1
  VaenylaeBard.LineScrollBar_Update()
  VaenylaeBard.LoadLineIntoEditor(VaenylaeBard.selectedLine)
end

function VaenylaeBard.MoveLineDown()
  if not VaenylaeBard.selectedSong or not VaenylaeBard.selectedLine then
    return
  end
  
  local song = VaenylaeBardSongs[VaenylaeBard.selectedSong]
  if VaenylaeBard.selectedLine >= table.getn(song) then
    return
  end
  
  local temp = song[VaenylaeBard.selectedLine]
  song[VaenylaeBard.selectedLine] = song[VaenylaeBard.selectedLine + 1]
  song[VaenylaeBard.selectedLine + 1] = temp
  
  VaenylaeBard.selectedLine = VaenylaeBard.selectedLine + 1
  VaenylaeBard.LineScrollBar_Update()
  VaenylaeBard.LoadLineIntoEditor(VaenylaeBard.selectedLine)
end

function VaenylaeBard.DeleteSelectedLine()
  if not VaenylaeBard.selectedSong or not VaenylaeBard.selectedLine then
    return
  end
  
  local song = VaenylaeBardSongs[VaenylaeBard.selectedSong]
  table.remove(song, VaenylaeBard.selectedLine)
  
  VaenylaeBard.selectedLine = nil
  VaenylaeBard.LineScrollBar_Update()
  VaenylaeBard.ClearEditFields()
  VaenylaeBard.log("Line deleted.")
end

function VaenylaeBard.PreviewSelectedLine()
  if not VaenylaeBard.selectedSong or not VaenylaeBard.selectedLine then
    return
  end
  
  local song = VaenylaeBardSongs[VaenylaeBard.selectedSong]
  local line = song[VaenylaeBard.selectedLine]
  if not line then
    return
  end
  
  if line.text and line.text ~= "" then
    SendChatMessage(line.text, "SAY")
  end
  
  if line.emote and line.emote ~= "" then
    DoEmote(line.emote)
  end
  
  VaenylaeBard.log("Previewed line " .. VaenylaeBard.selectedLine)
end

-----
-- Song Playback (following your existing pattern)
-----
function VaenylaeBard.PlaySongLines(song, lineIndex)
  if VaenylaeBard.isPlaying then
    VaenylaeBard.log("A song is already playing. Please wait.")
    return
  end
  
  if lineIndex > table.getn(song) then
    VaenylaeBard.log("Song finished.")
    VaenylaeBard.isPlaying = nil
    return
  end
  
  VaenylaeBard.isPlaying = true
  local line = song[lineIndex]
  if not line then
    VaenylaeBard.isPlaying = nil
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
  
  -- Schedule next line (following your existing timer pattern)
  local delay = line.delay or 3
  local timer = CreateFrame("Frame")
  local timeElapsed = 0
  timer:SetScript("OnUpdate", function()
    timeElapsed = timeElapsed + arg1
    if timeElapsed >= delay then
      timer:SetScript("OnUpdate", nil)
      VaenylaeBard.isPlaying = nil
      VaenylaeBard.PlaySongLines(song, lineIndex + 1)
    end
  end)
end

VaenylaeBard.log("|cff00ffff[Vaenylae Bard]|r Addon loaded successfully!")