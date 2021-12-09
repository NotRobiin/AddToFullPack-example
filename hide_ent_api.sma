#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>

#define AUTHOR "Wicked - amxx.pl/user/60210-wicked/"

const PDATA_SAFE = 2;
const MAX_CLASSNAME = 32;

// #define DEBUG_MODE
#define HIDE_ENT 0
#define SHOW_ENT 1

new Array:blocked_classes[MAX_PLAYERS + 1];
new Array:blocked_ents[MAX_PLAYERS + 1];

public plugin_init()
{
    register_plugin("Block showing certain entities", "v1.0", AUTHOR);
    
    register_forward(FM_AddToFullPack, "AddToFullPack", 1);
}

public plugin_natives()
{
    register_native("user_add_blocked_class", "native_user_add_blocked_class", 0);
    register_native("user_add_blocked_ent", "native_user_add_blocked_ent", 0);

    register_native("user_remove_blocked_class", "native_user_remove_blocked_class", 0);
    register_native("user_remove_blocked_ent", "native_user_remove_blocked_ent", 0);
}

/**
    @desc Adds passed classname to the list of classnames blocked from drawing to player.
    @param index, Int, Connected player index (1-32).
    @param class[], String, Classname to be blocked from drawing.
 */
public native_user_add_blocked_class(plugin, params)
{
    if(params != 2)
    {
        return 0;
    }

    new index = get_param(1);

    if(!is_user_connected(index) || is_user_hltv(index) || blocked_classes[index] == Invalid_Array)
    {
        return 0;
    }

    new temp_class[MAX_CLASSNAME + 1];
    get_string(2, temp_class, charsmax(temp_class));

    if(strlen(temp_class) == 0)
    {
        return 0;
    }

    ArrayPushString(blocked_classes[index], temp_class);

    #if defined DEBUG_MODE
        log_amx("Pushing class: ^"%s^" for player %i (%n)", temp_class, index, index);
    #endif

    return 1;
}

/**
    @desc Removes passed classname from the list of blocked from drawing to player.
    @param index, Int, Connected player index (1-32).
    @param class[], String, Classname to be drawn again.
 */
public native_user_remove_blocked_class(plugin, params)
{
    if(params != 2)
    {
        return 0;
    }

    new index = get_param(1);

    if(!is_user_connected(index) || is_user_hltv(index) || blocked_classes[index] == Invalid_Array)
    {
        return 0;
    }

    new temp_class[MAX_CLASSNAME + 1];
    get_string(2, temp_class, charsmax(temp_class));

    if(strlen(temp_class) == 0)
    {
        return 0;
    }
    
    new loop_class[MAX_CLASSNAME + 1];
    new array_id = -1;

    ForDynamicArray(i, blocked_classes[index])
    {
        ArrayGetString(blocked_classes[index], i, loop_class, charsmax(loop_class));

        if(equal(temp_class, loop_class))
        {
            array_id = i;
            break;
        }
    }

    if(array_id != -1)
    {
        ArrayDeleteItem(blocked_classes[index], array_id);
        
        #if defined DEBUG_MODE
            log_amx("Removing class: ^"%s^" for player %i (%n)", temp_class, index, index);
        #endif

        
        return 1;
    }

    return 0;
}

/**
    @desc Adds passed ent to the list of ents blocked from drawing to player.
    @param index, Int, Connected player index (1-32).
    @param ent, Int, Index of entity to be blocked from drawing.
 */
public native_user_add_blocked_ent(plugin, params)
{
    if(params != 2)
    {
        return 0;
    }

    new index = get_param(1);

    if(!is_user_connected(index) || is_user_hltv(index) || blocked_classes[index] == Invalid_Array)
    {
        return 0;
    }

    new ent = get_param(2);
    
    if(ent <= 0 || !pev_valid(ent))
    {
        return 0;
    }

    ArrayPushCell(blocked_ents[index], ent);

    #if defined DEBUG_MODE
        log_amx("Pushing ent: %i for player %i (%n)", ent, index, index);
    #endif


    return 1;
}

/**
    @desc Removes passed ent from the list of blocked from drawing to player.
    @param index, Int, Connected player index (1-32).
    @param ent, Int, Entity index to be drawn again.
 */
public native_user_remove_blocked_ent(plugin, params)
{
    if(params != 2)
    {
        return 0;
    }

    new index = get_param(1);

    if(!is_user_connected(index) || is_user_hltv(index) || blocked_classes[index] == Invalid_Array)
    {
        return 0;
    }

    new ent = get_param(2);

    if(!pev_valid(ent))
    {
        return 0;
    }
    
    new loop_ent;
    new array_id = -1;

    ForDynamicArray(i, blocked_ents[index])
    {
        loop_ent = ArrayGetCell(blocked_ents[index], i);

        if(ent == loop_ent)
        {
            array_id = i;
            break;
        }
    }

    if(array_id != -1)
    {
        ArrayDeleteItem(blocked_ents[index], array_id);
        
        #if defined DEBUG_MODE
            log_amx("Removing ent: %i for player %i (%n)", ent, index, index);
        #endif

        return 1;
    }

    return 0;
}

public client_putinserver(index)
{
    blocked_classes[index] = ArrayCreate(MAX_CLASSNAME, 1);
    blocked_ents[index] = ArrayCreate(1, 1);
}

public client_disconnected(index)
{
    if(blocked_classes[index] != Invalid_Array) ArrayDestroy(blocked_classes[index]);
    if(blocked_ents[index] != Invalid_Array) ArrayDestroy(blocked_ents[index]);
}

public AddToFullPack(es, other, other_ent, player, hostflags, ent_is_player, pSet)
{
    // Make sure the ent has pev data.
    if(pev_valid(other) != PDATA_SAFE)
    {
        return SHOW_ENT;
    }

    // Dont affect dead players
    if(!is_user_alive(player))
    {
        return SHOW_ENT;
    }

    new bool:block = false;

    if(blocked_classes[player] != Invalid_Array)
    {
        // Check by classname.
        new ent_class[MAX_CLASSNAME + 1];
        new blocked_class[MAX_CLASSNAME + 1];
        pev(other, pev_classname, ent_class, charsmax(ent_class));

        ForDynamicArray(i, blocked_classes[player])
        {
            ArrayGetString(blocked_classes[player], i, blocked_class, charsmax(blocked_class));

            if(equal(ent_class, blocked_class))
            {
                block = true;
                break;
            }
        }
    }

    // Check by ents if classes did not work.
    if(!block && blocked_ents[player] != Invalid_Array)
    {
        new blocked_ent;

        ForDynamicArray(i, blocked_ents[player])
        {
            blocked_ent = ArrayGetCell(blocked_ents[player], i);

            if(other_ent == blocked_ent)
            {
                block = true;
                break;
            }
        }
    }

    // Entity is not blocked.
    if(!block)
    {
        return SHOW_ENT;
    }

    // Hide the entity.
    set_es(es, ES_Effects, EF_NODRAW);

    return HIDE_ENT;
}