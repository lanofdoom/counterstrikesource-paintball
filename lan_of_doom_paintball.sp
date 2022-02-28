#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

public const Plugin myinfo = {
    name = "Paintball", author = "LAN of DOOM",
    description = "Replace your bullets with friendly paintballs!",
    version = "0.9.0",
    url = "https://github.com/lanofdoom/counterstrikesource-paintball"};

static ConVar g_paintball_mode_enabled_cvar;

static ArrayList g_decal_indices;

//
// Logic
//

static int PrecacheAndAddToDownloads(const char[] path) {
  char material[PLATFORM_MAX_PATH];
  Format(material, PLATFORM_MAX_PATH, "materials/%s", path);
  AddFileToDownloadsTable(material);

  return PrecacheDecal(path, true);
}

static int RegisterDecal(const char[] path) {
  char vtf[PLATFORM_MAX_PATH];
  Format(vtf, PLATFORM_MAX_PATH, "%s.vtf", path);
  PrecacheAndAddToDownloads(vtf);

  char vmt[PLATFORM_MAX_PATH];
  Format(vmt, PLATFORM_MAX_PATH, "%s.vmt", path);
  return PrecacheAndAddToDownloads(vmt);
}

//
// Hooks
//

static void OnBulletImpact(Handle event, const char[] name,
                           bool dontBroadcast) {
  if (!g_paintball_mode_enabled_cvar.BoolValue || g_decal_indices.Length == 0) {
    return;
  }

  int tick_count = GetGameTickCount();

  float hit_end_pos[3];
  hit_end_pos[0] = GetEventFloat(event, "x");
  hit_end_pos[1] = GetEventFloat(event, "y");
  hit_end_pos[2] = GetEventFloat(event, "z");
  int userid = GetEventInt(event, "userid");

  static int last_tick_count = 0;
  static int last_userid = 0;
  if (tick_count == last_tick_count && userid == last_userid) {
    return;
  }

  last_tick_count = tick_count;
  last_userid = userid;

  int decal_index = GetRandomInt(0, g_decal_indices.Length - 1);
  int decal = g_decal_indices.Get(decal_index);

  TE_Start("World Decal");
  TE_WriteVector("m_vecOrigin", hit_end_pos);
  TE_WriteNum("m_nIndex", decal);
  TE_SendToAll();

  int client = GetClientOfUserId(userid);
  if (!client) {
    return;
  }

  float client_pos[3];
  GetClientEyePosition(client, client_pos);

  float to_hit[3];
  MakeVectorFromPoints(hit_end_pos, client_pos, to_hit);
  NormalizeVector(to_hit, to_hit);

  float from_hit[3];
  from_hit[0] = to_hit[0];
  from_hit[1] = to_hit[1];
  from_hit[2] = to_hit[2];
  NegateVector(from_hit);

  float rotation[3]
  GetVectorAngles(from_hit, rotation);

  TE_Start("Projected Decal");
  TE_WriteVector("m_vecOrigin", hit_end_pos);
  TE_WriteVector("m_angRotation", rotation);
  TE_WriteNum("m_nIndex", decal);
  TE_SendToAll();
}

//
// Forwards
//

public void OnPluginStart() {
  g_paintball_mode_enabled_cvar = CreateConVar(
      "sm_paintball_mode_enabled", "1", "If true, paintball mode is enabled.");

  g_decal_indices = CreateArray(1);

  HookEvent("bullet_impact", OnBulletImpact);
}

public void OnMapStart() {
  g_decal_indices.Clear();
  g_decal_indices.Push(RegisterDecal("paintball/pb_babyblue2"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_black"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_blue2"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_brown"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_cyan"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_dark_green"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_goldenrod"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_green"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_medslateblue"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_olive"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_orange"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_pink"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_red_orange"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_red2"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_violet"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_white2"));
  g_decal_indices.Push(RegisterDecal("paintball/pb_yellow"));
}
