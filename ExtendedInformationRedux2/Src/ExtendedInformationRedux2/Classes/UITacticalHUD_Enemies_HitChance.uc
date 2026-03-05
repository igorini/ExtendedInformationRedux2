//-----------------------------------------------------------
//	Class:	UITacticalHUD_Enemies_HitChance
//	Author: tjnome / Mr.Nice / Sebkulu
//	
//-----------------------------------------------------------

class UITacticalHUD_Enemies_HitChance extends UITacticalHUD_Enemies;

`include(ExtendedInformationRedux2\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

var bool TH_AIM_ASSIST;
var bool DISPLAY_MISS_CHANCE;

simulated function int GetHitChanceForObjectRef(StateObjectReference TargetRef)
{
	local AvailableAction Action;
	local AvailableTarget			kTarget;
	local ShotBreakdown Breakdown;
	local X2TargetingMethod TargetingMethod;
	local XComGameState_Ability AbilityState;
	local int HitChance;

	//If a targeting action is active and we're hoving over the enemy that matches this action, then use action percentage for the hover  
	TargetingMethod = XComPresentationLayer(screen.Owner).GetTacticalHUD().GetTargetingMethod();

	if(TargetingMethod != none && TargetingMethod.GetTargetedObjectID() == TargetRef.ObjectID)
	{
		AbilityState = TargetingMethod.Ability;
	}
	else
	{			
		AbilityState = XComPresentationLayer(Movie.Pres).GetTacticalHUD().m_kAbilityHUD.GetCurrentSelectedAbility();

		if(AbilityState == None) {
			XComPresentationLayer(Movie.Pres).GetTacticalHUD().m_kAbilityHUD.GetDefaultTargetingAbility(TargetRef.ObjectID, Action, true);
			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(Action.AbilityObjectRef.ObjectID));
		}
	}

	if(AbilityState != none)
	{
		kTarget.PrimaryTarget=TargetRef;
		class'HitCalcLib'.static.GetShotBreakdownDiffAdjust(AbilityState, kTarget, Breakdown);
		
		if(!Breakdown.HideShotBreakdown)
		{
			HitChance = Breakdown.bIsMultishot ? Breakdown.MultiShotHitChance : Breakdown.FinalHitChance;

			if (getDISPLAY_MISS_CHANCE())
				HitChance = 100 - HitChance;
				
			return Clamp(HitChance, 0, 100);
	    }
	}

	return -1;
}

`MCM_CH_VersionChecker(class'MCM_Defaults'.default.VERSION, class'ExtendedInformationRedux2_MCMScreen'.default.CONFIG_VERSION)

function bool GetDISPLAY_MISS_CHANCE() {
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.DISPLAY_MISS_CHANCE, class'ExtendedInformationRedux2_MCMScreen'.default.DISPLAY_MISS_CHANCE);
}
