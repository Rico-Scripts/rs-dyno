local testing = false

RegisterCommand(Config.Command, function()
    if testing then return end
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then
        TriggerEvent('chat:addMessage', { args = { 'Dyno', 'Je moet als bestuurder in een voertuig zitten.' } })
        return
    end

    testing = true
    local start = GetGameTimer()
    local maxSpeed, maxRpm = 0.0, 0.0
    TriggerEvent('chat:addMessage', { args = { 'Dyno', ('Meting gestart voor %s seconden.'):format(Config.TestSeconds) } })
    while GetGameTimer() - start < Config.TestSeconds * 1000 do
        Wait(100)
        maxSpeed = math.max(maxSpeed, GetEntitySpeed(vehicle) * 3.6)
        maxRpm = math.max(maxRpm, GetVehicleCurrentRpm(vehicle))
    end

    local model = GetEntityModel(vehicle)
    local acceleration = GetVehicleModelAcceleration(model)
    local estimatedHp = math.floor((GetVehicleModelEstimatedMaxSpeed(model) * 3.6) * (acceleration * 10.0) + 0.5)
    local plate = GetVehicleNumberPlateText(vehicle):gsub('^%s*(.-)%s*$', '%1')
    TriggerServerEvent('rs-dyno:server:result', {
        plate = plate,
        model = GetDisplayNameFromVehicleModel(model),
        speed = maxSpeed,
        rpm = maxRpm,
        hp = math.max(1, estimatedHp)
    })
    testing = false
end, false)

RegisterNetEvent('rs-dyno:client:result', function(result)
    TriggerEvent('chat:addMessage', { args = { 'Dyno', ('Resultaat: %s | %d pk indicatie | %.1f km/u | %.0f%% RPM'):format(result.plate, result.hp, result.speed, result.rpm * 100) } })
end)

