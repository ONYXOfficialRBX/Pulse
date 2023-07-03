local Pulse = require(game.ReplicatedStorage.Pulse.Pulse)
local Player = game.Players.LocalPlayer
local Character = Player.Character
Player.CharacterAdded:Connect(function(Char)
	Character = Char
end)
local Config = {
	bodyGyroCheck = true,
	MaxWalkSpeed = 20,
	F9LogCheck = true, -- THIS CAN BE UNSTABLE, BUT VERY EFFECTIVE
	F9LogWhitelist = {}, -- Any Keywords for specifics outputs in F9 log (info, warning, output, error, etc)
	ReportFingerPrint = true, -- Automatically gets the fingerprint
	
}

local ActualInfo = { -- We clone incase an exploiter attempts to change the main Config table as the script is running
	[1] = Config.bodyGyroCheck,
	[2] = Config.MaxWalkSpeed,
	[3] = Config.F9LogCheck,
	[4] = Config.F9LogWhitelist,
	[5] = Config.ReportFingerPrint,
}

task.spawn(function()
	
	local function VerifyTables(Table1,Table2)
		local Data = 0
		for i,v in pairs(Table1) do 
			for a,b in pairs(Table2) do 
				if v == b then
					Data = Data + 1
				end
			end
		end
		if Data ~= #Table2 then return false end
		return true
	end
	
	while true do 
		task.wait(5)
		if not VerifyTables(ActualInfo,Config) then
			warn(VerifyTables(ActualInfo,Config))
		end
	end
end)

local FlyCheck = function()
	if not ActualInfo[1] then return end
	if not Character then return end
	if not Character:FindFirstChild('HumanoidRootPart') then return end
	for i,v in ipairs(Character:GetDescendants()) do 
		if v:IsA('BasePart') and v:FindFirstChildOfClass('BodyGyro') then
			return 'check_failed',v:GetFullName()
		end
	end
end

local WalkSpeedCheck = function()
	if ActualInfo[2] == 0 then return end
	if not Character then return end
	if not Character:FindFirstChildOfClass('Humanoid') then return end
	local Hum = Character:FindFirstChildOfClass('Humanoid') -- we do this incase exploits rename the Humanoid to error the script
	if Hum.WalkSpeed > ActualInfo[2]  then
		return 'check_failed',Hum.WalkSpeed
	end
end

local F9Check = function()
	if not ActualInfo[3] then return end
	local Whitelist = ActualInfo[4]
	local ToCheck = {}
	game:GetService('LogService').MessageOut:Connect(function(Msg,MsgType)
		for i,v in pairs(Whitelist) do 
			if string.find(Msg,v) then return end
		end
		table.insert(ToCheck,Msg)
	end)
	task.spawn(function()
		while true do 
			task.wait(10)
			if #ToCheck >= 1 then
				return 'check_failed',ToCheck
			end
		end
	end)
end

Pulse.new(FlyCheck,2,'Fly')
Pulse.new(WalkSpeedCheck,1,'Speed')
Pulse.new(F9Check,10000000,'Output') -- We only want it to execute once. be sure the delay is above os.time() or it wont execute