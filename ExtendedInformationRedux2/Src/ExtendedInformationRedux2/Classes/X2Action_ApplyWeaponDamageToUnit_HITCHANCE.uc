//-----------------------------------------------------------
//	Class:	X2Action_ApplyWeaponDamageToUnit_HITCHANCE
//	Author: Mr.Nice / Sebkulu
//	
//-----------------------------------------------------------
// Used by the visualizer system to control a Visualization Actor
//-----------------------------------------------------------

class X2Action_ApplyWeaponDamageToUnit_HITCHANCE extends X2Action_ApplyWeaponDamageToUnit;

`include(ExtendedInformationRedux2\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)
`include(ExtendedInformationRedux2\Src\ExtendedInformationRedux2\LangFallBack.uci)

var bool SHOW_TEMPLAR_MSG;

var localized string GUARANTEED_HIT;
var localized string FAILED_TEXT;

// Short versions
var localized string SHORT_GUARANTEED_HIT;
var localized string SHORT_HIT_CHANCE;
var localized string SHORT_MISS_CHANCE;
var localized string SHORT_CRIT_CHANCE;
var localized string SHORT_DODGE_CHANCE;
var localized string SHORT_COUNTER_CHANCE;

function Init()
{
	Super.Init();
	if(UnitState==none)
	{
		UnitState = XComGameState_Unit(AbilityContext.GetLastStateInInterruptChain().GetGameStateForObjectID(Metadata.StateObject_NewState.ObjectID));
		if (UnitState == None) //This can occur for abilities which were interrupted but never resumed, e.g. because the shooter was killed.
			UnitState = XComGameState_Unit(Metadata.StateObject_NewState); //Will typically be the same as the OldState in this case.
	}
}

simulated function bool getHIT_CHANCE_ENABLED()
{	
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.HIT_CHANCE_ENABLED, class'ExtendedInformationRedux2_MCMScreen'.default.HIT_CHANCE_ENABLED);
}

simulated function bool getVERBOSE_TEXT()
{	
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.VERBOSE_TEXT, class'ExtendedInformationRedux2_MCMScreen'.default.VERBOSE_TEXT);
}

simulated function bool getDISPLAY_MISS_CHANCE()
{	
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.DISPLAY_MISS_CHANCE, class'ExtendedInformationRedux2_MCMScreen'.default.DISPLAY_MISS_CHANCE);
}

simulated function bool getSHOW_TEMPLAR_MSG()
{	
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.SHOW_TEMPLAR_MSG, class'ExtendedInformationRedux2_MCMScreen'.default.SHOW_TEMPLAR_MSG);
}

simulated function bool getSHOW_GUARANTEED_HIT()
{	
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.SHOW_GUARANTEED_HIT, class'ExtendedInformationRedux2_MCMScreen'.default.SHOW_GUARANTEED_HIT);
}

`MCM_CH_VersionChecker(class'MCM_Defaults'.default.VERSION, class'ExtendedInformationRedux2_MCMScreen'.default.CONFIG_VERSION)

simulated state Executing
{
	simulated function ShowAttackMessages()
	{
		Super.ShowAttackMessages();
		return;
	}
	
	simulated function ShowHPDamageMessage(string UIMessage, optional string CritMessage, optional EWidgetColor DisplayColor = eColor_Bad)
	{
		local string HitIcon;
		local XComPresentationLayerBase kPres;

		// This is done to re-create a Crit-Like flyover message to be displayed just under the Crit Flyover containing damages, and the Crit Label
		
		kPres = XComPlayerController(class'Engine'.static.GetCurrentWorldInfo().GetALocalPlayerController()).Pres;
		UIMessage $= GetChanceString();
		if (CritMessage != "")
		{
			HitIcon = "img:///UILibrary_ExtendedInformationRedux2.HitIcon32";
			// Soooo Grimy's right, had to do Shenanigans until Firaxis fixes their shit on the damn Flash Component that handles Crit Flyovers behavior.
			// Right now the Flash makes it so when Crit Flyover appears, then Crit Label stays for 1.3s before disappearing (with its panel beneath it)
			// but then another panel beneath text may not appear properly although text is being displayed...
			class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), CritMessage, UnitPawn.m_eTeamVisibilityFlags, , m_iDamage, 0, CritMessage, DamageTypeName == 'Psi'? eWDT_Psi : -1, eColor_Yellow);
			kPres.GetWorldMessenger().Message(UIMessage, m_vHitLocation, Unit.GetVisualizedStateReference(), eColor_Yellow, , class'UIWorldMessageMgr'.default.DAMAGE_DISPLAY_DEFAULT_ID, UnitPawn.m_eTeamVisibilityFlags, class'UIWorldMessageMgr'.default.DAMAGE_DISPLAY_DEFAULT_USE_SCREEN_LOC_PARAM, class'UIWorldMessageMgr'.default.DAMAGE_DISPLAY_DEFAULT_SCREEN_LOC, , , HitIcon, , , , , DamageTypeName == 'Psi'? eWDT_Psi : -1);
		}
		else
		{
			class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), UIMessage, UnitPawn.m_eTeamVisibilityFlags, , m_iDamage, 0, CritMessage, DamageTypeName == 'Psi'? eWDT_Psi : -1, DisplayColor);
		}
	}

	simulated function ShowShieldedMessage(EWidgetColor DisplayColor)
	{
		if (m_iDamage > 0) Super.ShowShieldedMessage(DisplayColor);
		else class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), class'XGLocalizedData'.default.ShieldedMessage $ GetChanceString(), UnitPawn.m_eTeamVisibilityFlags, , m_iShielded,,,, DisplayColor);
	}

	simulated function ShowMissMessage(EWidgetColor DisplayColor)
	{	
		local String MissedMessage;

		MissedMessage = OriginatingEffect.OverrideMissMessage;
		if( MissedMessage == "" )
		{
			MissedMessage = class'XLocalizedData'.default.MissedMessage;
		}

		if (m_iDamage > 0)
			class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), (MissedMessage $ GetChanceString()), UnitPawn.m_eTeamVisibilityFlags, , m_iDamage,,,, DisplayColor);
		else if (!OriginatingEffect.IsA('X2Effect_Persistent')) //Persistent effects that are failing to cause damage are not noteworthy.
			class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), (MissedMessage $ GetChanceString()),,,,,,, DisplayColor);
	}
	
	simulated function ShowCounterattackMessage(EWidgetColor DisplayColor)
	{
		class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), class'XLocalizedData'.default.CounterattackMessage $ GetChanceString(),,,,,,, DisplayColor);
	}

	simulated function ShowLightningReflexesMessage(EWidgetColor DisplayColor)
	{
		local XComGameState_HeadquartersXCom XComHQ;
		local XComGameStateHistory History;
		local string DisplayMessageString;

		History = `XCOMHISTORY;
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		if( XComHQ.TacticalGameplayTags.Find('DarkEvent_LightningReflexes') != INDEX_NONE )
		{
			DisplayMessageString = class'XLocalizedData'.default.DarkEvent_LightningReflexesMessage;
		}
		else
		{
			DisplayMessageString = class'XLocalizedData'.default.LightningReflexesMessage;
		}
		if (getSHOW_TEMPLAR_MSG()) { DisplayMessageString = DisplayMessageString $ GetChanceString(); }
		class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), DisplayMessageString,,,,,,, DisplayColor);
	}

	simulated function ShowUntouchableMessage(EWidgetColor DisplayColor)
	{
		local string DisplayMessageString;
		DisplayMessageString=class'XLocalizedData'.default.UntouchableMessage;
		if (getSHOW_TEMPLAR_MSG()) { DisplayMessageString = DisplayMessageString $ GetChanceString(); }
		class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), DisplayMessageString,,,,,,, DisplayColor);
	}

	simulated function ShowParryMessage(EWidgetColor DisplayColor)
	{
		local string ParryMessage;

		ParryMessage = class'XLocalizedData'.default.ParryMessage;
		if (getSHOW_TEMPLAR_MSG()) { ParryMessage = ParryMessage $ GetChanceString(); }
		class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), ParryMessage,,,,,,, DisplayColor);
	}

	simulated function ShowDeflectMessage(EWidgetColor DisplayColor)
	{
		local string DeflectMessage;

		DeflectMessage = class'XLocalizedData'.default.DeflectMessage;
		if (getSHOW_TEMPLAR_MSG()) { DeflectMessage = DeflectMessage $ GetChanceString(); }
		class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), DeflectMessage,,,,,,, DisplayColor);
	}

	simulated function ShowReflectMessage(EWidgetColor DisplayColor)
	{
		local string ReflectMessage;

		ReflectMessage = class'XLocalizedData'.default.ReflectMessage;
		if (getSHOW_TEMPLAR_MSG()) { ReflectMessage = ReflectMessage $ GetChanceString(); }
		class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), ReflectMessage,,,,,,, DisplayColor);
	}

	simulated function ShowFreeKillMessage(name AbilityName, EWidgetColor DisplayColor)
	{
		local X2AbilityTemplate Template;
		local string KillMessage;

		KillMessage = class'XLocalizedData'.default.FreeKillMessage;

		if (AbilityName != '')
		{
			Template = class'XComGameState_Ability'.static.GetMyTemplateManager( ).FindAbilityTemplate( AbilityName );
			if ((Template != none) && (Template.LocFlyOverText != ""))
			{
				KillMessage = Template.LocFlyOverText;
			}
		}

		class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), (KillMessage $ GetChanceString()), , , , , , eWDT_Repeater, DisplayColor);
	}

	// Hit Chance mod change
	function string GetChanceString()
	{
		local array<string> Elements;
		local string outString, sgHit, sHit, sMiss, sCrit, sGraze, sCounter;

		local XComGameState_Ability AbilityState;
		local AvailableTarget kTarget;
		local int hitChance, critChance, grazeChance;
		local ShotBreakdown TargetBreakdown;
		local X2AbilityToHitCalc_StandardAim StandardHitCalc;
		local XComGameState_Unit TargetUnitState;
		local UnitValue CounterattackCheck;
		local X2GameRulesetEventObserverInterface Observer;

		if (!getHIT_CHANCE_ENABLED() || IsPersistent())
			return "";

		Observer = `GAMERULES.GetEventObserverOfType(class'X2TacticalGameRuleset_BreakdownObserver');
		if (X2TacticalGameRuleset_BreakdownObserver(Observer).FindBreakdown(AbilityContext, Metadata.StateObject_OldState, TargetBreakdown) == -1)
		{
			return "";
		}

		if (getVERBOSE_TEXT())
		{
			sgHit=GUARANTEED_HIT;
			sHit=class'UITacticalHUD_ShotHUD'.default.m_sShotChanceLabel;
			sMiss=Caps(class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[eHit_Miss]);
			sCrit=class'UITacticalHUD_ShotHUD'.default.m_sCritChanceLabel;
			sGraze=Caps(class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[eHit_Graze]);
			sCounter=`LOCFALLBACK(ShortCounterAttack, Caps(class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[eHit_CounterAttack]));
		}
		else
		{
			sgHit=SHORT_GUARANTEED_HIT;
			sHit=SHORT_HIT_CHANCE;
			sMiss=SHORT_MISS_CHANCE;
			sCrit=SHORT_CRIT_CHANCE;
			sGraze=SHORT_DODGE_CHANCE;
			sCounter=SHORT_COUNTER_CHANCE;
		}

		hitChance = Clamp(TargetBreakdown.FinalHitChance, 0, 100);// 500);
		critChance =  Clamp(TargetBreakdown.ResultTable[eHit_Crit], 0, 100);// 500);
		grazeChance = Clamp(TargetBreakdown.ResultTable[eHit_Graze], 0, 100);// 500);

		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
		StandardHitCalc=X2AbilityToHitCalc_StandardAim(AbilityState.GetMyTemplate().AbilityToHitCalc);
		if (StandardHitCalc!=none && StandardHitCalc.bMeleeAttack)
		{
			TargetUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kTarget.PrimaryTarget.ObjectID));
			if (TargetUnitState!=none && !TargetUnitState.IsImpaired()
				&& TargetUnitState.GetUnitValue(class'X2Ability'.default.CounterattackDodgeEffectName, CounterattackCheck)
				&& CounterattackCheck.fValue == class'X2Ability'.default.CounterattackDodgeUnitValue)
			{
				if (StandardHitCalc.bGuaranteedHit)
					grazeChance+=max(0,(hitChance-grazeChance))*class'X2Ability_Muton'.default.COUNTERATTACK_DODGE_AMOUNT/100;
				grazeChance+=100-hitChance;
				sGraze=sCounter;
			}
		}

		//Elements.AddItem("Context: " $ XComGameStateContext_Ability(StateChangeContext).ResultContext.CalculatedHitChance $ "%");
		if (IsGuaranteedHit())
		{
			if (getSHOW_GUARANTEED_HIT()) Elements.AddItem(sgHit);
		}
		else if (getDISPLAY_MISS_CHANCE()) Elements.AddItem(sMiss $ ": " $ (100-hitChance)$ "%");
		else Elements.AddItem(sHit $ ": " $ hitChance $ "%");

		if (critChance>0) Elements.AddItem(sCrit $ ": " $ critChance $ "%");
		if (grazeChance>0) Elements.AddItem(sGraze $ ": " $ GrazeChance $ "%");
		
		//foreach Elements(sHit) `log(sHit);

		JoinArray(Elements, OutString, " - ");
		if(OutString!="") OutString= " - " $ OutString;
		return OutString;
	}

	simulated function bool IsPersistent()
	{
		if (X2Effect_Persistent(DamageEffect) != none)
			return true;

		if (X2Effect_Persistent(OriginatingEffect) != None)
			return true;

		if (X2Effect_Persistent(AncestorEffect) != None)
			return true;

		return false;
	}

	simulated function bool IsGuaranteedHit()
	{
		if ( X2AbilityToHitCalc_DeadEye(AbilityTemplate.AbilityToHitCalc) != None)	return true;
		if ( X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc).bGuaranteedHit) return true;		
		if ( X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc).bIndirectFire) return true;		
		if (FallingContext != none) return true;
		if (AreaDamageContext != None) return true;
		return false;
	}
}