//-----------------------------------------------------------
//	Class:	ExtendedInformationRedux2_UITacticalHUD_ShotWings
//	Author: Mr.Nice / Sebkulu
//	
//-----------------------------------------------------------

class ExtendedInformationRedux2_UITacticalHUD_ShotWings extends UITacticalHUD_ShotWings;

`define RANGESTRING(MIN, MAX)  ( `MIN == `MAX ? string(`MIN) : string(`MIN) $ "-" $ string(`MAX) )
//`define RANGESTRINGO(WEPDAM) `RANGESTRING( `MINDAM(`WEPDAM), `MAXDAM(`WEPDAM) )
//`define RANGESTRINGN(WEPITEM) `RANGESTRING(`WEPITEM.min, `WEPITEM.max)
//`define SETCOLOR(VAL) IF(`VAL<0) {eState = eUIState_Bad;prefix="";}else {eState=eUIState_Good;prefix="+";}
//`define COLORTEXT(OUTSTR, INSTR) `OUTSTR=class'UIUtilities_Text'.static.GetColoredText(`INSTR, eState)

`include(ExtendedInformationRedux2\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

//var bool SHOW_ALWAYS_SHOT_BREAKDOWN_HUD;
var bool DISPLAY_MISS_CHANCE;
var bool HIT_SHOW_NonTRIVIAL;
var bool DAMAGE_SHOW_NonTRIVIAL;
var bool CRIT_SHOW_NonTRIVIAL;
var bool CRIT_HIDE_TRIVIAL;

var localized string CRIT_DAMAGE_LABEL;
var localized string MULTIPLIER;
//var public UIText CritDamageLabel;
var public UIText CritDamageValue;
var public UIMask CritDamageMask;
var public UIPanel CritDamageBodyArea;
var public UIStatList CritDamageStatList;
var public UIScrollingText  CritDamageLabel, DamageLabelsc, HitLabelsc, CritLabelsc;

`MCM_CH_VersionChecker(class'MCM_Defaults'.default.VERSION, class'ExtendedInformationRedux2_MCMScreen'.default.CONFIG_VERSION)

simulated function UITacticalHUD_ShotWings InitShotWings(optional name InitName, optional name InitLibID)
{
	local int ArrowButtonWidth, ArrowButtonOffset, StatsWidth, StatsOffset, LineHeight, ScrollWidth;
	local float LineOffset, ListOffset, TableGap, TmpInt;//Yes, TmpInt is now badly named! It's only used for UI positioning, and UI positions are floats
	local UIPanel HitLine, CritLine, CritDamageLine, DamageLine, HitBG, CritBG, LeftContainer, RightContainer; 

	InitPanel(InitName, InitLibID);

	StatsWidth = 188;
	ScrollWidth = 136;
	StatsOffset = 24;
	ArrowButtonWidth = 16;
	ArrowButtonOffset = 4;

	//YOffset =0;// 9;
	LineHeight=class'UIStatList'.default.LineHeight;

	LineOffset=24; //Default 24, Distance from top of Table to header/list divider line
	ListOffset=3.5; //Default=4, Distance from Line to List (Line itself is 2pxl High, so ifless than two 2 will overlap line when scrolling)
	TableGap=1.5; //Default=4, Gap between the two tables in one Wing (NOT visible gap between textlines, due to descender/ascender/accent allowances in the Fonts)

	// ----------
	// The wings are actually contained within the ShotHUD so they animate in and anchor properly -sbatista
	LeftWingArea = Spawn(class'UIPanel', UITacticalHUD(Screen).m_kShotHUD); 
	LeftWingArea.bAnimateOnInit = false;
	LeftWingArea.InitPanel('leftWing');
	
	HitBG = Spawn(class'UIPanel', LeftWingArea).InitPanel('wingBG');
	HitBG.bAnimateOnInit = false;
	HitBG.ProcessMouseEvents(LeftWingMouseEvent);

	LeftContainer = Spawn(class'UIPanel', LeftWingArea);
	LeftContainer.bAnimateOnInit = false;
	LeftContainer.InitPanel('wingContainer');

	LeftWingButton = Spawn(class'UIButton', LeftContainer);
	LeftWingButton.LibID = 'X2DrawerButton';
	LeftWingButton.bAnimateOnInit = false;
	LeftWingButton.InitButton(,,OnWingButtonClicked).SetPosition(ArrowButtonOffset, (height - 26) * 0.5);
	LeftWingButton.MC.ChildFunctionString("bg.arrow", "gotoAndStop", bLeftWingOpen ? "right" : "left");

	HitPercent = Spawn(class'UIText', LeftContainer);
	HitPercent.bAnimateOnInit = false;
	HitPercent.InitText('HitPercent');
	HitPercent.SetWidth(StatsWidth); 
	HitPercent.SetPosition(StatsOffset, 0);
	HitLabelsc = Spawn(class'UIScrollingText', LeftContainer);
	HitLabelsc.bAnimateOnInit = false;
	HitLabelsc.InitScrollingText('HitLabel',, ScrollWidth, StatsOffset, 0);
	//HitLabelsc.SetPosition(StatsOffset, 0);

	HitLine = Spawn(class'UIPanel', LeftContainer);
	HitLine.bAnimateOnInit = false;
	HitLine.InitPanel('HitHeaderLine', class'UIUtilities_Controls'.const.MC_GenericPixel);
	HitLine.SetPosition(StatsOffset, LineOffset);
	HitLine.SetSize(StatsWidth, 2);
	HitLine.SetAlpha(50);

	TmpInt = HitLine.Y + ListOffset;

	HitBodyArea = Spawn(class'UIPanel', LeftContainer); 
	HitBodyArea.bAnimateOnInit = false;
	HitBodyArea.InitPanel('HitBodyArea').SetPosition(HitLine.X, TmpInt);
	HitBodyArea.width = StatsWidth; 
	HitBodyArea.height = LineHeight*3;// - TmpInt;

	HitMask = Spawn(class'UIMask', LeftContainer).InitMask(, HitBodyArea);
	HitMask.SetPosition(HitBodyArea.X, HitBodyArea.Y); 
	HitMask.SetSize(StatsWidth, HitBodyArea.height);

	HitStatList = Spawn(class'UIStatList', HitBodyArea);
	HitStatList.bAnimateOnInit = false;
	HitStatList.InitStatList('StatListLeft',,,, HitBodyArea.Width, HitBodyArea.Height, 0, 0);

	TmpInt += LineHeight*3 + TableGap;

	DamagePercent = Spawn(class'UIText', LeftContainer);
	DamagePercent.bAnimateOnInit = false;
	DamagePercent.InitText('DamagePercent');
	DamagePercent.SetWidth(StatsWidth);
	DamagePercent.SetPosition(StatsOffset, TmpInt);
	DamageLabelsc = Spawn(class'UIScrollingText', LeftContainer);
	DamageLabelsc.bAnimateOnInit = false;
	DamageLabelsc.InitScrollingText('DamageLabel',, ScrollWidth, StatsOffset, TmpInt);
	//DamageLabelsc.InitText('DamageLabel');
	//DamageLabelsc.SetWidth(StatsWidth);
	//DamageLabelsc.SetPosition(StatsOffset, TmpInt);

	DamageLine = Spawn(class'UIPanel', LeftContainer);
	DamageLine.bAnimateOnInit = false;
	DamageLine.InitPanel('DamageHeaderLine', class'UIUtilities_Controls'.const.MC_GenericPixel);
	DamageLine.SetSize(StatsWidth, 2);
	DamageLine.SetPosition(StatsOffset, TmpInt + LineOffset);
	DamageLine.SetAlpha(50);

	TmpInt = DamageLine.Y + ListOffset;

	DamageBodyArea = Spawn(class'UIPanel', LeftContainer);
	DamageBodyArea.bAnimateOnInit = false;
	DamageBodyArea.InitPanel('DamageBodyArea').SetPosition(DamageLine.X, TmpInt);
	DamageBodyArea.width = StatsWidth;
	DamageBodyArea.height = LineHeight*2; //height - TmpInt;

	DamageMask = Spawn(class'UIMask', LeftContainer).InitMask(, DamageBodyArea);
	DamageMask.SetPosition(DamageBodyArea.X, DamageBodyArea.Y);
	DamageMask.SetSize(StatsWidth, DamageBodyArea.height);

	DamageStatList = Spawn(class'UIStatList', DamageBodyArea);
	DamageStatList.bAnimateOnInit = false;
	DamageStatList.InitStatList('DamageStatList', , , , DamageBodyArea.Width, DamageBodyArea.Height, 0, 0);

	// -----------
	// The wings are actually contained within the ShotHUD so they animate in and anchor properly -sbatista
	RightWingArea = Spawn(class'UIPanel', UITacticalHUD(Screen).m_kShotHUD); 
	RightWingArea.bAnimateOnInit = false;
	RightWingArea.InitPanel('rightWing');
	
	CritBG = Spawn(class'UIPanel', RightWingArea);
	CritBG.bAnimateOnInit = false;
	CritBG.InitPanel('wingBG');
	CritBG.ProcessMouseEvents(RightWingMouseEvent);

	RightContainer = Spawn(class'UIPanel', RightWingArea);
	RightContainer.bAnimateOnInit = false;
	RightContainer.InitPanel('wingContainer');

	RightWingButton = Spawn(class'UIButton', RightContainer);
	RightWingButton.LibID = 'X2DrawerButton';
	RightWingButton.bAnimateOnInit = false;
	RightWingButton.InitButton(,,OnWingButtonClicked).SetPosition(-ArrowButtonWidth - ArrowButtonOffset, (height - 26) * 0.5);
	RightWingButton.MC.FunctionString("gotoAndStop", "right");
	RightWingButton.MC.ChildFunctionString("bg.arrow", "gotoAndStop", bRightWingOpen ? "right" : "left");


	CritPercent = Spawn(class'UIText', RightContainer);
	CritPercent.bAnimateOnInit = false;
	CritPercent.InitText('CritPercent');
	CritPercent.SetWidth(StatsWidth); 
	CritPercent.SetPosition(-StatsWidth - StatsOffset, 0);
	CritLabelsc = Spawn(class'UIScrollingText', RightContainer);
	CritLabelsc.bAnimateOnInit = false;
	CritLabelsc.InitScrollingText('CritLabel',, ScrollWidth, -StatsWidth - StatsOffset, 0);
	//CritLabelsc.SetWidth(StatsWidth);
	//CritLabelsc.SetPosition(-StatsWidth - StatsOffset, 0);

	CritLine = Spawn(class'UIPanel', RightContainer);
	CritLine.bAnimateOnInit = false;
	CritLine.InitPanel('CritHeaderLine', class'UIUtilities_Controls'.const.MC_GenericPixel);
	CritLine.SetSize(StatsWidth, 2);
	CritLine.SetPosition(-StatsWidth - StatsOffset, LineOffset);
	CritLine.SetAlpha(50);

	TmpInt = CritLine.Y + ListOffset;

	CritBodyArea = Spawn(class'UIPanel', RightContainer); 
	CritBodyArea.bAnimateOnInit = false;
	CritBodyArea.InitPanel('CritBodyArea').SetPosition(CritLine.X, TmpInt);
	CritBodyArea.width = StatsWidth;
	CritBodyArea.height = 3*LineHeight; 

	CritMask = Spawn(class'UIMask', RightContainer).InitMask(, CritBodyArea);
	CritMask.SetPosition(CritBodyArea.X, CritBodyArea.Y); 
	CritMask.SetSize(StatsWidth, CritBodyArea.height);

	CritStatList = Spawn(class'UIStatList', CritBodyArea);
	CritStatList.bAnimateOnInit = false;
	CritStatList.InitStatList('CritStatList',,,, CritBodyArea.Width, CritBodyArea.Height, 0, 0);

	TmpInt += LineHeight*3 + TableGap;

	CritDamageValue = Spawn(class'UIText', RightContainer);
	CritDamageValue.bAnimateOnInit = false;
	CritDamageValue.InitText('CritDamageValue');
	CritDamageValue.SetWidth(StatsWidth); 
	CritDamageValue.SetPosition(-StatsWidth - StatsOffset, TmpInt);
	CritDamageLabel = Spawn(class'UIScrollingText', RightContainer);
	CritDamageLabel.bAnimateOnInit = false;
	CritDamageLabel.InitScrollingText('CritDamageLabel',, ScrollWidth,-StatsWidth - StatsOffset, TmpInt);
	//CritDamageLabel.InitText('CritDamageLabel');
	//CritDamageLabel.SetWidth(StatsWidth);
	//CritDamageLabel.SetPosition(-StatsWidth - StatsOffset, TmpInt);

	CritDamageLine = Spawn(class'UIPanel', RightContainer);
	CritDamageLine.bAnimateOnInit = false;
	CritDamageLine.InitPanel('CritDamageHeaderLine', class'UIUtilities_Controls'.const.MC_GenericPixel);
	CritDamageLine.SetSize(StatsWidth, 2);
	CritDamageLine.SetPosition(-StatsWidth - StatsOffset, TmpInt + LineOffset);
	CritDamageLine.SetAlpha(50);

	TmpInt = CritDamageLine.Y + ListOffset;

	CritDamageBodyArea = Spawn(class'UIPanel', RightContainer); 
	CritDamageBodyArea.bAnimateOnInit = false;
	CritDamageBodyArea.InitPanel('CritDamageBodyArea').SetPosition(CritDamageLine.X, TmpInt);
	CritDamageBodyArea.width = StatsWidth;
	CritDamageBodyArea.height = LineHeight*2;//height - TmpInt; 

	CritDamageMask = Spawn(class'UIMask', RightContainer).InitMask(, CritDamageBodyArea);
	CritDamageMask.SetPosition(CritDamageBodyArea.X, CritDamageBodyArea.Y); 
	CritDamageMask.SetSize(StatsWidth, CritDamageBodyArea.height);

	CritDamageStatList = Spawn(class'UIStatList', CritDamageBodyArea);
	CritDamageStatList.bAnimateOnInit = false;
	CritDamageStatList.InitStatList('CritDamageStatList',,,, CritDamageBodyArea.Width, CritDamageBodyArea.Height, 0, 0);


	Hide();

	//bLeftWingOpen = true;
	//bRightWingOpen = true;

	return self; 

//return super.InitShotWings(InitName, InitLibID);
}

simulated function RefreshData()
{
	//local StateObjectReference		kEnemyRef;
	local StateObjectReference		Target; 
	local AvailableAction			kAction;
	local AvailableTarget			kTarget;
	local XComGameState_Ability		AbilityState;
	local ShotBreakdown				Breakdown, skBreakdown;
	//local UIHackingBreakdown			kHackingBreakdown;
	//local WeaponDamageValue			MinDamageValue, MaxDamageValue;
	//local int						AllowsShield;
	local int						i, TargetIndex, iShotBreakdown, HitChance, CritChance;//, AimBonus
	local ShotModifierInfo			ShotInfo;
	local bool						bMultiShots;
	local string						TmpStr;
	local X2TargetingMethod			TargetingMethod;
	//local array<UISummary_ItemStat> Stats;
	local DamageBreakdown NormalDamage, CritDamage;
	local EIHackStructs.EIHackBreakdown HackBreakdown;
	local bool bHideLeft, bHideRight;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;

	DISPLAY_MISS_CHANCE = getDISPLAY_MISS_CHANCE();

	kAction = UITacticalHUD(Screen).GetSelectedAction();
	//kEnemyRef = XComPresentationLayer(Movie.Pres).GetTacticalHUD().m_kEnemyTargets.GetSelectedEnemyStateObjectRef();
	History=`XCOMHISTORY;
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(kAction.AbilityObjectRef.ObjectID));


	// Bail ifwe have  nothing to show -------------------------------------
	if(AbilityState == none || kAction.AvailableCode != 'AA_Success')
	{
		HideState();
		return;
	}

	//Mr. Nice: Pointless check, there are no non-trival implementations of GetUISummary_HackingBreakdown() in the game!
	/*
	//Don't show this normal shot breakdown for the hacking action ------------
	AbilityState.GetUISummary_HackingBreakdown( kHackingBreakdown, kEnemyRef.ObjectID );
	if(kHackingBreakdown.bShow)
	{
		HideState();
		return; 
	}
	*/

		// Refresh game data  ------------------------------------------------------

	// ifno targeted icon, we're actually hovering the shot "to hit" info field, 
	// so use the selected enemy for calculation.
	TargetingMethod = UITacticalHUD(screen).GetTargetingMethod();
	if(TargetingMethod != none)
		TargetIndex = TargetingMethod.GetTargetIndex();
	if(kAction.AvailableTargets.Length > 0 && TargetIndex < kAction.AvailableTargets.Length)
	{
		kTarget = kAction.AvailableTargets[TargetIndex];
	}

	Target = kTarget.PrimaryTarget; 

	if(class'HackCalcLib'.static.GetHackBreakdown(AbilityState, Target, HackBreakDown))
	{
		UITacticalHUD(screen).m_kShotHUD.MC.FunctionVoid( "ShowHit" );
		LeftWingButton.Show();
		if(bLeftWingWasOpen && !bLeftWingOpen)
		{
			OnWingButtonClicked(LeftWingButton);
			bLeftWingWasOpen = false;
		}
		UITacticalHUD(screen).m_kShotHUD.MC.FunctionVoid( "ShowCrit" );
		RightWingButton.Show();
		if(bRightWingWasOpen && !bRightWingOpen)
		{
			OnWingButtonClicked(RightWingButton);
			bRightWingWasOpen = false;
		}


		HitLabelsc.SetHtmlText(class'UIUtilities_Text'.static.StyleText(HackBreakDown.RewardList[1].RewardTemplate.GetFriendlyName(), eUITextStyle_Tooltip_StatLabel));
		HitPercent.SetHtmlText(class'UIUtilities_Text'.static.StyleText(HackBreakDown.RewardList[1].Chance $ "%", eUITextStyle_Tooltip_StatValue));
		HitStatList.RefreshData(ProcessHackBreakdown(HackBreakdown, 1));

		DamageLabelsc.SetHtmlText(class'UIUtilities_Text'.static.StyleText(HackBreakdown.RatioLabel, eUITextStyle_Tooltip_StatLabel));
		DamagePercent.SetHtmlText(class'UIUtilities_Text'.static.StyleText(HackBreakdown.Ratio, eUITextStyle_Tooltip_StatValue));
		DamageStatList.RefreshData(HackBreakdown.LStats);

		CritLabelsc.SetHtmlText(class'UIUtilities_Text'.static.StyleText(HackBreakDown.RewardList[2].RewardTemplate.GetFriendlyName(), eUITextStyle_Tooltip_StatLabel));
		CritPercent.SetHtmlText(class'UIUtilities_Text'.static.StyleText(HackBreakDown.RewardList[2].Chance $ "%", eUITextStyle_Tooltip_StatValue));
		CritStatList.RefreshData(ProcessHackBreakdown(HackBreakdown, 2));

		CritDamageLabel.SetHtmlText(class'UIUtilities_Text'.static.StyleText(HackBreakdown.TechLabel, eUITextStyle_Tooltip_StatLabel));
		TmpStr = `RANGESTRING(CritDamage.Min, CritDamage.Max);
		CritDamageValue.SetHtmlText(class'UIUtilities_Text'.static.StyleText(HackBreakdown.TechValue, eUITextStyle_Tooltip_StatValue));
		CritDamageStatList.RefreshData(HackBreakdown.RStats);
		return;
	}
	
	iShotBreakdown = class'HitCalcLib'.static.GetShotBreakdownDiffAdjust(AbilityState, kTarget, Breakdown);
	HitChance = (Breakdown.bIsMultishot) ? Breakdown.MultiShotHitChance : Breakdown.FinalHitChance;
	if(AbilityState.GetMyTemplateName()=='SkirmisherVengeance'
		|| AbilityState.GetMyTemplateName()=='Justice')
	{
		UnitState=XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
		AbilityState=XComGameState_Ability(History.GetGameStateForObjectID(UnitState.FindAbility('SkirmisherPostAbilityMelee').ObjectID));
		class'HitCalcLib'.static.GetShotBreakdownDiffAdjust(AbilityState, kTarget, skBreakdown);
		for(i=Breakdown.Modifiers.Length-1; i>=0; i--)
			if (Breakdown.Modifiers[i].ModType==eHit_Crit)
				Breakdown.Modifiers.Remove(i, 1);
		for(i=0; i<skBreakdown.Modifiers.Length; i++)
			if (skBreakdown.Modifiers[i].ModType==eHit_Crit)
				Breakdown.Modifiers.AddItem(skBreakdown.Modifiers[i]);
		Breakdown.ResultTable[eHit_Crit]=skBreakdown.ResultTable[eHit_Crit];
	}
	CritChance=Breakdown.ResultTable[eHit_Crit];
	
	class'DamagePreviewLib'.static.GetDamagePreview(AbilityState, kTarget.PrimaryTarget, NormalDamage, CritDamage);

	// Hide ifrequested -------------------------------------------------------
	bHideLeft=Breakdown.HideShotBreakdown &&
		!( HIT_SHOW_NonTRIVIAL && HitChance>0 && HitChance<100 && Breakdown.Modifiers.Length!=0 //If there's no Modifiers(aka, stuff to show in the list!), then the HUD will already show all we know
		|| DAMAGE_SHOW_NonTRIVIAL && NormalDamage.InfoList.Length>1 ); //Larger than one since one entry means just the baseweapon/ability damage, to not interesting!
	bHideRight=CritChance<0
		|| (Breakdown.HideShotBreakdown && !(CRIT_SHOW_NonTRIVIAL && (CritDamage.Min>0 || CritDamage.Max>0) && (CritDamage.InfoList.Length>1 || CritChance>0)) )
		|| (!Breakdown.HideShotBreakdown && CRIT_HIDE_TRIVIAL && CritDamage.InfoList.Length==0 && CritChance<=0);
	if (bHideLeft && bHideRight)
	{
		HideState();
		return;
	}

	// Gameplay special hackery for multi-shot display. -----------------------
	if (bHideLeft) HideLeft();
	else
	{
		UITacticalHUD(screen).m_kShotHUD.MC.FunctionVoid( "ShowHit" );
		LeftWingButton.Show();
		if(bLeftWingWasOpen && !bLeftWingOpen)
		{
			OnWingButtonClicked(LeftWingButton);
			bLeftWingWasOpen = false;
		}

		if(iShotBreakdown != Breakdown.FinalHitChance)
		{
			bMultiShots = true;
			ShotInfo.ModType = eHit_Success;
			ShotInfo.Value = iShotBreakdown - Breakdown.FinalHitChance;
			ShotInfo.Reason = class'XLocalizedData'.default.MultiShotChance;
			Breakdown.Modifiers.AddItem(ShotInfo);
			Breakdown.FinalHitChance = iShotBreakdown;
		}

		// Now update the UI ------------------------------------------------------
		Breakdown.Modifiers.Sort(SortModifiers);

		if(bMultiShots)
			HitLabelsc.SetHtmlText(class'UIUtilities_Text'.static.StyleText(class'XLocalizedData'.default.MultiHitLabel, eUITextStyle_Tooltip_StatLabel));
		else if(DISPLAY_MISS_CHANCE)
			HitLabelsc.SetHtmlText(class'UIUtilities_Text'.static.StyleText(class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[eHit_Miss], eUITextStyle_Tooltip_StatLabel));
		else
			HitLabelsc.SetHtmlText(class'UIUtilities_Text'.static.StyleText(class'XLocalizedData'.default.HitLabel, eUITextStyle_Tooltip_StatLabel));
	
		if(DISPLAY_MISS_CHANCE)
			TmpStr = (100 - clamp(HitChance, 0, 100)) $ "%";
		else
			TmpStr = HitChance $ "%";

		HitPercent.SetHtmlText(class'UIUtilities_Text'.static.StyleText(TmpStr, eUITextStyle_Tooltip_StatValue));
		HitStatList.RefreshData(ProcessHitCritBreakdown(Breakdown, eHit_Success));

		DamageLabelsc.SetHtmlText(class'UIUtilities_Text'.static.StyleText(class'XLocalizedData'.default.DamageLabel, eUITextStyle_Tooltip_StatLabel));
		TmpStr = `RANGESTRING(NormalDamage.Min, NormalDamage.Max);
		DamagePercent.SetHtmlText(class'UIUtilities_Text'.static.StyleText(TmpStr, eUITextStyle_Tooltip_StatValue));
		DamageStatList.RefreshData(ProcessNeoDamageBreakdown(NormalDamage, true));
	}

	if (bHideRight) HideRight();
	else
	{
		UITacticalHUD(screen).m_kShotHUD.MC.FunctionVoid( "ShowCrit" );

		RightWingButton.Show();

		if(bRightWingWasOpen && !bRightWingOpen)
		{
			OnWingButtonClicked(RightWingButton);
			bRightWingWasOpen = false;
		}

		CritLabelsc.SetHtmlText(class'UIUtilities_Text'.static.StyleText(class'XLocalizedData'.default.CritLabel, eUITextStyle_Tooltip_StatLabel));
		TmpStr = string(CritChance) $ "%";
		CritPercent.SetHtmlText(class'UIUtilities_Text'.static.StyleText(TmpStr, eUITextStyle_Tooltip_StatValue));
		CritStatList.RefreshData(ProcessHitCritBreakdown(Breakdown, eHit_Crit));

		CritDamageLabel.SetHtmlText(class'UIUtilities_Text'.static.StyleText(CRIT_DAMAGE_LABEL, eUITextStyle_Tooltip_StatLabel));
		TmpStr = `RANGESTRING(CritDamage.Min, CritDamage.Max);
		CritDamageValue.SetHtmlText(class'UIUtilities_Text'.static.StyleText("+" $ TmpStr, eUITextStyle_Tooltip_StatValue));
		CritDamageStatList.RefreshData(ProcessNeoDamageBreakdown(CritDamage));
	}
}

simulated function Show()
{
	local int ScrollHeight;

	super.Show();

	if(bIsVisible)
	{
		CritDamageBodyArea.ClearScroll();
		CritDamageBodyArea.MC.SetNum("_alpha", 100);
	
		//This will reset the scrolling upon showing this tooltip.
		ScrollHeight = (CritDamageStatList.height > CritDamageBodyArea.height ) ? CritDamageStatList.height : CritDamageBodyArea.height; 
		CritDamageBodyArea.AnimateScroll(ScrollHeight, CritDamageBodyArea.height);
	}
}

simulated function HideState()
{
	Hide();
	HideLeft();
	HideRight();
}

simulated function HideLeft()
{
		if(bLeftWingOpen)
		{
			bLeftWingWasOpen = true;
			OnWingButtonClicked(LeftWingButton);
		}
		LeftWingButton.Hide();	
}

simulated function HideRight()
{
		if(bRightWingOpen)
		{
			bRightWingWasOpen = true;
			OnWingButtonClicked(RightWingButton);
		}
		RightWingButton.Hide();	
}

simulated function array<UISummary_ItemStat> ProcessHackBreakdown(EIHackBreakdown HackBreakdown, int i)
{
	local array<UISummary_ItemStat> Stats;
	local HackRewardInfo RewardItem;
	local UISummary_ItemStat Item, EmptyItem;

	RewardItem=HackBreakdown.RewardList[i];

	Item.Label="Base Difficulty";
	Item.Value=(100-RewardItem.RewardTemplate.MinHackSuccess) $ "%";
	Stats.AddItem(Item);
	Item=EmptyItem;

	if (RewardItem.RewardTemplate.HackSuccessVariance!=0)
	{
		Item.Label="Random Variance";
		Item.Value=(-RewardItem.RollMod) $ "%";
		if (RewardItem.RollMod>0)
		{
			Item.LabelState=eUIState_Bad;
			Item.ValueState=eUIState_Bad;
		}
		else if (RewardItem.RollMod<0)
		{
			Item.LabelState=eUIState_Good;
			Item.ValueState=eUIState_Good;
		}
		Stats.AddItem(Item);
		Item=EmptyItem;
	}

	Item.Label="&#215;" $ HackBreakdown.Ratio @ MULTIPLIER;
	if(RewardItem.Chance-100+RewardItem.RollMod+RewardItem.RewardTemplate.MinHackSuccess>0)
	{
		Item.Value = "+";
		Item.ValueState=eUIState_Good;
		Item.LabelState=eUIState_Good;
		
	}
	else
	{
		Item.ValueState=eUIState_Bad;
		Item.LabelState=eUIState_Bad;
	}
	Item.Value $= (RewardItem.Chance-100+RewardItem.RollMod+RewardItem.RewardTemplate.MinHackSuccess) $ "%";
	Stats.AddItem(Item);

	return Stats;
}

simulated function array<UISummary_ItemStat> ProcessNeoDamageBreakdown(const out DamageBreakdown DamageValue, optional bool bNoSignFirst=false)
{
	local array<UISummary_ItemStat> Stats;
	local UISummary_ItemStat Item;
	local int i;
	local string Prefix;

	for( i = 0; i < DamageValue.InfoList.Length; i++ )
	{
		if(DamageValue.InfoList[i].Min>=0)
		{
			Item.ValueState=eUIState_Good;
			Item.LabelState=eUIState_Good;
			if(!bNoSignFirst) prefix="+";
		}
		else
		{
			Item.ValueState=eUIState_Bad;
			Item.LabelState=eUIState_Bad;
			if(!bNoSignFirst) prefix="";
		}
		Item.Label=DamageValue.InfoList[i].Label;
		Item.Value= prefix $ `RANGESTRING( DamageValue.InfoList[i].Min, DamageValue.InfoList[i].Max);
		Stats.additem(Item);
		bNoSignFirst=false;
	}
	return Stats;
}

simulated function array<UISummary_ItemStat> ProcessHitCritBreakdown(ShotBreakdown Breakdown, int eHitType)
{
	local array<UISummary_ItemStat> Stats; 
	local UISummary_ItemStat Item; 
	local int i;
	local string strPrefix; 
	local EUIState eState_Negative, eState_Positive;

	if(DISPLAY_MISS_CHANCE)
	{
		eState_Negative=eUIState_Good;
		eState_Positive=eUIState_Bad;
	}
	else
	{
		eState_Negative=eUIState_Bad;
		eState_Positive=eUIState_Good;
	}

	for( i=0; i < Breakdown.Modifiers.Length; i++)
	{	
		
		if( Breakdown.Modifiers[i].ModType == eHitType )
		{
			if(DISPLAY_MISS_CHANCE)
				Breakdown.Modifiers[i].Value = -Breakdown.Modifiers[i].Value;

			if( Breakdown.Modifiers[i].Value < 0 )
			{
				Item.LabelState = eState_Negative;
				Item.ValueState = eState_Negative;
				strPrefix = "";
			}
			else
			{
				Item.LabelState = eState_Positive;
				Item.ValueState = eState_Positive;
				strPrefix = "+";
			}

			Item.Label = Breakdown.Modifiers[i].Reason; 
			Item.Value = strPrefix $ string(Breakdown.Modifiers[i].Value) $ "%";
			Stats.AddItem(Item);
		}
	}

	if( eHitType == eHit_Crit && Stats.length == 1 && Breakdown.ResultTable[eHit_Crit] == 0 )
		Stats.length = 0; 

	return Stats; 
}

function bool getDISPLAY_MISS_CHANCE()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.DISPLAY_MISS_CHANCE, class'ExtendedInformationRedux2_MCMScreen'.default.DISPLAY_MISS_CHANCE);
}


defaultproperties
{
	HIT_SHOW_NonTRIVIAL=true;
	DAMAGE_SHOW_NonTRIVIAL=true;
	CRIT_SHOW_NonTRIVIAL=true;
	CRIT_HIDE_TRIVIAL=true;
}
