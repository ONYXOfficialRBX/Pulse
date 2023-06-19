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



function module:Encrypt(Message,Seed,Player)
	if not Auth()() then return end
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
	local ConvertedString = ''
	for i = 1, string.len(Message) do 
		local Code = string.byte(Message,i,i)
		local NewCode = EncryptionKey[Code]
		ConvertedString = ConvertedString .. string.char(NewCode)
	end

	return ConvertedString,Seed/Player.AccountAge
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
	local NewString = ''
	for i = 1, string.len(Message) do 
		local Code = string.byte(Message,i,i)
		local NewChar = DecryptionKey[Code]
		NewString = NewString .. string.char(NewChar)
	end
	return NewString
end

return module
