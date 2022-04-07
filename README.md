# skillbar
This is a direct replacement for QBus qb-skillbar

Installation:
Remove qb-skillbar from [qb] directory. Rename this resource to "qb-skillbar" and put in [qb] directory

---------------------------------------------------------------
Example implementation for lockpicking cars:

Edit [qb]\qb-vehiclekeys\client\main.lua

At top, add:

        local SucceededAttempts = 0
        local NeededAttempts = 4

Edit local function LockpickDoor(isAdvanced)

comment out the following:

        --TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)

add just below it:

				RequestAnimDict("anim@amb@business@weed@weed_inspecting_lo_med_hi@")
				while not HasAnimDictLoaded("anim@amb@business@weed@weed_inspecting_lo_med_hi@") do Citizen.Wait(5) end
				TaskPlayAnim(PlayerPedId(), "anim@amb@business@weed@weed_inspecting_lo_med_hi@", "weed_spraybottle_crouch_idle_01_inspector", 4.0, 4.0, -1, 1, 0.0, 0, 0, 0)
				local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
				if usingAdvanced then
					Skillbar.Start({
						duration = math.random(4000,6000),
						pos = math.random(10, 30),
						width = math.random(30, 40)
					},
					function()
						if SucceededAttempts + 1 >= NeededAttempts then
							ClearPedTasks(PlayerPedId())
							lockpickFinish(true)
							SucceededAttempts = 0
						else
							Skillbar.Repeat({
								duration = math.random(4000,6000),
								pos = math.random(10, 30),
								width = math.random(30, 40)
							})
							SucceededAttempts = SucceededAttempts + 1
						end
					end, function()
						ClearPedTasks(PlayerPedId())
						lockpickFinish(false)
						SucceededAttempts = 0
					end)
	
				else
					Skillbar.Start({
						duration = math.random(2500,4500),
						pos = math.random(10, 30),
						width = math.random(10, 20)
					},
					function()
						if SucceededAttempts + 1 >= NeededAttempts then
							ClearPedTasks(PlayerPedId())
							lockpickFinish(true)
							SucceededAttempts = 0
						else
							Skillbar.Repeat({
								duration = math.random(2500,4500),
								pos = math.random(10, 30),
								width = math.random(10, 20)
							})
							SucceededAttempts = SucceededAttempts + 1
						end
					end, function()
						ClearPedTasks(PlayerPedId())
						lockpickFinish(false)
						SucceededAttempts = 0
					end)
				end
