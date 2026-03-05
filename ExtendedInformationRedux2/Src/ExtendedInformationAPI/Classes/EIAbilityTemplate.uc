//-----------------------------------------------------------
//	Class:	EIAbilityTemplate
//	Author: Mr. Nice
//	
//-----------------------------------------------------------


class EIAbilityTemplate extends X2AbilityTemplate implements(EI_DamagePreviewTemplateAPI);

delegate bool EIDamagePreviewFn(EI_DamagePreviewHelperAPI PreviewHelper, XComGameState_Ability AbilityState, StateObjectReference TargetRef, out DamageBreakdown NormalDamage, out DamageBreakdown CritDamage, out int AllowsShield){return false;}
