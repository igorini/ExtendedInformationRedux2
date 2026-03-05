//-----------------------------------------------------------
//	Class:	ExtendedInformationRedux2_MCMScreen
//	Author: Mr.Nice / Sebkulu
//	
//-----------------------------------------------------------

class ExtendedInformationRedux2_MCMScreenListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local ExtendedInformationRedux2_MCMScreen DisplayHitChanceMCMScreen;
	
	// Everything out here runs on every UIScreen. Not great but necessary.
	if (MCM_API(Screen) == none) return;

	if (ScreenClass==none) ScreenClass=Screen.Class;

	DisplayHitChanceMCMScreen = new class'ExtendedInformationRedux2_MCMScreen';
	DisplayHitChanceMCMScreen.OnInit(Screen);
}

defaultproperties
{
    ScreenClass = none;
}