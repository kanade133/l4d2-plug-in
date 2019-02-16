

#include <sourcemod>

new Handle:hMode;
new Handle:hMap;
new Handle:hChangeable;
new String:C_Mode[16];
new String:C_Map[32];
new bool:isReseting = false;
public void OnPluginStart()
{
	hMode = CreateConVar("C_Mode", "coop", "默认模式 coop 战役 realism 写实 mutation4 八特 写其他值默认coop");
	hMap = CreateConVar("C_Map", "c2m1_highway", "默认地图");
	hChangeable = CreateConVar("Changeable", "1", "是否允许玩家改变模式");
	RegConsoleCmd("sm_cmode", ChangeModeMenu);
	RegServerCmd("sv_cmode", ServerChangeMode);
	AutoExecConfig(true, "l4d2_changemode");
	CreateTimer(0.1, InitConVar, any:0, 0);
	HookEvent("player_disconnect", Event_Player_Disconnect);
}

public Action:InitConVar(Handle:timer)
{
	GetConVarString(hMode, C_Mode, 16);
	TrimString(C_Mode);
	if(!StrEqual(C_Mode, "coop", false) && !StrEqual(C_Mode, "realism", false) && !StrEqual(C_Mode, "mutation4", false))
	{
		C_Mode = "coop";
	}
	GetConVarString(hMap, C_Map, 32);
}

public void OnMapStart()
{
	CreateTimer(0.1, ChangeMode, any:0, 0);
}

public void Event_Player_Disconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!isReseting)
	{
		isReseting = true;
		CreateTimer(0.2, Reset, any:0, 0);
	}
}

public Action:Reset(Handle:timer)
{
	if(GetRealClientCount(false) == 0)
	{
		GetConVarString(hMode, C_Mode, 16);
		GetConVarString(hMap, C_Map, 32);
		CreateTimer(0.1, ChangeMode, any:0, 0);
		CreateTimer(0.1, ResetMap, any:0, 0);
	}
	isReseting = false;
}

public int GetRealClientCount( bool:inGameOnly ) 
{
	new clients = 0;
	for( new i = 1; i < GetMaxClients(); i++ ) {
		if( ( ( inGameOnly ) ? IsClientInGame( i ) : IsClientConnected( i ) ) && !IsFakeClient( i ) ) {
			clients++;
		}
	}
	return clients;
}

public Action:ServerChangeMode(args) 
{
	if(GetCmdArgs() > 0)
	{
		GetCmdArg(1, C_Mode, sizeof(C_Mode));
		CreateTimer(0.1, ChangeMode);
		PrintToChatAll("\x05[提示] \x04 切换游戏模式 \x05 %s", C_Mode);
	}
}

public Action:ChangeModeMenu(client, args) 
{
	if(GetConVarInt(hChangeable) == 1)
	{
		new Handle:menu = CreateMenu(MapMenuHandler);
		SetMenuTitle(menu, "请选择模式，目前模式:%s", C_Mode);
		AddMenuItem(menu, "coop","coop战役");
		AddMenuItem(menu, "realism","realism写实");
		AddMenuItem(menu, "mutation4","mutation4八特");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public MapMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[16] , String:name[32];
		GetMenuItem(menu, itemNum, info, sizeof(info), _, name, sizeof(name));
		C_Mode = info;
		CreateTimer(0.1, ChangeMode);
		PrintToChatAll("\x05[提示] \x04%N 切换游戏模式 \x05 %s", client, name);
	}
}

public Action:ResetMap(Handle:timer)
{
	ServerCommand("Map %s", C_Map);
}

public Action:ChangeMode(Handle:timer)
{
	SetConVarString(FindConVar("mp_gamemode"), C_Mode, false, false);
	new Handle:HTheammmoset = FindConVar("Theammoset");
	if (HTheammmoset == INVALID_HANDLE)return Action:0;
	Ammoset(HTheammmoset);
	PrintToServer("ChangeMode %s Ammoset %d", C_Mode, GetConVarInt(HTheammmoset));
	return Action:0;
}

public Action:Ammoset(Handle:HTheammmoset)
{
	if (StrEqual(C_Mode, "coop", false) || StrEqual(C_Mode, "realism", false))
	{
		SetConVarInt(HTheammmoset, 0, false, false);
	}
	if(StrEqual(C_Mode, "mutation4", false))
	{
		SetConVarInt(HTheammmoset, 3, false, false);
	}
	ServerCommand("sm_ammoset");
	return Action:0;
}