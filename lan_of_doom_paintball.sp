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

static const int kDecalBrightness = 255;
static const float kDecalLife = 2.0;
static const float kDecalSize = 0.0;

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
  TE_SetupGlowSprite(xyz, g_decal_indices[index], kDecalLife, kDecalSize,
                     kDecalBrightness);
  TE_SendToAll();

  PrintToServer("TE_SetupGlowSprite((%f, %f, %f), %d, %d, %f, %d)", xyz[0],
                xyz[1], xyz[2], g_decal_indices[index], kDecalLife, kDecalSize,
                kDecalBrightness);

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
  g_decal_indices[0] = PrecacheDecal("spb/spb_shot1.vmt", true);
  AddFileToDownloadsTable("materials/spb/spb_shot1.vmt");
  AddFileToDownloadsTable("materials/spb/spb_shot1.vtf");

  g_decal_indices[1] = PrecacheDecal("spb/spb_shot2.vmt", true);
  AddFileToDownloadsTable("materials/spb/spb_shot2.vmt");
  AddFileToDownloadsTable("materials/spb/spb_shot2.vtf");

  g_decal_indices[2] = PrecacheDecal("spb/spb_shot3.vmt", true);
  AddFileToDownloadsTable("materials/spb/spb_shot3.vmt");
  AddFileToDownloadsTable("materials/spb/spb_shot3.vtf");

  g_decal_indices[3] = PrecacheDecal("spb/spb_shot5.vmt", true);
  AddFileToDownloadsTable("materials/spb/spb_shot5.vmt");
  AddFileToDownloadsTable("materials/spb/spb_shot5.vtf");

  g_decal_indices[4] = PrecacheDecal("spb/spb_shot6.vmt", true);
  AddFileToDownloadsTable("materials/spb/spb_shot6.vmt");
  AddFileToDownloadsTable("materials/spb/spb_shot6.vtf");

  g_decal_indices[5] = PrecacheDecal("spb/spb_shot7.vmt", true);
  AddFileToDownloadsTable("materials/spb/spb_shot7.vmt");
  AddFileToDownloadsTable("materials/spb/spb_shot7.vtf");

  g_decals_indices_valid = true;
}