local ForestGeneration = {}

-- Services
local ServerStorage = game:GetService("ServerStorage")

-- Modules
local ModuleScripts = ServerStorage:WaitForChild("ModuleScripts")
local ForestScripts = ModuleScripts:WaitForChild("ForestScripts")
local ForestSettings = require(ForestScripts:WaitForChild("ForestSettings"))
local Tree = require(ForestScripts:WaitForChild("Tree"))
local Bush = require(ForestScripts:WaitForChild("Bush"))

-- Local Functions
local function generateRandomPointAround(x, z, radius)
	local r = math.random(radius, 2 * radius)
	local angle = math.random() * 2 * math.pi
	local newX = x + r * math.cos(angle)
	local newZ = z + r * math.sin(angle)
	return newX, newZ
end

local function calcDistance(x1, x2)
	return math.abs((x2-x1))
end

local function createPartsXYListFromModel(model)
	local decendents = model:GetDescendants()
	local parts = {}
	
	for _, descendant in pairs(decendents) do
		local descendantPosition = descendant.Position
		local descendantSize = descendant.Size
		if descendant:IsA("BasePart") then
			table.insert(parts, {
				descendantPosition.X - descendantSize.X / 2, -- minx
				descendantPosition.X + descendantSize.X / 2, -- maxX
				descendantPosition.Z - descendantSize.Z / 2, -- minZ
				descendantPosition.Z + descendantSize.Z / 2,  -- maxZ
				descendant
			})
		end
	end
	return parts
end

local function getYfromXZ(parts, x, z)
	for _, partInfo in pairs(parts) do
		if x >= partInfo[1] and x <= partInfo[2] and z >= partInfo[3] and z <= partInfo[4] then
			-- point is above this part
			
			local part = partInfo[5]
			
			local rayOrigin = Vector3.new(x, 1000, z)
			local rayDirection = Vector3.new(0, -2000, 0)
			
			local raycastParams = RaycastParams.new()
			raycastParams.IgnoreWater = true
			raycastParams.FilterDescendantsInstances = {part}
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			
			local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
			
			if raycastResult then
				return raycastResult.Position.Y
			end
		end
	end
	
	return nil
end

local function getGridIndex(x, z, cellSize, gridWidth, gridLength)
	local gx = math.abs(math.floor(x / cellSize)) + 1
	local gy = math.abs(math.floor(z / cellSize)) + 1

	if gx >= 1 and gx <= gridWidth and gy >= 1 and gy <= gridLength then
		return (gy - 1) * gridWidth + gx
	end

	return nil
end

local function validPoint(parts, x, z, cellSize, gridWidth, gridLength, lowerX, lowerZ, grid, radius)
	
	-- Check if point is within bounds of the model
	local inBounds = false
	for _, part in pairs(parts) do
		if x >= part[1] and x <= part[2] and z >= part[3] and z <= part[4] then
			inBounds = true
			break
		end
	end
	
	if not inBounds then
		return false
	end
	
	-- Center points on model
	local cenX = calcDistance(x, lowerX)
	local cenZ = calcDistance(z, lowerZ)
	
	-- Check if point has a valid index
	if getGridIndex(cenX, cenZ, cellSize, gridWidth, gridLength) == nil then
		return false
	end
	
	-- Check neighboring cells
	local gx = math.floor(cenX / cellSize) + 1
	local gz = math.floor(cenZ / cellSize) + 1
	for i = -1, 1 do
		for j = -1, 1 do
			local neighborIndex = getGridIndex((gx + i - 1) * cellSize, (gz + j - 1) * cellSize, cellSize, gridWidth, gridLength)
			if neighborIndex and grid[neighborIndex] then
				local neighborPoint = grid[neighborIndex]
				if neighborPoint == 1 then
					continue
				end
				local dx = neighborPoint.x - x
				local dz = neighborPoint.z - z
				if (dx * dx + dz * dz) < (radius * radius) then
					return false
				end
			end
		end
	end
	
	return true
end

local function createForest(ForestLocation, model) -- Poisson Disk Sampling (Bridson Algorithm)
	local parts = createPartsXYListFromModel(model)
	local radius = ForestSettings.PoissonDiskSamplingRadius
	local maxAttempts = ForestSettings.maxPointPlaceAttempts
	
	local cellSize = radius / math.sqrt(2)
	
	-- Grid Size
	local modelPosition, modelSize = model:GetBoundingBox()
	local gridWidth = math.abs(math.ceil(modelSize.X / cellSize))
	local gridLength = math.abs(math.ceil(modelSize.Z / cellSize))
	local lowerX = modelPosition.X - modelSize.X / 2
	local lowerZ = modelPosition.Z - modelSize.Z / 2
	
	-- Initialize grid and active list
	local grid = {}
	for i = 1, gridWidth * gridLength do
		table.insert(grid, 1)
	end
	local activeList = {}
	local points = {}
	
	-- Get random starting point on first part in model
	local startX = math.random(parts[1][1], parts[1][2])
	local startZ = math.random(parts[1][3], parts[1][4])
	local startY = getYfromXZ(parts, startX, startZ)
	local startVector = Vector3.new(startX, startY, startZ)
	
	-- Center points on the lower edge of the model and get its index
	local startIndex = getGridIndex(calcDistance(startX, lowerX), calcDistance(startZ, lowerZ), cellSize, gridWidth, gridLength)
	
	-- Add the x and y to the grid, active list, and points
	grid[startIndex] = {x = startX, z = startZ}
	table.insert(activeList, {x = startX, z = startZ})
	table.insert(points, Vector3.new(startX, startY, startZ))
	
	-- Start main loop
	while #activeList > 0 do
		-- Pick a random point from the active list
		local activeIndex = math.random(#activeList)
		local point = activeList[activeIndex]

		local found = false
		for i = 1, maxAttempts do
			local newX, newZ = generateRandomPointAround(point.x, point.z, radius)
			
			if validPoint(parts, newX, newZ, cellSize, gridWidth, gridLength, lowerX, lowerZ, grid, radius) then
				local newIndex = getGridIndex(calcDistance(newX, lowerX), calcDistance(newZ, lowerZ), cellSize, gridWidth, gridLength)
				grid[newIndex] = {x = newX, z = newZ}
				table.insert(activeList, {x = newX, z = newZ})
				found = true
				local newY = getYfromXZ(parts, newX, newZ)
				if newY then
					table.insert(points, Vector3.new(newX, newY, newZ))
					break
				end
			end
			
		end
		
		if not found then
			table.remove(activeList, activeIndex)
		end
	end
	
	return points
end



-- Module Functions
function ForestGeneration.createForestOnModel(ForestLocation, model)
	return createForest(ForestLocation, model)
end

return ForestGeneration