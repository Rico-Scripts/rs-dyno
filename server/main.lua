local cooldown = {}

RegisterNetEvent('rs-dyno:server:result', function(data)
    local src = source
    if Config.RequireAce and not IsPlayerAceAllowed(src, Config.Ace) then return end
    local now = os.time()
    if cooldown[src] and cooldown[src] > now then return end
    if type(data) ~= 'table' or type(data.speed) ~= 'number' or data.speed < 0 or data.speed > Config.MaxSpeedKmh then return end
    data.plate = tostring(data.plate or 'ONBEKEND'):sub(1, 12)
    data.model = tostring(data.model or 'ONBEKEND'):sub(1, 32)
    data.hp = math.max(1, math.min(2500, math.floor(tonumber(data.hp) or 1)))
    data.rpm = math.max(0, math.min(1, tonumber(data.rpm) or 0))
    cooldown[src] = now + Config.CooldownSeconds
    TriggerClientEvent('rs-dyno:client:result', src, data)

    local fields = {
        { name = 'Speler', value = ('%s (`%s`)'):format(GetPlayerName(src) or 'Onbekend', src), inline = false },
        { name = 'Voertuig', value = data.model, inline = true },
        { name = 'Kenteken', value = data.plate, inline = true },
        { name = 'Meting', value = ('%d pk indicatie\n%.1f km/u\n%.0f%% RPM'):format(data.hp, data.speed, data.rpm * 100), inline = false }
    }
    if GetResourceState('RS-core') == 'started' then
        exports['RS-core']:Log('Dyno-meting', 'Een nieuwe dyno-meting is voltooid.', 10181046, fields, Config.Webhook ~= '' and Config.Webhook or nil)
    elseif Config.Webhook ~= '' then
        PerformHttpRequest(Config.Webhook, function() end, 'POST', json.encode({ username = 'Rico Scripts', embeds = {{ title = 'Dyno-meting', color = 10181046, fields = fields }} }), { ['Content-Type'] = 'application/json' })
    end
end)

AddEventHandler('playerDropped', function() cooldown[source] = nil end)

