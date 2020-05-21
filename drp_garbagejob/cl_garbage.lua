local AreaType, AreaMarker, AreaInfo, currentZone, currentstop = nil, nil, nil, nil, 0
local HasAlreadyEnteredArea, clockedin, vehiclespawned, albetogetbags, truckdeposit = false, false, false, false, false
local work_truck, NewDrop, LastDrop, binpos, truckpos, garbagebag, truckplate, mainblip = nil, nil, nil, nil, nil, nil, nil, nil
local Blips, CollectionJobs, depositlist = {}, {}, {}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		mainblip = AddBlipForCoord(Zones[2].pos)

		SetBlipSprite (mainblip, 318)
		SetBlipDisplay(mainblip, 4)
		SetBlipScale  (mainblip, 1.2)
		SetBlipColour (mainblip, 5)
		SetBlipAsShortRange(mainblip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("biffa Logistics")
		EndTextCommandSetBlipName(mainblip)
	end
end)

Citizen.CreateThread(function()
	local spawnedIn = false

	while true do
		Citizen.Wait(1000)

		if exports["drp_id"]:SpawnedInAndLoaded() and not spawnedIn then
			spawnedIn = true
			TriggerServerEvent("FLRP_GarbageJob:setconfig")
		end
	end
end)

-- Not used anymore. TriggerServerEvent('FLRP_GarbageJob:setconfig')

-- Not used anymore. TriggerEvent('FLRP_GarbageJob:checkjob')

Zones = {
	[1] = {type = 'Zone', size = 5.0 , name = 'endmission', pos   = vector3(-335.26,-1529.56, 26.58),},
	[2] = {type = 'Zone', size = 3.0 , name = 'timeclock', pos   = vector3(-321.70,-1545.94, 30.02),},
	[3] = {type = 'Zone', size = 3.0 , name = 'vehiclelist', pos   = vector3(-316.16,-1536.08, 26.65)}
}

TruckPlateNumb = 0  -- This starts the custom plate for trucks at 0
MaxStops	= 10 -- Total number of stops a person is allowed to do before having to return to depot.
MaxBags = 10 -- Total number of bags a person can get out of a bin
MinBags = 4 -- Min number of bags that a bin can contain.
StopPay = 200 -- Total pay for the stop before bagpay.

UseWorkClothing = false	-- Will change the player into garbage outfit  at clock-in   and back to street close at clock-out

Trucks = {
	'trash4',
	'trash2',
}

DumpstersAvaialbe = {
	'prop_dumpster_01a',
	'prop_dumpster_02a',
	'prop_dumpster_02b',
	'prop_dumpster_3a',
	'prop_dumpster_4a',
	'prop_dumpster_4b',
	'prop_skip_01a',
	'prop_skip_02a',
	'prop_skip_06a',
	'prop_skip_05a',
	'prop_skip_03',
	'prop_skip_10a'
}

VehicleSpawn = {pos = vector3(-328.50,-1520.99, 27.53),}

Collections = {
	[1] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(114.83,-1462.31, 29.29508),},
	[2] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-6.04,-1566.23, 29.209197),},
	[3] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-1.88,-1729.55, 29.300233),},
	[4] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(159.09,-1816.69, 27.91234),},
	[5] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(358.94,-1805.07, 28.96659),},
	[6] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(481.36,-1274.82, 29.64475),},
	[7] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(127.9472,-1057.73, 29.19237),},
	[8] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-1613.123, -509.06, 34.99874),},
	[9] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(342.78,-1036.47, 29.19420),},
	[10] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(383.03,-903.60, 29.15601),}, 
	[11] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(165.44,-1074.68, 28.90792),}, 
	[12] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(50.42,-1047.98, 29.31497),}, 
	[13] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-1463.92, -623.96, 30.20619),},
	[14] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(443.96,-574.33, 28.49450),},
	[15] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-1255.41,-1286.82,3.58411),}, 
	[16] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-1229.35, -1221.41, 6.44954),},
	[17] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-31.94,-93.43, 57.24907),},
	[18] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(274.31,-164.43, 60.35734),},
	[19] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-364.33,-1864.71, 20.24249),}, 
	[20] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-1239.42, -1401.13, 3.75217),}, 
	[21] = {type = 'Collection', size = 9.0 , name = 'collection', pos   = vector3(813.52, -758.79, 26.73),}, 
	[22] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(763.21, -732.42, 2768),}, 
	[23] = {type = 'Collection', size = 9.0 , name = 'collection', pos   = vector3(743.56, -982.52, 24.24),}, 
	[24] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(299.99, -903.31, 29.29),}, 
	[25] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(6.78, -1033, 29.16),}, 
	[26] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-78.49, -1262.47, 28.53),}, 
	[27] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-151.39, -1411.48, 30.71),}, 
	[28] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-188.09, -1378.26, 30.79),}, 
	[29] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(-607.79, -1788.94, 23.14),}, 
	[30] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(240, -1773.05, 28.23),}, 
	[31] = {type = 'Collection', size = 5.0 , name = 'collection', pos   = vector3(451.7, -1971.85, 22.48),},

}

RegisterNetEvent('FLRP_GarbageJob:movetruckcount')
AddEventHandler('FLRP_GarbageJob:movetruckcount', function(count)
	TruckPlateNumb = count
end)

RegisterNetEvent('FLRP_GarbageJob:updatejobs')
AddEventHandler('FLRP_GarbageJob:updatejobs', function(newjobtable)
	CollectionJobs = newjobtable
end)


RegisterNetEvent('FLRP_GarbageJob:selectnextjob')
AddEventHandler('FLRP_GarbageJob:selectnextjob', function()
	print{"selectnextjob"}
	SetBlipRoute(Blips['delivery'], false)
	FindDeliveryLoc()
	print("Find new location.")
	albetogetbags = false
end)

RegisterCommand("a",function(source, args)
	MenuCloakRoom()
	Citizen.Wait(1000)
	MenuVehicleSpawner()
end, false)

RegisterNetEvent('FLRP_GarbageJob:enteredarea')
AddEventHandler('FLRP_GarbageJob:enteredarea', function(zone)
	CurrentAction = zone.name

	if CurrentAction == 'timeclock' then
		MenuCloakRoom()
	end

	if CurrentAction == 'vehiclelist' then
		if clockedin  then
			MenuVehicleSpawner()
		end
	end

	if CurrentAction == 'endmission' and vehiclespawned then
		CurrentActionMsg = ('Press E to stop working.')
	end

	if CurrentAction == 'collection' and not albetogetbags then
		if IsPedInAnyVehicle(GetPlayerPed(-1)) and GetHashKey("Trash2") then
			CurrentActionMsg = ('~INPUT_PICKUP~ to Pickup')
		else
			CurrentActionMsg = ('You must be in company truck to start collection')
		end

	end

	if CurrentAction == 'bagcollection' then
		if zone.bagsremaining > 0 then
			CurrentActionMsg = ('Press E to collect bags | '.. tostring(zone.bagsremaining) .." left.")
		else
			CurrentActionMsg = nil
		end
	end

	if CurrentAction == 'deposit' then
		CurrentActionMsg = ('Press E to toss bag into truck.')
	end

end)

Citizen.CreateThread( function()
	while true do 
		Citizen.Wait(0)
		while CurrentAction ~= nil and CurrentActionMsg ~= nil do
			Citizen.Wait(0)
			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) then

				if CurrentAction == 'endmission' then
					if IsPedInAnyVehicle(GetPlayerPed(-1)) then
						local getvehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
						TaskLeaveVehicle(GetPlayerPed(-1), getvehicle, 0)
					end
					while IsPedInAnyVehicle(GetPlayerPed(-1)) do
						Citizen.Wait(0)
					end
					Citizen.InvokeNative( 0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized( work_truck ) )
					if Blips['delivery'] ~= nil then
						RemoveBlip(Blips['delivery'])
						Blips['delivery'] = nil
					end
					
					if Blips['endmission'] ~= nil then
						RemoveBlip(Blips['endmission'])
						Blips['endmission'] = nil
					end
					SetBlipRoute(Blips['delivery'], false)
					vehiclespawned = false
					CurrentAction =nil
					CurrentActionMsg = nil
				end

				if CurrentAction == 'collection' then
					if CurrentActionMsg == ('~INPUT_PICKUP~ to Pickup') then
						SelectBinAndCrew(GetEntityCoords(GetPlayerPed(-1)))
						CurrentAction = nil
						CurrentActionMsg  = nil
						IsInArea = false
					end
				end

				if CurrentAction == 'bagcollection' then
					CurrentAction = nil
					CollectBagFromBin(currentZone)
					CurrentActionMsg = nil
					IsInArea = false
					print("Bag Collection")
				end

				if CurrentAction == 'deposit' then
					print("Deposit")
					CurrentAction = nil
					CurrentActionMsg = nil
					PlaceBagInTruck(currentZone)
					IsInArea = false
				end
			end
		end
	end
end)

Citizen.CreateThread( function()
	while true do 
		sleep = 1500
		ply = GetPlayerPed(-1)
		plyloc = GetEntityCoords(ply)

		for i, v in pairs(Zones) do
			if GetDistanceBetweenCoords(plyloc, v.pos, true)  < 20.0 then
				sleep = 0
				if v.name == 'timeclock' then
					DrawMarker(1, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.size,  v.size, 1.0, 204,204, 0, 100, false, true, 2, false, false, false, false)
				elseif v.name == 'endmission' and vehiclespawned then
					DrawMarker(1, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0,  v.size,  v.size, 1.0, 204,204, 0, 100, false, true, 2, false, false, false, false)
				elseif v.name == 'vehiclelist' and clockedin and not vehiclespawned then
					DrawMarker(1, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0,  v.size,  v.size, 1.0, 204,204, 0, 100, false, true, 2, false, false, false, false)
				end
			end
		end

		for i, v in pairs(CollectionJobs)  do
			if GetDistanceBetweenCoords(plyloc, v.pos, true)  < 10.0 and truckpos == nil then
				sleep = 0
				DrawMarker(1, v.pos.x,  v.pos.y,  v.pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0,  3.0,  3.0, 1.0, 255,0, 0, 100, false, true, 2, false, false, false, false)
				break
			end
		end

		if truckpos ~= nil then
			if GetDistanceBetweenCoords(plyloc, truckpos, true) < 10.0  then
				sleep = 0
				DrawMarker(20, truckpos.x,  truckpos.y,  truckpos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0,  1.0, 1.0, 1.0, 0,100, 0, 100, false, true, 2, false, false, false, false)
			end
		end

		if oncollection then
			if GetDistanceBetweenCoords(plyloc, NewDrop.pos, true) < 20.0 and not albetogetbags then
				sleep = 0
				DrawMarker(1, NewDrop.pos.x,  NewDrop.pos.y,  NewDrop.pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0,  NewDrop.size,  NewDrop.size, 1.0, 204,204, 0, 100, false, true, 2, false, false, false, false)
			end
		end

		Citizen.Wait(sleep)
	end
end)

-- thread so the script knows you have entered a markers area - 
Citizen.CreateThread( function()
	while true do 
		sleep = 1000
		ply = GetPlayerPed(-1)
		plyloc = GetEntityCoords(ply)
		IsInArea = false
		currentZone = nil
		
		for i,v in pairs(Zones) do
			if GetDistanceBetweenCoords(plyloc, v.pos, false)  <  v.size then
				IsInArea = true
				currentZone = v
			end
		end

		if oncollection and not albetogetbags then
			if GetDistanceBetweenCoords(plyloc, NewDrop.pos, true)  <  NewDrop.size then
				IsInArea = true
				currentZone = NewDrop
			end
		end

		if truckpos ~= nil then
			if GetDistanceBetweenCoords(plyloc, truckpos, false)  <  2.0 then
				IsInArea = true
				currentZone = {type = 'Deposit', name = 'deposit', pos = truckpos,}
			end
		end

		for i,v in pairs(CollectionJobs) do
			if GetDistanceBetweenCoords(plyloc, v.pos, false)  <  2.0 and truckpos == nil then
				IsInArea = true
				currentZone = v
			end
		end

		if IsInArea and not HasAlreadyEnteredArea then
			HasAlreadyEnteredArea = true
			sleep = 0
			TriggerEvent('FLRP_GarbageJob:enteredarea', currentZone)
		end

		if not IsInArea and HasAlreadyEnteredArea then
			HasAlreadyEnteredArea = false
			sleep = 1000
			-- TODO, Leave area menu 
		end

		Citizen.Wait(sleep)
	end
end)

	truckmodel = GetHashKey("Trash2")

function CollectBagFromBin(currentZone)
	binpos = currentZone.pos
	truckplate = currentZone.trucknumber

	if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
		RequestAnimDict("anim@heists@narcotics@trash") 
		while not HasAnimDictLoaded("anim@heists@narcotics@trash") do 
			Citizen.Wait(0)
		end
	end

	local playerped = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(playerped, true)
	local isVehicleGarbageTruck = IsVehicleModel(vehicle, truckmodel)
	local worktruck = NetworkGetEntityFromNetworkId(currentZone.truckmodel)

	if isVehicleGarbageTruck then
	
		truckpos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -5.25, 0.0)
		TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
		TriggerServerEvent('FLRP_GarbageJob:bagremoval', currentZone.pos, currentZone.truckmodel) 
		trashcollection = false
		Citizen.Wait(4000)
		ClearPedTasks(PlayerPedId())
		local randombag = math.random(0,2)
		print("Before randombag")
		if randombag == 0 then
			garbagebag = CreateObject(GetHashKey("prop_cs_street_binbag_01"), 0, 0, 0, true, true, true) -- creates object
			AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to right hand    
		elseif randombag == 1 then
			garbagebag = CreateObject(GetHashKey("bkr_prop_fakeid_binbag_01"), 0, 0, 0, true, true, true) -- creates object
			AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), .65, 0, -.1, 0, 270.0, 60.0, true, true, false, true, 1, true) -- object is attached to right hand    
		elseif randombag == 2 then
			garbagebag = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true) -- creates object
			AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true) -- object is attached to right hand    
		end  
		print("after")

		TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,49,0,0, 0,0)
		CurrentAction = nil
		CurrentActionMsg = nil
		HasAlreadyEnteredArea = false
		print("After Walk trash")
	else
		exports['mythic_notify']:DoLongHudText('error', "No truck nearby to toss bags into.")
		TriggerServerEvent('FLRP_GarbageJob:unknownlocation', currentZone.pos, currentZone.truckmodel)
	end
end

function PlaceBagInTruck(thiszone)
	print("Before.")
	if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
		RequestAnimDict("anim@heists@narcotics@trash") 
		while not HasAnimDictLoaded("anim@heists@narcotics@trash") do 
			Citizen.Wait(0)
		end
	end
	ClearPedTasksImmediately(GetPlayerPed(-1))
	TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0,-1,2,0,0, 0,0)
	Citizen.Wait(800)
	local garbagebagdelete = DeleteEntity(garbagebag)
	Citizen.Wait(100)
	ClearPedTasksImmediately(GetPlayerPed(-1))
	CurrentAction = nil
	CurrentActionMsg = nil
	depositlist = nil
	truckpos = nil

	TriggerServerEvent('FLRP_GarbageJob:bagdumped', binpos, truckmodel)
	HasAlreadyEnteredArea = false
end

function SelectBinAndCrew(location)
	local bin = nil
	for i, v in pairs(DumpstersAvaialbe) do
		bin = GetClosestObjectOfType(location, 10.0, GetHashKey(v), false, false, false )
		if bin ~= 0 then
			break
		end
	end
	if bin ~= 0 then
		truckmodel = GetHashKey("Trash2")
		truckid = NetworkGetNetworkIdFromEntity(work_truck)
		truckplatenumber = GetVehicleNumberPlateText(true, GetVehiclePedIsIn(GetPlayerPed(source)))
		TriggerServerEvent('FLRP_GarbageJob:setworkers', GetEntityCoords(bin), truckmodel, truckid )
		truckpos = nil
		albetogetbags = true
		SetBlipRoute(Blips['delivery'], false)
		currentstop = currentstop + 1
		SetVehicleDoorOpen(work_truck, 5, false, false)
	else
		exports['mythic_notify']:DoLongHudText('error', "No trash available for pickup at this location.")
		SetBlipRoute(Blips['delivery'], false)
		FindDeliveryLoc()
	end
end

function FindDeliveryLoc()
	if currentstop < MaxStops then
		if LastDrop ~= nil then
			lastregion = GetNameOfZone(LastDrop.pos)
		end
		local newdropregion = nil
		while newdropregion == nil or newdropregion == lastregion do
			randomloc = math.random(1, #Collections)
			newdropregion = GetNameOfZone(Collections[randomloc].pos)
		end
		NewDrop = Collections[randomloc]
		LastDrop = NewDrop
		if Blips['delivery'] ~= nil then
			RemoveBlip(Blips['delivery'])
			Blips['delivery'] = nil
		end
		
		if Blips['endmission'] ~= nil then
			RemoveBlip(Blips['endmission'])
			Blips['endmission'] = nil
		end
		
		Blips['delivery'] = AddBlipForCoord(NewDrop.pos)
		SetBlipSprite (Blips['delivery'], 318)
		SetBlipAsShortRange(Blips['delivery'], true)
		SetBlipRoute(Blips['delivery'], true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('biffa Logistics : Delivery')
		EndTextCommandSetBlipName(Blips['delivery'])
		
		Blips['endmission'] = AddBlipForCoord(Zones[1].pos)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('biffa Logistics : Return Point')
		EndTextCommandSetBlipName(Blips['endmission'])

		oncollection = true
		exports['mythic_notify']:DoLongHudText('inform', "Drive to next pickup location.")
	else
		exports['mythic_notify']:DoLongHudText('error', "Return to the depot.")
	end
end

	function MenuCloakRoom()
		if clockedin then
			clockedin = false
			print(clockedin)
		else
			print(clockedin)
			clockedin = true
		end
	end

	-- TODO -- Create menu or signin area.

	--[[function MenuCloakRoom()
		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
				title    = ('cloakroom'),
				elements = {
					{label = ('Clock-In'), value = 'job_wear'},
					{label = ('Clock-Out'), value = 'citizen_wear'}
				}}, function(data, menu)
				if data.current.value == 'citizen_wear' then
					clockedin = false
				end
				if data.current.value == 'job_wear' then
					clockedin = true
				end	
				menu.close()
			end, function(data, menu)
				menu.close()
			end)
	end --]]




	-- TODO Spawn Vehicle Menu
function MenuVehicleSpawner()
exports["drp_garages"]:SpawnJobVehicle("trash2", false, -328.50,-1520.99, 27.53, 155.0, 100)
	TriggerServerEvent('FLRP_GarbageJob:movetruckcount')
	vehiclespawned = true
	work_truck = vehicle
	FindDeliveryLoc()
end