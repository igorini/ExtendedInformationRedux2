//-----------------------------------------------------------
//	Class:	HackCalcLib
//	Author: Mr. Nice
//	
//-----------------------------------------------------------


class HackCalcLib extends Object;

`include(ExtendedInformationRedux2\Src\ExtendedInformationRedux2\LangFallBack.uci)
`include(ExtendedInformationRedux2\Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci)

var localized string RatioLabel;

static function bool GetHackBreakdown(XComGameState_Ability AbilityState, StateObjectReference Target, out EIHackBreakdown HackBreakdown)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local XComGameState_BaseObject TargetState;
	local array<name> PossibleHackRewards;
	local array<int> HackRollMods;
	local X2HackRewardTemplateManager HackRewardTemplateManager;
	local name HackRewardName;
	local Hackable HackableObject;
	local X2AbilityTemplate AbilityTemplate;
	local HackRewardInfo RewardItem;
	local int i;
	local float HackOffense, HackDefense;
	local bool bFillRolls;
	local UISummary_ItemStat Item;
	local string Neo;
	local XComGameState_Item ItemState;
	local array<XComGameState_Item> Items;
	local X2ItemTemplate SkullJackTemplate;
	local X2GremlinTemplate GremlinTemplate;
	local XComGameState NewGameState;

	if (!GetTH_PREVIEW_HACKING()) return false;

	AbilityTemplate=AbilityState.GetMyTemplate();
	if (AbilityTemplate.FinalizeAbilityName=='') return false;

	History=`XCOMHISTORY;
	TargetState=History.GetGameStateForObjectID(Target.ObjectID);
	HackableObject = Hackable(TargetState);
	if (HackableObject == none) return false;     //  if we don't have an interactive object or a unit, what is going on?

	UnitState=XComGameState_Unit(History.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));
	HackOffense= class'X2AbilityToHitCalc_Hacking'.static.GetHackAttackForUnit(UnitState, AbilityState);
	HackDefense= class'X2AbilityToHitCalc_Hacking'.static.GetHackDefenseForTarget(TargetState);

	PossibleHackRewards = HackableObject.GetHackRewards(AbilityTemplate.FinalizeAbilityName);
	HackRollMods = HackableObject.GetHackRewardRollMods();

	bFillRolls = HackRollMods.Length == 0;
	HackRewardTemplateManager = class'X2HackRewardTemplateManager'.static.GetHackRewardTemplateManager();

	foreach PossibleHackRewards(HackRewardName, i)
	{
		RewardItem.RewardTemplate = HackRewardTemplateManager.FindHackRewardTemplate(HackRewardName);

		if(bFillRolls)
			HackRollMods.AddItem(`SYNC_RAND_STATIC(RewardItem.RewardTemplate.HackSuccessVariance * 2) - RewardItem.RewardTemplate.HackSuccessVariance);
		RewardItem.RollMod = HackRollMods[i];
		//Mr. Nice: variables defined as floats and copied exactly (except for variable name substition) so no wierd differences occur from float/int conversions
		RewardItem.Chance=(100.0 - (RewardItem.RewardTemplate.MinHackSuccess + RewardItem.RollMod)) * HackOffense / HackDefense;
		HackBreakdown.RewardList.AddItem(RewardItem);
	}
	if (bFillRolls)
	{
		// If we need to fill the rolls, we need to submit a gamestate during preview, which is mildly naughty...
		// But to keep Robo happy, we'll at least check that there is no latent submission first!
		if (`TACTICALRULES.IsDoingLatentSubmission()) return false;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("X2AchievementTracker_DLC_Day60.OnTacticalGameEnd");
		HackableObject = Hackable(NewGameState.ModifyStateObject(TargetState.Class, TargetState.ObjectID));
		HackableObject.SetHackRewardRollMods(HackRollMods);
		History.AddGameStateToHistory(NewGameState);
	}

	HackBreakdown.Ratio=FormatFloat(HackOffense/HackDefense);//Mr. Nice: Round() would be strictly more accurate, but since the final results are truncated, trauncating the decimal is a better approximation of the  apparent ratio .
	HackBreakdown.RatioLabel=class'UIHackingScreen'.default.strHackAbilityLabel $ ": " $ default.RatioLabel;

	Neo=UnitState.GetNickName();
	If (Neo=="") Neo=UnitState.GetName(eNameType_Last);//Mr. Nice GetName() provides fall back for non soliders/civs, whereas GetLastName() doesn't

	Item.Label=Neo;
	Item.Value=string(int(HackOffense));
	Item.LabelState=eUIState_Good;
	Item.ValueState=eUIState_Good;
	HackBreakdown.LStats.AddItem(Item);

	Item.Label=Lootable(TargetState).GetLootingName();;
	Item.Value=string(int(HackDefense));
	Item.LabelState=eUIState_Bad;
	Item.ValueState=eUIState_Bad;
	HackBreakdown.LStats.AddItem(Item);

	HackBreakdown.TechLabel=Neo $ ": " $ class'UIHackingScreen'.default.strHackAbilityLabel;
	HackBreakdown.TechValue=string(int(HackOffense));

	Item.Label=class'XLocalizedData'.default.TechLabel;
	Item.Value=string(int(UnitState.GetCurrentStat(eStat_Hacking)));
	Item.LabelState=eUIState_Good;
	Item.ValueState=eUIState_Good;
	HackBreakdown.RStats.AddItem(Item);

	if(`XCOMHQ.IsTechResearched('Skullmining'))
	{
		Items=UnitState.GetAllInventoryItems(, true);
		foreach Items(ItemState)
			if (ItemState.GetMyTemplateName()=='SKULLJACK')
			{
				SkullJackTemplate=ItemState.GetMyTemplate();
				break;
			}

		if(SkullJackTemplate!=none)
		{
			Item.Label= SkullJackTemplate.GetItemFriendlyName(ItemState.ObjectID);
			Item.Value = "+" $ class'X2AbilityToHitCalc_Hacking'.default.SKULLJACK_HACKING_BONUS;
			HackBreakdown.RStats.AddItem(Item);
		}
	}
	ItemState=AbilityState.GetSourceWeapon();
	GremlinTemplate = X2GremlinTemplate(ItemState.GetMyTemplate());
	if (GremlinTemplate != None)
	{
		Item.Label=GremlinTemplate.GetItemFriendlyName(ItemState.ObjectID);
		Item.Value="+" $ GremlinTemplate.HackingAttemptBonus;
		HackBreakdown.RStats.AddItem(Item);
	}
	return true;
}

static delegate int RoundDelegate(float f);

static function string FormatFloat(float f, optional delegate<RoundDelegate> RdFn=fFloor, optional int dp=2)
{
	local int iPart;
	local string fPart;

	iPart=f;
	fPart=string(RdFn((f-iPart)*10**dp));
	while (len(fPart)<dp)
	{
		fPart= "0" $ fPart;
	}
	return iPart $ "." $ fPart;
}



`MCM_CH_StaticVersionChecker(class'MCM_Defaults'.default.VERSION, class'ExtendedInformationRedux2_MCMScreen'.default.CONFIG_VERSION)

static function bool GetTH_PREVIEW_HACKING()
{
	return `MCM_CH_GetValue(class'MCM_Defaults'.default.TH_PREVIEW_HACKING, class'ExtendedInformationRedux2_MCMScreen'.default.TH_PREVIEW_HACKING);
}

