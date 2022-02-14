#include <sdktools>
#include <sourcemod>

public const Plugin myinfo = {
    name = "Paintball", author = "LAN of DOOM",
    description = "Replace your bullets with friendly paintballs!",
    version = "0.8.0",
    url = "https://github.com/lanofdoom/counterstrikesource-paintball"};

static ConVar g_paintball_mode_enabled_cvar;

static ArrayList g_decal_indices;

//
// Logic
//

int PrecacheAndAddToDownloads(const char[] path) {
  char material[PLATFORM_MAX_PATH];
  Format(material, PLATFORM_MAX_PATH, "materials/%s", path);
  AddFileToDownloadsTable(material);

  return PrecacheDecal(path, true);
}

int RegisterDecal(const char[] path) {
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

static Action OnBulletImpact(Handle event, const char[] name,
                             bool dontBroadcast) {
  if (!g_paintball_mode_enabled_cvar.BoolValue || g_decal_indices.Length == 0) {
    return Plugin_Continue;
  }

  float xyz[3];
  xyz[0] = GetEventFloat(event, "x");
  xyz[1] = GetEventFloat(event, "y");
  xyz[2] = GetEventFloat(event, "z");

  int index = GetRandomInt(0, g_decal_indices.Length - 1);

  TE_Start("World Decal");
  TE_WriteVector("m_vecOrigin", xyz);
  TE_WriteNum("m_nIndex", g_decal_indices.Get(index));
  TE_SendToAll();

  return Plugin_Continue;
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