;╔═════════════════════════════════════════════════════════════════════════════════════════════════
;║     command-panel-data.pbi                                                                           
;╠═════════════════════════════════════════════════════════════════════════════════════════════════
;║     Created: 02-09-2025 
;║
;║     Copyright (c) 2025 James Dooley <james@dooley.ch>
;║
;║     History:
;║     02-09-2025: Initial version
;╚═════════════════════════════════════════════════════════════════════════════════════════════════

DeclareModule CommandPanelData
  
  ; Defines the call back function to handle a user
  ; clicking on a CommandPanel item
  Prototype OnCommandItemClick(index.i)
  
  ; Flags to indicate the CommandPanel border requirements
  EnumerationBinary BorderSides
    #CP_LeftBorder
    #CP_RightBorder
    #CP_TopBorder
    #CP_BottomBorder
  EndEnumeration
  
  ; Indicates the state of an item 
  Enumeration ItemState
    #CP_NormalItem
    #CP_SelectedItem
    #CP_HoverItem
    #CP_DisabledItem
    #CP_DeletedItem
  EndEnumeration
  
  ; Holds the information needed to handle the
  ; drawing of the CommandPanel borders
  Structure cpBorders
    Sides.b
    Colour.i
    Width.i
  EndStructure
  
  ; Holds the information needed to create the
  ; CommandPanel instance
  Structure cpConfiguration
    BackColour.i
    Borders.cpBorders
    Width.i
    Selected.i
    IsToggle.b
  EndStructure
  
  ; Structure used internally to store the CommandPanel
  ; instance
  Structure cpConfigurationEx Extends cpConfiguration
    Index.i
    GadgetNO.i
  EndStructure
  
  ; Holds the colours to be used for items in diifferent
  ; states
  Structure cpColours
    Normal.i
    Disabled.i
    Hover.i
    Selected.i
  EndStructure
  
  ; Holds details of the font to be used to paint the captions
  ; on the CommandPanel items
  Structure cpFont
    Name$
    Size.i
    Colours.cpColours
  EndStructure
  
  ; Holds the PB numbers for the images used by the CommandPanel
  Structure cpImages
    Normal.i
    Disabled.i
    Hover.i
    Selected.i
  EndStructure
  
  ; Holds the information needed to create a CommandPanel item
  Structure cpItemConfiguration
    Caption$
    Font.cpFont
    Icons.cpImages
    Colours.cpColours
    Border.b
    BorderColour.i
    CallBackFunc.OnCommandItemClick
    PanelIndex.i
  EndStructure
  
  ; The structure used to store the item information
  ; internally
  Structure cpItemConfigurationEx Extends cpItemConfiguration
    Index.i
    GadgetNO.i
    Images.cpImages
    State.i
  EndStructure
  
  Declare.i AddCmdPanelRecord(*cfg.cpConfiguration)                                     ; Adds an entry to the panels collection
  Declare.b FindCmdPanelRecord(index.i, *cfg.cpConfigurationEx)                         ; Locates a panel entry based on the given index
  Declare.i CommandPanelNO(index.i)                                                     ; Returns the PB number for a given CommandPanel
  Declare.b SetCommandPanelNO(index.i, panelNO.i)                                       ; Sets the CommandPanel PB number 
  Declare.b SetCommandPanelSelected(index.i, itemIndex.i)                               ; Sets the selected item for the panel
  Declare.i GetCommandPanelSelected(index.i)                                            ; Get the selected item for the panel
  Declare InitCommandPanelConfig(*cfg.cpConfiguration)                                  ; Initialize the structure
  
  Declare.i AddCmdPanelItemRecord(*cfg.cpItemConfiguration)                             ; Adds an entry to the items collection
  Declare.b FindCmdPanelItemRecord(index.i, *cfg.cpItemConfigurationEx)                 ; Locates an item entry based on the given index
  Declare.b SetCmdPanelItemState(index.i, state.b)                                      ; Sets the item state
  Declare.b SetCmdPanelItemNO(index.i, indexNO.i)                                       ; Sets the item PB number
  Declare.b SetCmpPanelItemImages(index.i, normal.i, selected.i, disabled.i, hover.i)   ; Sets the item images
  Declare FindCmdPanelItemsByCmd(panelIndex.i, List items.cpItemConfigurationEx())      ; Retursn a list of items for the given CommandPanel
  Declare.b FindCmdPanelItemRecord(index.i, *cfg.cpItemConfigurationEx)                 ; Locates the item in the collection
  Declare.b DeleteCmdPanelItem(index.i)                                                 ; Delete an item from the collection
  Declare.b SetCmdPanelItemNO(index.i, itemNO.i)                                        ; Sets the CommandPanel item PB number 
  Declare InitCmdPanelItemConfig(*cfg.cpItemConfiguration)                              ; Initializes the structure
  
EndDeclareModule

Module CommandPanelData
  EnableExplicit
  
  ;────────────────────────────────────────────────────────────────────────────────────────────────
  ;      Variables 
  Define _nextPanelIndex.i = 10000
  Define NewList _cpPanels.cpConfigurationEx()
  Define _nextItemIndex.i = 100
  Define NewList _cpItems.cpItemConfigurationEx()
  
  ;┌───────────────────────────────────────────────────────────────────────────────────────────────
  ;│     Public     
  ;└───────────────────────────────────────────────────────────────────────────────────────────────
  
  ; Adds an entry to the panels collection
  ;
  ; Params
  ;   *cfg - The new record to add
  ;
  ; Return
  ;   Returns the new index number for the record
  ;
  Procedure.i AddCmdPanelRecord(*cfg.cpConfiguration)
    Shared _nextPanelIndex, _cpPanels()
    Protected *new.cpConfiguration
    
    *new = AddElement(_cpPanels())
    
    _cpPanels()\BackColour = *cfg\BackColour
    _cpPanels()\Borders = *cfg\Borders
    _cpPanels()\GadgetNO = 0
    _cpPanels()\Index = _nextPanelIndex
    _cpPanels()\IsToggle = *cfg\IsToggle
    
    _nextPanelIndex = _nextPanelIndex + 1
    
    ProcedureReturn _cpPanels()\Index
  EndProcedure
  
  ; Locates a panel entry based on the given index
  ;
  ; Params
  ;   index - The index number of the required panel
  ;   *cfg - The record to populate
  ;
  ; Return
  ;   Returns True if found, otherwise False
  ;
  Procedure.b FindCmdPanelRecord(index.i, *cfg.cpConfigurationEx)
    Shared _cpPanels()
    Protected *panel.cpConfigurationEx
    
    ResetList(_cpPanels())
    *panel = FirstElement(_cpPanels())
    
    While *panel
      If *panel\Index = index
        CopyStructure(*panel, *cfg, cpConfigurationEx)
        ProcedureReturn #True
      EndIf
      
      *panel = NextElement(_cpPanels())
    Wend
    
    ProcedureReturn #False
  EndProcedure
  
  ; Returns the PB number for a given CommandPanel
  ;
  ; Params
  ;   index - The index of the required panel number
  ;
  Procedure.i CommandPanelNO(index.i)                             
    Protected cfg.cpConfigurationEx
    
    If FindCmdPanelRecord(index, @cfg)
      ProcedureReturn cfg\GadgetNO
    EndIf
    
    ProcedureReturn 0
  EndProcedure
  
  ; Sets the CommandPanel PB number
  ;
  ; Params
  ;   index - The index of the panel to set the PB number for
  ;   panelNO - The PB number to set
  ;   
  ; Return
  ;   True fi successful, otherwise False
  ;
  Procedure.b SetCommandPanelNO(index.i, panelNO.i) 
    Shared _cpPanels()
    
    ResetList(_cpPanels())
    ForEach _cpPanels()
      If _cpPanels()\Index = index
        _cpPanels()\GadgetNO = panelNO
        ProcedureReturn #True
      EndIf
    Next 
    
    ProcedureReturn #False
  EndProcedure
  
  ; Sets the selected item for the panel
  ;
  ; Params
  ;   index - Panel index
  ;   itemIndex - The selected item
  ;
  ; Return
  ;   True if selected, otherwise False
  ;
  Procedure.b SetCommandPanelSelected(index.i, itemIndex.i)   
    Shared _cpPanels()
    
    ResetList(_cpPanels())
    ForEach _cpPanels()
      If _cpPanels()\Index = index
        _cpPanels()\Selected = itemIndex
       
        ProcedureReturn #True
      EndIf
    Next
    
    ProcedureReturn #False
  EndProcedure
  
  ; Get the selected item for the panel
  ;
  ; Params
  ;   index - The panel index
  ;
  ; Return
  ;   The item index if any 
  ;
  Procedure.i GetCommandPanelSelected(index.i)                    
    Shared _cpPanels()
    
    ResetList(_cpPanels())
    ForEach _cpPanels()
      If _cpPanels()\Index = index
        ProcedureReturn _cpPanels()\Selected
      EndIf
    Next
    
    ProcedureReturn #False
  EndProcedure
  
  ; Initialize the structure
  ;
  ; Params
  ;   *cfg - The structure to initialize
  ;
  Procedure InitCommandPanelConfig(*cfg.cpConfiguration)         
    *cfg\BackColour = $AC9A64
    *cfg\Borders\Sides = #CP_RightBorder
    *cfg\Borders\Colour = $C6C6C6
    *cfg\Borders\Width = 2
    *cfg\Width = 200
    *cfg\IsToggle = #False
  EndProcedure
  
  ; Adds an entry to the items collection
  ;
  ; Params
  ;   *cfg - The new record to add
  ;
  ; Return
  ;   Returns the new index number for the record
  ;  
  Procedure.i AddCmdPanelItemRecord(*cfg.cpItemConfiguration)
    Shared _cpItems(), _nextItemIndex
    
    AddElement(_cpItems())
    _cpItems()\Index = _nextItemIndex
    _cpItems()\Caption$ = *cfg\Caption$
    
    _cpItems()\Font\Name$ = *cfg\Font\Name$
    _cpItems()\Font\Size = *cfg\Font\Size
    _cpItems()\Font\Colours\Normal = *cfg\Font\Colours\Normal
    _cpItems()\Font\Colours\Selected = *cfg\Font\Colours\Selected
    _cpItems()\Font\Colours\Disabled = *cfg\Font\Colours\Disabled
    _cpItems()\Font\Colours\Hover = *cfg\Font\Colours\Hover
    
    _cpItems()\Border = *cfg\Border
    _cpItems()\BorderColour = *cfg\BorderColour
    
    _cpItems()\Colours\Normal = *cfg\Colours\Normal
    _cpItems()\Colours\Selected = *cfg\Colours\Selected
    _cpItems()\Colours\Disabled = *cfg\Colours\Disabled
    _cpItems()\Colours\Hover = *cfg\Colours\Hover
    
    _cpItems()\Icons\Normal = *cfg\Icons\Normal
    _cpItems()\Icons\Selected = *cfg\Icons\Selected
    _cpItems()\Icons\Disabled = *cfg\Icons\Disabled
    _cpItems()\Icons\Hover = *cfg\Icons\Hover
    
    _cpItems()\PanelIndex = *cfg\PanelIndex
    _cpItems()\CallBackFunc = *cfg\CallBackFunc
    
    _nextItemIndex = _nextItemIndex + 1
    
    ProcedureReturn _cpItems()\Index
  EndProcedure
  
  ; Locates an item entry based on the given index
  ;
  ; Params
  ;   index - The index number of the required panel
  ;   *cfg - The record to populate
  ;
  ; Return
  ;   Returns True if found, otherwise False
  ;  
  Procedure.b FindCmdPanelItemRecord(index.i, *cfg.cpItemConfigurationEx)   
    Shared _cpItems()
    Protected *item.cpItemConfigurationEx
    
    ResetList(_cpItems())
    *item = FirstElement(_cpItems())
    
    While *item
      If *item\Index = index
        CopyStructure(*item, *cfg, cpItemConfigurationEx)
        ProcedureReturn #True
      EndIf
      
      *item = NextElement(_cpItems())
    Wend
    
    ProcedureReturn #False
  EndProcedure
  
  ; Sets the item state
  ;
  ; Params
  ;   index - The index for the itme to set
  ;   state - The new state
  ;
  ; Return
  ;   Returns True if successful, otherwise false
  ;
  Procedure.b SetCmdPanelItemState(index.i, state.b)   
    Shared _cpItems()
    
    ResetList(_cpItems())
    ForEach _cpItems()
      If _cpItems()\Index = index
        _cpItems()\State = state
        ProcedureReturn #True
      EndIf
    Next
    
    ProcedureReturn #False
  EndProcedure
  
  ; Sets the item state
  ;
  ; Params
  ;   index - The index for the itme to set
  ;   indexNO - The PB number to set
  ;
  ; Return
  ;   Returns True if successful, otherwise false
  ;  
  Procedure.b SetCmdPanelItemNO(index.i, indexNO.i)                         
    Shared _cpItems()
    
    ResetList(_cpItems())
    ForEach _cpItems()
      If _cpItems()\Index = index
        _cpItems()\GadgetNO = indexNO
        ProcedureReturn #True
      EndIf
    Next
    
    ProcedureReturn #False
  EndProcedure
  
  ; Sets the item images
  ;
  ; Params
  ;   index - The index for the itme to set
  ;   normal - The item image
  ;   selected - The item image
  ;   disabled - The item image
  ;   hover - The item image
  ;
  ; Return
  ;   Returns True if successful, otherwise false
  ;
  Procedure.b SetCmpPanelItemImages(index.i, normal.i, selected.i, disabled.i, hover.i)   
    Shared _cpItems()
    
    ResetList(_cpItems())
    ForEach _cpItems()
      If _cpItems()\Index = index
        If normal <> #PB_Ignore
          _cpItems()\Images\Normal = normal
        EndIf
        
        If selected <> #PB_Ignore
          _cpItems()\Images\Selected = selected
        EndIf
        
        If disabled <> #PB_Ignore
          _cpItems()\Images\Disabled = disabled
        EndIf
        
        If hover <> #PB_Ignore
          _cpItems()\Images\Hover = hover
        EndIf
        
        ProcedureReturn #True
      EndIf
    Next
    
    ProcedureReturn #False
  EndProcedure
  
  ; Delete an item from the collection
  ;
  ; Params
  ;   index - The index of the item to delete
  ;
  ; Return
  ;   Returns True if successful, otherwise False
  ;
  Procedure.b DeleteCmdPanelItem(index.i)
    Shared _cpItems()
    
    ResetList(_cpItems())
    ForEach _cpItems()
      If _cpItems()\Index = index
        DeleteElement(_cpItems())
        ProcedureReturn #True
      EndIf
    Next
    
    ProcedureReturn #False
  EndProcedure
  
  ; Retursn a list of items for the given CommandPanel
  ;
  ; Params
  ;   panelIndex - The index of the owning CommandPanel
  ;   items() - The list to populate with the items for a given panel
  ;
  Procedure FindCmdPanelItemsByCmd(panelIndex.i, List items.cpItemConfigurationEx())  
    Shared _cpItems()
    
    ClearList(items())
    ResetList(_cpItems())
    
    ForEach _cpItems()
      If _cpItems()\PanelIndex = panelIndex
        AddElement(items())
        
        With items()
          \Caption$ = _cpItems()\Caption$
          \Font\Name$ = _cpItems()\Font\Name$
          \Font\Size = _cpItems()\Font\Size
          \Font\Colours\Normal = _cpItems()\Font\Colours\Normal
          \Font\Colours\Selected = _cpItems()\Font\Colours\Selected
          \Font\Colours\Disabled = _cpItems()\Font\Colours\Disabled
          \Font\Colours\Hover = _cpItems()\Font\Colours\Hover
          \Icons\Normal = _cpItems()\Icons\Normal
          \Icons\Selected = _cpItems()\Icons\Selected
          \Icons\Disabled = _cpItems()\Icons\Disabled
          \Icons\Hover = _cpItems()\Icons\Hover
          \Colours\Normal = _cpItems()\Colours\Normal
          \Colours\Selected = _cpItems()
          \Colours\Disabled = _cpItems()\Colours\Disabled
          \Colours\Hover = _cpItems()\Colours\Hover
          \Border = _cpItems()\Border
          \BorderColour = _cpItems()\BorderColour
          \CallBackFunc = _cpItems()\CallBackFunc
          \PanelIndex = _cpItems()\PanelIndex 
          \Index = _cpItems()\Index 
          \GadgetNO = _cpItems()\GadgetNO
          \Images\Normal = _cpItems()\Images\Normal
          \Images\Selected = _cpItems()\Images\Selected
          \Images\Disabled = _cpItems()\Images\Disabled
          \Images\Hover = _cpItems()\Images\Hover
          \State = _cpItems()\State
        EndWith
      EndIf
    Next
  EndProcedure
  
  ; Initializes the structure
  ;
  ; Params
  ;   *cfg - The structure to initialize
  ;
  Procedure InitCmdPanelItemConfig(*cfg.cpItemConfiguration) 
    With *cfg
      \Caption$ = #Null$
      \Font\Name$ = #Null$
      \Font\Size = 15
      \Font\Colours\Normal = $654847
      \Font\Colours\Selected = #Black
      \Font\Colours\Disabled = $9FA1A4
      \Font\Colours\Hover = #Black
      \Icons\Normal = #Null
      \Icons\Selected = #Null
      \Icons\Disabled = #Null
      \Icons\Hover = #Null
      \Colours\Normal = $EED9B6
      \Colours\Selected = $C6C6C6
      \Colours\Disabled = $E8E3DA
      \Colours\Hover = $31DDF6
      \Border = #False
      \BorderColour = #White
      \CallBackFunc = #Null
      \PanelIndex = 0      
    EndWith
  EndProcedure
  
EndModule
; IDE Options = PureBasic 6.21 - C Backend (MacOS X - arm64)
; ExecutableFormat = Console
; CursorPosition = 106
; FirstLine = 89
; Folding = ---
; EnableXP
; DPIAware