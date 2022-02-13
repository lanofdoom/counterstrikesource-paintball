#include <sdktools>
#include <sourcemod>

public const Plugin myinfo = {
    name = "Paintball", author = "LAN of DOOM",
    description = "Replace your bullets with friendly paintballs!",
    version = "1.0.0",
    url = "https://github.com/lanofdoom/counterstrikesource-paintball"};

static ConVar g_paintball_mode_enabled_cvar;

#define NUM_INDICES 6
static int g_decal_indices[NUM_INDICES];
static bool g_decals_indices_valid = false;

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
  if (!g_paintball_mode_enabled_cvar.BoolValue || !g_decals_indices_valid) {
    return Plugin_Continue;
  }

  float xyz[3];
  xyz[0] = GetEventFloat(event, "x");
  xyz[1] = GetEventFloat(event, "y");
  xyz[2] = GetEventFloat(event, "z");

  int index = GetRandomInt(0, NUM_INDICES - 1);

  TE_Start("World Decal");
  TE_WriteVector("m_vecOrigin", xyz);
  TE_WriteNum("m_nIndex", g_decal_indices[index]);
  TE_SendToAll();

  return Plugin_Continue;
}

//
// Forwards
//

public void OnPluginStart() {
  g_paintball_mode_enabled_cvar = CreateConVar(
      "sm_paintball_mode_enabled", "1", "If true, paintball mode is enabled.");

  HookEvent("bullet_impact", OnBulletImpact);
}

public void OnMapStart() {
  g_decal_indices[0] = RegisterDecal("spb/spb_shot1");
  g_decal_indices[1] = RegisterDecal("spb/spb_shot2");
  g_decal_indices[2] = RegisterDecal("spb/spb_shot3");
  g_decal_indices[3] = RegisterDecal("spb/spb_shot5");
  g_decal_indices[4] = RegisterDecal("spb/spb_shot6");
  g_decal_indices[5] = RegisterDecal("spb/spb_shot7");
  g_decals_indices_valid = true;
}