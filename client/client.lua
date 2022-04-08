local QBCore = exports['qb-core']:GetCoreObject()
Skillbar = {}
Skillbar.Data = {}
Skillbar.Data = {
	Active = false,
	Data = {},
}
successCb = nil
failCb = nil
local SkillbarWidth
local CurrentTargetPos
local TargetWidth
local TargetHeight
local CurrentTriggerPos
local TriggerWidth
local TriggerHeight
local TriggerColor = {['R'] = Config.TriggerOutColor.R, ['G'] = Config.TriggerOutColor.G, ['B'] = Config.TriggerOutColor.B, ['A'] = Config.TriggerOutColor.A}
local Message = ""

function MinigameCb(data)
	if successCb ~= nil then
		Skillbar.Data.Active = false
		if data then
				successCb()
			else
				failCb()
		end
	end
end

Skillbar.Start = function(data, success, fail)
	if not Skillbar.Data.Active then
		Skillbar.Data.Active = true
		if success ~= nil then
			successCb = success
		end
		if fail ~= nil then
			failCb = fail
		end
		Skillbar.Data.Data = data
		Minigame(data.duration, data.pos, data.width)
	else
		QBCore.Functions.Notify('You are already doing something...', 'error')
	end
end

Skillbar.Repeat = function(data)
	Skillbar.Data.Active = true
	Skillbar.Data.Data = data
	Citizen.CreateThread(function()
		Wait(100)
		Minigame(data.duration, data.pos, data.width)
	end)
end

function GetSkillbarObject()
	return Skillbar
end

-- duration -> movement increments (speed); pos -> skillbar width; width -> target width. duration, pos, and width nomenclature used for backward compatibility. 
function Minigame(duration, pos, width)
	Citizen.CreateThread(function()
		SkillbarWidth = pos / 100
		TargetWidth = width * 0.001
		TargetHeight = Config.SkillbarHeight - 0.002
		TriggerWidth = 0.001
		TriggerHeight = Config.SkillbarHeight - 0.004
		local StartTargetPos = Config.SkillbarX + (SkillbarWidth / 2) - (TargetWidth / 2)
		CurrentTargetPos = StartTargetPos
		local EndTargetPos = Config.SkillbarX - (SkillbarWidth / 2) + (TargetWidth / 2) + 0.002
		local StartTriggerPos = Config.SkillbarX - (SkillbarWidth / 2) + (TriggerWidth / 2)
		CurrentTriggerPos = StartTriggerPos
		local EndTriggerPos = Config.SkillbarX + (SkillbarWidth / 2) - (TriggerWidth / 2) - 0.002
		local MovementIncrement = 3.0 / duration
		local TargetMovement = -1
		local TriggerMovement = 1
		local TraverseCount = 0
		Skillbar.Data.Active = true
		while Skillbar.Data.Active do
			if CurrentTriggerPos + (MovementIncrement * TriggerMovement) > ((CurrentTargetPos + (MovementIncrement * TargetMovement)) - TargetWidth / 2) and CurrentTriggerPos + (MovementIncrement * TriggerMovement) < ((CurrentTargetPos + (MovementIncrement * TargetMovement)) + TargetWidth / 2) then
				TriggerColor = {['R'] = Config.TriggerInColor.R, ['G'] = Config.TriggerInColor.G, ['B'] = Config.TriggerInColor.B, ['A'] = Config.TriggerInColor.A}
				Message = "Success"
			else
				TriggerColor = {['R'] = Config.TriggerOutColor.R, ['G'] = Config.TriggerOutColor.G, ['B'] = Config.TriggerOutColor.B, ['A'] = Config.TriggerOutColor.A}
				Message = "Fail"
			end
			DrawSkillRect(Config.SkillbarX, Config.SkillbarY, SkillbarWidth + 0.002, Config.SkillbarHeight + 0.002, Config.SkillbarBorderColor.R, Config.SkillbarBorderColor.G, Config.SkillbarBorderColor.B, Config.SkillbarBorderColor.A)
			DrawSkillRect(Config.SkillbarX, Config.SkillbarY, SkillbarWidth, Config.SkillbarHeight, Config.SkillbarColor.R, Config.SkillbarColor.G, Config.SkillbarColor.B, Config.SkillbarColor.A)
			DrawSkillRect(CurrentTargetPos, Config.SkillbarY, TargetWidth, TargetHeight, Config.TargetColor.R, Config.TargetColor.G, Config.TargetColor.B, Config.TargetColor.A)
			DrawSkillRect(CurrentTriggerPos, Config.SkillbarY, TriggerWidth, TriggerHeight, TriggerColor.R, TriggerColor.G, TriggerColor.B, TriggerColor.A)
			CurrentTargetPos = CurrentTargetPos + (MovementIncrement * TargetMovement)
			CurrentTriggerPos = CurrentTriggerPos + (MovementIncrement * TriggerMovement)
			if CurrentTargetPos <= EndTargetPos or CurrentTargetPos >= StartTargetPos then
				TargetMovement = TargetMovement * -1
				TraverseCount = TraverseCount + 1
			end
			if CurrentTriggerPos >= EndTriggerPos or CurrentTriggerPos <= StartTriggerPos then
				TriggerMovement = TriggerMovement * -1
			end
			if IsControlJustReleased(0, 38) then -- E key
				DisplayResult()
				if CurrentTriggerPos > (CurrentTargetPos - TargetWidth / 2) and CurrentTriggerPos < (CurrentTargetPos + TargetWidth / 2) then
					Skillbar.Data.Result = true -- Gives additional data to export
					MinigameCb(Skillbar.Data.Result)
				else
					Skillbar.Data.Result = false -- Gives additional data to export
					MinigameCb(Skillbar.Data.Result)
				end
				Skillbar.Data.Active = false
			end
			if TraverseCount > Config.TraverseCount then
				Skillbar.Data.Result = false -- Gives additional data to export
				MinigameCb(Skillbar.Data.Result)
				Skillbar.Data.Active = false
			end
			Citizen.Wait(1)
		end
	end)
end

function DrawSkillRect(x, y, w, h, r, g, b, a)
	DrawRect(x, y, w, h, r, g, b, a)
end

function DrawMessage(x, y, t)
	SetTextFont(4)
	SetTextScale(0.35, 0.35)
	SetTextColour(Config.MessageColor.R, Config.MessageColor.G, Config.MessageColor.B, Config.MessageColor.A)
	SetTextEntry("STRING")
	SetTextCentre(true)
	SetTextDropShadow(0, 0, 0, 0, 128)
	SetTextDropShadow()
	SetTextEdge(4, 0, 0, 0, 255)
	SetTextOutline()
	AddTextComponentString(t)
	EndTextCommandDisplayText(x, y)
end

function DisplayResult()
	local duration = Config.DisplayResultDuration / 10
	for i = 1, duration, 1 do
		DrawMessage(Config.SkillbarX, Config.SkillbarY - Config.SkillbarHeight * 1.5, Message)
		DrawSkillRect(Config.SkillbarX, Config.SkillbarY, SkillbarWidth + 0.002, Config.SkillbarHeight + 0.002, Config.SkillbarBorderColor.R, Config.SkillbarBorderColor.G, Config.SkillbarBorderColor.B, Config.SkillbarBorderColor.A)
		DrawSkillRect(Config.SkillbarX, Config.SkillbarY, SkillbarWidth, Config.SkillbarHeight, Config.SkillbarColor.R, Config.SkillbarColor.G, Config.SkillbarColor.B, Config.SkillbarColor.A)
		DrawSkillRect(CurrentTargetPos, Config.SkillbarY, TargetWidth, TargetHeight, Config.TargetColor.R, Config.TargetColor.G, Config.TargetColor.B, Config.TargetColor.A)
		DrawSkillRect(CurrentTriggerPos, Config.SkillbarY, TriggerWidth, TriggerHeight, TriggerColor.R, TriggerColor.G, TriggerColor.B, TriggerColor.A)
		Wait(10)
	end
end



