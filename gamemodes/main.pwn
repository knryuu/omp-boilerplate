/*
 * OPEN.MP Simple Boilerplate
 * Version: 1.0
 * Author: Yuuki Tachyon (NaCl)
 *
 * Licensed under MIT, please don't voilate the copyright by mentioning my name
 * when you use this gamemode for comercial use!
 *
*/

#include <open.mp>

#undef MAX_PLAYERS
#define MAX_PLAYERS                     100 // sesuaikan dengan jumlah maksimal pemain di config.json!

#define SERVER_MYSQL_HOSTNAME           "localhost"
#define SERVER_MYSQL_USERNAME           "root"
#define SERVER_MYSQL_PASSWORD           ""
#define SERVER_MYSQL_DATABASE           "testdb"

#define DEFAULT_SPAWN_SKIN              (1)
#define DEFAULT_SPAWN_X                 (0.0)
#define DEFAULT_SPAWN_Y                 (0.0)
#define DEFAULT_SPAWN_Z                 (0.0)
#define DEFAULT_SPAWN_ANGLE             (90.0)

#include <a_mysql>
#include <foreach>
#include <Pawn.CMD>

new
    MySQL:g_iHandle,
    Iterator:SpawnedPlayers<MAX_PLAYERS>;

void:ClearConsole(lines=5)
{
    while(--lines) print("");
}

ReturnPlayerName(playerid)
{
    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    return name;
}

public OnGameModeInit()
{
    ClearConsole();

    print("+---------------------------------+");
    print("|   open.mp / SA:MP Boilerplate   |");
    print("|    Created by Yuuki Tachyon     |");
    print("+---------------------------------+");

    ClearConsole(1);
    print(" [...] Connecting you to mysql...");

    g_iHandle = mysql_connect(
        SERVER_MYSQL_HOSTNAME,
        SERVER_MYSQL_USERNAME,
        SERVER_MYSQL_PASSWORD,
        SERVER_MYSQL_DATABASE
    );

    if (g_iHandle == MYSQL_INVALID_HANDLE || mysql_errno(g_iHandle))
    {
        new reason[128];
        mysql_error(reason);
        print(" [ x_x ] Failed to connect ot mysql.");
        printf(" Reason: %s", reason);

        SendRconCommand("exit"); // keluar dari server
        return 0;
    }

    print(" [ ^_^ ] MySQL Connection success!");
    return 1;
}

main()
{
    ClearConsole(3);
    print("+-----------------------------------------+");
    print("| Copyright (c) 2025, all rights reserved |");
    print("+-----------------------------------------+");
}

public OnPlayerConnect(playerid)
{
    SetSpawnInfo(playerid,
        NO_TEAM,
        DEFAULT_SPAWN_SKIN,
        DEFAULT_SPAWN_X,
        DEFAULT_SPAWN_Y,
        DEFAULT_SPAWN_Z,
        DEFAULT_SPAWN_ANGLE
    );

    SpawnPlayer(playerid);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    // Add to spawn iterator.
    if (!Iter_Contains(SpawnedPlayers, playerid))
    {
        Iter_Add(SpawnedPlayers, playerid);
    }
    return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if (!Iter_Contains(SpawnedPlayers, playerid))
    {
        SendClientMessage(playerid, 0xFF0000AA, "[ERROR]:{FFFFFF} Anda tidak bisa menggunakan perintah ketika belum spawn!");
        return 0; // tolak perintah dengan error kita!
    }

    return 1; // lanjutkan Pawn.CMD!
}

public OnPlayerDisconnect(playerid, reason)
{
    static arrReason[][] = {
        "Crash/Timeout",
        "Exit/Leaving",
        "Kicked/Banned"
    };

    SendClientMessageToAll(0xFFFFFFAA, "[LEAVE]: Pemain %s telah keluar dari game (Alasan: %s)", ReturnPlayerName(playerid), arrReason[reason]);
    return 1;
}

public OnGameModeExit()
{
    if (g_iHandle != MYSQL_INVALID_HANDLE)
    {
        mysql_close(g_iHandle);
    }
    return 1;
}

CMD:halo(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFFAA, "[SERVER]: Halo juga!");
    return 1;
}

CMD:sebutnamaku(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFFAA, "[SERVER]: Nama kamu %s", ReturnPlayerName(playerid));
    return 1;
}
