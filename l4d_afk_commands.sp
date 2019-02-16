
#include <sourcemod>

new String:BotName[16];

public OnPluginStart()
{
	RegConsoleCmd("sm_afk", AFKTurnClientToSpectate);
	RegConsoleCmd("sm_away", AFKTurnClientToSpectate);
	//RegConsoleCmd("sm_idle", AFKTurnClientToSpectate);
	//RegConsoleCmd("sm_spectate", AFKTurnClientToSpectate);
	//RegConsoleCmd("sm_spectators", AFKTurnClientToSpectate);
	//RegConsoleCmd("sm_joinspectators", AFKTurnClientToSpectate);
	//RegConsoleCmd("sm_jointeam1", AFKTurnClientToSpectate);
	//RegConsoleCmd("sm_survivors", AFKTurnClientToSurvivors);
	//RegConsoleCmd("sm_joinsurvivors", AFKTurnClientToSurvivors);
	//RegConsoleCmd("sm_jointeam2", AFKTurnClientToSurvivors);
	RegConsoleCmd("sm_join", AFKTurnClientToSurvivors);
	RegConsoleCmd("sm_jn", AFKTurnClientToNick);
	RegConsoleCmd("sm_je", AFKTurnClientToEllis);
	RegConsoleCmd("sm_jr", AFKTurnClientToRochelle);
	RegConsoleCmd("sm_jc", AFKTurnClientToCoach);
	RegConsoleCmd("sm_jb", AFKTurnClientToBill);
	RegConsoleCmd("sm_jf", AFKTurnClientToFrancis);
	RegConsoleCmd("sm_jz", AFKTurnClientToZoey);
	RegConsoleCmd("sm_jl", AFKTurnClientToLouis);
	RegConsoleCmd("sm_kickbot", KickBotMenu);
	RegConsoleCmd("sm_addbot", AddBotMenu);
	//RegConsoleCmd("sm_infected", AFKTurnClientToInfected);
	//RegConsoleCmd("sm_joininfected", AFKTurnClientToInfected);
	//RegConsoleCmd("sm_jointeam3", AFKTurnClientToInfected);
}

public Action:AddBotMenu(client, args) 
{
	CreateTimer(0.1, AddBot);
	return Plugin_Handled;
}

public Action:KickBotMenu(client, args) 
{
	new Handle:menu = CreateMenu(MapMenuHandler);
	SetMenuPagination(Handle:menu, MENU_NO_PAGINATION);
	SetMenuTitle(menu, "请选择踢出的电脑");
	AddMenuItem(menu, "nick","Nick");
	AddMenuItem(menu, "ellis","Ellis");
	AddMenuItem(menu, "rochelle","Rochelle");
	AddMenuItem(menu, "coach","Coach");
	AddMenuItem(menu, "bill","Bill");
	AddMenuItem(menu, "louis","Louis");
	AddMenuItem(menu, "francis","Francis");
	AddMenuItem(menu, "zoey","Zoey");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public MapMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[16] , String:name[32];
		GetMenuItem(menu, itemNum, info, sizeof(info), _, name, sizeof(name));
		BotName = info;
		CreateTimer(0.1, KickBot);
	}
}

public Action:AddBot(Handle:timer)
{
	ServerCommand("sb_add");
}

public Action:KickBot(Handle:timer)
{
	ServerCommand("kick %s", BotName);
}

public Action:AFKTurnClientToSpectate(client, argCount)
{
	ChangeClientTeam(client, 1)
	return Plugin_Handled;
}

public Action:AFKTurnClientToSurvivors(client, args)
{ 	
	ClientCommand(client, "jointeam 2");
	return Plugin_Handled;
}

public Action:AFKTurnClientToNick(client, args)
{
	ChangeClientTeam(client, 1)
	ClientCommand(client, "jointeam 2 nick");
	return Plugin_Handled;
}

public Action:AFKTurnClientToEllis(client, args)
{ 
	ChangeClientTeam(client, 1)
	ClientCommand(client, "jointeam 2 ellis");
	return Plugin_Handled;
}

public Action:AFKTurnClientToCoach(client, args)
{ 
	ChangeClientTeam(client, 1)
	ClientCommand(client, "jointeam 2 coach");
	return Plugin_Handled;
}

public Action:AFKTurnClientToRochelle(client, args)
{ 
	ChangeClientTeam(client, 1)
	ClientCommand(client, "jointeam 2 rochelle");
	return Plugin_Handled;
}

public Action:AFKTurnClientToBill(client, args)
{ 
	ChangeClientTeam(client, 1)
	ClientCommand(client, "jointeam 2 bill");
	return Plugin_Handled;
}
public Action:AFKTurnClientToFrancis(client, args)
{ 
	ChangeClientTeam(client, 1)
	ClientCommand(client, "jointeam 2 francis");
	return Plugin_Handled;
}
public Action:AFKTurnClientToZoey(client, args)
{ 
	ChangeClientTeam(client, 1)
	ClientCommand(client, "jointeam 2 zoey");
	return Plugin_Handled;
}
public Action:AFKTurnClientToLouis(client, args)
{ 
	ChangeClientTeam(client, 1)
	ClientCommand(client, "jointeam 2 louis");
	return Plugin_Handled;
}
/*public Action:AFKTurnClientToInfected(client, args)
{ 
	ClientCommand(client, "jointeam 3");
	return Plugin_Handled;
}*/