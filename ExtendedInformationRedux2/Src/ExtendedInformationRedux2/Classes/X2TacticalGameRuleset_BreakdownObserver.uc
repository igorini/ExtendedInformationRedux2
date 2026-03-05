//-----------------------------------------------------------
//	Class:	X2TacticalGameRuleset_BreakdownObserver
//	Author: MrNice
//	
//-----------------------------------------------------------


class X2TacticalGameRuleset_BreakdownObserver extends Object implements(X2GameRulesetEventObserverInterface);;

/// <summary>
/// Called immediately prior to the creation of a new game state via SubmitGameStateContext. New game states can be submitted
/// prior to a game state being created with this context
/// </summary>
/// <param name="NewGameState">The state to examine</param>

struct BreakdownHistory
{
	var int HistoryIndex;
	var ShotBreakdown PrimaryBreakdown;
	var array<ShotBreakdown> MultiTargetBreakdown;
};

var array<BreakdownHistory> Breakdowns;

event PreBuildGameStateFromContext(XComGameStateContext NewGameStateContext)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local X2AbilityToHitCalc HitCalc;
	local AvailableTarget kTarget;
	local BreakdownHistory BreakdownEntry;
	local ShotBreakdown kBreakdown;
	local int i;

	AbilityContext = XComGameStateContext_Ability(NewGameStateContext);
	if (AbilityContext == none) return;

	History = `XCOMHISTORY;
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	HitCalc = AbilityState.GetMyTemplate().AbilityToHitCalc;
	if(HitCalc == none || X2AbilityToHitCalc_DeadEye(HitCalc) != none) return;

	BreakdownEntry.HistoryIndex = History.GetCurrentHistoryIndex();

	kTarget.PrimaryTarget = AbilityContext.InputContext.PrimaryTarget;
	class'HitCalcLib'.static.GetShotBreakdownDiffAdjust(AbilityState, kTarget, BreakdownEntry.PrimaryBreakdown);
	for (i = 0; i < AbilityContext.InputContext.MultiTargets.Length; i++)
	{
		kTarget.PrimaryTarget = AbilityContext.InputContext.MultiTargets[i];
		class'HitCalcLib'.static.GetShotBreakdownDiffAdjust(AbilityState, kTarget, kBreakdown);
		BreakdownEntry.MultiTargetBreakdown.AddItem(kBreakdown);
	}
	Breakdowns.AddItem(BreakdownEntry);
	`log(`showvar(Breakdowns.Length));
}

/// <summary>
/// This event is issued from within the context method ContextBuildGameState
/// </summary>
/// <param name="NewGameState">The state to examine</param>
event InterruptGameState(XComGameState NewGameState);

/// <summary>
/// Called immediately after the creation of a new game state via SubmitGameStateContext. 
/// Note that at this point, the state has already been committed to the history
/// </summary>
/// <param name="NewGameState">The state to examine</param>
event PostBuildGameState(XComGameState NewGameState);

/// <summary>
/// Allows the observer class to set up any internal state it needs to when it is created
/// </summary>
event Initialize();

/// <summary>
/// Event observers may use this to cache information about the state objects they need to operate on
/// </summary>
event CacheGameStateInformation();

function int FindBreakdown(XComGameStateContext_Ability Context, XComGameState_BaseObject TargetState,  optional out ShotBreakdown Breakdown)
{
	local int BreakdownIndex, MultiIndex;

	BreakdownIndex = Breakdowns.Find('HistoryIndex', Context.GetFirstStateInInterruptChain().HistoryIndex - 1);
	if (BreakdownIndex == INDEX_NONE) return -1;

	if (Context.InputContext.PrimaryTarget.ObjectID == TargetState.ObjectID)
	{
		Breakdown = Breakdowns[BreakdownIndex].PrimaryBreakdown;
	}
	else 
	{
		MultiIndex = Context.InputContext.MultiTargets.Find('ObjectID', TargetState.ObjectID);
		if (MultiIndex == INDEX_NONE) return -1;
		Breakdown = Breakdowns[BreakdownIndex].MultiTargetBreakdown[MultiIndex];
	}
	return Breakdown.FinalHitChance;
}
