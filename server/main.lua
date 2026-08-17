local pending,cooldowns={},{}
local function identifier(source)for _,prefix in ipairs({'license2:','license:','fivem:'})do for _,id in ipairs(GetPlayerIdentifiers(source))do if id:sub(1,#prefix)==prefix then return id end end end end
local function employee(source)local id=identifier(source);if not id then return end;return MySQL.single.await('SELECT identifier,player_name,rank,on_duty FROM rs_bikemechanic_employees WHERE identifier=?',{id})end
local function throttle(source,key,wait)local now=GetGameTimer();local token=source..':'..key;if cooldowns[token]and now-cooldowns[token]<wait then return false end;cooldowns[token]=now;return true end
local function validVehicle(source,netId)
    local entity=NetworkGetEntityFromNetworkId(tonumber(netId) or -1);if not entity or entity==0 or not DoesEntityExist(entity) or GetVehicleClass(entity)~=Config.MotorcycleClass then return false end
    local ped=GetPlayerPed(source);if not ped or ped==0 then return false end
    if #(GetEntityCoords(entity)-Config.Dyno.coords)>Config.Dyno.maxVehicleDistance+1.0 or #(GetEntityCoords(ped)-Config.Dyno.coords)>Config.Dyno.maxVehicleDistance+2.0 then return false end
    return true,entity
end
local function webhook(source,result)
    local url=GetConvar('rs_bikemechanic_webhook_services',GetConvar('rs_bikemechanic_webhook_default',''));if url==''then return end
    PerformHttpRequest(url,function()end,'POST',json.encode({username='Moto Workshop Logs',allowed_mentions={parse={}},embeds={{title='Dynotest afgerond',color=5763719,fields={{name='Monteur',value=GetPlayerName(source),inline=true},{name='Kenteken',value=result.plate,inline=true},{name='Resultaat',value=('%s PK / %s Nm'):format(result.horsepower,result.torque),inline=true}},timestamp=os.date('!%Y-%m-%dT%H:%M:%SZ')}}}),{['Content-Type']='application/json'})
end
lib.callback.register('rs-dyno:start',function(source,netId)
    if not throttle(source,'start',1000)then return false,'Wacht even.'end;local worker=employee(source);if not worker or worker.on_duty~=1 then return false,'Je bent niet in dienst.'end
    local valid,entity=validVehicle(source,netId);if not valid then return false,'Motor of locatie kon niet worden bevestigd.'end
    pending[source]={netId=tonumber(netId),plate=tostring(GetVehicleNumberPlateText(entity)or''):match('^%s*(.-)%s*$'),started=GetGameTimer()};return true
end)
lib.callback.register('rs-dyno:finish',function(source,netId,result)
    if not throttle(source,'finish',1000)or type(result)~='table'then return false,'Ongeldige aanvraag.'end;local job=pending[source];pending[source]=nil
    if not job or job.netId~=tonumber(netId)or GetGameTimer()-job.started<Config.Dyno.duration-750 then return false,'Dynotest is niet geldig voltooid.'end
    local worker=employee(source);local valid,entity=validVehicle(source,netId);if not worker or worker.on_duty~=1 or not valid then return false,'Validatie mislukt.'end
    local plate=tostring(GetVehicleNumberPlateText(entity)or''):match('^%s*(.-)%s*$');if plate~=job.plate or result.plate~=plate then return false,'Kentekencontrole mislukt.'end
    local hp,torque,top=math.floor(tonumber(result.horsepower) or -1),math.floor(tonumber(result.torque) or -1),math.floor(tonumber(result.topSpeed) or -1)
    if hp<0 or hp>2500 or torque<0 or torque>3000 or top<0 or top>700 then return false,'Resultaat buiten bereik.'end
    MySQL.insert.await([[INSERT INTO rs_dyno_history(plate,model,mechanic_identifier,mechanic_name,horsepower,torque,top_speed,zero_to_hundred)VALUES(?,?,?,?,?,?,?,?)]],{plate,tostring(result.model or 'unknown'):sub(1,64),worker.identifier,GetPlayerName(source),hp,torque,top,tonumber(result.zeroToHundred) or 0})
    webhook(source,{plate=plate,horsepower=hp,torque=torque});return true
end)
lib.callback.register('rs-dyno:history',function(source)if not throttle(source,'history',1500)then return{}end;local worker=employee(source);if not worker then return{}end;return MySQL.query.await('SELECT plate,model,mechanic_name,horsepower,torque,top_speed,zero_to_hundred,tested_at FROM rs_dyno_history ORDER BY id DESC LIMIT 50')end)
AddEventHandler('playerDropped',function()
    pending[source]=nil
    local prefix=source..':'
    for key in pairs(cooldowns)do if key:sub(1,#prefix)==prefix then cooldowns[key]=nil end end
end)
