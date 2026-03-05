//-----------------------------------------------------------
//	Class:	X2EventListener_ExtendedInformation
//	Author: MrNice
//	
//-----------------------------------------------------------


class X2EventListener_ExtendedInformation extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem( AddClearBreakdownEvent() );


	return Templates;
}

static function X2EventListenerTemplate AddClearBreakdownEvent()
{
	local X2AbilityPointTemplate Template;

	`CREATE_X2TEMPLATE(class'X2AbilityPointTemplate', Template, 'EIClearBreakdown');
	Template.AddEvent('PlayerTurnEnded', ClearBreakdown);

	return Template;
}

static function EventListenerReturn ClearBreakdown(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local X2GameRulesetEventObserverInterface Observer;

	Observer = `GAMERULES.GetEventObserverOfType(class'X2TacticalGameRuleset_BreakdownObserver');
	X2TacticalGameRuleset_BreakdownObserver(Observer).Breakdowns.Length = 0;
	return ELR_NoInterrupt;
}