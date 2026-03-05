//-----------------------------------------------------------
//	Class:	HitChanceBuildVisualization
//	Author: Mr.Nice / Sebkulu
//	
//-----------------------------------------------------------


class HitChanceBuildVisualization extends Object;

`include(ExtendedInformationRedux2\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

`define GETHITTEXT ( getDISPLAY_MISS_CHANCE() ? (getVERBOSE_TEXT() ? Caps(class'X2TacticalGameRulesetDataStructures'.default.m_aAbilityHitResultStrings[eHit_Miss]) : class'X2Action_ApplyWeaponDamageToUnit_HITCHANCE'.default.SHORT_MISS_CHANCE) \\
	: (getVERBOSE_TEXT() ? class'UITacticalHUD_ShotHUD'.default.m_sShotChanceLabel : class'X2Action_ApplyWeaponDamageToUnit_HITCHANCE'.default.SHORT_HIT_CHANCE) )


// Localized Array(s) required
var bool		DISPLAY_MISS_CHANCE;
var bool		HIT_CHANCE_ENABLED;
var bool		VERBOSE_TEXT;

var delegate<X2AbilityTemplate.BuildVisualizationDelegate> OrigBuildVisualizationFn;
//var localized string HIT_CHANCE_LABEL;

var array<string> FlyoverMessages;

static function HitChanceBuildVisualization CreateFlyoverVisualization(optional delegate<X2AbilityTemplate.BuildVisualizationDelegate> _OrigBuildVisualizationFn)
{
	local HitChanceBuildVisualization NewVis;

	NewVis=new default.Class;
	if (_OrigBuildVisualizationFn==none)
		NewVis.OrigBuildVisualizationFn=class'x2ability'.static.TypicalAbility_BuildVisualization;
	else
		NewVis.OrigBuildVisualizationFn=_OrigBuildVisualizationFn;

	return NewVis;
}

function BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateVisualizationMgr VisMgr;
	local X2Action						Action;
	local Array<X2Action>				arrActions;

	local XComGameStateContext_Ability	Context;

	local X2TacticalGameRuleset_BreakdownObserver BreakdownObserver;
	local X2GameRulesetEventObserverInterface Observer;
	local int							hitChance;
	
	local string						hittext;

	//Let normal build vis do it's stuff.
	OrigBuildVisualizationFn(VisualizeGameState);


	// Here we're gonna lookup into a struct array to see if flyover message matches one of our already defined Message for targeted Ability
	if(getHIT_CHANCE_ENABLED())
	{
		//Fill in those context/state variables
		Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
		Observer = `GAMERULES.GetEventObserverOfType(class'X2TacticalGameRuleset_BreakdownObserver');
		BreakdownObserver = X2TacticalGameRuleset_BreakdownObserver(Observer);

		VisMgr = `XCOMVISUALIZATIONMGR;
		VisMgr.GetNodesOfType(VisMgr.BuildVisTree, class'X2Action_PlaySoundAndFlyOver', arrActions);

		hittext= `GETHITTEXT;

		//look through those actions for the expected flyoverstrings;
		foreach arrActions(action)
		{
			if (FlyoverMessages.Find(X2Action_PlaySoundAndFlyOver(Action).FlyOverMessage) != INDEX_NONE)
			{
				HitChance = BreakdownObserver.FindBreakdown(Context, Action.Metadata.StateObject_OldState);
				if (HitChance != -1)
				{
					if(getDISPLAY_MISS_CHANCE())
					{
						HitChance = 100 - HitChance;
					}
					X2Action_PlaySoundAndFlyOver(Action).FlyOverMessage @= "-" @ HitText $ ":" @ HitChance $ "%";
				}
			}
		}
	}
}

`MCM_CH_VersionChecker(class'MCM_Defaults'.default.VERSION, class'ExtendedInformationRedux2_MCMScreen'.default.CONFIG_VERSION)

simulated function bool getHIT_CHANCE_ENABLED()
{	
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.HIT_CHANCE_ENABLED, class'ExtendedInformationRedux2_MCMScreen'.default.HIT_CHANCE_ENABLED);
}

simulated function bool getDISPLAY_MISS_CHANCE()
{	
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.DISPLAY_MISS_CHANCE, class'ExtendedInformationRedux2_MCMScreen'.default.DISPLAY_MISS_CHANCE);
}

simulated function bool getVERBOSE_TEXT()
{	
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.VERBOSE_TEXT, class'ExtendedInformationRedux2_MCMScreen'.default.VERBOSE_TEXT);
}

