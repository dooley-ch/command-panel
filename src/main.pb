;╔═════════════════════════════════════════════════════════════════════════════════════════════════
;║     <File Name>                                                                           
;╠═════════════════════════════════════════════════════════════════════════════════════════════════
;║     Created: 00-00-2025 
;║
;║     Copyright (c) 2025 James Dooley <james@dooley.ch>
;║
;║     History:
;║     00-00-2025: Initial version
;╚═════════════════════════════════════════════════════════════════════════════════════════════════

;-------- Modules --------
XIncludeFile "command-panel-gadget.pbi"

EnableExplicit
  
Enumeration
  #DemoWindow
  #EnableTwoButton
  #DisableTwoButton
EndEnumeration

#APP_TITLE = "Demo Command Panel"

UseModule CommandPanelGadgetUI

UsePNGImageDecoder()

;-------- Variables -------

Define event.i, quit.b, leftCtrl.i, rightCtrl.i
Define.i itemOne, itemTwo, itemThree
Define cfg.CommandPanelData::cpConfiguration,
       cfgItem.CommandPanelData::cpItemConfiguration
Define image01.i = CatchImage(#PB_Any, ?Image_01),
       image02.i = CatchImage(#PB_Any, ?Image_02),
       image03.i = CatchImage(#PB_Any, ?Image_03)

;-------- Support Routines --------

Procedure _OnResizeWindow()
  Shared leftCtrl, rightCtrl
  Protected.i locX, locY, NO, wndHeight, wndWidth, panelWidth
  
  locX = 0
  locY = 0
  
  wndHeight = WindowHeight(#DemoWindow)
  wndWidth = WindowWidth(#DemoWindow)
  
  ; Position the CommandPanels
  NO = CommandPanelData::CommandPanelNO(leftCtrl)
  
  ResizeGadget(NO, locX, locY, #PB_Ignore, wndHeight)
  
  NO = CommandPanelData::CommandPanelNO(rightCtrl)
  panelWidth = GadgetWidth(NO)
  locX = wndWidth - panelWidth
  
  ResizeGadget(NO, locX, locY, #PB_Ignore, wndHeight)
  
  ; Position the left buttons
  locX = 200
  locY = 10
  
  ResizeGadget(#EnableTwoButton, locX, locY, #PB_Ignore, #PB_Ignore)
  
  locY = locY + 30
  
  ResizeGadget(#DisableTwoButton, locX, locY, #PB_Ignore, #PB_Ignore)
  
EndProcedure

Procedure _ItemClicked(index.i)
  MessageRequester(#APP_TITLE, "You clicked on item => " + Str(index), 
                   #PB_MessageRequester_Ok | #PB_MessageRequester_Info, 
                   #DemoWindow) 
EndProcedure

Procedure _OnEnableTwo()
  Shared itemTwo
  
  DisableGadget(#EnableTwoButton, #True)
  DisableGadget(#DisableTwoButton, #False)
  DisableCmpPanelItem(itemTwo, #False)
EndProcedure

Procedure _OnDisableTwo()
  Shared itemTwo
  
  DisableGadget(#DisableTwoButton, #True)
  DisableGadget(#EnableTwoButton, #False)
  DisableCmpPanelItem(itemTwo)
EndProcedure

;┌───────────────────────────────────────────────────────────────────────────────────────────────
;│     Main Loop     
;└───────────────────────────────────────────────────────────────────────────────────────────────

OpenWindow(#DemoWindow, #PB_Ignore, #PB_Ignore, 900, 600, #APP_TITLE,
                      #PB_Window_TitleBar | #PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_SizeGadget)

If IsWindow(#DemoWindow)
  SetWindowColor(#DemoWindow, $E8E3DA)
  
  CommandPanelData::InitCommandPanelConfig(@cfg)
  leftCtrl = CommandPanelGadget(@cfg)
  
  CommandPanelData::InitCommandPanelConfig(@cfg)
  cfg\Width = 250
  rightCtrl = CommandPanelGadget(@cfg)
  
  CommandPanelData::InitCmdPanelItemConfig(@cfgItem)
  cfgItem\PanelIndex = leftCtrl
  cfgItem\Icons\Normal = image01
  cfgItem\Icons\Hover = image01
  cfgItem\Icons\Disabled = image01
  cfgItem\Caption$ = "Item Number One"
  cfgItem\CallBackFunc = @_ItemClicked()
  
  itemOne = AddCmpPanelItem(@cfgItem)
  
  CommandPanelData::InitCmdPanelItemConfig(@cfgItem)
  cfgItem\PanelIndex = leftCtrl
  cfgItem\Icons\Normal = image02
  cfgItem\Icons\Hover = image02  
  cfgItem\Icons\Disabled = image02
  cfgItem\Border = #True
  cfgItem\BorderColour = #Black
  cfgItem\Caption$ = "Item Number Two"
  cfgItem\CallBackFunc = @_ItemClicked()
  
  itemTwo = AddCmpPanelItem(@cfgItem)
  
  CommandPanelData::InitCmdPanelItemConfig(@cfgItem)
  cfgItem\PanelIndex = leftCtrl
  cfgItem\Icons\Normal = image03
  cfgItem\Icons\Hover = image03  
  cfgItem\Icons\Disabled = image03
  cfgItem\Border = #True
  cfgItem\BorderColour = #Black
  cfgItem\Caption$ = "Item Number Three"
  cfgItem\CallBackFunc = @_ItemClicked()
  
  itemThree = AddCmpPanelItem(@cfgItem)
  
  ButtonGadget(#EnableTwoButton, 10, 10, 150, 25, "Enable Two")
  DisableGadget(#EnableTwoButton, #True)
  BindGadgetEvent(#EnableTwoButton, @_OnEnableTwo(), #PB_EventType_LeftClick)
  
  ButtonGadget(#DisableTwoButton, 10, 10, 150, 25, "Disable Two")
  BindGadgetEvent(#DisableTwoButton, @_OnDisableTwo(), #PB_EventType_LeftClick)
  
  _OnResizeWindow()
  
  quit = #False
  
  Repeat
    event = WaitWindowEvent()
    
    Select event
      Case #PB_Event_SizeWindow
        _OnResizeWindow()
      Case #PB_Event_CloseWindow
        quit = #True
    EndSelect
    
  Until quit
  
  CloseWindow(#DemoWindow)
EndIf  

DataSection
  Image_01:
  IncludeBinary #PB_Compiler_FilePath + "images/24_businessmen.png"
  Image_02:
  IncludeBinary #PB_Compiler_FilePath + "images/24_castle.png"
  Image_03:
  IncludeBinary #PB_Compiler_FilePath + "images/24_cd_gold.png"    
EndDataSection

;-------- Terminate --------
End
; IDE Options = PureBasic 6.21 - C Backend (MacOS X - arm64)
; ExecutableFormat = Console
; CursorPosition = 138
; FirstLine = 121
; Folding = -
; EnableXP
; DPIAware