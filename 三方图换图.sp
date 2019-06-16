#pragma semicolon 1


#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
#define SCORE_DELAY_EMPTY_SERVER 3.0
#define ZOMBIECLASS_SMOKER 1
#define ZOMBIECLASS_BOOMER 2
#define ZOMBIECLASS_HUNTER 3
#define ZOMBIECLASS_SPITTER 4
#define ZOMBIECLASS_JOCKEY 5
#define ZOMBIECLASS_CHARGER 6
#define ZOMBIECLASS_TANK 8
#define MaxHealth 100
#define VOTE_NO "no"
#define VOTE_YES "yes"
#define L4D_MAXCLIENTS_PLUS1 (MaxClients+1)
new Votey = 0;
new Voten = 0;
new bool: game_l4d2 = false;
//new String:ReadyMode[64];
//new String:Label[16];//ready 开启/关闭
//new String:VotensReady_ED[32];
new String:VotensHp_ED[32];
new String:VotensMap_ED[32];
new String:kickplayer[MAX_NAME_LENGTH];
new String:kickplayername[MAX_NAME_LENGTH];
new String:votesmaps[MAX_NAME_LENGTH];
new String:votesmapsname[MAX_NAME_LENGTH];
new Handle:g_hVoteMenu = INVALID_HANDLE;

new String:EN_name[64][16][16];
new String:CHI_name[64][16][16];

new Handle:g_Cvar_Limits;
//new Handle:cvarFullResetOnEmpty;
//new Handle:VotensReadyED;
new Handle:VotensHpED;
new VotensHpTimes;
new Handle:VotensMapED;
new Handle:VotensKickED;
new Handle:VotensED;
new Float:lastDisconnectTime;
 
enum voteType
{
	//ready,
	hp,
	map,
	kicks
}
new voteType:g_voteType = voteType;
public Plugin:myinfo =
{
	name = "",
	author = "fenghf",
	description = "Votes Commands",
	version = "1.2.2a",
	url = "http://bbs.3dmgame.com/l4d"
};

public OnPluginStart()
{
	decl String: game_name[64];
	GetGameFolderName(game_name, sizeof(game_name));
	if (!StrEqual(game_name, "left4dead", false) && !StrEqual(game_name, "left4dead2", false))
	{
		SetFailState("只能在left4dead1&2使用.");
	}
	if (StrEqual(game_name, "left4dead2", false))
	{
		game_l4d2 = true;
	}
	//RegAdminCmd("sm_voter", Command_Vote, ADMFLAG_KICK|ADMFLAG_VOTE|ADMFLAG_GENERIC|ADMFLAG_BAN|ADMFLAG_CHANGEMAP, "投票开启ready插件");S
	//RegConsoleCmd("votesready", Command_Voter);
	RegConsoleCmd("voteshp", Command_VoteHp);
	RegConsoleCmd("votesmapsmenu", Command_VotemapsMenu);
	RegConsoleCmd("voteskick", Command_Voteskick);
	RegConsoleCmd("sm_v", Command_Votes, "打开投票菜单");
	g_Cvar_Limits = CreateConVar("sm_votes_s", "0.60", "百分比.", 0, true, 0.05, true, 1.0);
	//cvarFullResetOnEmpty = CreateConVar("l4d_full_reset_on_empty", "1", " 当服务器没有人的时候关闭ready插件", FCVAR_PLUGIN|FCVAR_NOTIFY);
	//VotensReadyED = CreateConVar("l4d_VotensreadyED", "0", " 启用、关闭 投票ready功能", FCVAR_PLUGIN|FCVAR_NOTIFY);
	VotensHpED = CreateConVar("l4d_VotenshpED", "1", " 启用、关闭 投票回血功能");
	VotensMapED = CreateConVar("l4d_VotensmapED", "1", " 启用、关闭 投票换图功能");
	VotensKickED = CreateConVar("l4d_VotenskickED", "1", " 启用、关闭 投票踢人功能");
	VotensED = CreateConVar("l4d_Votens", "1", " 启用、关闭 插件");
	VotensHpTimes = 1;
	HookEvent("round_start", EventHook:VotensHpEvent_RoundStart);
	MapInit();
}
public OnClientPutInServer(client)
{
	CreateTimer(30.0, TimerAnnounce, client);
}

public Action:VotensHpEvent_RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	VotensHpTimes = 1;
	return Action:0;
}

public MapInit()
{
    new i = 0;
    new Handle:hFile = OpenConfig();
    if (KvGotoFirstSubKey(hFile))
    {
        KvGetString(hFile, "中文名", CHI_name[i][0][0], 64, "错误地图名");
        KvGetString(hFile, "建图代码", EN_name[i][0][0], 64, "wrong map code");
        i++;
    }
    while (KvGotoNextKey(hFile))
    {
        KvGetString(hFile, "中文名", CHI_name[i][0][0], 64, "错误地图名");
        KvGetString(hFile, "建图代码", EN_name[i][0][0], 64, "wrong map code");
        i++;
    }
    CloseHandle(hFile);
}

public Handle:OpenConfig()
{
    decl String:sPath[256];
    BuildPath(PathType:0, sPath, 256, "%s", "data/l4d2_abbw_map.txt");
    if (!FileExists(sPath, false, "GAME"))
    {
        SetFailState("Fail To Find File 'data/l4d2_abbw_map.tx't");
    }
    new Handle:hFile = CreateKeyValues("第三方图数据", "", "");
    if (FileToKeyValues(hFile, sPath))
    {
		PrintToServer("File Data 'data/l4d2_abbw_map.txt Load' Success");
    }
	else
	{
        CloseHandle(hFile);
        SetFailState("Can't Load 'File data/l4d2_abbw_map.txt'");
	}
    return hFile;
}

public Action:TimerAnnounce(Handle:timer, any:client)
{
	if (IsClientInGame(client))
		PrintToChat(client, "");
}
public Action:Command_Votes(client, args) 
{ 
	if(GetConVarInt(VotensED) == 1)
	{
		//new VotensReadyE_D = GetConVarInt(VotensReadyED); 
		new VotensHpE_D = GetConVarInt(VotensHpED); 
		new VotensMapE_D = GetConVarInt(VotensMapED);
		new VotensKickE_D = GetConVarInt(VotensKickED);
		/*
		if(VotensReadyE_D == 0)
		{
			VotensReady_ED = "开启";
		}
		else if(VotensReadyE_D == 1)
		{
			VotensReady_ED = "禁用";
		}*/
		if(VotensHpE_D == 0)
		{
			VotensHp_ED = "开启";
		}
		else if(VotensHpE_D == 1)
		{
			VotensHp_ED = "禁用";
		}
		
		if(VotensMapE_D == 0)
		{
			VotensMap_ED = "开启";
		}
		else if(VotensMapE_D == 1)
		{
			VotensMap_ED = "禁用";
		}
		new Handle:menu = CreatePanel();
		new String:Value[64];
		SetPanelTitle(menu, "投票菜单");
		/*
		if (VotensReadyE_D == 0)
		{
			DrawPanelItem(menu, "禁用投票ready插件");
		}
		else if(VotensReadyE_D == 1)
		{
			Format(Value, sizeof(Value), "投票%s ready插件", Label);
			DrawPanelItem(menu, Value);
		}*/
		if (VotensHpE_D == 0 || VotensHpTimes <= 0)
		{
			DrawPanelItem(menu, "禁用投票回血");
		}
		else if (VotensHpE_D == 1 && VotensHpTimes > 0)
		{
			DrawPanelItem(menu, "投票回血(每回合限一次)");
		}
		if (VotensMapE_D == 0)
		{
			DrawPanelItem(menu, "禁用投票换图");
		}
		else if (VotensMapE_D == 1)
		{
			DrawPanelItem(menu, "投票换图");
		}
		if (VotensKickE_D == 0)
		{
			DrawPanelItem(menu, "禁用投票踢人");
		}
		else if (VotensKickE_D == 1)
		{
			DrawPanelItem(menu, "投票踢人");
		}
		//DrawPanelItem(menu, "投票踢人");//常用,不添加开启关闭
		if (GetUserFlagBits(client)&ADMFLAG_ROOT || GetUserFlagBits(client)&ADMFLAG_CONVARS)
		{
			DrawPanelText(menu, "管理员选项");
			/*
			Format(Value, sizeof(Value), "%s 投票ready插件", VotensReady_ED);
			DrawPanelItem(menu, Value);
			*/
			Format(Value, sizeof(Value), "%s 投票回血", VotensHp_ED);
			DrawPanelItem(menu, Value);
			Format(Value, sizeof(Value), "%s 投票换图", VotensMap_ED);
			DrawPanelItem(menu, Value);
		}
		DrawPanelText(menu, " \n");
		DrawPanelItem(menu, "关闭");
		//SetMenuExitButton(menu, true);
		SendPanelToClient(menu, client,Votes_Menu, MENU_TIME_FOREVER);
		return Plugin_Handled;
	}
	else if(GetConVarInt(VotensED) == 0)
	{}
	return Plugin_Stop;
}
public Votes_Menu(Handle:menu, MenuAction:action, client, itemNum)
{
	if ( action == MenuAction_Select ) 
	{
		//new VotensReadyE_D = GetConVarInt(VotensReadyED); 
		new VotensHpE_D = GetConVarInt(VotensHpED); 
		new VotensMapE_D = GetConVarInt(VotensMapED);
		switch (itemNum)
		{
		/*
			case 1: 
			{
				if (VotensReadyE_D == 0)
				{
					FakeClientCommand(client,"sm_votes");
					PrintToChat(client, "[提示] 禁用投票ready插件");
					return ;
				}
				else if (VotensReadyE_D == 1)
				{
					FakeClientCommand(client,"votesready");
				}
			}
			*/
			case 1: 
			{
				if (VotensHpE_D == 0)
				{
					FakeClientCommand(client,"sm_votes");
					PrintToChat(client, "[提示] 禁用投票回血");
					return;
				}
				else if (VotensHpE_D == 1)
				{
					FakeClientCommand(client,"voteshp");
				}
			}
			case 2: 
			{
				if (VotensMapE_D == 0)
				{
					FakeClientCommand(client,"sm_votes");
					PrintToChat(client, "[提示] 禁用投票换图");
					return ;
				}
				else if (VotensMapE_D == 1)
				{
					FakeClientCommand(client,"votesmapsmenu");
				}
			}
			case 3: 
			{
				FakeClientCommand(client,"voteskick");
			}/*
			case 5: 
			{
				if (VotensReadyE_D == 0 && GetUserFlagBits(client)&ADMFLAG_ROOT || GetUserFlagBits(client)&ADMFLAG_CONVARS && VotensReadyE_D == 0)
				{
					SetConVarInt(FindConVar("l4d_VotensreadyED"), 1);
					PrintToChatAll("\x05[提示] \x04管理员 开启投票ready插件");
				}
				else if (VotensReadyE_D == 1 && GetUserFlagBits(client)&ADMFLAG_ROOT || GetUserFlagBits(client)&ADMFLAG_CONVARS && VotensReadyE_D == 1)
				{
					SetConVarInt(FindConVar("l4d_VotensreadyED"), 0);
					PrintToChatAll("\x05[提示] \x04管理员 禁用投票ready插件");
				}
			}*/
			case 4: 
			{
				if (VotensHpE_D == 0 && GetUserFlagBits(client)&ADMFLAG_ROOT || GetUserFlagBits(client)&ADMFLAG_CONVARS && VotensHpE_D == 0)
				{
					SetConVarInt(FindConVar("l4d_VotenshpED"), 1);
					PrintToChatAll("\x05[提示] \x04管理员 开启投票回血");
				}
				else if (VotensHpE_D == 1 && GetUserFlagBits(client)&ADMFLAG_ROOT || GetUserFlagBits(client)&ADMFLAG_CONVARS && VotensHpE_D == 1)
				{
					SetConVarInt(FindConVar("l4d_VotenshpED"), 0);
					PrintToChatAll("\x05[提示] \x04管理员 禁用投票回血");
				}
			}
			case 5: 
			{
				if (VotensMapE_D == 0 && GetUserFlagBits(client)&ADMFLAG_ROOT || GetUserFlagBits(client)&ADMFLAG_CONVARS && VotensMapE_D == 0)
				{
					SetConVarInt(FindConVar("l4d_VotensmapED"), 1);
					PrintToChatAll("\x05[提示] \x04管理员 开启投票换图");
				}
				else if (VotensMapE_D == 1 && GetUserFlagBits(client)&ADMFLAG_ROOT || GetUserFlagBits(client)&ADMFLAG_CONVARS && VotensMapE_D == 1)
				{
					SetConVarInt(FindConVar("l4d_VotensmapED"), 0);
					PrintToChatAll("\x05[提示] \x04管理员 禁用投票换图");
				}
			}
		}
	}
}

/*
public Action:Command_Voter(client, args)
{
	if(GetConVarInt(VotensED) == 1 && GetConVarInt(VotensReadyED) == 1)
	{
		if (IsVoteInProgress())
		{
			ReplyToCommand(client, "[提示] 已有投票在进行中");
			return Plugin_Handled;
		}
		if (!TestVoteDelay(client))
		{
			return Plugin_Handled;
		}
			
		PrintToChatAll("\x05 \x04%N \x03发起投票换三方图 \x05%s \x03ready插件", client, Label);
		PrintToChatAll("\x05[提示] \x04服务器没有玩家的时候,ready插件自动关闭");
		
		g_voteType = voteType:ready;
		decl String:SteamId[35];
		GetClientAuthString(client, SteamId, sizeof(SteamId));
		LogMessage("%N %s发起投票%s ready插件!",  client, SteamId, Label);//记录在log文件
		
		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "是否%s ready插件?",Label);
		AddMenuItem(g_hVoteMenu, VOTE_YES, "Yes");
		AddMenuItem(g_hVoteMenu, VOTE_NO, "No");
	
		SetMenuExitButton(g_hVoteMenu, false);
		VoteMenuToAll(g_hVoteMenu, 20);		
		return Plugin_Handled;
	}
	else if(GetConVarInt(VotensED) == 0 && GetConVarInt(VotensReadyED) == 0)
	{
		PrintToChat(client, "[提示] 禁用投票ready插件");
	}
	return Plugin_Handled;
}
*/
public Action:Command_VoteHp(client, args)
{
	if(GetConVarInt(VotensED) == 1 
	&& GetConVarInt(VotensHpED) == 1
	&& VotensHpTimes > 0)
	{
		if (IsVoteInProgress())
		{
			ReplyToCommand(client, "[提示] 已有投票在进行中");
			return Plugin_Handled;
		}
		
		if (!TestVoteDelay(client))
		{
			return Plugin_Handled;
		}
		PrintToChatAll("\x05[提示] \x04 %N \x03发起投票回血",client);
		
		g_voteType = voteType:hp;
		decl String:SteamId[35];
		GetClientAuthString(client, SteamId, sizeof(SteamId));
		LogMessage("%N &s发起投票所有人回血!",  client, SteamId);//记录在log文件
		g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
		SetMenuTitle(g_hVoteMenu, "是否所有人回血?");
		AddMenuItem(g_hVoteMenu, VOTE_YES, "Yes");
		AddMenuItem(g_hVoteMenu, VOTE_NO, "No");
	
		SetMenuExitButton(g_hVoteMenu, false);
		VoteMenuToAll(g_hVoteMenu, 20);		
		return Plugin_Handled;	
	}
	else if(GetConVarInt(VotensED) == 0 && GetConVarInt(VotensHpED) == 0)
	{
		PrintToChat(client, "[提示] 禁用投票回血");
	}
	return Plugin_Handled;
}

public Action:Command_Voteskick(client, args)
{
	if(client!=0) CreateVotekickMenu(client);		
	return Plugin_Handled;
}

CreateVotekickMenu(client)
{	
	new Handle:menu = CreateMenu(Menu_Voteskick);		
	new team = GetClientTeam(client);
	new String:name[MAX_NAME_LENGTH];
	new String:playerid[32];
	SetMenuTitle(menu, "选择踢出玩家");
	for(new i = 1;i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i)==team)
		{
			Format(playerid,sizeof(playerid),"%i",GetClientUserId(i));
			if(GetClientName(i,name,sizeof(name)))
			{
				AddMenuItem(menu, playerid, name);						
			}
		}		
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);	
}
public Menu_Voteskick(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[32] , String:name[32];
		GetMenuItem(menu, param2, info, sizeof(info), _, name, sizeof(name));
		kickplayer = info;
		kickplayername = name;
		PrintToChatAll("\x05[提示] \x04%N 发起投票踢出 \x05 %s", param1, kickplayername);
		DisplayVoteKickMenu(param1);		
	}
}

public DisplayVoteKickMenu(client)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "[提示] 已有投票在进行中");
		return;
	}
	
	if (!TestVoteDelay(client))
	{
		return;
	}
	g_voteType = voteType:kicks;
	
	g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
	SetMenuTitle(g_hVoteMenu, "是否踢出玩家 %s",kickplayername);
	AddMenuItem(g_hVoteMenu, VOTE_YES, "Yes");
	AddMenuItem(g_hVoteMenu, VOTE_NO, "No");
	SetMenuExitButton(g_hVoteMenu, false);
	VoteMenuToAll(g_hVoteMenu, 20);
}

public Action:Command_VotemapsMenu(client, args)
{
	if(GetConVarInt(VotensED) == 1 && GetConVarInt(VotensMapED) == 1)
	{
		
		if (!TestVoteDelay(client))
		{
			return Plugin_Handled;
		}
		new Handle:menu = CreateMenu(MapMenuHandler);
	
		SetMenuTitle(menu, "请选择投票地图");
		if(game_l4d2)
		{
			new i = 0;
			while (i < 64) {
				if (!StrEqual("", CHI_name[i][0][0], true))
				{
					AddMenuItem(menu, EN_name[i][0][0], CHI_name[i][0][0]);
				}
				i++;
			}
		
			//AddMenuItem(menu, "option1", "返回");
			/*AddMenuItem(menu, "msd1_town", "再见了晨茗");
			AddMenuItem(menu, "qe2_ep1", "伦理问题2");
			AddMenuItem(menu, "qe_1_cliche", "伦理问题");
			AddMenuItem(menu, "l4d2_bts01_forest", "回到学校");
			AddMenuItem(menu, "l4d_dbd2dc_anna_is_gone", "活死人黎明：导演版");
			AddMenuItem(menu, "mall_of_ukraine", "切尔诺贝利");
			AddMenuItem(menu, "l4d_viennacalling_city", "维也纳的呼唤");
			AddMenuItem(menu, "l4d_viennacalling2_1", "维也纳的呼唤2");
			AddMenuItem(menu, "wfp1_track", "白森林");
			AddMenuItem(menu, "l4d_fallen01_approach", "坠落");
			AddMenuItem(menu, "l4d_tbm_1", "血腥荒野");
			AddMenuItem(menu, "srocchurch", "巴塞罗那");
			AddMenuItem(menu, "l4d_ihm01_forest", "我恨山");
			AddMenuItem(menu, "c1_1_mall", "死亡高校");
			AddMenuItem(menu, "gr-mapone-7", "赶尽杀绝");
			AddMenuItem(menu, "l4d2_ic_1_city", "感染之城");
			AddMenuItem(menu, "l4d2_ic_2_1", "感染之城2");
			AddMenuItem(menu, "uf1_boulevard", "城市航班");
			AddMenuItem(menu, "l4d2_city17_01", "城市17");
			AddMenuItem(menu, "ud_map01_n", "城市灾难");
			AddMenuItem(menu, "shopcenter", "死亡街区13");
			AddMenuItem(menu, "l4d_yama_1", "摩耶山危机");
			AddMenuItem(menu, "l4d2_fallindeath01", "坠入死亡");
			AddMenuItem(menu, "symbyosys_01", "合作符号 v13");
			AddMenuItem(menu, "AirCrash", "天堂可待2");
			AddMenuItem(menu, "l4d2_win1", "冰与火");
			AddMenuItem(menu, "l4d2_daybreak01_hotel", "黎明");
			AddMenuItem(menu, "hf01_theforest", "颤栗森林");
			AddMenuItem(menu, "nt01_mansion", "夜惊2013");
			AddMenuItem(menu, "Dead_Series1", "连续死亡");
			AddMenuItem(menu, "village_beta408", "死亡之旅");
			AddMenuItem(menu, "l4d2_deadcity01_riverside", "死城2");
			AddMenuItem(menu, "l4d2_darkblood01_tanker", "黑血2");
			AddMenuItem(menu, "damitdc1", "大坝2导演版");
			AddMenuItem(menu, "bhm1_outskirts", "别被丢下");
			AddMenuItem(menu, "dw_woods", "阴暗森林1.4");
			AddMenuItem(menu, "l4d_draxmap0", "死亡终点站");
			AddMenuItem(menu, "damshort170surv", "黄金眼");
			AddMenuItem(menu, "p84m1_apartment", "84警区");
			AddMenuItem(menu, "l4d2_trainstation_01", "半条命2：好日子 1/3");
			AddMenuItem(menu, "l4d2_canals_01", "半条命2：运河航道 2/3");
			AddMenuItem(menu, "l4d2_canals_07", "半条命2：水障碍区 3/3");
			AddMenuItem(menu, "l4d2_stadium1_apartment", "闪电突袭2");
			AddMenuItem(menu, "redemptionII-deadstop", "救赎2");*/


			
		}
		else
		{
			//AddMenuItem(menu, "option1", "返回");
			AddMenuItem(menu, "l4d_vs_hospital01_apartment", "毫不留情");
			AddMenuItem(menu, "l4d_vs_airport01_greenhouse", "静寂时分");
			AddMenuItem(menu, "l4d_vs_smalltown01_caves", "死亡丧钟");
			AddMenuItem(menu, "l4d_vs_farm01_hilltop", "血腥收获");
			AddMenuItem(menu, "l4d_garage01_alleys", "坠机险途");
			AddMenuItem(menu, "l4d_river01_docks", "牺牲");
		}
		SetMenuExitBackButton(menu, true);
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		
		return Plugin_Handled;
	}
	else 
	if(GetConVarInt(VotensED) == 0 && GetConVarInt(VotensMapED) == 0)
	{
		PrintToChat(client, "[提示] 禁用投票换图");
	}
	return Plugin_Handled;
}

public MapMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[32] , String:name[32];
		GetMenuItem(menu, itemNum, info, sizeof(info), _, name, sizeof(name));
		votesmaps = info;
		votesmapsname = name;
		PrintToChatAll("\x05[提示] \x04%N 发起投票换图 \x05 %s", client, votesmapsname);
		DisplayVoteMapsMenu(client);		
	}
}
public DisplayVoteMapsMenu(client)
{
	if (IsVoteInProgress())
	{
		ReplyToCommand(client, "[提示] 已有投票在进行中");
		return;
	}
	
	if (!TestVoteDelay(client))
	{
		return;
	}
	g_voteType = voteType:map;
	
	g_hVoteMenu = CreateMenu(Handler_VoteCallback, MenuAction:MENU_ACTIONS_ALL);
	SetMenuTitle(g_hVoteMenu, "发起投票换图 %s %s",votesmapsname, votesmaps);
	AddMenuItem(g_hVoteMenu, VOTE_YES, "Yes");
	AddMenuItem(g_hVoteMenu, VOTE_NO, "No");
	SetMenuExitButton(g_hVoteMenu, false);
	VoteMenuToAll(g_hVoteMenu, 20);
}
public Handler_VoteCallback(Handle:menu, MenuAction:action, param1, param2)
{
	//==========================
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 0: 
			{
				Votey += 1;
				PrintToChatAll("\x03%N \x05投票了.", param1);
			}
			case 1: 
			{
				Voten += 1;
				PrintToChatAll("\x03%N \x04投票了.", param1);
			}
		}
	}
	//==========================
	decl String:item[64], String:display[64];
	new Float:percent, Float:limit, votes, totalVotes;

	GetMenuVoteInfo(param2, votes, totalVotes);
	GetMenuItem(menu, param1, item, sizeof(item), _, display, sizeof(display));
	
	if (strcmp(item, VOTE_NO) == 0 && param1 == 1)
	{
		votes = totalVotes - votes;
	}
	percent = GetVotePercent(votes, totalVotes);

	limit = GetConVarFloat(g_Cvar_Limits);
	
	CheckVotes();
	if (action == MenuAction_End)
	{
		VoteMenuClose();
	}
	else if (action == MenuAction_VoteCancel && param1 == VoteCancel_NoVotes)
	{
		PrintToChatAll("[提示] 没有票数");
	}	
	else if (action == MenuAction_VoteEnd)
	{
		if ((strcmp(item, VOTE_YES) == 0 && FloatCompare(percent,limit) < 0 && param1 == 0) || (strcmp(item, VOTE_NO) == 0 && param1 == 1))
		{
			PrintToChatAll("[提示] 投票失败. 至少需要 %d%% 支持.(同意 %d%% 总共 %i 票)", RoundToNearest(100.0*limit), RoundToNearest(100.0*percent), totalVotes);
			CreateTimer(2.0, VoteEndDelay);
		}
		else
		{
			PrintToChatAll("[提示] 投票通过.(同意 %d%% 总共 %i 票)", RoundToNearest(100.0*percent), totalVotes);
			CreateTimer(2.0, VoteEndDelay);
			switch (g_voteType)
			{
			/*
				case (voteType:ready):
				{
					if (strcmp(ReadyMode, "0", false) == 0 || strcmp(item, VOTE_NO) == 0 || strcmp(item, VOTE_YES) == 0 )
					{
						strcopy(item, sizeof(item), display);
						ServerCommand("sv_search_key 1");
						SetConVarInt(FindConVar("l4d_ready_enabled"), 1);
					}
					if (strcmp(ReadyMode, "1", false) == 0 || strcmp(item, VOTE_NO) == 0 || strcmp(item, VOTE_YES) == 0 )
					{
						ServerCommand("sv_search_key 1");
						SetConVarInt(FindConVar("l4d_ready_enabled"), 0);
					}
					PrintToChatAll("[提示] 投票的结果为: %s.", item);
					LogMessage("投票 %s ready通过",Label);
				}
				*/
				case (voteType:hp):
				{
					AnyHp();
					VotensHpTimes--;
					LogMessage("投票 所有玩家回血 ready通过");
				}
				case (voteType:map):
				{
					CreateTimer(5.0, Changelevel_Map);
					PrintToChatAll("\x03[提示] \x04 5秒后换图 \x05%s",votesmapsname);
					PrintToChatAll("\x04 %s",votesmaps);
					LogMessage("投票换图 %s %s 通过",votesmapsname,votesmaps);
				}
				case (voteType:kicks):
				{
					PrintToChatAll("\x05[提示] \x05 %s \x04投票踢出", kickplayername);
					ServerCommand("sm_kick %s 投票踢出", kickplayername);	
					LogMessage(" 投票踢出%s 通过",kickplayername);
				}
			}
		}
	}
	return 0;
}
//====================================================
public AnyHp()
{
	PrintToChatAll("\x03[提示]\x04所有玩家回血 本回合已禁用投票回血");
	new flags = GetCommandFlags("give");	
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			FakeClientCommand(i, "give health");
			SetEntityHealth(i, MaxHealth);
			//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03回血",i);
		}
		else
		if (IsClientInGame(i) && GetClientTeam(i) == 3 && IsPlayerAlive(i)) 
		{
			new class = GetEntProp(i, Prop_Send, "m_zombieClass");
			if (class == ZOMBIECLASS_SMOKER)
			{
				SetEntityHealth(i, 250);
				//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03Smoker回血",i);//请勿使用提示,否则知道有那些特感
			}
			else
			if (class == ZOMBIECLASS_BOOMER)
			{
				SetEntityHealth(i, 50);
				//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03Boomer回血",i);//请勿使用提示,否则知道有那些特感
			}
			else
			if (class == ZOMBIECLASS_HUNTER)
			{
				SetEntityHealth(i, 250);
				//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03Hunter回血",i);//请勿使用提示,否则知道有那些特感
			}
			else
            if (class == ZOMBIECLASS_SPITTER)
			{
				SetEntityHealth(i, 100);
				//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03Spitter 回血",i);//请勿使用提示,否则知道有那些特感
			}
			else
			if (class == ZOMBIECLASS_JOCKEY)
			{
				decl String:game_name[64];
				GetGameFolderName(game_name, sizeof(game_name));
				if (!StrEqual(game_name, "left4dead2", false))
				{
					SetEntityHealth(i, 6000);
					//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03Tank 回血",i);//请勿使用提示,否则知道有那些特感
				}
				else
				{
					SetEntityHealth(i, 325);
					//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03Jockey回血",i);//请勿使用提示,否则知道有那些特感
				}
			}
			else
			if (class == ZOMBIECLASS_CHARGER)
			{
				SetEntityHealth(i, 600);
				//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03Charger回血",i);//请勿使用提示,否则知道有那些特感
			}
			else
			if (class == ZOMBIECLASS_TANK)
			{
				SetEntityHealth(i, 6000);
				//PrintToChatAll("\x03[所有人]玩家 \x04%N \x03Tank回血",i);//请勿使用提示,否则知道有那些特感
			}
		}
	}
	SetCommandFlags("give", flags|FCVAR_CHEAT);
}
//================================
CheckVotes()
{
	PrintHintTextToAll("同意: %i\n不同意: %i", Votey, Voten);
}
public Action:VoteEndDelay(Handle:timer)
{
	Votey = 0;
	Voten = 0;
}
public Action:Changelevel_Map(Handle:timer)
{
	ServerCommand("changelevel %s", votesmaps);
}
//===============================
VoteMenuClose()
{
	Votey = 0;
	Voten = 0;
	CloseHandle(g_hVoteMenu);
	g_hVoteMenu = INVALID_HANDLE;
}
Float:GetVotePercent(votes, totalVotes)
{
	return FloatDiv(float(votes),float(totalVotes));
}
bool:TestVoteDelay(client)
{
 	new delay = CheckVoteDelay();
 	
 	if (delay > 0)
 	{
 		if (delay > 60)
 		{
 			PrintToChat(client, "[提示] 您必须再等 %i 分钟後才能发起新一轮投票", delay % 60);
 		}
 		else
 		{
 			PrintToChat(client, "[提示] 您必须再等 %i 秒钟後才能发起新一轮投票", delay);
 		}
 		return false;
 	}
	return true;
}
//=======================================
public OnClientDisconnect(client)
{
	if (IsClientInGame(client) && IsFakeClient(client)) return;

	new Float:currenttime = GetGameTime();
	
	if (lastDisconnectTime == currenttime) return;
	
	CreateTimer(SCORE_DELAY_EMPTY_SERVER, IsNobodyConnected, currenttime);
	lastDisconnectTime = currenttime;
}

public Action:IsNobodyConnected(Handle:timer, any:timerDisconnectTime)
{
	if (timerDisconnectTime != lastDisconnectTime) return Plugin_Stop;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && !IsFakeClient(i))
			return  Plugin_Stop;
	}
	/*
	SetConVarInt(FindConVar("l4d_ready_enabled"), 0);		
	if (GetConVarBool(cvarFullResetOnEmpty))
	{
		SetConVarInt(FindConVar("l4d_ready_enabled"), 0);
	}*/
	
	return  Plugin_Stop;
}
