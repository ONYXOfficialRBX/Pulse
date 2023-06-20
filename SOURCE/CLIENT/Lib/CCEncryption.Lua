local module = {}

local function isValid(BaseOrder,Chosen)
	for i,v in pairs(BaseOrder) do 
		if Chosen == v then return false end
	end
	return true
end

local function Auth()
	local function RealAuth()
		return true
	end

	return RealAuth
end

local BaseOrderCache = {}
local EncryptionStorage = {}
local function GenerateKeys(Seed)
	if BaseOrderCache[math.floor(Seed)] then
		local a = BaseOrderCache[math.floor(Seed)]
		return a[1],a[2]
	end
	math.randomseed(Seed)
	local BaseOrder = {}
	for i = 0, 255 do 
		local Char = string.char(i)
		local Chosen = math.random(0,255)
		while not isValid(BaseOrder,Chosen) do 
			Chosen = math.random(0,255)
		end
		BaseOrder[i] = Chosen
	end
	local EncryptionKey = BaseOrder
	local DecryptionKey = {}
	for i,v in ipairs(EncryptionKey) do 
		DecryptionKey[v] = i 
	end
	BaseOrderCache[math.floor(Seed)] = {EncryptionKey,DecryptionKey}
	spawn(function()
		task.wait(600)
		BaseOrderCache[math.floor(Seed)] = nil
	end)
	return EncryptionKey,DecryptionKey
end

local function MainEncrypt(Message,EncryptionKey)
	local NewTable = {}
	if typeof(Message) == 'table' then
		for i,v in pairs(Message) do 
			local NewIndex = MainEncrypt(i,EncryptionKey)
			local NewValue = MainEncrypt(v,EncryptionKey)
			NewTable[NewIndex] = NewValue
		end
		return NewTable
	else
		local ConvertedString = ''
		Message = tostring(Message)
		for i = 1, string.len(Message) do 
			local Code = string.byte(Message,i,i)
			local NewCode = EncryptionKey[Code]
			ConvertedString = ConvertedString .. string.char(NewCode)
		end
		return ConvertedString
	end
end

function module:Encrypt(Message,Seed,Player)
	if not Auth()() then return end
	if not Player and game.Players.LocalPlayer then
		Player = game.Players.LocalPlayer
	end
	local Age = Player.AccountAge
	if Player.AccountAge <= 1 then
		Age = 2
	end
	if shared.Seed and not Seed then
		Seed = shared.Seed
	end
	if not Seed then
		Seed = tick()
	end
	local EncryptionKey = GenerateKeys(Seed)
	local Result = MainEncrypt(Message,EncryptionKey)

	return Result,Seed/Age
end
local function Convert(m)
	if typeof(m) == 'table' then return m end
	local a = string.split(m)
	if #a == 3 then
		return Vector3.new(a[1],a[2],a[3])
	elseif #a == 12 then
		return CFrame.new(a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12])
	elseif tonumber(m) then
		return tonumber(m)
	else return m
	end
end
local function MainDecrypt(Message,EncryptionKey)
	local NewTable = {}
	if typeof(Message) == 'table' then
		for i,v in pairs(Message) do 
			local NewIndex = MainDecrypt(i,EncryptionKey)
			local NewValue = MainDecrypt(v,EncryptionKey)
			NewIndex = Convert(NewIndex)
			NewValue = Convert(NewValue)
			NewTable[NewIndex] = NewValue
		end
		return NewTable
	else
		local ConvertedString = ''
		Message = tostring(Message)
		for i = 1, string.len(Message) do 
			local Code = string.byte(Message,i,i)
			local NewCode = EncryptionKey[Code]
			ConvertedString = ConvertedString .. string.char(NewCode)
		end
		return ConvertedString
	end
end

function module:Decrypt(Message,Seed,Player)
	if not Auth()() then return end
	if not Player and not game.Players.LocalPlayer then
		error('No Valid Player')
	elseif not Player and game.Players.LocalPlayer then
		Player = game.Players.LocalPlayer
	end
	local Age = Player.AccountAge
	if Age <= 1 then
		Age = 2
	end

	if shared.Seed and not Seed then
		Seed = shared.Seed
	end
	if not Seed then
		Seed = tick()
	end
	local EncryptionKey,DecryptionKey = GenerateKeys(Seed)
	local NewString = MainDecrypt(Message,DecryptionKey)
	NewString = Convert(NewString)
	return NewString
end

return module
