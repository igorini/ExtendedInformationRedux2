 //-----------------------------------------------------------
//	Class:	ExtendedInformationRedux2_UITacticalHUD_ShotHUD
//	Author: Mr.Nice / Sebkulu
//	
//-----------------------------------------------------------

class ExtendedInformationRedux2_UITacticalHUD_ShotHUD extends UITacticalHUD_ShotHUD config(ShotHUD) dependson(ExtendedInformationRedux2_UITacticalHUD_ShotWings);

`include(ExtendedInformationRedux2\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)
`include(ExtendedInformationRedux2\Src\ExtendedInformationRedux2\LangFallBack.uci)

`define RANGESTRING(MIN, MAX)  ( `MIN == `MAX ? string(`MIN) : string(`MIN) $ "-" $ string(`MAX) )

var UIBGBox BarBoxes[5];
var UIText GrazeValue, GrazeLabel, CritDamValue, CritDamLabel;
var int BAR_HEIGHT, BAR_OFFSET_X, BAR_OFFSET_Y, BAR_POSITION_Y, BAR_WIDTH_MULT, GENERAL_OFFSET_Y;
var int DODGE_OFFSET_X, DODGE_OFFSET_Y, CRIT_OFFSET_X, CRIT_OFFSET_Y;
var int MAX_ABILITIES_PER_ROW;
var int LabelFontSize, ValueFontSize, TEXTWIDTH;
var int BAR_ALPHA;
var string BarColours[5];
var int GRAZE_CRIT_LAYOUT;
var float LabelsOffset;

var EUIState GRAZE_STATE_COLOUR, CRIT_STATE_COLOUR;


var bool HIT_SHOW_NonTRIVIAL;
var bool GRAZE_SHOW_NonTRIVIAL;
var bool CRIT_SHOW_NonTRIVIAL;
var bool CRIT_HIDE_TRIVIAL;
var bool BAR_HIDE_TRIVIAL;
//FIX
var bool TH_ASSIST_BAR;
var bool DISPLAY_MISS_CHANCE;
var bool TH_SHOW_GRAZED;
var bool TH_SHOW_CRIT_DMG;
var bool TH_AIM_LEFT_OF_CRIT;
var bool TH_ASSIST_BESIDE_HIT;
var bool TH_PREVIEW_MINIMUM;

var localized string CRIT_DAMAGE_LABEL, GRAZE_CHANCE_LABEL, MISS_CHANCE_LABEL;

struct OffsetProperties
{
	var int GrazeOffsetX;
	var int GrazeOffsetY;
	var int CritDOffsetX;
	var int CritDOffsetY;
	var string GrazeTextAlign;
	var string CritDTextAlign;
};

struct ResOffsetSt
{
	var string Res;
	var float offset;
	var int ResX;
	var int ResY;
};

var config array<OffsetProperties> Offsets;
var config array<ResOffsetSt> ResOffset;

simulated function UITacticalHUD_ShotHUD InitShotHUD()
{
	Super.InitShotHUD();
	InitLayout();
	return self;
}

simulated function InitLayout()
{
	local int Index;
	local int ResX, ResY;
	local int RenderWidth, RenderHeight, FullWidth, FullHeight, AlreadyAdjustedVerticalSafeZone;
	local float RenderAspectRatio, FullAspectRatio;
	local string searchString, searchString2;
	local XComOnlineEventMgr EventManager;

	LabelsOffset = 0;
	Movie.GetScreenDimensions(RenderWidth, RenderHeight, RenderAspectRatio, FullWidth, FullHeight, FullAspectRatio, AlreadyAdjustedVerticalSafeZone);
	ResX = RenderWidth;
	ResY = RenderHeight;
	searchString = "p" $ ResX $ "x" $ ResY;

	Index = ResOffset.Find('Res', searchString);

	if(Index == INDEX_NONE)
	{
		FindClosestRes(ResX, ResY);
		searchString2 = "p" $ ResX $ "x" $ ResY;
		Index = ResOffset.Find('Res', searchString2);
	}

	if(Index != INDEX_NONE)
	{
		LabelsOffset = ResOffset[Index].offset;
	}
	//DEBUG
	//LabelsOffset = getDODGE_OFFSET_Y();
	//Offsets[2].CritDOffsetX = 272;

	/*`redscreen(`showvar(searchString));
	`redscreen(`showvar(searchString2));
	`redscreen(`showvar(RenderWidth));
	`redscreen(`showvar(RenderHeight));
	`redscreen(`showvar(FullWidth));
	`redscreen(`showvar(FullHeight));
	`redscreen(`showvar(ResX));
	`redscreen(`showvar(ResY));
	`redscreen(`showvar(LabelsOffset));*/
	//DEBUG

	// Init MCM Config Variables
	/*BAR_WIDTH_MULT = getBAR_WIDTH_MULT();*/
	BAR_HEIGHT = getBAR_HEIGHT();
	BAR_ALPHA = getBAR_ALPHA();
	BAR_OFFSET_Y = BAR_POSITION_Y -BAR_HEIGHT + getBAR_OFFSET_Y();
	/*BAR_OFFSET_X = getBAR_OFFSET_X();
	GENERAL_OFFSET_Y = getGENERAL_OFFSET_Y();
	DODGE_OFFSET_X = getDODGE_OFFSET_X();
	DODGE_OFFSET_Y = getDODGE_OFFSET_Y();
	CRIT_OFFSET_X = getCRIT_OFFSET_X();
	CRIT_OFFSET_Y = getCRIT_OFFSET_Y();*/
	BarColours[0] = getHIT_HEX_COLOR();
	BarColours[1] = getCRIT_HEX_COLOR();
	BarColours[2] = getDODGE_HEX_COLOR();
	BarColours[3] = getASSIST_HEX_COLOR();
	BarColours[4] = getMISS_HEX_COLOR();
	GRAZE_CRIT_LAYOUT = getGRAZE_CRIT_LAYOUT();
	//Mr. Nice Check for auto layout
	if (GRAZE_CRIT_LAYOUT==0)
	{
		EventManager = `ONLINEEVENTMGR;
		for(Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--)
		{
			if(EventManager.GetDLCNames(Index)=='WOTCLifetimeStats') break;
		}
		if (Index==-1)
		//if (XComGameState_CampaignSettings(class'XComGameStateHistory'.static.GetGameStateHistory().GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings', true)).RequiredDLC.Find('WOTCLifetimeStats')==INDEX_NONE)
			GRAZE_CRIT_LAYOUT=2;
		else GRAZE_CRIT_LAYOUT=3;
	}
		
	TH_ASSIST_BAR = getTH_ASSIST_BAR();
	TH_SHOW_GRAZED = getTH_SHOW_GRAZED();
	TH_SHOW_CRIT_DMG = getTH_SHOW_CRIT_DMG();
	TH_ASSIST_BESIDE_HIT = getTH_ASSIST_BESIDE_HIT();
	TH_AIM_LEFT_OF_CRIT = getTH_AIM_LEFT_OF_CRIT();
	TH_PREVIEW_MINIMUM = getTH_PREVIEW_MINIMUM();
	DISPLAY_MISS_CHANCE = getDISPLAY_MISS_CHANCE();

	DODGE_OFFSET_X = Offsets[GRAZE_CRIT_LAYOUT].GrazeOffsetX;
	DODGE_OFFSET_Y = Offsets[GRAZE_CRIT_LAYOUT].GrazeOffsetY;
	CRIT_OFFSET_X = Offsets[GRAZE_CRIT_LAYOUT].CritDOffsetX;
	CRIT_OFFSET_Y = Offsets[GRAZE_CRIT_LAYOUT].CritDOffsetY;

	GrazeValue = Spawn(class'UIText', self);
	GrazeValue.InitText();
	GrazeValue.AnchorBottomCenter();
	GrazeValue.SetWidth(TEXTWIDTH);
	GrazeValue.Hide();

	GrazeLabel = Spawn(class'UIText', self);
	GrazeLabel.InitText();
	GrazeLabel.AnchorBottomCenter();
	GrazeLabel.SetWidth(TEXTWIDTH);
	GrazeLabel.Hide();

	CritDamValue = Spawn(class'UIText', self);
	CritDamValue.InitText();
	CritDamValue.AnchorBottomCenter();
	CritDamValue.SetWidth(TEXTWIDTH);
	CritDamValue.Hide();

	CritDamLabel = Spawn(class'UIText', self);
	CritDamLabel.InitText();
	CritDamLabel.AnchorBottomCenter();
	CritDamLabel.SetWidth(TEXTWIDTH);
	CritDamLabel.Hide();
	
	for(Index=0; Index<=ArrayCount(BarBoxes); Index++)
	{
		BarBoxes[Index]=Spawn(class'UIBGBox', self)
			.InitBG(,,, 60, BAR_HEIGHT)
			.SetBGColor("gray_highlight");
		BarBoxes[Index].SetColor(BarColours[Index])
			.AnchorBottomCenter()
			.SetAlpha(BAR_ALPHA);
		BarBoxes[Index].Hide();
	}
}

simulated function FindClosestRes(out int ResX, out int ResY)
{
	local ResOffsetSt ResOffsetItem;
	local int tempInt, smallestDiff, i, tempResX, tempResY;
	
	foreach ResOffset(ResOffsetItem, i)
	{
		tempInt = Abs(ResY - ResOffsetItem.ResY);
		if ((tempResY == 0) || (tempResY != 0 && tempInt < smallestDiff))
		{
			smallestDiff = tempInt;
			tempResY = ResOffsetItem.ResY;
		}
	}
	foreach ResOffset(ResOffsetItem, i)
	{
		if (tempResY == ResOffsetItem.ResY)
		{
			tempInt = Abs(ResX - ResOffsetItem.ResX);
			if ((tempResX == 0) || (tempResX != 0 && tempInt < smallestDiff))
			{
				smallestDiff = tempInt;
				tempResX = ResOffsetItem.ResX;
			}
		}
	}
	ResX = tempResX;
	ResY = tempResY;
}

simulated function Update()
{
	local bool isValidShot, IsSkPostMelee;
	local string ShotName, ShotDescription, ShotDamage;
	local int HitChance, skHitChance, CritChance, GrazeChance, TargetIndex, AimBonus, skAimBonus, BarOffsetY, DodgeOffsetY, CritOffsetY;
	local ShotBreakdown kBreakdown;
	local StateObjectReference Target, EmptyRef;
	local XComGameState_Ability SelectedAbilityState, skAbilityState;
	local X2AbilityTemplate SelectedAbilityTemplate;
	local AvailableAction SelectedUIAction;
	local AvailableTarget kTarget;
	local XGUnit ActionUnit;
	local UITacticalHUD TacticalHUD;
	local UIUnitFlag UnitFlag;
	//local WeaponDamageValue MinDamageValue, MaxDamageValue;
	local X2TargetingMethod TargetingMethod;
	local bool WillBreakConcealment, WillEndTurn, bHide, bCounter;
	local DamageBreakdown NormalDamage, CritDamage;
	local X2AbilityToHitCalc_StandardAim StandardHitCalc;
	local UnitValue CounterattackCheck;
	local XComGameState_Unit UnitState, TargetUnitState;
	local XComGameStateHistory History;
	// New from Grimy Shot Bar
	local string FontString;
   	local int offsetX, Current, i, CounterGraze, CounterCrit, CounterHit, CounterBonus;
	local float Chance[4];

	TacticalHUD = UITacticalHUD(Screen);
	History=`XCOMHISTORY;

	SelectedUIAction = TacticalHUD.GetSelectedAction();
	if (SelectedUIAction.AbilityObjectRef.ObjectID > 0)
	{ //If we do not have a valid action selected, ignore this update request
		SelectedAbilityState = XComGameState_Ability(History.GetGameStateForObjectID(SelectedUIAction.AbilityObjectRef.ObjectID));
		SelectedAbilityTemplate = SelectedAbilityState.GetMyTemplate();
		UnitState=XComGameState_Unit(History.GetGameStateForObjectID(SelectedAbilityState.OwnerStateObject.ObjectID));
		ActionUnit = XGUnit(UnitState.GetVisualizer());
		TargetingMethod = TacticalHUD.GetTargetingMethod();
		if( TargetingMethod != None )
		{
			TargetIndex = TargetingMethod.GetTargetIndex();
			if( SelectedUIAction.AvailableTargets.Length > 0 && TargetIndex < SelectedUIAction.AvailableTargets.Length )
			{
				kTarget = SelectedUIAction.AvailableTargets[TargetIndex];
				Target = kTarget.PrimaryTarget;

			}
		}

		//Update L3 help and OK button based on ability.
		//*********************************************************************************
		if (SelectedUIAction.bFreeAim)
		{
			AS_SetButtonVisibility(Movie.IsMouseActive(), false);
			isValidShot = true;
		}
		else if (SelectedUIAction.AvailableTargets.Length == 0 || SelectedUIAction.AvailableTargets[0].PrimaryTarget.ObjectID < 1)
		{
			AS_SetButtonVisibility(Movie.IsMouseActive(), false);
			isValidShot = false;
		}
		else
		{
			AS_SetButtonVisibility(Movie.IsMouseActive(), Movie.IsMouseActive());
			isValidShot = true;
		}
 
		//Set shot name / help text
		//*********************************************************************************
		ShotName = SelectedAbilityState.GetMyFriendlyName(kTarget.PrimaryTarget);
 
		if (SelectedUIAction.AvailableCode == 'AA_Success')
		{
			ShotDescription = SelectedAbilityState.GetMyHelpText();
			if (ShotDescription == "") ShotDescription = "Missing 'LocHelpText' from ability template.";
		}
		else
		{
			ShotDescription = class'X2AbilityTemplateManager'.static.GetDisplayStringForAvailabilityCode(SelectedUIAction.AvailableCode);
		}
 
 
		WillBreakConcealment = SelectedAbilityState.MayBreakConcealmentOnActivation(Target.ObjectID);
		WillEndTurn = SelectedAbilityState.WillEndTurn();
 
		//AS_SetShotInfo(ShotName, ShotDescription, WillBreakConcealment, WillEndTurn);
		// Display Hack Info if relevant
		AS_SetShotInfo(ShotName, UpdateHackDescription(SelectedAbilityState, Target, ShotDescription), WillBreakConcealment, WillEndTurn);
 
		// Disable Shot Button if we don't have a valid target.
		AS_SetShotButtonDisabled(!isValidShot);
 
		ResetDamageBreakdown();
		
		if (SelectedUIAction.AvailableCode != 'AA_Success')
		{
			HideAll();
			return;
		}

		if(SelectedAbilityTemplate.DataName=='SkirmisherVengeance'
			|| SelectedAbilityTemplate.DataName=='Justice')
		{
			IsSkPostMelee=true;
			skAbilityState=XComGameState_Ability(History.GetGameStateForObjectID(UnitState.FindAbility('SkirmisherPostAbilityMelee').ObjectID));
		}
		else skAbilityState=SelectedAbilityState;
		// In the rare case that this ability is self-targeting, but has a multi-target effect on units around it,
		// look at the damage preview, just not against the target (self).
		if (SelectedAbilityTemplate.AbilityTargetStyle.IsA('X2AbilityTarget_Self')
			&& SelectedAbilityTemplate.AbilityMultiTargetStyle != none
			&& SelectedAbilityTemplate.AbilityMultiTargetEffects.Length > 0 )
		{
			class'DamagePreviewLib'.static.GetDamagePreview(skAbilityState, EmptyRef, NormalDamage, CritDamage);
		}
		else class'DamagePreviewLib'.static.GetDamagePreview(skAbilityState, Target, NormalDamage, CritDamage);

		if ( NormalDamage.Min > 0 || NormalDamage.Max > 0)
		{
			ShotDamage=`RANGESTRING(NormalDamage.Min, NormalDamage.Max);
 			if(NormalDamage.Bonus>0)
			{
				AddDamage(class'UIUtilities_Text'.static.GetColoredText(ShotDamage, eUIState_Warning2, 38), true);
			}
			else
			{
				AddDamage(class'UIUtilities_Text'.static.GetColoredText(ShotDamage, eUIState_Good, 36), true);
			}
		}
 
		//Set up percent to hit / crit values
		//*********************************************************************************
	   
		if (SelectedAbilityTemplate.AbilityToHitCalc != none && SelectedAbilityState.iCooldown == 0)
		{
			//Mr. Nice: these three lines from Firaxis original)
		   /*****************************************************/
		   class'HitCalcLib'.static.GetShotBreakdownDiffAdjust(SelectedAbilityState, kTarget, kBreakdown, AimBonus);
			HitChance = Clamp(((kBreakdown.bIsMultishot) ? kBreakdown.MultiShotHitChance : kBreakdown.FinalHitChance), 0, 100);
		   if(IsSkPostMelee)
		   {
			   class'HitCalcLib'.static.GetShotBreakdownDiffAdjust(skAbilityState, kTarget, kBreakdown, SkAimBonus);
   			   skHitChance=Clamp(((kBreakdown.bIsMultishot) ? kBreakdown.MultiShotHitChance : kBreakdown.FinalHitChance), 0, 100);
			}
			else
			{
				skHitChance=HitChance;
				skAimBonus=AimBonus;
			}
			CritChance = kBreakdown.ResultTable[eHit_Crit];
			GrazeChance= kBreakdown.ResultTable[eHit_Graze];
		   /*****************************************************/

 			
			// If User selected to display the Modified Hit Chance
			BarOffsetY=BAR_OFFSET_Y;
			DodgeOffsetY=DODGE_OFFSET_Y;
			CritOffsetY=CRIT_OFFSET_Y;
			if (TacticalHUD.m_kAbilityHUD.ActiveAbilities > MAX_ABILITIES_PER_ROW)
			{
				BarOffsetY += GENERAL_OFFSET_Y;
				DodgeOffsetY += GENERAL_OFFSET_Y;
				CritOffsetY += GENERAL_OFFSET_Y;
			}

			bHide = HitChance < 0 || kBreakdown.HideShotBreakdown;
			
			if (!bHide || HIT_SHOW_NonTRIVIAL && HitChance>0 && HitChance<100)
			{
				if (DISPLAY_MISS_CHANCE)
				{
					//Mr.Nice: Why special case Miss==0? We might as well manually draw it the whoLe time....
					//Flipped version only used once, and now want the real hitchance later too, so don't bother changing the variable.
					//HitChance = 100 - HitChance;
					// DEBUG TEST
					//if (HitChance == 0) AS_SetShotChance(class'UIUtilities_Text'.static.GetColoredText(class'X2Action_ApplyWeaponDamageToUnit_HITCHANCE'.default.MISS_CHANCE, eUIState_Header), HitChance + 0.0);
					//AS_SetShotChance(class'UIUtilities_Text'.static.GetColoredText(class'X2Action_ApplyWeaponDamageToUnit_HITCHANCE'.default.MISS_CHANCE, eUIState_Header), HitChance);
					//if (HitChance == 0)
					//{
						MC.ChildSetBool("statsHit", "_visible", true);
						MC.ChildSetString("statsHit.shotLabel", "htmlText", Caps(class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[eHit_Miss]));
						MC.ChildSetString("statsHit.shotValue", "htmlText", (100-HitChance) @ "%");
					//}
				}
				else AS_SetShotChance(class'UIUtilities_Text'.static.GetColoredText(m_sShotChanceLabel, eUIState_Header), HitChance);
				TacticalHUD.SetReticleAimPercentages(float(HitChance) / 100.0f, float(CritChance) / 100.0f);
			}
			else
			{
				AS_SetShotChance("", -1);
				TacticalHUD.SetReticleAimPercentages(-1, -1);
			}
			
			if( CritChance>-1 &&(
				(!bHide && !(CRIT_HIDE_TRIVIAL && CritDamage.InfoList.Length==0 && CritChance<=0))
				|| (bHide && CRIT_SHOW_NonTRIVIAL &&(CritDamage.Min>0 || CritDamage.Max>0))) )
			{
				if(TH_SHOW_CRIT_DMG)
				{
					FontString = "+" $ `RANGESTRING(CritDamage.Min, CritDamage.Max);
					FontString = class'UIUtilities_Text'.static.GetColoredText(FontString, CRIT_STATE_COLOUR, , Offsets[GRAZE_CRIT_LAYOUT].CritDTextAlign);
					FontString = class'UIUtilities_Text'.static.AddFontInfo(FontString,false,true, , ValueFontSize);
					CritDamValue.SetPosition(CRIT_OFFSET_X-TEXTWIDTH*int(Offsets[GRAZE_CRIT_LAYOUT].CritDTextAlign=="right"),CritOffsetY - 0.8);
					CritDamValue.SetText(FontString);
					CritDamValue.Show();
				
					FontString = CRIT_DAMAGE_LABEL;
					FontString = class'UIUtilities_Text'.static.GetColoredText(FontString,eUIState_Header, LabelFontSize, Offsets[GRAZE_CRIT_LAYOUT].CritDTextAlign);
					CritDamLabel.SetPosition(CRIT_OFFSET_X-TEXTWIDTH*int(Offsets[GRAZE_CRIT_LAYOUT].CritDTextAlign=="right"),CritOffsetY + LabelsOffset);
					CritDamLabel.SetText(FontString);
					CritDamLabel.Show();
				}
				else
				{
					CritDamValue.Hide();
					CritDamLabel.Hide();
				}
				if (!bHide || CritChance!=0)
					AS_SetCriticalChance(class'UIUtilities_Text'.static.GetColoredText(m_sCritChanceLabel, eUIState_Header), CritChance);
				else
					AS_SetCriticalChance("", -1);
			}
			else
			{
				AS_SetCriticalChance("", -1);
				CritDamValue.Hide();
				CritDamLabel.Hide();
			}
			
			//************Counter Attack Stuff**************************
			//Mr. Nice: Counter attacks turn all graze & miss results to counters,
			//plus a chance to turn guaranteed hit melees to counters (at the same rate as Mutons boosted dodge against melee)
			StandardHitCalc=X2AbilityToHitCalc_StandardAim(skAbilityState.GetMyTemplate().AbilityToHitCalc);
			if (StandardHitCalc!=none && StandardHitCalc.bMeleeAttack)
			{
				TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(Target.ObjectID));
				if (TargetUnitState!=none && !TargetUnitState.IsImpaired()
					&& TargetUnitState.GetUnitValue(class'X2Ability'.default.CounterattackDodgeEffectName, CounterattackCheck)
					&& CounterattackCheck.fValue == class'X2Ability'.default.CounterattackDodgeUnitValue)
				{
					bCounter=true;
					if (StandardHitCalc.bGuaranteedHit)
					{
						CounterGraze=max(0,(skHitChance-GrazeChance))*class'X2Ability_Muton'.default.COUNTERATTACK_DODGE_AMOUNT/100;
						if (CritChance!=0)
							//Mr. Nice: For bar purposes, don't want crit to disappear if non-zero in principle
							CounterCrit=max(1, CritChance*(100-class'X2Ability_Muton'.default.COUNTERATTACK_DODGE_AMOUNT)/100);
						if (skAimBonus!=0)
							CounterBonus=max(1, skAimBonus*(100-class'X2Ability_Muton'.default.COUNTERATTACK_DODGE_AMOUNT)/100);
						CounterHit=CounterGraze-CounterCrit-CounterBonus;
					}
					if (!IsSkPostMelee) CounterGraze+=100-HitChance;
					GrazeChance+=CounterGraze;
				}
			}

			if (TH_SHOW_GRAZED && (!bHide || GRAZE_SHOW_NonTRIVIAL) && GrazeChance > 0)
			{
				FontString = GrazeChance $ "%";
				FontString = class'UIUtilities_Text'.static.GetColoredText(FontString, GRAZE_STATE_COLOUR, , Offsets[GRAZE_CRIT_LAYOUT].GrazeTextAlign);
				FontString = class'UIUtilities_Text'.static.AddFontInfo(FontString,false,true, , ValueFontSize);
				GrazeValue.SetPosition(DODGE_OFFSET_X -TEXTWIDTH*int(Offsets[GRAZE_CRIT_LAYOUT].GrazeTextAlign=="right"),DodgeOffsetY - 0.8);
				GrazeValue.SetText(FontString);
				GrazeValue.Show();
				FontString = Caps(bCounter ? `LOCFALLBACK(ShortCounterAttack, class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[eHit_CounterAttack])
					: class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[eHit_Graze]);
				FontString = class'UIUtilities_Text'.static.GetColoredText(FontString,eUIState_Header,LabelFontSize ,Offsets[GRAZE_CRIT_LAYOUT].GrazeTextAlign);
				GrazeLabel.SetPosition(DODGE_OFFSET_X -TEXTWIDTH*int(Offsets[GRAZE_CRIT_LAYOUT].GrazeTextAlign=="right"),DodgeOffsetY + LabelsOffset);
				GrazeLabel.SetText(FontString);
				GrazeLabel.Show();
			}
			else
			{
				GrazeLabel.Hide();
				GrazeValue.Hide();
			}
				
			// Generate the shot breakdown bar
			if ( BAR_HEIGHT > 0 && !bHide &&
			!(BAR_HIDE_TRIVIAL && CritDamage.InfoList.Length==0 && CritChance<=0 && GrazeChance<=0) )
			{	   //Mr. Nice: If you're going to replicate the % results from RollforAbilityHit, then copy it's code structure!
					// Note RollforabilityHit() is an empty function is the basic X2AbilitytoHitCalc class, below is _StandardAim drived
					// In principle, other X2AbilitytoHitCalc implementations could use shotbreakdown differently, or even not use it at all!
					for (i = 0; i < eHit_Miss; ++i)	 //  If we don't match a result before miss, then it's a miss.
					{
						Chance[i]= max(0, min(Current + kBreakdown.ResultTable[i], 100) - max(Current, 0) );
						Current += kBreakdown.ResultTable[i];
					//`redscreen(`showvar(Current));
					}
					//`redscreen(`showvar(HitChance));
					Chance[eHit_Miss]=100-HitChance;
				if (bCounter)
				{
					Chance[eHit_Graze]+=CounterGraze;
					Chance[eHit_Crit]-=CounterCrit;
					Chance[eHit_Success]-=CounterHit;
					AimBonus-=CounterBonus;
					Chance[eHit_Miss]=0;//Misses will be Counters, so no miss to show in the bar
				}
				if (IsSkPostMelee)
				{
					Chance[eHit_Success]+=skAimBonus;
					AimBonus*=Chance[eHit_Success]/100.0;
					for (i = 0; i < eHit_Miss; ++i)	
						Chance[i]*=float(HitChance)/float(skHitChance);
					Chance[eHit_Miss]=100-HitChance;//Incase counters have set it to 0!
					Chance[eHit_Success]-=AimBonus;
				}

				if (TH_ASSIST_BAR)
				{
					Chance[eHit_Success] += AimBonus; //Assist bonus directly adds to eHit_Success changes;
					AimBonus=0; //Hide the seperate aimbonus bar;
				}
				offsetX = BAR_WIDTH_MULT * (-50) + BAR_OFFSET_X;
				//Mr. Nice: offsetX is an out parameter, and is incremented in SetBox() as required.
				switch(int(TH_AIM_LEFT_OF_CRIT) + 2* int(TH_ASSIST_BESIDE_HIT))
				{
					case 1+0:
						SetBox(BarBoxes[0], Chance[eHit_Success], offsetX, BarOffsetY);
						SetBox(BarBoxes[1], Chance[eHit_Crit], offsetX, BarOffsetY);
						SetBox(BarBoxes[2], Chance[eHit_Graze], offsetX, BarOffsetY);
						SetBox(BarBoxes[3], AimBonus, offsetX, BarOffsetY);
					break;
					case 1+2:
						SetBox(BarBoxes[0], Chance[eHit_Success], offsetX, BarOffsetY);
						SetBox(BarBoxes[3], AimBonus, offsetX, BarOffsetY);
						SetBox(BarBoxes[1], Chance[eHit_Crit], offsetX, BarOffsetY);
						SetBox(BarBoxes[2], Chance[eHit_Graze], offsetX, BarOffsetY);
					break;
					case 0+0:
						SetBox(BarBoxes[1], Chance[eHit_Crit], offsetX, BarOffsetY);
						SetBox(BarBoxes[0], Chance[eHit_Success], offsetX, BarOffsetY);
						SetBox(BarBoxes[2], Chance[eHit_Graze], offsetX, BarOffsetY);
						SetBox(BarBoxes[3], AimBonus, offsetX, BarOffsetY);
					break;
					case 0+2:
						SetBox(BarBoxes[1], Chance[eHit_Crit], offsetX, BarOffsetY);
						SetBox(BarBoxes[0], Chance[eHit_Success], offsetX, BarOffsetY);
						SetBox(BarBoxes[3], AimBonus, offsetX, BarOffsetY);
						SetBox(BarBoxes[2], Chance[eHit_Graze], offsetX, BarOffsetY);
					break;
				}
				//Mr. Nice: No longer optional to call SetBox for miss, since SetBox is what hides it if needed
				SetBox(BarBoxes[4], Chance[eHit_Miss], offsetX, BarOffsetY);
			}
			else for (i=0; i<arraycount(BarBoxes); i++) BarBoxes[i].Hide();
		}
		else HideAll();

		TacticalHUD.m_kShotInfoWings.Show();
 
		//Show preview points, must be negative
		UnitFlag = XComPresentationLayer(Owner.Owner).m_kUnitFlagManager.GetFlagForObjectID(Target.ObjectID);
		if(UnitFlag != none)
		{
			if (TH_PREVIEW_MINIMUM)
				SetAbilityMinDamagePreview(UnitFlag, skAbilityState, Target);
			else
				XComPresentationLayer(Owner.Owner).m_kUnitFlagManager.SetAbilityDamagePreview(UnitFlag, skAbilityState, Target);
		}
 
		//@TODO - jbouscher - ranges need to be implemented in a template friendly way.
		//Hide any current range meshes before we evaluate their visibility state
		if (!ActionUnit.GetPawn().RangeIndicator.HiddenGame) ActionUnit.RemoveRanges();
	}
 
	if (`REPLAY.bInTutorial)
		{
		if (SelectedAbilityTemplate != none && `TUTORIAL.IsNextAbility(SelectedAbilityTemplate.DataName) && `TUTORIAL.IsTarget(Target.ObjectID))
			ShowShine();
		else HideShine();
	}
	RefreshTooltips();
}

simulated function HideAll()
{
	local int i;

	AS_SetShotChance("", -1);
	AS_SetCriticalChance("", -1);
	for (i=0; i<arraycount(BarBoxes); i++) BarBoxes[i].Hide();
	GrazeValue.Hide();
	GrazeLabel.Hide();
	CritDamValue.Hide();
	CritDamLabel.Hide();
}

simulated function ExtendedInformationRedux2_UITacticalHUD_ShotHUD RemoveAll()
{
	local int i;
	for (i=0; i<arraycount(BarBoxes); i++) BarBoxes[i].Remove();
	GrazeValue.Remove();
	GrazeLabel.Remove();
	CritDamValue.Remove();
	CritDamLabel.Remove();
	return self;
}

simulated function SetBox (UIBGBox BarBox, int Chance, out int offsetX, int offsetY)
{
	local int bWidth;

	if (Chance <=0)
	{
		BarBox.Hide();
		return;
	}

	bWidth=Chance*BAR_WIDTH_MULT;
	BarBox.SetPosition(offsetX, offsetY);
	BarBox.SetWidth(bWidth);
	BarBox.Show();

	offsetX += bWidth;
}

`MCM_CH_VersionChecker(class'MCM_Defaults'.default.VERSION, class'ExtendedInformationRedux2_MCMScreen'.default.CONFIG_VERSION)


// GRIMY - Added this to do a minimum damage preview.
// Recreated the preview function in order to minimize # of files edited, and thus conflicts
static function SetAbilityMinDamagePreview(UIUnitFlag kFlag, XComGameState_Ability AbilityState, StateObjectReference TargetObject)
{
	local XComGameState_Unit FlagUnit;
	local int shieldPoints, AllowedShield;
	local int possibleHPDamage, possibleShieldDamage;
	local WeaponDamageValue MinDamageValue;
	local WeaponDamageValue MaxDamageValue;
 
	if(kFlag == none || AbilityState == none)
	{
		return;
	}
 
	AbilityState.GetDamagePreview(TargetObject, MinDamageValue, MaxDamageValue, AllowedShield);
 
	FlagUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kFlag.StoredObjectID));
	shieldPoints = FlagUnit != none ? int(FlagUnit.GetCurrentStat(eStat_ShieldHP)) : 0;
 
	possibleHPDamage = MinDamageValue.Damage;
	possibleShieldDamage = 0;
 
	// MaxHP contains extra HP points given by shield
	if(shieldPoints > 0 && AllowedShield > 0)
	{
		possibleShieldDamage = min(shieldPoints, MinDamageValue.Damage);
		possibleShieldDamage = min(possibleShieldDamage, AllowedShield);
		possibleHPDamage = MinDamageValue.Damage - possibleShieldDamage;
	}
 
	if (!AbilityState.DamageIgnoresArmor() && FlagUnit != none)
		possibleHPDamage -= max(0,FlagUnit.GetArmorMitigationForUnitFlag() - MinDamageValue.Pierce);
 
	kFlag.SetShieldPointsPreview( possibleShieldDamage );
	kFlag.SetHitPointsPreview( possibleHPDamage );
	kFlag.SetArmorPointsPreview(MinDamageValue.Shred, MinDamageValue.Pierce);
}
 
function string UpdateHackDescription( XComGameState_Ability AbilityState, StateObjectReference Target, string ShotDescription)
{
	local EIHackStructs.EIHackBreakdown HackBreakdown;
	local HackRewardInfo RewardItem;

	if(class'HackCalcLib'.static.GetHackBreakdown(AbilityState, Target, HackBreakdown))
	{
		RewardItem=HackBreakdown.RewardList[0];
		ShotDescription $= "\n" $ class'UIUtilities_Text'.static.GetColoredText(RewardItem.RewardTemplate.GetFriendlyName(), RewardItem.RewardTemplate.bBadThing ? eUIState_Bad : eUIState_Good);
		RewardItem=HackBreakdown.RewardList[1];
		ShotDescription $= " - " $ class'UIUtilities_Text'.static.GetColoredText(RewardItem.RewardTemplate.GetFriendlyName() $ ": " $ Clamp(RewardItem.Chance, 0, 100) $ "%", eUIState_Good);
		RewardItem=HackBreakdown.RewardList[2];
		ShotDescription $= ", " $ class'UIUtilities_Text'.static.GetColoredText(RewardItem.RewardTemplate.GetFriendlyName() $ ": " $ Clamp(RewardItem.Chance, 0, 100) $ "%", eUIState_Good);
	}
	return ShotDescription;
}

function bool GetDISPLAY_MISS_CHANCE()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.DISPLAY_MISS_CHANCE, class'ExtendedInformationRedux2_MCMScreen'.default.DISPLAY_MISS_CHANCE);
}

function bool GetTH_SHOW_GRAZED()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.TH_SHOW_GRAZED, class'ExtendedInformationRedux2_MCMScreen'.default.TH_SHOW_GRAZED);
}

function bool GetTH_SHOW_CRIT_DMG()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.TH_SHOW_CRIT_DMG, class'ExtendedInformationRedux2_MCMScreen'.default.TH_SHOW_CRIT_DMG);
}

function bool GetTH_AIM_LEFT_OF_CRIT()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.TH_AIM_LEFT_OF_CRIT, class'ExtendedInformationRedux2_MCMScreen'.default.TH_AIM_LEFT_OF_CRIT);
}

function bool GetTH_PREVIEW_MINIMUM()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.TH_PREVIEW_MINIMUM, class'ExtendedInformationRedux2_MCMScreen'.default.TH_PREVIEW_MINIMUM);
}

function int getBAR_HEIGHT()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.BAR_HEIGHT, class'ExtendedInformationRedux2_MCMScreen'.default.BAR_HEIGHT);
}

/*function int getBAR_OFFSET_X()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.BAR_OFFSET_X, class'ExtendedInformationRedux2_MCMScreen'.default.BAR_OFFSET_X);
}*/

function int getBAR_OFFSET_Y()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.BAR_OFFSET_Y, class'ExtendedInformationRedux2_MCMScreen'.default.BAR_OFFSET_Y);
}

function int getBAR_ALPHA()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.BAR_ALPHA, class'ExtendedInformationRedux2_MCMScreen'.default.BAR_ALPHA);
}

/*function int getBAR_WIDTH_MULT()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.BAR_WIDTH_MULT, class'ExtendedInformationRedux2_MCMScreen'.default.BAR_WIDTH_MULT);
}

function int getGENERAL_OFFSET_Y()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.GENERAL_OFFSET_Y, class'ExtendedInformationRedux2_MCMScreen'.default.GENERAL_OFFSET_Y);
}

function int getDODGE_OFFSET_X()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.DODGE_OFFSET_X, class'ExtendedInformationRedux2_MCMScreen'.default.DODGE_OFFSET_X);
}

function int getCRIT_OFFSET_X()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.CRIT_OFFSET_X, class'ExtendedInformationRedux2_MCMScreen'.default.CRIT_OFFSET_X);
}

function int getCRIT_OFFSET_Y()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.CRIT_OFFSET_Y, class'ExtendedInformationRedux2_MCMScreen'.default.CRIT_OFFSET_Y);
}*/

function string getHIT_HEX_COLOR()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.HIT_HEX_COLOR, class'ExtendedInformationRedux2_MCMScreen'.default.HIT_HEX_COLOR);
}

function string getCRIT_HEX_COLOR()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.CRIT_HEX_COLOR, class'ExtendedInformationRedux2_MCMScreen'.default.CRIT_HEX_COLOR);
}

function string getDODGE_HEX_COLOR()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.DODGE_HEX_COLOR, class'ExtendedInformationRedux2_MCMScreen'.default.DODGE_HEX_COLOR);
}

function string getMISS_HEX_COLOR()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.MISS_HEX_COLOR, class'ExtendedInformationRedux2_MCMScreen'.default.MISS_HEX_COLOR);
}

function string getASSIST_HEX_COLOR()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.ASSIST_HEX_COLOR, class'ExtendedInformationRedux2_MCMScreen'.default.ASSIST_HEX_COLOR);
}

function int getGRAZE_CRIT_LAYOUT()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.GRAZE_CRIT_LAYOUT, class'ExtendedInformationRedux2_MCMScreen'.default.GRAZE_CRIT_LAYOUT);
}

function bool getTH_ASSIST_BESIDE_HIT()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.TH_ASSIST_BESIDE_HIT, class'ExtendedInformationRedux2_MCMScreen'.default.TH_ASSIST_BESIDE_HIT);
}

function bool getTH_ASSIST_BAR()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.TH_ASSIST_BAR, class'ExtendedInformationRedux2_MCMScreen'.default.TH_ASSIST_BAR);
}


//DEBUG
/*function float getDODGE_OFFSET_Y()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.DODGE_OFFSET_Y, class'ExtendedInformationRedux2_MCMScreen'.default.DODGE_OFFSET_Y);
}*/
//DEBUG


defaultproperties
{
	//ASSIST_HEX_COLOR="b6b3e3" ; //PURPLE

	// ShotBar position, size, and offset settings, should not be altered whatsoever
	// so created those default values inside the class to not expose them in MCM any more
	BAR_WIDTH_MULT = 3;
	BAR_HEIGHT = 10;
	BAR_OFFSET_X = 3;
	//BAR_OFFSET_Y = -122;
	//BAR_POSITION_Y = -119;
	BAR_POSITION_Y = -108;
	GENERAL_OFFSET_Y = -32;
	LabelsOffset = -23;
	LabelFontSize = 18;
	ValueFontSize = 28;
	MAX_ABILITIES_PER_ROW = 15;
	//TEXTWIDTH=100;
	TEXTWIDTH=150;

	GRAZE_STATE_COLOUR=eUIState_Cash;
	CRIT_STATE_COLOUR=eUIState_Warning;


	HIT_SHOW_NonTRIVIAL=true;
	GRAZE_SHOW_NonTRIVIAL=true;
	CRIT_SHOW_NonTRIVIAL=true;
	CRIT_HIDE_TRIVIAL=true;
	BAR_HIDE_TRIVIAL=true;
	//TH_ASSIST_BAR=true;
}