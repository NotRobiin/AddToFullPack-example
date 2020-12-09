#include <amxmodx>
#include <fakemeta>

#define AUTHOR "Wicked - amxx.pl/user/60210-wicked/"

static const PDATA_SAFE = 2;

public plugin_init()
{
    register_plugin("Show dropped guns only for admins", "v1.0", AUTHOR);
    
    register_forward(FM_AddToFullPack, "AddToFullPack", 1);
}

/**
@param es Handle
@param other Index of entity that "player" is looking at
@param other_ent Entity of "other"
@param player Player who is looking around
@param hostflags -
@param ent_is_player Wether entity that "player" is looking at is a player (bool)
@param pSet -
*/
public AddToFullPack(es, other, other_ent, player, hostflags, ent_is_player, pSet)
{
    // Dont affect dead players
    if(!is_user_alive(player))
    {
        return 1;
    }

    // Make sure the ent has pev data.
    if(pev_valid(other) != PDATA_SAFE)
    {
        return 1;
    }

    new class[15];

    pev(other, pev_classname, class, charsmax(class));

    // Check the classname of dropped weapon.
    if(!equal(class, "weaponbox"))
    {
        return 1;
    }

    new f = get_user_flags(player);
    new required = ADMIN_BAN;

    // Make sure the player is an admin.
    if(!(f & required))
    {
        return 1;
    }

    // Hide the weapon entity.
    set_es(es, ES_Effects, EF_NODRAW);

    return 0
}