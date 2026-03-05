//-----------------------------------------------------------
//	Interface:	EI_DamagePreviewTemplateAPI
//	Author: Mr. Nice
//	
//-----------------------------------------------------------

interface EI_DamagePreviewTemplateAPI;

function bool EIDamagePreviewFn(EI_DamagePreviewHelperAPI PreviewHelper, XComGameState_Ability AbilityState, StateObjectReference TargetRef, out DamageBreakdown NormalDamage, out DamageBreakdown CritDamage, out int AllowsShield);
