local module = {}

local CurrentLoops = {}
local MainTraces = {}
local MaxTraces = math.huge
local Triggers = {}
local AdminEvent = nil
local ExploitsDetected = false
local LastRan = nil
local UseEncryption = true
local Encryption = require(game.ReplicatedStorage.Pulse.Lib.AES_Client)
local VerifyData = function(SentData,ReturnedData)
	for i,v in pairs(SentData) do 
		if not ReturnedData[i] then return false end
		if ReturnedData[i] ~= v then return false end
	end
	for i,v in pairs(ReturnedData) do 
		if not SentData[i] then return false end
		if SentData[i] ~= v then return false end
	end
	return true
end

local Cooldowns = {}
local AnimationId = 0

function module:SetEvent(Event)
	AdminEvent = Event
end

function module:UseEncryption(boolean)
	UseEncryption = boolean
end

local GhostTrigger = function()
	repeat task.wait() until game.Players.LocalPlayer.Character
	local Character = game.Players.LocalPlayer.Character
	local Animation = Instance.new('Animation')
	Animation.AnimationId = "rbxassetid://" .. '10094361327'
	local LoadedAn = Character.Humanoid:LoadAnimation(Animation)
	LoadedAn:Play()
end
pcall(function()
	Encryption = require(game.ReplicatedStorage.ONYX.Modules.Encryption)
end)
Encryption = require(game.ReplicatedStorage.Pulse.Lib.AES_Client)
local function Convert(ValueReturned)
	local EncryptedMessage = ValueReturned[1]
	math.randomseed(game.Players.LocalPlayer.AccountAge)
	local Num = math.random(1,100)
	local NewStartTime = ValueReturned[2] * Num
	local TheMainNumber = ValueReturned[3] * Num/game.Players.LocalPlayer.AccountAge
	return {EncryptedMessage,NewStartTime,TheMainNumber}
end

AdminEvent = game.ReplicatedStorage.Call
local Trigger = function(Detection,Data)
	warn('e')
	if Cooldowns[Detection] then return end
	Cooldowns[Detection] = true
	spawn(function()
		task.wait(5)
		Cooldowns[Detection] = nil
	end)
	if Detection == 'Client Tampering Detected' then
		warn(debug.traceback(''),1)
		warn(debug.traceback('',2))
	end
	local Thing2 = nil
	spawn(function()
		repeat task.wait() until AdminEvent
		if Detection == 'Client Tampering Detected' then
			Detection = 'Bypass'
		end
		local DataToSend = {}
		local Det,key = Encryption.new('Detection','Encrypt')
		warn(Det)
		warn(Encryption)
		Det = Convert(Det)
		local D =  Convert(Encryption.new('Data','Encrypt',key))
		local ActualDetection =  Convert(Encryption.new(Detection,'Encrypt',key))
		local ActualData =  Convert(Encryption.new(Data,'Encrypt',key))
		DataToSend[Det] = ActualDetection
		DataToSend[D] = ActualData
		table.insert(Triggers,os.time())
		warn('a')
		Thing2 = AdminEvent:InvokeServer(DataToSend)
		warn('b')
		local returned = VerifyData(DataToSend,Thing2)
		if not returned then
			GhostTrigger()
		end
		if typeof(Data) ~= 'table' then return Thing2 end
		local DataIndexes = 0
		local Result = true
		for i,v in pairs(DataToSend) do 
			DataIndexes = DataIndexes + 1
			if not Thing2[i] then
				Result = false
			end
			if Thing2[i] ~= v then
				Result = false
			end
		end
		local ThingIndex = 0
		for i,v in pairs(Thing2) do 
			ThingIndex = ThingIndex + 1
			if not Data[i] then
				Result = false
			end
			if Data[i] ~= v then
				Result = false
			end
		end
		if not Result then
			return 'Auth_Failed_false'
		end
	end)
	return Thing2
end

local Check = function(Arg1,Arg2)
	for i,v in ipairs(Arg2) do 
		if not string.find(v,Arg1[i]) then
			Trigger('Client Tampering detected','1' .. '\n' .. v .. ':' .. Arg1[i])
			return 'Auth_Failed_false'
		end
	end
	return true
end

local TracebackCheck = function(TracebackTable)
	local WhiteList = {'.AC:102','.ONYX:3'}
	for i,v in pairs(TracebackTable) do 
		if v == '' then
			table.remove(TracebackTable,i)
			TracebackTable[i] = nil
		end
	end
	local a = Check(WhiteList,TracebackTable)
	return a
end

local AuthFunctionValue = nil

local Auth = function()
	local function ActualAuth()
		if true then
			return 'Auth_Passed_true'
		end
		local Stack = getfenv(1)
		if not AuthFunctionValue then
			AuthFunctionValue = tostring(Stack.Auth)
		end
		if not Stack.script or Stack.script ~= script then
			Trigger('Client Tampering Detected','2' .. '\n' .. Stack.script)
			return 'Auth_Failed_false'
		end
		if ExploitsDetected then return 'Auth_Failed_false' end
		local Data = {debug.traceback('',1)}
		Data[1] = string.gsub(Data[1],'\n'," ")
		if not table.find(MainTraces,Data[1]) then
			table.insert(MainTraces,Data[1])
		end
		local e = Data[1]
		Data[1] = nil
		Data = nil
		for i = 1, string.len(e) do 
			if not e then return end
			if string.sub(e,i,i) == ' ' then
				e = string.gsub(e,' ','')
			end
		end
		if 'ReplicatedStorage.ONYX.Modules.' .. script.Name ~= debug.info(1,'s')  then
			Trigger('Client Tampering detected','3\n' .. debug.info(1,'s'))
			return 'Auth_Failed_false'
		end
		if not string.find(debug.traceback('',2),script:GetFullName() .. ':3') then
			Trigger('Client Tampering detected','4\n' .. debug.traceback('',2))
			return 'Auth_Failed_false'
		end
		TracebackCheck(string.split(debug.traceback('',1),'\n'))
		if not string.find(debug.traceback('',1),script:GetFullName() .. ':3')  then
			Trigger('Client Tampering detected','5\n' .. debug.traceback('',1))
			warn('4')
			return 'Auth_Failed_false'
		end
		if #MainTraces > MaxTraces then
			Trigger('Client Tampering detected','6\n' .. #MainTraces .. ':' .. MaxTraces)
			warn('5')
			return 'Auth_Failed_false'
		end
		if not debug.info(2,'l') then
			Trigger('Client Tampering detected','42\n' .. debug.info(2,'l'))
			return 'Auth_Failed_false'
		end
		for i = 1,10 do
			local _,Env = pcall(getfenv,i)
			if _ and Env and Env['getsenv'] then
				Env.spawn(function()
					local res,err = pcall(function()
						if Env.game:GetService('CoreGui'):FindFirstChild('Something') then
							Trigger('Client Tampering detected','7\nCoreGui Check Failed')
							warn('6')
							return 'Auth_Failed_false'
						end

					end)
					if res then
						Trigger('Client Tampering detected','8\nCoreGui Check Failed')
						warn('7')
						return 'Auth_Failed_false'
					end
				end)
			end
		end
		local callingScriptPath = debug.info(2,'s')
		if callingScriptPath == nil then
			Trigger('Client Tampering detected','9\n' .. callingScriptPath)
			warn('8')
			return 'Auth_Failed_false'
		elseif callingScriptPath == '[C]' then
			Trigger('Client Tampering detected','10\n' .. callingScriptPath)
			warn('9')
			return 'Auth_Failed_false'
		end
		LastRan = os.time()
		return 'Auth_Passed_true'
	end
	return ActualAuth
end
function module:SetId(Id)
	if Id ~= 10094361327 then
		Trigger('Client Tampering Detected','11\n' .. Id)
	end
	Auth()()
	AnimationId = Id
end
spawn(function()
	repeat task.wait() until AdminEvent
	AdminEvent.OnClientInvoke = function(VerifyData)
		if Triggers[VerifyData] then
			Triggers[VerifyData] = nil
		else
			Trigger('Remote Tampering Detected','12\n' .. VerifyData)
		end
	end
end)
local Response = function(Data)
	local Fired = false
	for i,v in pairs(Triggers) do 
		if v == Data then
			Fired = true
		end
	end
	if Fired then return end
	if not Fired then
		Trigger('Remote Tampering detected','13\nNot Fired')
	end
end


local LastRuns = {}
local MainThing = ''
function module.new(Func,LoopDelay:number,Detection:string)
	if not Func then return end
	if not LoopDelay then
		LoopDelay = 1/60
	end
	local Response = Auth()()
	if Response ~= 'Auth_Passed_true' and Response ~= 'Auth_Failed_false' then
		Trigger('Client Tampering detected','14\n' .. tostring(Response))
		ExploitsDetected = true
	end
	if Response == 'Auth_Failed_false' then
		ExploitsDetected = true
		Trigger('Client Tampering detected','41\n' .. tostring(Response))
		return 'Authorzation_Failed'
	end

	local Key = game:GetService('HttpService'):GenerateGUID(false)
	if typeof(Func) == 'function' then
		CurrentLoops[Key] = Func
		CurrentLoops[Key .. 'LastRun'] = 0
		CurrentLoops[Key .. 'Delay'] = LoopDelay
		CurrentLoops[Key .. 'Detection'] = Detection
		MainThing = MainThing .. Key .. ':'
	end
end

function module:GetFingerprint()
	local response = Auth()()
	if response ~= 'Auth_Passed_true' then
		Trigger('Client Tampering Detected','15\n' .. tostring(response))
		return
	end
	local LocalizationService = game:GetService('LocalizationService')
	local UserInputService = game:GetService('UserInputService')

	local GetPlatformID = function()
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
			return 2
		elseif UserInputService.TouchEnabled and UserInputService.KeyboardEnabled or UserInputService.KeyboardEnabled then
			return 1
		else
			return 3
		end
	end

	local function StringToBytes(Text)
		local Bytes = { string.byte(Text, 1,-1) }
		local CC = ''
		for i,v in pairs(Bytes) do
			CC = CC..v
		end
		return string.gsub(CC,' ','')
	end

	local function TimeZoneConvert(Timezone)
		local ReturnValue = ''
		local Thing = string.split(Timezone,' ')
		for i = 1, 3 do 
			local a = Thing[i]
			if not a then return end
			ReturnValue = ReturnValue .. string.sub(a,1,1)
		end
		return ReturnValue
	end

	local function Finalizer(Fingerprint)
		if not Fingerprint then return end
		if string.len(Fingerprint) > 47 then
			return string.sub(Fingerprint,1,47)
		end
		return Fingerprint
	end

	local CPUStart = math.floor(tick() - os.clock())
	local LocaleId = LocalizationService.RobloxLocaleId
	local SystemLocaleId = LocalizationService.SystemLocaleId
	local CR = LocalizationService:GetCountryRegionForPlayerAsync(game.Players.LocalPlayer)
	local TimeZone = os.date("%Z")
	local PlatformID = GetPlatformID()
	local ScreenSize = game.Workspace.Camera.ViewportSize.X + game.Workspace.Camera.ViewportSize.Y

	local BACFingerPrint = tostring(CPUStart)..'-'..string.byte('E',1)..'-'..StringToBytes(LocaleId)..'-'..StringToBytes(CR)..'-'..tostring(PlatformID)..'-'..ScreenSize..'-'..StringToBytes(TimeZoneConvert(TimeZone))
	BACFingerPrint = Finalizer(BACFingerPrint)
	if not BACFingerPrint then return CPUStart end
	return BACFingerPrint
end

local LastReturnValues = {}
local LastRun = 0

local Fingerprint = module:GetFingerprint()
spawn(function()
	Trigger('FingerPrint',Fingerprint)
end)
local LastChosenFunction = {}
local GetNextFunction = function()
	local PossibleFunc = {}
	local Keys = string.split(MainThing,':')
	for i,v in pairs(Keys) do 
		if v~= '' then
			local LastRun = CurrentLoops[v .. 'LastRun']
			local TheDelay = CurrentLoops[v .. 'Delay']
			if os.time() > LastRun + TheDelay and not table.find(LastChosenFunction,CurrentLoops[v .. 'Detection']) then
				table.insert(PossibleFunc,CurrentLoops[v])
			end
		end
	end
	if #PossibleFunc >= 1 then
		return PossibleFunc[math.random(1,#PossibleFunc)]
	else
		LastChosenFunction = {}
		return nil
	end
end

local GetKeyFromFunction = function(Function)
	local Keys = string.split(MainThing,':')
	Keys[#Keys] = nil
	for i,v in pairs(Keys) do 
		if CurrentLoops[v] == Function then
			return v
		end
	end
end

game:GetService('RunService').RenderStepped:Connect(function()
	if not script.Parent then
		--Trigger('Client Tampering Detected','16')
	end
	local Key  = GetNextFunction()
	local Actualkey = GetKeyFromFunction(Key)
	if Actualkey == '' or Actualkey == ' ' then return end
	if not Key then return end
	if not CurrentLoops[Actualkey] and Actualkey ~= '' then
		Trigger('Client Tampering Detected','17\n' .. 'function Removed.')
	end
	local lastRun = CurrentLoops[Actualkey .. 'LastRun']
	local TheDelay = CurrentLoops[Actualkey .. 'Delay']
	local success,err = nil
	CurrentLoops[Actualkey .. 'LastRun'] = os.time()
	success,err = pcall(function()
		local Result,ExtraData = Key()
		if not LastReturnValues[Actualkey] and Result ~= 'check_failed' then
			LastReturnValues[Actualkey] = Result 
		else
			if LastReturnValues[Actualkey] ~= Result and tostring(Result) ~= 'check_failed' and LastReturnValues[Actualkey] ~= 'check_failed' then
				Trigger('Client Tampering Detected','18\n' .. 'Expected: ' .. tostring(LastReturnValues[Actualkey]) .. ' Got: ' .. tostring(Result) .. '\nDetection: ' .. CurrentLoops[Actualkey .. 'Detection'])
			end
		end
		if Result == 'check_failed' then
			Trigger(CurrentLoops[Actualkey .. 'Detection'],ExtraData)
		end
	end)
	if success then
		LastRan = os.time()
		CurrentLoops[Actualkey .. 'LastRun'] = os.time()
	end
	if not success then
		warn(Actualkey)
		warn(err)
		warn(CurrentLoops[Actualkey .. 'Detection'] .. ' ran into a problem while executing, Data: ' .. err)
	end
	if Actualkey ~= '' and LastRan + TheDelay + 10 < TheDelay + os.time() then
		Trigger('Client Tampering Detected','20\n function execution ceased' )
	end

	LastRun = os.time()
end)

return module
