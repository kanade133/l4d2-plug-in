#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#undef REQUIRE_PLUGIN
new Handle:hC_SMG;
new C_SMG;
new Handle:hC_Shotgun;
new C_Shotgun;
new Handle:hC_Autoshotgun;
new C_Autoshotgun;
new Handle:hC_AssaultRifle;
new C_AssaultRifle;
new Handle:hC_HuntingRifle;
new C_HuntingRifle;
new Handle:hC_SniperRifle;
new C_SniperRifle;
new Handle:hC_GrenadeLauncher;
new C_GrenadeLauncher;
new Handle:hC_M60;
new C_M60;
new Handle:h_Theammoset;
new Theammoset;

public void OnPluginStart()
{
	
	//CreateConVar("L4D2_ammo_set_version", "L4D2备弹量设定1.0-by望夜", "!onammo双倍备弹;!offammo默认备弹;!onammo1自定备弹;!onammo2无限备弹", 8512, false, 0, false, 0);
	//RegConsoleCmd("sm_onammo", Onammosets, "", 0);
	//RegConsoleCmd("sm_offammo", Offammosets, "", 0);
	//RegConsoleCmd("sm_onammo2", Onammosets2, "", 0);
	//RegConsoleCmd("sm_onammo1", Onammosets1, "", 0);
	RegConsoleCmd("sm_ammoset", Ammoset, "", 0);
	HookEvent("round_start", EventHook:ammoEvent_RoundStart);
	hC_SMG = CreateConVar("C_SMG", "650", "!onammo1 自定微冲备弹数0-1000(1000=无限)", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:1000.0);
	C_SMG = GetConVarInt(Handle:hC_SMG);
	hC_Shotgun = CreateConVar("C_Shotgun", "56", "!onammo1 自定单喷备弹数0-1000(1000=无限)", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:1000.0);
	C_Shotgun = GetConVarInt(Handle:hC_Shotgun);
	hC_Autoshotgun = CreateConVar("C_Autoshotgun", "90", "!onammo1 自定连喷备弹数0-1000(1000=无限)", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:1000.0);
	C_Autoshotgun = GetConVarInt(Handle:hC_Autoshotgun);
	hC_AssaultRifle = CreateConVar("C_AssaultRifle", "360", "!onammo1 自定步枪备弹数0-1000(1000=无限)", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:1000.0);
	C_AssaultRifle = GetConVarInt(Handle:hC_AssaultRifle);
	hC_HuntingRifle = CreateConVar("C_HuntingRifle", "150", "!onammo1 自定1代狙备弹数0-1000(1000=无限)", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:1000.0);
	C_HuntingRifle = GetConVarInt(Handle:hC_HuntingRifle);
	hC_SniperRifle = CreateConVar("C_SniperRifle", "180", "!onammo1 自定2代狙备弹数0-1000(1000=无限)", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:1000.0);
	C_SniperRifle = GetConVarInt(Handle:hC_SniperRifle);
	hC_GrenadeLauncher = CreateConVar("C_GrenadeLauncher", "30", "!onammo1 自定榴弹备弹数0-1000(1000=无限)", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:1000.0);
	C_GrenadeLauncher = GetConVarInt(Handle:hC_GrenadeLauncher);
	hC_M60 = CreateConVar("C_M60", "0", "!onammo1 自定M60备弹数0-1000(1000=无限)", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:1000.0);
	C_M60 = GetConVarInt(Handle:hC_M60);
	h_Theammoset = CreateConVar("Theammoset", "3", "0默认子弹 1双倍子弹 2无限子弹 3自定子弹", FCVAR_PLUGIN, bool:true, Float:0.0, bool:true, Float:3.0);
	Theammoset = GetConVarInt(Handle:h_Theammoset);
	AutoExecConfig(true, "l4d2_ammo_set");
	CreateTimer(0.1, InitConVar, any:0, 0);
}

public Action:InitConVar(Handle:timer)
{
	C_SMG = GetConVarInt(Handle:hC_SMG);
	C_Shotgun = GetConVarInt(Handle:hC_Shotgun);
	C_Autoshotgun = GetConVarInt(Handle:hC_Autoshotgun);
	C_AssaultRifle = GetConVarInt(Handle:hC_AssaultRifle);
	C_HuntingRifle = GetConVarInt(Handle:hC_HuntingRifle);
	C_SniperRifle = GetConVarInt(Handle:hC_SniperRifle);
	C_GrenadeLauncher = GetConVarInt(Handle:hC_GrenadeLauncher);
	C_M60 = GetConVarInt(Handle:hC_M60);
	Theammoset = GetConVarInt(Handle:h_Theammoset);
}

public Action:Onammosets(client, args)
{
	Theammoset = 1;
	CreateTimer(0.1, ammosetStartDelays, any:0, 0);
	return Action:3;
}

public Action:Offammosets(client, args)
{
	Theammoset = 0;
	CreateTimer(0.1, ammosetStartDelays, any:0, 0);
	return Action:3;
}

public Action:Onammosets2(client, args)
{
	Theammoset = 2;
	CreateTimer(0.1, ammosetStartDelays, any:0, 0);
	return Action:3;
}

public Action:Onammosets1(client, args)
{
	Theammoset = 3;
	CreateTimer(0.1, ammosetStartDelays, any:0, 0);
	return Action:3;
}

public Action:Ammoset(client, args)
{
	Theammoset = GetConVarInt(Handle:h_Theammoset);
	CreateTimer(0.1, ammosetStartDelays, any:0, 0);
	return Action:0;
}

public Action:ammoEvent_RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	Theammoset = GetConVarInt(Handle:h_Theammoset);
	CreateTimer(0.1, ammosetStartDelays, any:0, 0);
	return Action:0;
}

public Action:ammosetStartDelays(Handle:timer)
{
	switch (Theammoset)
	{
		case 0: {
			SetConVarInt(FindConVar("ammo_smg_max"), 650, false, false);
			SetConVarInt(FindConVar("ammo_shotgun_max"), 56, false, false);
			SetConVarInt(FindConVar("ammo_autoshotgun_max"), 90, false, false);
			SetConVarInt(FindConVar("ammo_assaultrifle_max"), 360, false, false);
			SetConVarInt(FindConVar("ammo_huntingrifle_max"), 150, false, false);
			SetConVarInt(FindConVar("ammo_sniperrifle_max"), 180, false, false);
			SetConVarInt(FindConVar("ammo_grenadelauncher_max"), 30, false, false);
			SetConVarInt(FindConVar("ammo_m60_max"), 0, false, false);
			//PrintToChatAll("\x04[!提示!]\x03 已关闭更多备弹量! ");
			//PrintToChatAll("\x03!onammo,!onammo1,!onammo2,!offammo进行设置-by望夜 ");
		}
		case 1: {
			SetConVarInt(FindConVar("ammo_smg_max"), 999, false, false);
			SetConVarInt(FindConVar("ammo_shotgun_max"), 168, false, false);
			SetConVarInt(FindConVar("ammo_autoshotgun_max"), 180, false, false);
			SetConVarInt(FindConVar("ammo_assaultrifle_max"), 720, false, false);
			SetConVarInt(FindConVar("ammo_huntingrifle_max"), 300, false, false);
			SetConVarInt(FindConVar("ammo_sniperrifle_max"), 360, false, false);
			SetConVarInt(FindConVar("ammo_grenadelauncher_max"), 60, false, false);
			SetConVarInt(FindConVar("ammo_m60_max"), 150, false, false);
			//PrintToChatAll("\x04[!提示!]\x03 已开启2倍备弹!onammo,!offammo进行设置-by望夜 ");
		}
		case 2: {
			SetConVarInt(FindConVar("ammo_smg_max"), -2, false, false);
			SetConVarInt(FindConVar("ammo_shotgun_max"), -2, false, false);
			SetConVarInt(FindConVar("ammo_autoshotgun_max"), -2, false, false);
			SetConVarInt(FindConVar("ammo_assaultrifle_max"), -2, false, false);
			SetConVarInt(FindConVar("ammo_huntingrifle_max"), -2, false, false);
			SetConVarInt(FindConVar("ammo_sniperrifle_max"), -2, false, false);
			SetConVarInt(FindConVar("ammo_grenadelauncher_max"), -2, false, false);
			SetConVarInt(FindConVar("ammo_m60_max"), -2, false, false);
			//PrintToChatAll("\x04[!提示!]\x03 已开启无限备弹!onammo2,!offammo进行设置-by望夜 ");
		}
		case 3: {
			if (C_SMG == 1000)
			{
				C_SMG = -2;
			}
			if (C_Shotgun == 1000)
			{
				C_Shotgun = -2;
			}
			if (C_Autoshotgun == 1000)
			{
				C_Autoshotgun = -2;
			}
			if (C_AssaultRifle == 1000)
			{
				C_AssaultRifle = -2;
			}
			if (C_HuntingRifle == 1000)
			{
				C_HuntingRifle = -2;
			}
			if (C_SniperRifle == 1000)
			{
				C_SniperRifle = -2;
			}
			if (C_GrenadeLauncher == 1000)
			{
				C_GrenadeLauncher = -2;
			}
			if (C_M60 == 1000)
			{
				C_M60 = -2;
			}
			SetConVarInt(FindConVar("ammo_smg_max"), C_SMG, false, false);
			SetConVarInt(FindConVar("ammo_shotgun_max"), C_Shotgun, false, false);
			SetConVarInt(FindConVar("ammo_autoshotgun_max"), C_Autoshotgun, false, false);
			SetConVarInt(FindConVar("ammo_assaultrifle_max"), C_AssaultRifle, false, false);
			SetConVarInt(FindConVar("ammo_huntingrifle_max"), C_HuntingRifle, false, false);
			SetConVarInt(FindConVar("ammo_sniperrifle_max"), C_SniperRifle, false, false);
			SetConVarInt(FindConVar("ammo_grenadelauncher_max"), C_GrenadeLauncher, false, false);
			SetConVarInt(FindConVar("ammo_m60_max"), C_M60, false, false);
		}
		default: {
			return Action:0;
		}
	}
	//PrintToServer("Ammoset %d", Theammoset);
	return Action:0;
}

