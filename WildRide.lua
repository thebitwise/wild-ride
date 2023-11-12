--$$\        $$$$$$\  $$\   $$\  $$$$$$\  $$$$$$$$\ 
--$$ |      $$  __$$\ $$$\  $$ |$$  __$$\ $$  _____|
--$$ |      $$ /  $$ |$$$$\ $$ |$$ /  \__|$$ |      
--$$ |      $$$$$$$$ |$$ $$\$$ |$$ |      $$$$$\    
--$$ |      $$  __$$ |$$ \$$$$ |$$ |      $$  __|   
--$$ |      $$ |  $$ |$$ |\$$$ |$$ |  $$\ $$ |      
--$$$$$$$$\ $$ |  $$ |$$ | \$$ |\$$$$$$  |$$$$$$$$\ 
--\________|\__|  \__|\__|  \__| \______/ \________|
-- coded by Lance/stonerchrist on Discord
pluto_use "0.5.0"
util.require_natives("2944a", "g")
menu.my_root():divider('WildRide')

local active_rideable_animal = 0

function notify(text)
    util.toast('[WILDRIDE] ' .. text)
end


function request_model_load(hash)
    util.request_model(hash, 2000)
end

local function request_anim_dict(dict)
    while not HAS_ANIM_DICT_LOADED(dict) do
        REQUEST_ANIM_DICT(dict)
        util.yield()
    end
end


-- rideable animal tick handler
util.create_tick_handler(function()
    if active_rideable_animal ~= 0 then 

        -- dismounting 
        if IS_CONTROL_JUST_PRESSED(23, 23) then 
            DETACH_ENTITY(players.user_ped())
            entities.delete_by_handle(active_rideable_animal)
            CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
            active_rideable_animal = 0
        end

        -- movement
        if not IS_ENTITY_IN_AIR(active_rideable_animal) then 
            if IS_CONTROL_PRESSED(32, 32) then 
                local side_move = GET_CONTROL_NORMAL(146, 146)
                local fwd = GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(active_rideable_animal, side_move*10.0, 8.0, 0.0)
                TASK_LOOK_AT_COORD(active_rideable_animal, fwd.x, fwd.y, fwd.z, 0, 0, 2)
                TASK_GO_STRAIGHT_TO_COORD(active_rideable_animal, fwd.x, fwd.y, fwd.z, 20.0, -1, GET_ENTITY_HEADING(active_rideable_animal), 0.5)
            end
            if IS_CONTROL_JUST_PRESSED(76, 76) then 
                --CLEAR_PED_TASKS(active_rideable_animal)
                local w = {}
                w.x, w.y, w.z, _ = players.get_waypoint(players.user())
                if w.x == 0.0 and w.y == 0.0 then 
                    notify("No waypoint set.")
                else
                    TASK_FOLLOW_NAV_MESH_TO_COORD(active_rideable_animal, w.x, w.y, w.z, 1.0, -1, 100, 0, 0)
                end
            end
        end

    end
end)

local ranimal_hashes = {
    util.joaat("a_c_deer"), util.joaat("a_c_boar"), util.joaat("a_c_cow"),
    util.joaat('a_c_coyote'), util.joaat('a_c_mtlion'), util.joaat('a_c_pig'), util.joaat('a_c_retriever'),
    util.joaat('a_c_rottweiler'), util.joaat('a_c_shepherd')
}

menu.my_root():list_action("Ride an animal", {"rideanimal"}, "", {"Deer", "Boar", "Cow", "Coyote", "Mountain Lion", "Pig", "Golden Retriever", 'Rottweiler', 'Shepherd'}, function(index)
    if active_rideable_animal ~= 0 then 
        notify("You are already riding an animal. Get off it to spawn another.")
        return 
    end
    local hash = ranimal_hashes[index]
    request_model_load(hash)
    local animal = entities.create_ped(8, hash, players.get_position(players.user()), GET_ENTITY_HEADING(players.user_ped()))
    SET_ENTITY_INVINCIBLE(animal, true)
    FREEZE_ENTITY_POSITION(animal, true)
    FREEZE_ENTITY_POSITION(players.user_ped(), true)
    active_rideable_animal = animal
    local m_z_off = 0 
    local f_z_off = 0

    switch index do 
        case 1: 
            m_z_off = 0.3 
            f_z_off = 0.15
            break
        case 2:
            m_z_off = 0.4
            f_z_off = 0.3
            break
        case 3:
            m_z_off = 0.2 
            f_z_off = 0.1 
            break
    end

    if GET_ENTITY_MODEL(players.user_ped()) == util.joaat("mp_f_freemode_01") then 
        z_off = f_z_off
    else
        z_off = m_z_off
    end

    ATTACH_ENTITY_TO_ENTITY(players.user_ped(), animal, GET_PED_BONE_INDEX(animal, 24816), -0.3, 0.0, z_off, 0.0, 0.0, 90.0, false, false, false, true, 2, true)
    request_anim_dict("rcmjosh2")
    TASK_PLAY_ANIM(players.user_ped(), "rcmjosh2", "josh_sitting_loop", 8.0, 1, -1, 2, 1.0, false, false, false)
    notify("Use your regular player movement controls to move the animal.\nPress your vehicle dismount key to dismount.\nPress your jump key to teleport to your waypoint.")
    FREEZE_ENTITY_POSITION(animal, false)
    FREEZE_ENTITY_POSITION(players.user_ped(), false)

end)

menu.my_root():hyperlink('Join Discord', 'https://discord.gg/zZ2eEjj88v', '')
