_addon.name    = 'Hungry'
_addon.author  = 'Kainminter'
_addon.version = '1.3'
_addon.command = 'hungry'


require('logger')
texts = require('texts')


local settings = {
    display_text        = true,       -- Toggle on/off wavy text display.
    play_sound          = false,       -- Toggle on/off stomach grumble sound.
    reminder_text       = "Hungry...",-- The reminder string.
	letter_size			= 60,
    letter_spacing      = 60 , 
    letter_alpha      = 100 ,
	letter_font			= 'Verdana',
	letter_bold			= true,
	pos_x_offset		= 0,
	pos_y_offset		= -500,
    amplitude           = 20,         -- Maximum vertical offset (in pixels) for the sine wave.
    frequency           = 2,          -- How fast the wave oscillates (radians per second).
    phase_offset        = 0.5,        -- Phase difference between each successive letter.
    sound_min_interval  = 15,         -- Minimum seconds between grumbles.
    sound_max_interval  = 30,         -- Maximum seconds between grumbles.

    food_buff_ids       = {

        [251] = true,

    },
}

local letters = {}


local screen_center_x, screen_center_y


local function init_text_objects()

    local ws = windower.get_windower_settings()
screen_center_x = ws.x_res / 2
screen_center_y = ws.y_res / 2

    local len = settings.reminder_text:len()
    local total_width = (len - 1) * settings.letter_spacing
    local start_x = screen_center_x - (total_width / 2)

    for i = 1, len do
        local char = settings.reminder_text:sub(i, i)
        local pos_x = start_x + (i - 1) * settings.letter_spacing

        local t = texts.new(char, { pos = { x = pos_x, y = screen_center_y }, visible = false })

        t:color(255, 0, 0)
        t:alpha(settings.letter_alpha)
        t:size(settings.letter_size)
		t:bg_alpha(0) 
		t:font(settings.letter_font)  
		t:bold(settings.letter_bold)  	

        letters[i] = { text_obj = t, base_x = pos_x, index = i }
    end
end


local function is_food_active()
    local player = windower.ffxi.get_player()
    if not player or not player.buffs then
        return true  -- If no player data, assume food is active to avoid false alert
    end

    for _, buff in ipairs(player.buffs) do
        if buff and settings.food_buff_ids[buff] then
            return true
        end
    end
    return false
end


local function update_texts()
    local current_time = os.clock()


    local fade_value = (math.sin(current_time * math.pi / 1.5) + 1) / 2  -- Maps from 0 to 1
    local alpha_value = math.floor(fade_value * settings.letter_alpha)  -- Scale to max alpha

    for _, letter in ipairs(letters) do
        local offset_y = settings.amplitude * math.sin(current_time * settings.frequency + letter.index * settings.phase_offset)
        letter.text_obj:pos(letter.base_x + settings.pos_x_offset, screen_center_y + offset_y + settings.pos_y_offset)
        letter.text_obj:alpha(alpha_value)  -- Apply the fade effect
    end
end

local function show_texts(show)
    for _, letter in ipairs(letters) do
        letter.text_obj:visible(show)
    end
end


local function play_grumble_sound()
    --Here is where the tummy grumble noise would go... IF I HAD ONE
	--windower.play_sound('hungry.wav')
	
end

local last_sound_time = os.clock()
local next_sound_time = last_sound_time + math.random(settings.sound_min_interval, settings.sound_max_interval)

windower.register_event('prerender', function()
    if is_food_active() then
        -- When the food buff is present, hide the reminder.
        show_texts(false)
        return
    else
        if settings.display_text then
            show_texts(true)
            update_texts()
        end
    end


    if settings.play_sound and not is_food_active() then
        local now = os.clock()
        if now >= next_sound_time then
            play_grumble_sound()
            next_sound_time = now + math.random(settings.sound_min_interval, settings.sound_max_interval)
        end
    end
end)


windower.register_event('addon command', function(cmd, ...)
    local args = {...}
    if cmd == 'text' then
        if args[1] == 'on' then
            settings.display_text = true
            log('Hungry: Text reminder enabled.')
        elseif args[1] == 'off' then
            settings.display_text = false
            show_texts(false)
            log('Hungry: Text reminder disabled.')
        else
            log('Usage: //hungry text [on|off]')
        end
    elseif cmd == 'sound' then
        if args[1] == 'on' then
            settings.play_sound = true
            log('Hungry: Sound reminder enabled.')
        elseif args[1] == 'off' then
            settings.play_sound = false
            log('Hungry: Sound reminder disabled.')
        else
            log('Usage: //hungry sound [on|off]')
        end

    elseif cmd == 'pos' then
reset_text_objects()
        if args[1] == 'x' and tonumber(args[2]) then
            settings.pos_x_offset = tonumber(args[2])
            log('Hungry: X position offset set to ' .. settings.pos_x_offset)
            init_text_objects() -- Reinitialize text objects
        elseif args[1] == 'y' and tonumber(args[2]) then
            settings.pos_y_offset = tonumber(args[2])
            log('Hungry: Y position offset set to ' .. settings.pos_y_offset)
            init_text_objects()
        else
            log('Usage: //hungry pos [x|y] <value>')
        end


    elseif cmd == 'size' and tonumber(args[1]) then
reset_text_objects()
        local new_size = tonumber(args[1])
        settings.letter_size = new_size
        settings.letter_spacing = new_size
        log('Hungry: Letter size & spacing set to ' .. new_size)
        init_text_objects() -- Reinitialize with new size & spacing

	
    else
        log('Usage:')
        log('//hungry text [on|off] | sound [on|off]')
        log('//hungry pos [x|y] <value>  (Move text)')
        log('//hungry size <value>  (Change letter size & spacing)')    end
end)


init_text_objects()


windower.register_event('unload', function()
    for _, letter in ipairs(letters) do
        letter.text_obj:destroy()
    end
end)

function reset_text_objects()
    -- Destroy all existing text objects
    for _, letter in ipairs(letters) do
        if letter.text_obj then
            letter.text_obj:destroy()
        end
    end
    letters = {} -- Clear table
    init_text_objects() -- Reinitialize text objects
end
