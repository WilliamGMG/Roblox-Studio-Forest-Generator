local Bush = {}

-- Services
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local ModuleScripts = ServerStorage:WaitForChild("ModuleScripts")
local ForestScripts = ModuleScripts:WaitForChild("ForestScripts")
local BushSettings = require(ForestScripts:WaitForChild("BushSettings"))

-- Local Functions
local function rollChance(chance, outOf)
	local result = math.random(1, outOf)
	return result <= chance
end

local function decayValue(value, decay, n)
	return value * (decay^n)
end

local function tableToPart(partTable)
	local part = Instance.new("Part")
	
	part.Size = partTable.size
	part.CFrame = partTable.position
	part.Material = Enum.Material.LeafyGrass
	part.Color = partTable.color
	part.Anchored = true
	part.CanCollide = false
	
	return part
	
end

local function newPartSize()
	local length = math.random(BushSettings.minLength * 100, BushSettings.maxLength * 100) / 100
	local height = math.random(BushSettings.minHeight * 100, BushSettings.maxHeight * 100) / 100
	local width = math.random(BushSettings.minWidth * 100, BushSettings.maxWidth * 100) / 100
	
	return Vector3.new(length, height, width)
end

local function complieBush(position)
	local bushModel = Instance.new("Model")
	
	local minParts = BushSettings.minParts
	local maxXoffset = BushSettings.maxXoffset
	local maxYoffset = BushSettings.maxYoffset
	local maxZoffset = BushSettings.maxZoffset
	local failChance = BushSettings.failChance
	local minGreen = BushSettings.minGreen
	local maxGreen = BushSettings.maxGreen
	local numParts = 0
	
	repeat 
		local bushSize = newPartSize()
		local rx = math.random(0, 100) / 100
		local ry = math.random(0, 100) / 100
		local rz = math.random(0, 100) / 100
		local xOffset = math.random(-maxXoffset * 100, maxXoffset * 100) / 100
		local yOffset = math.random(-maxYoffset * 100, maxYoffset * 100) / 100
		local zOffset = math.random(-maxZoffset * 100, maxZoffset * 100) / 100
		local bushPosition = Vector3.new(position.X + xOffset, position.Y + bushSize.Y / 4 + yOffset, position.Z + zOffset)
		local bushCFrame = CFrame.new(bushPosition) * CFrame.Angles(rx, ry, rz)
		local bushColor = Color3.fromRGB(0, math.random(minGreen, maxGreen), 0)
		local bushPart = tableToPart({size = bushSize, position = bushCFrame, color = bushColor})
		bushPart.Parent = bushModel
		
		numParts = numParts + 1
	until numParts > minParts and rollChance(failChance, 10)
	
	return bushModel
end

local function complieBushOld(position)
	local bushModel = Instance.new("Model")
	
	local startinglength = math.random(BushSettings.minLength * 100, BushSettings.maxLength * 100) / 100
	local startingheight = math.random(BushSettings.minHeight * 100, BushSettings.maxHeight * 100) / 100
	local startingWidth = math.random(BushSettings.minWidth * 100, BushSettings.maxWidth * 100) / 100
	
	local lengthMultiplier = math.random(BushSettings.maxLengthMultiplier * 1000, BushSettings.minLengthMultiplier * 1000) / 1000
	local heightMultiplier = math.random(BushSettings.maxHeightMultiplier * 1000, BushSettings.minHeightMultiplier * 1000) / 1000
	local widthMultiplier = math.random(BushSettings.minWidthMultiplier * 1000, BushSettings.maxWidthMultiplier * 1000) / 1000
	
	local runningLengthMultiplier = lengthMultiplier
	local runningHeightMultiplier = heightMultiplier
	local runningWidthMultiplier = widthMultiplier
	
	local decayRatio = BushSettings.decayRatio
	local minHeightValue = BushSettings.minHeightValue
	local redBlue = BushSettings.redBlueValue
	local minGreen = BushSettings.minGreen
	local maxGreen = BushSettings.maxGreen
	
	local ry = math.random(0, 100) / 100
	local nthBush = 0
	
	repeat
		nthBush = nthBush + 1
		
		local bushSize = Vector3.new(startinglength * runningLengthMultiplier, startingheight * runningHeightMultiplier, startingWidth * runningWidthMultiplier)
		local bushPosition = Vector3.new(position.X, position.Y + bushSize.Y / 2, position.Z)
		local rx = math.random(0, 1000) / 1000
		local rz = math.random(0, 1000) / 1000
		
		local bushCFrame
		if nthBush == 1 then
			bushCFrame = CFrame.new(bushPosition) * CFrame.Angles(0, ry, 0)
		else
			bushCFrame = CFrame.new(bushPosition) * CFrame.Angles(rx, ry, ry)
		end

		local bushColor = Color3.fromRGB(redBlue, math.random(minGreen, maxGreen), redBlue)
		local bushPart = tableToPart({size = bushSize, position = bushCFrame, color = bushColor})
		bushPart.Parent = bushModel
		
		runningLengthMultiplier = decayValue(lengthMultiplier, decayRatio, nthBush)
		runningHeightMultiplier = decayValue(heightMultiplier, decayRatio, nthBush)
		runningWidthMultiplier = decayValue(widthMultiplier, decayRatio, nthBush)
	until runningHeightMultiplier * startingheight < minHeightValue
	
	return bushModel
end

-- Module Functions
function Bush.CreateNewBush(FolderLocation, position)
	local bush = complieBush(position)
	bush.Parent = FolderLocation
end

return Bush