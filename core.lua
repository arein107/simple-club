local clubName = 42
local clubIdStr = 44


--Windows and stuff

borderFrame = CreateFrame("Frame", nil, UIParent, "PortraitFrameTemplate")
borderFrame:SetPoint("CENTER",UIParent)
borderFrame:SetSize(1000, 400)
borderFrame:EnableMouse(true)
borderFrame:SetMovable(true)
borderFrame:RegisterForDrag("LeftButton")--   Register left button for dragging1
borderFrame:SetScript("OnDragStart",borderFrame.StartMoving)--  Set script for drag start
borderFrame:SetScript("OnDragStop",borderFrame.StopMovingOrSizing)--    Set script for drag stop

borderFrameTitleFrame = CreateFrame("Frame", nil, borderFrame, "AnimatedShineTemplate")
borderFrameTitleFrame:SetPoint("TOP", borderFrame, "TOP",0,0)
borderFrameTitleFrame:SetSize(400, 20)

borderFrameTitleFrameText = borderFrameTitleFrame:CreateFontString("borderFrameTitleFrameText", "OVERLAY", "GameFontNormal")
borderFrameTitleFrameText:SetPoint("CENTER", borderFrameTitleFrame, "TOP", 0,-10)
borderFrameTitleFrameText:SetText("Simple Club Tool")

---the image that goes in the upper-left corner of the frame
portraitIcon = borderFrame:CreateTexture(nil, "OVERLAY")
portraitIcon:SetHeight(60)
portraitIcon:SetWidth(60)
portraitIcon:SetPoint("TOPLEFT",-5, 5)
SetPortraitToTexture(portraitIcon, "Interface\\ICONS\\UI_HordeIcon-round")

scrollFrame = CreateFrame("ScrollFrame", nil, borderFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(300,370)
scrollFrame:SetPoint("RIGHT", borderFrame, "RIGHT", -25, -10)


--roster column
rosterTitleFrame = CreateFrame("Frame", nil, borderFrame, "AnimatedShineTemplate")
rosterTitleFrame:SetPoint("RIGHT", borderFrame, "TOPRIGHT", -60, -45)
rosterTitleFrame:SetSize(400,40)

rosterFrame = CreateFrame("Editbox", nil, scrollFrame, "AnimatedShineTemplate")
rosterFrame:SetPoint("RIGHT", scrollFrame, "RIGHT",0, 0)
rosterFrame:SetSize(300, 300)
rosterFrame:SetFontObject(Number18Font)
rosterFrame:EnableMouse(true)
rosterFrame:SetAutoFocus(false)
rosterFrame:SetTextInsets(5,5,5,5)
rosterFrame:SetMultiLine(true)

rosterFrame:SetText("\n" .."\n" .. "Your selected club's roster will output here. CTRL + C to export to Google Sheets, Excel, etc." .. "\n" .. "\n" .. "Does NOT work for Battle.net-only groups")
rosterFrame:HighlightText()
scrollFrame:SetScrollChild(rosterFrame)

rosterTitleFrameText = rosterTitleFrame:CreateFontString( "rosterTitleFrameText" , "OVERLAY" , "Fancy22Font" );
rosterTitleFrameText:SetPoint("CENTER", rosterTitleFrame, "TOP", -25, -10)
rosterTitleFrameText:SetText("Roster: ")


--general club info column
infoTitleFrame = CreateFrame("Frame", nil, borderFrame, "AnimatedShineTemplate")
infoTitleFrame:SetPoint("TOP", borderFrame, "TOP",-76 ,-25)
infoTitleFrame:SetSize(400, 40)

infoFrame = CreateFrame("Editbox", nil, borderFrame, "AnimatedShineTemplate")
infoFrame:SetPoint("TOP", borderFrame, "TOP",0, -45)
infoFrame:SetSize(300, 400)
infoFrame:SetFontObject(Number16Font)
infoFrame:EnableMouse(true)
infoFrame:SetAutoFocus(false)
infoFrame:SetTextInsets(5,5,5,5)
infoFrame:SetMultiLine(true)

infoFrameText = infoTitleFrame:CreateFontString("infoFrameText", "OVERLAY", "Fancy22Font");
infoFrameText:SetPoint("CENTER", infoTitleFrame, "TOP", 0,-10)
infoFrameText:SetText("Club Info: ")



--test column over infoFrame
textFrame = CreateFrame("Editbox", nil, borderFrame, "AnimatedShineTemplate")
textFrame:SetPoint("CENTER", borderFrame, "CENTER",0, 0)
textFrame:SetSize(300, 400)
textFrame:SetAutoFocus(false)
textFrame:SetMultiLine(true)

textFrameText = textFrame:CreateFontString("textFrameText", "OVERLAY", "AchievementPointsFont");
textFrameText:SetPoint("CENTER", textFrame, "LEFT", -40,77)
textFrameText:SetText(" Club: \n \n Members: \n \n Club ID: \n \n Club Type: \n \n Join Date: ")

dropDownList = CreateFrame("Frame", "DropDownList", borderFrame, "UIDropDownMenuTemplate");
dropDownList:SetPoint("TOPLEFT", borderFrame, "TOPLEFT",40,-20)
UIDropDownMenu_SetWidth(dropDownList,200)
UIDropDownMenu_SetText(dropDownList, "Club: ")
UIDropDownMenu_JustifyText(dropDownList, "LEFT")

------------------------------------------------------------------------------------------------------
---drop down menu functions

UIDropDownMenu_Initialize(dropDownList, function(frame, level, menuList) 

  local info = UIDropDownMenu_CreateInfo()
  local subscribedClubs = C_Club.GetSubscribedClubs()
  rosterString = ""

  info.func = dropDownList.SetValue


  for i, clubInfo in ipairs(subscribedClubs) do

----variables that make the club info readable
    clubNameStr = clubInfo.name
    joinTime = clubInfo.joinTime
    formatJoinTime = joinTime / 1000000
    notStupidTime = (date("!%m-%d-%Y at %H:%M:%SZ", formatJoinTime))
  
-----club type formatting

    clubTypeStr = clubInfo.clubType
    clubIdStr = clubInfo.clubId


    if clubTypeStr == 1 then
      clubTypeStr = "Character-based community"

    elseif clubTypeStr == 2 then
      clubTypeStr = "Guild"

    elseif clubTypeStr == 0 then
      clubTypeStr = "Battle.net Community"

    else 
      clubTypeStr = "Other"
    end
-----------

  rosterStr = ""
  for j, memberId in ipairs(C_Club.GetClubMembers((clubIdStr))) do
    memberInfo = C_Club.GetMemberInfo(clubIdStr, memberId)

    strName = tostring(memberInfo.name)

    if strName == "nil" then

      rosterStr = rosterStr 

    else

       rosterStr = rosterStr .."\n" ..  tostring(memberInfo.name)
     end
  end
---------the text that shows when the item is selected in the dropdown menu
    info.text = clubInfo.name
    info.arg1 =
    clubNameStr .. "\n" .. "\n" ..
    clubInfo.memberCount .. "\n" .. "\n" ..
    clubInfo.clubId .. "\n" .."\n" ..
    clubTypeStr .. "\n" .. "\n" ..
    notStupidTime .. "\n"
    checked = true
    info.arg2 = rosterStr
  
  UIDropDownMenu_AddButton(info)
  
  end

end)


-- Implement the function to change drop-down selection
function dropDownList:SetValue(newValue, rosterValue)

---converts the full club info into a long string to parse for the title
  strValue = tostring(newValue)

  lines = {}

  for s in strValue:gmatch("[^\n]+") do
    table.insert(lines,s)
  end

----actually sets the text on the columns
  borderFrameTitleFrameText:SetText(lines[1])
  infoFrame:SetText(newValue)
  rosterFrame:SetText(rosterValue)

  UIDropDownMenu_SetText(dropDownList,lines[1])

end

