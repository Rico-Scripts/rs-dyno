local profile, tabletOpen, selectedVehicle, lastResult = nil, false, nil, nil

local function notify(message,kind) lib.notify({title=Config.NotifyTitle,description=message,type=kind or 'inform'}) end
local function trim(value)return value and value:match('^%s*(.-)%s*$') or '' end
local function motorcycle(vehicle)return DoesEntityExist(vehicle) and GetVehicleClass(vehicle)==Config.MotorcycleClass end
local function closest()
    local found,distance=nil,Config.Dyno.maxVehicleDistance+0.01
    for _,vehicle in ipairs(GetGamePool('CVehicle')) do if motorcycle(vehicle) then local d=#(Config.Dyno.coords-GetEntityCoords(vehicle));if d<distance then found,distance=vehicle,d end end end
    return found
end
local function refreshProfile() profile=lib.callback.await('rs-bikemechanic:profile',false) return profile and profile.onDuty end
local function close()tabletOpen=false SetNuiFocus(false,false) SendNUIMessage({action='hide'})end
local function vehicleData(vehicle)if not motorcycle(vehicle)then return nil end return{plate=trim(GetVehicleNumberPlateText(vehicle)),engine=math.floor(GetVehicleEngineHealth(vehicle)/10),body=math.floor(GetVehicleBodyHealth(vehicle)/10)}end
local function open(vehicle)
    if not refreshProfile()then notify('Je bent geen medewerker in dienst.','error')return end
    selectedVehicle=vehicle or selectedVehicle or closest();tabletOpen=true SetNuiFocus(true,true)
    SendNUIMessage({action='show',vehicle=vehicleData(selectedVehicle),dynoResult=lastResult})
end
local function modLevel(vehicle,mod)local current=GetVehicleMod(vehicle,mod);if current<0 then return 0 end return current+1 end
local function calculate(vehicle)
    SetVehicleModKit(vehicle,0)
    local model=string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))or'unknown')
    local force=GetVehicleHandlingFloat(vehicle,'CHandlingData','fInitialDriveForce')or .28
    local inertia=GetVehicleHandlingFloat(vehicle,'CHandlingData','fDriveInertia')or 1.0
    local flat=GetVehicleHandlingFloat(vehicle,'CHandlingData','fInitialDriveMaxFlatVel')or 140.0
    local engine,transmission,brakes,suspension=modLevel(vehicle,11),modLevel(vehicle,13),modLevel(vehicle,12),modLevel(vehicle,15)
    local turbo=IsToggleModOn(vehicle,18);local condition=math.max(0,math.min(1000,GetVehicleEngineHealth(vehicle)))/1000
    local installed=lib.callback.await('rs-bikemechanic:vehicleSoftware',false,trim(GetVehicleNumberPlateText(vehicle)))or{}
    local upgrades=1+(engine*.085)+(transmission*.055)+(suspension*.015)+(brakes*.01)+(turbo and .18 or 0)
    local multiplier=Config.Dyno.modelMultipliers[model]or 1.0
    if (tonumber(installed.stage)or 0)>=2 then multiplier=multiplier*Config.Performance.stage2.dynoMultiplier end
    if installed.sportExhaust then multiplier=multiplier*Config.Performance.sportExhaust.dynoMultiplier end
    return{plate=trim(GetVehicleNumberPlateText(vehicle)),model=model,horsepower=math.floor((Config.Dyno.baseHorsepower+force*210+inertia*24+flat*.42)*multiplier*upgrades*(.76+condition*.24)),torque=math.floor((Config.Dyno.baseTorque+force*260+inertia*42)*multiplier*(1+transmission*.04)*condition),topSpeed=math.floor(flat*1.22*(1+transmission*.025)),zeroToHundred=tonumber(string.format('%.2f',math.max(2.1,7.8-force*8.5-engine*.28-transmission*.18-(turbo and .45 or 0)))),engineHealth=math.floor(condition*100),bodyHealth=math.floor(GetVehicleBodyHealth(vehicle)/10),turbo=turbo,engineLevel=engine,transmissionLevel=transmission,brakeLevel=brakes,suspensionLevel=suspension}
end
local function run()
    if not refreshProfile()then notify('Je bent niet in dienst.','error')return end
    local vehicle=selectedVehicle;if not motorcycle(vehicle)then vehicle=closest()selectedVehicle=vehicle end
    if not motorcycle(vehicle)or#(GetEntityCoords(vehicle)-Config.Dyno.coords)>Config.Dyno.maxVehicleDistance then notify('Zet een motor correct op de testbank.','error')return end
    local netId=NetworkGetNetworkIdFromEntity(vehicle);local allowed,reason=lib.callback.await('rs-dyno:start',false,netId)
    if not allowed then notify(reason or 'Dynotest geweigerd.','error')return end
    close();if Config.Dyno.freezeVehicle then FreezeEntityPosition(vehicle,true)end
    local success=lib.progressCircle({duration=Config.Dyno.duration,label='Dynotest draait',canCancel=true,disable={car=true,move=true,combat=true}})
    if Config.Dyno.freezeVehicle then FreezeEntityPosition(vehicle,false)end
    if not success then notify('Dynotest geannuleerd.','error')return end
    lastResult=calculate(vehicle);local saved,message=lib.callback.await('rs-dyno:finish',false,netId,lastResult)
    if not saved then notify(message or 'Resultaat geweigerd.','error')return end
    notify(('Dyno klaar: %s PK / %s Nm'):format(lastResult.horsepower,lastResult.torque),'success');open(vehicle)
end
RegisterCommand(Config.OpenCommand,function()open()end,false)
RegisterKeyMapping(Config.OpenCommand,'Open dynotablet','keyboard',Config.OpenKey)
RegisterNUICallback('close',function(_,cb)close()cb(true)end)
RegisterNUICallback('startDyno',function(_,cb)run()cb(true)end)
RegisterNUICallback('getDynoHistory',function(_,cb)cb(lib.callback.await('rs-dyno:history',false)or{})end)
exports.ox_target:addSphereZone({coords=Config.Dyno.coords,radius=Config.Dyno.radius,options={{name='rs-dyno',icon=Config.Dyno.targetIcon,label=Config.Dyno.targetLabel,distance=Config.TargetDistance,onSelect=function()selectedVehicle=closest()open(selectedVehicle)end}}})
CreateThread(function()while true do Wait(0)if tabletOpen and IsControlJustPressed(0,322)then close()end end end)
