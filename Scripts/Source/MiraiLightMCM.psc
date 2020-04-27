Scriptname MiraiLightMCM extends SKI_ConfigBase

import po3_SKSEFunctions
import NetImmerse

MiraiLightMCM property mlmQuest auto
; Sorted by alphabet, the same way xEdit sorts them
int property mlmAttach auto
int property mlmColor auto
bool property mlmEnableNotification auto
bool property mlmEnableTrace auto
float property mlmFade auto
FormList property mlmFList auto
int property mlmKeyCode auto
Light property mlmLight auto
MagicEffect property mlmME auto
int property mlmPosX auto
int property mlmPosY auto
int property mlmPosZ auto
int property mlmRadius auto
Spell property mlmSpell auto
int property mlmType auto
Actor property PlayerRef auto
; Do Not Edit ^^^^^^^^^^^^^^^^^^^^^^^^^^

Bool FaceLightEsp
Spell FaceLightDark
Spell FaceLightBright
Int FaceLight
ColorForm LightColor

string[] LightType
string[] LightAttach
string[] LightPreset
int LightPresetIdx

bool bModEnable = true

event OnGameReload()
	parent.OnGameReload()		; Don't forget to call the parent!

	fStartup()
endEvent

function fStartup()
	if game.GetModbyName("FacelightPlus.esp") < 255
		FaceLightEsp = true
		FaceLightDark = game.GetFormFromFile(4815, "FaceLightPlus.esp") as spell
		FaceLightBright = game.GetFormFromFile(4816, "FaceLightPlus.esp") as spell
	elseIf game.GetModbyName("Facelight.esp") < 255
		FaceLightEsp = true
		FaceLightDark = game.GetFormFromFile(524194, "Facelight.esp") as spell
		FaceLightBright = game.GetFormFromFile(538000, "Facelight.esp") as spell
	endIf
	
	fUpdateKeyRegistration(mlmKeyCode)
	fResetLight()
endFunction

function fUpdateKeyRegistration(int keyCode)
	UnregisterForAllKeys()
	if keyCode != 0
		RegisterForKey(keyCode)
	endif
endFunction

function OnKeyDown(int keyCode)
	if !utility.IsInMenuMode() && !UI.IsMenuOpen("Console") && !UI.IsMenuOpen("Loading Menu") && keyCode == mlmKeyCode
		fToggleLight()
	endIf
endFunction

function fResetLight()
	if PlayerRef.HasSpell(mlmSpell)
		PlayerRef.RemoveSpell(mlmSpell)
		
		fToggleLight()
	endIf
endFunction

function fToggleLight()
	if PlayerRef.HasSpell(mlmSpell) == false
		if FaceLightEsp == true
			if PlayerRef.HasSpell(FaceLightDark as form) == true
				PlayerRef.RemoveSpell(FaceLightDark)
				FaceLight = 1
			elseIf PlayerRef.HasSpell(FaceLightBright as form) == true
				PlayerRef.RemoveSpell(FaceLightBright)
				FaceLight = 2
			endIf
		endIf
		
		fSetLight()
		fSetAttach()
		
		utility.wait(0.1)
		PlayerRef.AddSpell(mlmSpell, false)
		utility.wait(0.1)
		
		if Game.GetCameraState() == 0
			fSetLightPosFP(mlmPosX, mlmPosY, mlmPosZ)
		else
			fSetLightPos(mlmPosX, mlmPosY, mlmPosZ)
		endIf
	else
		PlayerRef.RemoveSpell(mlmSpell)
		
		if FaceLight == 1
			PlayerRef.AddSpell(FaceLightDark, false)
			FaceLight = 0
		elseIf FaceLight == 2
			PlayerRef.AddSpell(FaceLightBright, false)
			FaceLight = 0
		endIf
	endIf
endFunction

; depends on po3_SKSEFunctions
Function fSetLight()
	SetLightType(mlmLight, mlmType)
	
	LightColor = mlmFList.GetAt(0) as ColorForm
	LightColor.SetColor(mlmColor)

	SetLightColor(mlmLight, LightColor)
	SetLightRadius(mlmLight, mlmRadius)
	SetLightFade(mlmLight, mlmFade) 
EndFunction
; ----------------------------

; depends on nioverride
Function fSetAttach()
	if mlmAttach == 0
		mlmME.GetHitEffectArt().SetModelPath("Az\\MiraiLight\\LightEffect.nif")
	elseif mlmAttach == 1
		mlmME.GetHitEffectArt().SetModelPath("Az\\MiraiLight\\LightEffect_Pelvis.nif")
	elseif mlmAttach == 2
		mlmME.GetHitEffectArt().SetModelPath("Az\\MiraiLight\\LightEffect_Spine2.nif")
	elseif mlmAttach == 3
		mlmME.GetHitEffectArt().SetModelPath("Az\\MiraiLight\\LightEffect_Head.nif")
	elseif mlmAttach == 4
		mlmME.GetHitEffectArt().SetModelPath("Az\\MiraiLight\\LightEffect_MagicEffectsNode.nif")
	endIf
EndFunction

Function fSetLightPos (float X, float Y, float Z)
	SetNodeLocalPositionX(PlayerRef, "AttachLight", X, false)
	SetNodeLocalPositionY(PlayerRef, "AttachLight", Y, false)
	SetNodeLocalPositionZ(PlayerRef, "AttachLight", Z, false)
EndFunction

Function fSetLightPosFP (float X, float Y, float Z)
	SetNodeLocalPositionX(PlayerRef, "AttachLight", X, true)
	SetNodeLocalPositionY(PlayerRef, "AttachLight", Y, true)
	SetNodeLocalPositionZ(PlayerRef, "AttachLight", Z, true)
EndFunction
; ----------------------------

event OnConfigInit()
	LightType = new string[3]
	LightType[0] = "$_Omnidirectional"
	LightType[1] = "$_Shadow_Omnidirectional"
	LightType[2] = "$_Spotlight"
	
	LightAttach = new string[5]
	LightAttach[0] = "$_NPC"
	LightAttach[1] = "$_Pelvis"
	LightAttach[2] = "$_Spine2"
	LightAttach[3] = "$_Head"
	LightAttach[4] = "$_MagicEffects"	
	
	LightPreset = new string[9]
	LightPreset[0] = "$_Default_Light"
	LightPreset[1] = "$_Default_Shadow"
	LightPreset[2] = "$_Wide_Light"
	LightPreset[3] = "$_Wide_Shadow"
	LightPreset[4] = "$_MageLight"
	LightPreset[5] = "$_Torch"
	LightPreset[6] = "$_Torch_Shadow"
	LightPreset[7] = "$_FaceLight"
	LightPreset[8] = "$_FaceLight_Bright"

	Pages = new string[1]
	Pages[0] = "$_Main_"
endEvent

event OnPageReset(string a_page)
	if (a_page == "")
		LoadCustomContent("CustomLight/logo.dds", 258, 95)
		return
	else
		UnloadCustomContent()
	endIf

	if (a_page == "$_Main_")
		SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("$_Main_Settings")
		AddToggleOptionST("tModEnable", "$_ModEnable", bModEnable)
		AddKeyMapOptionST("kMapKey", "$_Toggle", mlmKeyCode, 0)
		AddMenuOptionST("mLightPreset", "$_LightPreset", LightPreset[LightPresetIdx])
		AddEmptyOption()
		
		SetCursorPosition(1)
		AddHeaderOption("$_Light_Settings")
		AddMenuOptionST("mLightType", "$_LightType", LightType[mlmType - 2])
		AddSliderOptionST("sLightRadius", "$_LightRadius", mlmRadius)
		AddSliderOptionST("sLightFade", "$_LightFade", mlmFade, "{1}")
		AddEmptyOption()
		
		SetCursorPosition(10)
		AddHeaderOption("$_Light_Pos_Settings")
		AddMenuOptionST("mLightAttach", "$_LightAttach", LightAttach[mlmAttach])
		AddSliderOptionST("sLightPosX", "$_LightPos_X", mlmPosX)
		AddSliderOptionST("sLightPosY", "$_LightPos_Y", mlmPosY)
		AddSliderOptionST("sLightPosZ", "$_LightPos_Z", mlmPosZ)
		AddEmptyOption()
		
		SetCursorPosition(11)
		AddHeaderOption("$_Light_Color_Settings")
		AddSliderOptionST("sLightColorRed", "$_LightColor_Red", ColorComponent.GetRed(mlmColor))
		AddSliderOptionST("sLightColorGreen", "$_LightColor_Green", ColorComponent.GetGreen(mlmColor))
		AddSliderOptionST("sLightColorBlue", "$_LightColor_Blue", ColorComponent.GetBlue(mlmColor))
		AddEmptyOption()
	endIf
endEvent

state tModEnable
	event OnSelectST()
		bModEnable = !bModEnable
		SetToggleOptionValueST(bModEnable)
	endEvent

	event OnDefaultST()
	endEvent

	event OnHighlightST()
		SetInfoText("$_ModEnable_Desc")
	endEvent
endState

state kMapKey
	event OnDefaultST()
		mlmKeyCode = 0
		SetKeyMapOptionValueST(211, false, "")
		fUpdateKeyRegistration(mlmKeyCode)
	endEvent

	event OnHighlightST()
		SetInfoText("$_Toggle_Desc")
	endEvent

	event OnKeyMapChangeST(int keyCode, string conflictControl, string conflictName)
		if keyCode == 1 || keyCode == 211
			mlmKeyCode = 0
			SetKeyMapOptionValueST(211, false, "")
			fUpdateKeyRegistration(mlmKeyCode)
		elseif conflictControl == ""
			mlmKeyCode = keyCode
			SetKeyMapOptionValueST(mlmKeyCode, false, "")
			fUpdateKeyRegistration(mlmKeyCode)
		elseif conflictName == ""
			bool choice = ShowMessage("Key is in conflict with '" + conflictControl + "'. Do you still want to use this key?", true, "Yes", "No")
			if choice
				mlmKeyCode = keyCode
				SetKeyMapOptionValueST(mlmKeyCode, false, "")
				fUpdateKeyRegistration(mlmKeyCode)
			endif
		else
			bool choice = ShowMessage("Key is in conflict with '" + conflictControl + "' from the mod, '" + conflictName + "'. Do you still want to use this key?", true, "Yes", "No")
			if choice
				mlmKeyCode = keyCode
				SetKeyMapOptionValueST(mlmKeyCode, false, "")
				fUpdateKeyRegistration(mlmKeyCode)
			endif
		endif
	endEvent
endState

state sLightPosX
	event OnSliderOpenST()
		SetSliderDialogStartValue(mlmPosX)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-1000, 1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		mlmPosX = value as Int
		SetSliderOptionValueST(mlmPosX)
	endEvent

	event OnDefaultST()
		mlmPosX = 0
		SetSliderOptionValueST(mlmPosX)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightPosX_Desc")
	endEvent
endState

state sLightPosY
	event OnSliderOpenST()
		SetSliderDialogStartValue(mlmPosY)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(-1000, 1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		mlmPosY = value as Int
		SetSliderOptionValueST(mlmPosY)
	endEvent

	event OnDefaultST()
		mlmPosY = 50
		SetSliderOptionValueST(mlmPosY)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightPosY_Desc")
	endEvent
endState

state sLightPosZ
	event OnSliderOpenST()
		SetSliderDialogStartValue(mlmPosZ)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(-1000, 1000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		mlmPosZ = value as Int
		SetSliderOptionValueST(mlmPosZ)
	endEvent

	event OnDefaultST()
		mlmPosZ = 100
		SetSliderOptionValueST(mlmPosZ)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightPosZ_Desc")
	endEvent
endState

state sLightColorRed
	event OnSliderOpenST()
		SetSliderDialogStartValue(ColorComponent.GetRed(mlmColor))
		SetSliderDialogDefaultValue(225)
		SetSliderDialogRange(0, 255)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		int iLightColorRed = value as int
		mlmColor = ColorComponent.SetRed(mlmColor, iLightColorRed)
		SetSliderOptionValueST(iLightColorRed)
	endEvent

	event OnDefaultST()
		mlmColor = ColorComponent.SetRed(mlmColor, 225)
		SetSliderOptionValueST(225)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightColor_Red_Desc")
	endEvent
endState

state sLightColorGreen
	event OnSliderOpenST()
		SetSliderDialogStartValue(ColorComponent.GetGreen(mlmColor))
		SetSliderDialogDefaultValue(225)
		SetSliderDialogRange(0, 255)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		int iLightColorGreen = value as int
		mlmColor = ColorComponent.SetGreen(mlmColor, iLightColorGreen)
		SetSliderOptionValueST(iLightColorGreen)
	endEvent

	event OnDefaultST()
		mlmColor = ColorComponent.SetGreen(mlmColor, 225)
		SetSliderOptionValueST(225)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightColor_Green_Desc")
	endEvent
endState

state sLightColorBlue
	event OnSliderOpenST()
		SetSliderDialogStartValue(ColorComponent.GetBlue(mlmColor))
		SetSliderDialogDefaultValue(225)
		SetSliderDialogRange(0, 255)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		int iLightColorBlue = value as int
		mlmColor = ColorComponent.SetBlue(mlmColor, iLightColorBlue)
		SetSliderOptionValueST(iLightColorBlue)
	endEvent

	event OnDefaultST()
		mlmColor = ColorComponent.SetBlue(mlmColor, 225)
		SetSliderOptionValueST(225)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightColor_Blue_Desc")
	endEvent
endState

state sLightFade
	event OnSliderOpenST()
		SetSliderDialogStartValue(mlmFade)
		SetSliderDialogDefaultValue(1.7)
		SetSliderDialogRange(0.1, 10.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float value)
		mlmFade = value
		SetSliderOptionValueST(mlmFade, "{1}")
	endEvent

	event OnDefaultST()
		mlmFade = 1.7
		SetSliderOptionValueST(mlmFade, "{1}")
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightFade_Desc")
	endEvent
endState

state sLightRadius
	event OnSliderOpenST()
		SetSliderDialogStartValue(mlmRadius)
		SetSliderDialogDefaultValue(750)
		SetSliderDialogRange(20, 5000)
		SetSliderDialogInterval(10)
	endEvent

	event OnSliderAcceptST(float value)
		mlmRadius = value as Int
		SetSliderOptionValueST(mlmRadius)
	endEvent

	event OnDefaultST()
		mlmRadius = 750
		SetSliderOptionValueST(mlmRadius)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightRadius_Desc")
	endEvent
endState

state mLightType
	event OnMenuOpenST()
		SetMenuDialogStartIndex(mlmType - 2)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(LightType)
	endEvent

	event OnMenuAcceptST(int index)
		mlmType = index + 2
		SetMenuOptionValueST(LightType[index])
	endEvent

	event OnDefaultST()
		mlmType = 2
		SetMenuOptionValueST(0)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightType_Desc")
	endEvent
endState

state mLightAttach
	event OnMenuOpenST()
		SetMenuDialogStartIndex(mlmAttach)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(LightAttach)
	endEvent

	event OnMenuAcceptST(int index)
		mlmAttach = index
		SetMenuOptionValueST(LightAttach[mlmAttach])
	endEvent

	event OnDefaultST()
		mlmAttach = 0
		SetMenuOptionValueST(LightAttach[mlmAttach])
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightAttach_Desc")
	endEvent
endState

state mLightPreset
	event OnMenuOpenST()
		SetMenuDialogStartIndex(LightPresetIdx)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(LightPreset)
	endEvent

	event OnMenuAcceptST(int index)
		LightPresetIdx = index
		SetMenuOptionValueST(LightPreset[LightPresetIdx])

		if	LightPresetIdx == 0	;Default       
			fLightPreset(0, 0, 750, 1.7, 100, 50, 0, 225, 225, 225)
		elseif LightPresetIdx == 1 ;Default_Shadow
			fLightPreset(1, 0, 750, 1.7, 100, 50, 0, 225, 225, 225)
		elseif LightPresetIdx == 2 ;Wide
			fLightPreset(0, 0, 1500, 1.5, 100, 50, 0, 225, 225, 225)
		elseif LightPresetIdx == 3 ;Wide_Shadow
			fLightPreset(1, 0, 1500, 1.5, 100, 50, 0, 225, 225, 225)
		elseif LightPresetIdx == 4 ;MageLight
			fLightPreset(0, 4, 450, 2.5, 120, 0, 0, 129, 175, 226)
		elseif LightPresetIdx == 5 ;Torch
			fLightPreset(0, 2, 512, 1.3, 40, 40, -40, 250, 190, 131)	
		elseif LightPresetIdx == 6 ;Torch Shadow
			fLightPreset(1, 2, 512, 1.3, 40, 40, -40, 248, 170, 92)	
		elseif LightPresetIdx == 7 ;FaceLight
			fLightPreset(0, 3, 45, 0.5, 0, 20, 0, 254, 230, 155)	
		elseif LightPresetIdx == 8 ;FaceLightBright
			fLightPreset(0, 3, 80, 1.0, 0, 20, 0, 254, 230, 155)
		endIf
	endEvent

	event OnDefaultST()
		LightPresetIdx = 0
		SetMenuOptionValueST(LightPreset[LightPresetIdx])
		fLightPreset(0, 0, 750, 1.7, 100, 50, 0, 225, 225, 225)
	endEvent

	event OnHighlightST()
		SetInfoText("$_LightPreset_Desc")
	endEvent
endState

event OnConfigClose()
	utility.wait(0.1)
	
	if bModEnable == false
		log("$_StoppingQuest")
		utility.wait(2.0)
		PlayerRef.RemoveSpell(mlmSpell)
		mlmQuest.Stop()
		log("$_QuestStopped")
	endif

	fResetLight()
endEvent

Function fLightPreset(int akType, int akAttach, int akRadius, float akFade, int akPosZ, int akPosY, int akPosX, int akRed, int akGreen, int akBlue)
	mlmType = akType + 2
	SetMenuOptionValueST(LightType[akType])	

	mlmAttach = akAttach
	SetMenuOptionValueST(LightAttach[mlmAttach])		

	mlmRadius = akRadius
	SetSliderOptionValueST(mlmRadius)

	mlmFade = akFade
	SetSliderOptionValueST(mlmFade, "{1}")

	mlmPosX = akPosX
	SetSliderOptionValueST(mlmPosX)
	
	mlmPosY = akPosY
	SetSliderOptionValueST(mlmPosY)

	mlmPosZ = akPosZ
	SetSliderOptionValueST(mlmPosZ)

	ColorComponent.SetRed(mlmColor, akRed)
	SetSliderOptionValueST(akRed)
	
	ColorComponent.SetGreen(mlmColor, akGreen)
	SetSliderOptionValueST(akGreen)
	
	ColorComponent.SetBlue(mlmColor, akBlue)
	SetSliderOptionValueST(akBlue)
	
	ForcePageReset()
EndFunction

function log(string msg, string type = "MESSAGE")
	if mlmEnableTrace
		Debug.Trace("MiraiLight " + type + ": " + msg)
	endif
	if mlmEnableNotification
		Debug.Notification("MiraiLight :" + msg)
	endif
endFunction