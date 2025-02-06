_addon.name = 'HelpNa'
_addon.version = '2.0'
_addon.author = 'Kainminter'
_addon.commands = {'hn', 'helpna'}

require('tables')
require('strings')




--SETTINGS
	local ADDON_COOLDOWN = 5 -- seconds
	local CAST_COOLDOWN = 4  -- seconds
	local MOVE_COOLDOWN = 1  -- seconds

-- Default actions  (example: keyword = 'Spell Name')
local actions = {
    para    = 'Paralyna',
    pois    = 'Poisona',
    psn     = 'Poisona',
    silence = 'Silena',
    silena  = 'Silena',
    zzz     = 'Cure',
    erase   = "Erase",
    slow    = "Erase",
    bio     = "Erase",
    bind    = "Erase",
    bound   = "Erase",
    gravi   = "Erase",
    help    = "Cure IV",
    cure    = "Cure III",
    blind   = "Blindna",
    petri   = "Stona",
    stone   = "Stona",
    curs    = "Cursna",
    doom    = "Cursna",
    curaga  = "Curaga",
    pro     = "Protect V",
    shell   = "Shell V",
    haste   = "Haste",  -- Auto changes to Haste II if RDM of appropriate level
    flurry  = "Flurry", -- Auto changes to Flurry II if RDM of appropriate level
    refresh = "Refresh",-- Auto changes to Refresh II/III if RDM of appropriate level
    phalanx = "Phalanx II",
    raise   = "Arise",
    r1      = "Arise",
    r2      = "Arise",
    r3      = "Arise",
    arise   = "Arise",
    charm   = "Sleep",
    aurora  = "Aurorastorm II",
}


--Other Variables
	local castQueue = {}   
	local busyUntil = 0    
	local last_position = nil
	local last_cast_time = 0
	local last_move_time = 0
	Trueaction = 0 --global


local function enqueue_cast(target, spell)
    table.insert(castQueue, {target = target, spell = spell, time = os.clock()})
    windower.add_to_chat(207, string.format('Queued cast: %s -> %s', spell, target))
end

windower.register_event('prerender', function()
    local now = os.clock()
	
	-- Reasons to do nothing:
	if is_player_moving() then return end 	--Moving
	if is_casting() then return end			--Performing other actions
    if now < busyUntil then return end		-- Addon cooldown
    if #castQueue == 0 then return end 		-- Nothing in queue

	-- Cast next spell from the queue, and take it off the stack.
    local req = table.remove(castQueue, 1)
    windower.send_command(string.format('input /ma "%s" %s', req.spell, req.target))
    busyUntil = now + ADDON_COOLDOWN
end)

windower.register_event('incoming text', function(original, modified, mode, is_self)
    
	if mode == 13 then --13 = Party Chat
        local sender, message = original:match("^(%b())%s*(.+)$") --Expecting FFXI default party chat format, saves sender's name. May not work if format is not vanilla
        if sender then
            sender = sender:sub(4, -4)
        end

        -- Update job-specific spell names based on current player status.
        local player = windower.ffxi.get_player()
        if player then
            local mainjob   = player.main_job 
            local mainlevel = player.main_job_level 
            -- local subjob  = player.sub_job  -- not used here, but available if needed
            -- local sublevel = player.sub_job_level  
            
            if mainjob == "RDM" then
                if mainlevel > 95 then 
                    actions.haste   = "Haste II" 
                    actions.flurry  = "Flurry II" 
                end
                if mainlevel > 81 and mainlevel < 99 then 
                    actions.refresh = "Refresh II" 
                end
                if mainlevel > 98 then 
                    actions.refresh = "Refresh III" 
                end
            end
        end
		-- Put the request in the queue
        if sender and message then
            for keyword, spell in pairs(actions) do
                if message:lower():contains(keyword) then
                    enqueue_cast(sender, spell)
                    break
                end
            end
        end
    end
end)

-- Allow user to add/remove keywords via command
windower.register_event('addon command', function(cmd, keyword, spell)
    if cmd:lower() == 'add' and keyword and spell then
        actions[keyword:lower()] = spell
        windower.add_to_chat(207, string.format('Added keyword: %s -> %s', keyword, spell))
    elseif cmd:lower() == 'remove' and keyword then
        actions[keyword:lower()] = nil
        windower.add_to_chat(207, string.format('Removed keyword: %s', keyword))
    else
        windower.add_to_chat(207, 'Usage: //helpna add <keyword> <spell> | //helpna remove <keyword>')
    end
end)

function get_player_status()  -- 0 idle, 1 engage, 33 rest, -1 no player/zone, 
    local player = windower.ffxi.get_mob_by_target('me')
    if not player then
        return -1
    end

	if player.status then return player.status else return -1 end

end

function is_player_moving()

    local current_time = os.clock()
    local player = windower.ffxi.get_mob_by_target('me')
    if not player then
        return false
    end

    local current_position = {x = player.x, y = player.y, z = player.z}
    local moving = false
	if (current_time - last_move_time) < MOVE_COOLDOWN then moving = true end

    if last_position then
        local dx = current_position.x - last_position.x
        local dy = current_position.y - last_position.y
        local dz = current_position.z - last_position.z
        local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

        if distance > 0.1 then
            moving = true
			last_move_time = os.clock()
        end
    end

    last_position = current_position
    return moving
end

windower.register_event('action', function(action)
    local player = windower.ffxi.get_player()
    if not player then return end

    if action.actor_id == player.id then
		Trueaction = action.category
         if Trueaction ~= 0 and Trueaction ~= 8 then
             last_cast_time = os.clock()
			 Trueaction = 0
         end
    end
end)

function is_casting()
    local current_time = os.clock()
    if Trueaction ~= 0 then return true end
	return (current_time - last_cast_time) < CAST_COOLDOWN
end




