local module = {}

local function isValid(BaseOrder,Chosen)
	for i,v in pairs(BaseOrder) do 
		if Chosen == v then return false end
	end
	return true
end

local function GenerateKeys(Seed)
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
	return EncryptionKey,DecryptionKey
end

function module:Encrypt(Message,Seed)
	if shared.Seed then
		Seed = shared.Seed
	end
	if not Seed then
		Seed = tick()
	end
	local EncryptionKey = GenerateKeys(Seed)
	local NewString = ''
	for i = 1, string.len(Message) do 
		local Char = string.sub(Message,i,i)
		local Code = string.byte(Char)
		local NewChar = EncryptionKey[Code]
		NewString = NewString .. string.char(NewChar)
	end
	return NewString,Seed
end

function module:Decrypt(Message,Seed)
	if shared.Seed then
		Seed = shared.Seed
	end
	if not Seed then
		Seed = tick()
	end
	local _,DecryptionKey = GenerateKeys(Seed)
	local NewString = ''
	for i = 1, string.len(Message) do 
		local Char = string.sub(Message,i,i)
		local Code = string.byte(Char)
		local NewChar = DecryptionKey[Code]
		NewString = NewString .. string.char(NewChar)
	end
	return NewString
end

return module
