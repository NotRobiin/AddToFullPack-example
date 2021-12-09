#include <amxmodx>
#include <fakemeta>

#define AUTHOR "Wicked - amxx.pl/user/60210-wicked/"

native user_add_blocked_class(index, const class[]);
native user_remove_blocked_class(index, const class[]);

native user_add_blocked_ent(index, ent);
native user_remove_blocked_ent(index, ent);

new c4_ent = -1;

public plugin_init()
{
    register_plugin("API test for hiding entities", "v1.0", AUTHOR);

    register_clcmd("say /hide", "handle_hide");
    register_clcmd("say /show", "handle_show");
    register_event("HLTV", "new_round", "a", "1=0", "2=0")
}
 
public new_round()
{
    ForPlayers(i)
    {
        if(!is_user_connected(i) && !is_user_hltv(i))
        {
            continue;
        }

        user_remove_blocked_ent(i, c4_ent);
        client_print(i, print_chat, "Removed draw block of c4 (c4_ent=%i) from player %n.", c4_ent, i);
    }
    
    c4_ent = -1;
}

public bomb_planted()
{
    c4_ent = get_c4_ent();
}

public handle_hide(index)
{
    // Block drawing c4 by ent.
    user_add_blocked_ent(index, c4_ent);
    client_print(index, print_chat, "Now blocking bomb draw (c4_ent=%i).", c4_ent);
    
    // Block drawing dropped weapons.
    user_add_blocked_class(index, "weaponbox");
    client_print(index, print_chat, "Now blocking dropped weapons draw (class=weaponbox)");
}

public handle_show(index)
{
    user_remove_blocked_ent(index, c4_ent);
    client_print(index, print_chat, "Now drawing bomb (c4_ent=%i).", c4_ent);

    // Block drawing dropped weapons.
    user_remove_blocked_class(index, "weaponbox");
    client_print(index, print_chat, "Now drawing dropped weapons (class=weaponbox)");
}

stock get_c4_ent()
{
    new ent = -1;

    while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "grenade"))
        && (!(get_pdata_int(ent, 96) & (1<<8)))) { }
    
    if(ent)
    {
        return ent;
    }

    return 0;
}