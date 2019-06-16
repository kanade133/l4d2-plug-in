
#include <sourcemod>
#include <sdktools>

public OnPluginStart()
{
	RegConsoleCmd("sm_kill", KillSelf);
	RegConsoleCmd("sm_zs", KillSelf);
}

public Action:KillSelf(client, args)
{
	ForcePlayerSuicide(client);
}
