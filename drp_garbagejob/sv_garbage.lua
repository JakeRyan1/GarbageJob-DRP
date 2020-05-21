local currentjobs = {}
local currentadd = {}
local currentworkers = {}



Citizen.CreateThread(function()
    while true do
        local addsleep = 250
        local collectionfinished = false
        local updated = false
        while #currentadd > 0 do
            addsleep = 0
            if currentadd[1].type == 'bagdumped' then
                for i,v in pairs(currentjobs) do
                    if v.pos == currentadd[1].location and v.truckmodel == "trash2"  then
                        for workers, ids in pairs(v.workers) do
                            if ids.id == currentadd[1].id then
                                ids.bags = ids.bags + 1
                                v.bagsdropped = v.bagsdropped + 1
                                if v.bagsremaining <= 0  and v.bagsdropped == v.totalbags then
                                    TriggerEvent('FLRP_GarbageJob:paycrew', i)
                                end
                                updated = true
                                break
                            end
                        end

                        if not updated then
                            local buildlist = { id = currentadd[1].id, bags = 1,}
                            table.insert(v.workers, buildlist)
                            v.bagsdropped = v.bagsdropped + 1
                            if v.bagsremaining <= 0  and v.bagsdropped == v.totalbags then
                            TriggerEvent('FLRP_GarbageJob:paycrew', i)
                            end
                        end
                        table.remove(currentadd, 1)
                    break
                    end
                    
                end
            elseif currentadd[1].type == 'setworkers' then
                Citizen.Wait(0)
                local bagtotal = math.random(4, 10)
                local buildlist = {type = 'bags', name = 'bagcollection', jobboss = currentadd[1].id, pos = currentadd[1].location, totalbags = bagtotal, bagsdropped = 0, bagsremaining = bagtotal, truckmodel = "trash2", truckid = currentadd[1].truckid, workers = {}, }
                table.insert(currentjobs, buildlist)
                TriggerClientEvent('FLRP_GarbageJob:updatejobs', -1, currentjobs)
                table.remove(currentadd, 1)
                break
            end
            Citizen.Wait(addsleep)
        end
        Citizen.Wait(addsleep)
    end
end)


RegisterServerEvent('FLRP_GarbageJob:bagdumped')
AddEventHandler('FLRP_GarbageJob:bagdumped', function(location, truckmodel)
    local _source = source
    local buildlist = {
        type = 'bagdumped',
        id = _source,
        location = location,
        truckmodel = truckmodel,
    }
    table.insert(currentadd, buildlist)
end)


RegisterServerEvent('FLRP_GarbageJob:setworkers')
AddEventHandler('FLRP_GarbageJob:setworkers', function(location, truckmodel, truckid)
    print("trying to set workers")
    _source = source
    buildlist = { 
        type = 'setworkers',
        id = _source,
        location = location,
        truckmodel = truckmodel,
        truckid = truckid, 
    }
   table.insert(currentadd, buildlist)
   print(tostring(#currentadd))
end)




RegisterServerEvent('FLRP_GarbageJob:unknownlocation')
AddEventHandler('FLRP_GarbageJob:unknownlocation', function(location, truckmodel)
    for i,v in pairs(currentjobs) do
        if v.pos == location and v.truckmodel == "trash2"  then
            if #v.workers > 0 then
                TriggerEvent('FLRP_GarbageJob:paycrew', i)
            else
                table.remove(currentjobs, number)
                TriggerClientEvent('FLRP_GarbageJob:updatejobs', -1, currentjobs)
            end
            break
       end
   end
end)

RegisterServerEvent('FLRP_GarbageJob:bagremoval')
AddEventHandler('FLRP_GarbageJob:bagremoval', function(location, truckmodel)
    for i,v in pairs(currentjobs) do
        if v.pos == location and v.truckmodel == "trash2" and v.bagsremaining > 0 then
            v.bagsremaining = v.bagsremaining - 1
            break
        end
    end
 
    TriggerClientEvent('FLRP_GarbageJob:updatejobs', -1, currentjobs)
end)

local TruckPlateNumb = 0

RegisterServerEvent('FLRP_GarbageJob:movetruckcount')
AddEventHandler('FLRP_GarbageJob:movetruckcount', function()
    TruckPlateNumb = TruckPlateNumb + 1
    if TruckPlateNumb == 1000 then
        TruckPlateNumb = 1
    end
    TriggerClientEvent('FLRP_GarbageJob:movetruckcount', -1, TruckPlateNumb)
end)

RegisterServerEvent('FLRP_GarbageJob:setconfig')
AddEventHandler('FLRP_GarbageJob:setconfig', function()
    TriggerClientEvent('FLRP_GarbageJob:movetruckcount', -1, TruckPlateNumb)
    if #currentjobs >  0 then
        TriggerClientEvent('FLRP_GarbageJob:updatejobs', -1, currentjobs)
    end
end)

AddEventHandler('playerDropped', function()
    _source = source
     for i, v in pairs(currentjobs) do
        for index, value in pairs(v.workers) do
            if value.id == _source then
                TriggerEvent('FLRP_GarbageJob:paycrew', i)
            end
        end
     end
end)


AddEventHandler('FLRP_GarbageJob:paycrew', function(number)
    currentcrew = currentjobs[number].workers
    payamount = (200 / currentjobs[number].totalbags) + 25
    for i, v in pairs(currentcrew) do
        local character = exports["drp_id"]:GetCharacterData(v.id)
        if character ~= nil then
            local amount = math.ceil(payamount * v.bags)
            TriggerEvent("DRP_Bank:AddCashMoney", character, amount)
            TriggerClientEvent('mythic_notify:client:SendAlert', v.id, { type = 'success', text = 'Received $'..tostring(amount)..' from this stop.', length = 10000 }) -- TODO New Notify?
        end
    end
    TriggerClientEvent('FLRP_GarbageJob:selectnextjob',source, currentjobs[number].jobboss )
    table.remove(currentjobs, number)
    TriggerClientEvent('FLRP_GarbageJob:updatejobs', -1, currentjobs)
end)

--[[AddEventHandler('esx_garbagecrew:paycrew', function(number)
    currentcrew = currentjobs[number].workers
    payamount = (200 / currentjobs[number].totalbags) + 25
    for i, v in pairs(currentcrew) do
        local xPlayer = ESX.GetPlayerFromId(v.id)
        if xPlayer ~= nil then
            local amount = math.ceil(payamount * v.bags)
            xPlayer.addMoney(tonumber(amount))
            TriggerClientEvent('mythic_notify:client:SendAlert', v.id, { type = 'success', text = 'Received $'..tostring(amount)..' from this stop.', length = 10000 })
        end
    end
    TriggerClientEvent('esx_garbagecrew:selectnextjob', currentjobs[number].jobboss )
    table.remove(currentjobs, number)
    TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs)
end)--]]
