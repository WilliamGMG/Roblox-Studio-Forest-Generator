local Tree = {}

-- Services 
local ServerStorage = game:GetService("ServerStorage")

-- Module Scripts
local ModuleScripts = ServerStorage:WaitForChild("ModuleScripts")
local ForestScripts = ModuleScripts:WaitForChild("ForestScripts")
local TreeSettings = require(ForestScripts:WaitForChild("TreeSettings"))

-- Local Functions
local function rollChance(chance, outOf)
	local result = math.random(1, outOf)
	return result <= chance
end

local function decayValue(value, ratio, n)
	return value * ratio
end

local function turnToPart(partTable)
	local treePart = Instance.new("Part")
	
	treePart.Size = partTable.size
	treePart.CFrame = partTable.position * partTable.offset:Inverse()
	treePart.Material = Enum.Material.Sand
	treePart.Color = partTable.color
	treePart.Name = partTable.partType
	treePart.Anchored = true
	treePart.CanCollide = true
	
	return treePart
end

local function turnToLeafPart(partTable)
	local leafPart = Instance.new("Part")
	
	leafPart.Size = partTable.size
	leafPart.CFrame = partTable.position
	leafPart.Material = Enum.Material.LeafyGrass
	leafPart.Color = partTable.color
	leafPart.Name = partTable.partType
	leafPart.Anchored = true
	leafPart.CanCollide = false

	return leafPart
end

local function ComplieTree(position)
	local treeModel = Instance.new("Model")
	local trunkMinHeight = TreeSettings.trunkMinHeight + TreeSettings.trunkLower
	local trunkMaxHeight = TreeSettings.trunkMaxHeight + TreeSettings.trunkLower
	local maxTrunkTilt = TreeSettings.maxTrunkTilt
	local widthMultiplier = TreeSettings.widthMultiplier
	local treeColor = TreeSettings.treeColor
	local maxTreeColorIncr = TreeSettings.maxTreeColorIncr
	local pi = math.pi
		
	-- Create the trunk
	local trunkHeight = math.random(trunkMinHeight * 100, trunkMaxHeight * 100) / 100
	local trunkWidth = trunkHeight * widthMultiplier
	local trunkSize = Vector3.new(trunkWidth, trunkHeight, trunkWidth)
	local trunkPosition = Vector3.new(position.X, position.Y + trunkHeight / 2, position.Z)	
	local rxTrunk = math.random(-maxTrunkTilt * 1000, maxTrunkTilt * 1000) / 1000
	local rzTrunk = math.random(-maxTrunkTilt * 1000, maxTrunkTilt * 1000) / 1000
	local trunkCFrame = CFrame.new(trunkPosition) * CFrame.Angles(rxTrunk, 0, rzTrunk)
	local treeColorIncr = math.random(0, maxTreeColorIncr)
	local trunkColor = Color3.fromRGB(treeColor.r + treeColorIncr, treeColor.g + treeColorIncr, treeColor.b + treeColorIncr)
	local trunkPart = turnToPart({size = trunkSize, position = trunkCFrame, offset = CFrame.new(), color = trunkColor, partType = "trunk"})
	trunkPart.Parent = treeModel
	
	-- Create branches & leaves
	local numGuaranteedBranches = TreeSettings.numGuaranteedBranches
	local segmentScaleDecayRatio = TreeSettings.newSegmentScaleMultiplierDecayRatio
	local newBranchChance = TreeSettings.newBranchChance
	local branchFailChance = TreeSettings.branchFailChance
	local maxBranchTilt = TreeSettings.maxBranchTilt
	local minBranchWidth = TreeSettings.minBranchWidth
	local leafHeightMultiplier = TreeSettings.leafHeightMultiplier
	local maxLeafWidthMultiplier = TreeSettings.maxLeafWidthMultiplier
	local minLeafWidthMultiplier = TreeSettings.minLeafWidthMultiplier
	local leafRedBlueValue = TreeSettings.leafRedBlueValue
	local minLeafGreen = TreeSettings.minLeafGreen
	local maxLeafGreen = TreeSettings.maxLeafGreen
	local maxLeafTransparency = TreeSettings.maxLeafTransparency
	local minLeafTransparency = TreeSettings.minLeafTransparency
	local maxMainBranches = TreeSettings.maxMainBranches
	local numBranches = 0
	
	repeat
		local newSegmentScaleMultiplier = TreeSettings.maxNewSegmentScaleMultiplier
		local startingHeight
		local startingRx
		local startingRz
		local decayN = 0
		local branchPart = nil
		numBranches = numBranches + 1
		
		-- check if the next width will be less than minBranchWidth
		repeat
			local treePart
			if newSegmentScaleMultiplier == TreeSettings.maxNewSegmentScaleMultiplier then
				treePart = treeModel:WaitForChild("trunk")
			else
				treePart = branchPart
			end
			
			-- Get the information from the part that the branch is coming from
			local startingSize = treePart.Size
			local startingCFrame = treePart.CFrame

			local startingHeight = startingSize.Y
			local startingRx, _, startingRz = startingCFrame:ToOrientation()
			local topSurfaceOffset = startingCFrame.UpVector * (startingSize.Y / 2)
			local topSurfacePosition = startingCFrame.Position + topSurfaceOffset		
			
			-- Get branch dimension and position
			local branchHeight = startingHeight * newSegmentScaleMultiplier
			local branchWidth = branchHeight * widthMultiplier
			local branchSize = Vector3.new(branchWidth, branchHeight, branchWidth)
			local rxBranch = startingRx + math.random(-maxBranchTilt * 1000, maxBranchTilt * 1000) / 1000
			local rzBranch = startingRz + math.random(-maxBranchTilt * 1000, maxBranchTilt * 1000) / 1000
			local branchOffset = CFrame.new(Vector3.new(0, -branchHeight / 2, 0))
			local branchPosition = Vector3.new(topSurfacePosition.X, topSurfacePosition.Y, topSurfacePosition.Z)
			local branchCFrame = CFrame.new(branchPosition) * CFrame.Angles(rxBranch, 0, rzBranch)
			local branchColor = treePart.Color
			branchPart = turnToPart({size = branchSize, position = branchCFrame, offset = branchOffset, color = branchColor, partType = "branch"})
			branchPart.Parent = treeModel
			
			decayN = decayN + 1
			newSegmentScaleMultiplier = newSegmentScaleMultiplier * (segmentScaleDecayRatio ^ decayN)
		until branchHeight * newSegmentScaleMultiplier * widthMultiplier < minBranchWidth -- or rollChance(10 - branchFailChance, 10)
		
		-- Mark the last branch
		branchPart.Name = "lastBranch"
		
		-- Add leaves onto the end of the last branch
		local treeModelDescendants = treeModel:GetDescendants()
		local lastBranch = treeModelDescendants[#treeModelDescendants]
		local leafHeight = lastBranch.Size.Y * leafHeightMultiplier
		local leafWidth = math.random(minLeafWidthMultiplier * 100, maxLeafWidthMultiplier * 100) / 100
		local leafSize = Vector3.new(leafWidth, leafHeight, leafWidth)
		local rxLeaf, _, rzLeaf = lastBranch.CFrame:ToOrientation()
		local ryLeaf = math.random(0, 100) / 100
		local leafGreen = math.random(minLeafGreen, maxLeafGreen)
		local leafColor = Color3.fromRGB(leafRedBlueValue, leafGreen, leafRedBlueValue)
		local leafCFrame = CFrame.new(lastBranch.Position + lastBranch.CFrame.UpVector * (lastBranch.Size.Y / 2)) * CFrame.Angles(rxLeaf, ryLeaf, rzLeaf)
		local leafPart = turnToLeafPart({size = leafSize, position = leafCFrame, color = leafColor, partType = "leaf"})
		leafPart.Parent = treeModel
		
		
		-- if no more guaranteed branches and chance to branch fails then break
	until numBranches > numGuaranteedBranches and not rollChance(newBranchChance, 10) or numBranches >= maxMainBranches

	
	return treeModel
end

-- Module Functions
function Tree.CreateNewTree(ForestFolder, position)
	local position = position + Vector3.new(0, -TreeSettings.trunkLower, 0)
	local tree = ComplieTree(position)
	tree.Parent = ForestFolder
	
end

return Tree
