//-----------------------------------------------------------
//	Interface:	EI_DamagePreviewHelperAPI
//	Author: Mr. Nice
//	
//-----------------------------------------------------------

Interface EI_DamagePreviewHelperAPI;

struct DamageInfo
{
	var string Label;
	var int Min;
	var int Max;
};

struct DamageBreakdown
{
	var int Min;
	var int Max;
	var array<DamageInfo> InfoList;
	var int Bonus;
};

function NormalAbilityDamagePreview(XComGameState_Ability AbilityState, StateObjectReference TargetRef, out DamageBreakdown NormalDamage, out DamageBreakdown CritDamage, out int AllowsShield);
