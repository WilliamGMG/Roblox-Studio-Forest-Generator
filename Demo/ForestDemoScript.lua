-- Forest Generator Demo
-- Services
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

-- Module Scripts
local ModuleScripts = ServerStorage:WaitForChild("ModuleScripts")
local ForestScripts = ModuleScripts:WaitForChild("ForestScripts")
local ForestGeneration = require(ForestScripts:WaitForChild("ForestGeneration"))
local Tree = require(ForestScripts:WaitForChild("Tree"))
local Bush = require(ForestScripts:WaitForChild("Bush"))

---------------------------- FOLDER ORGANIZATION --------------------
local ForestFolder = Instance.new("Folder")
local TreeFolder = Instance.new("Folder")
local BushFolder = Instance.new("Folder")
ForestFolder.Name = "Forest"
BushFolder.Name = "Bushes"
TreeFolder.Name = "Trees"
ForestFolder.Parent = Workspace
BushFolder.Parent = ForestFolder
TreeFolder.Parent = ForestFolder

----------------------------------- FOREST CREATION -------------------- 
local ForestModel = game.Workspace:FindFirstChild("TestModel") -- Load the model
if ForestModel then
	
	local TreePointTable = ForestGeneration.createForestOnModel(ForestModel) -- Create a table of points for trees
	local BushPointTable = ForestGeneration.createForestOnModel(ForestModel) -- Create a table of points for bushes
	
	-- Create Trees
	for _, point in pairs(TreePointTable) do
		Tree.CreateNewTree(TreeFolder, point)
	end

	-- Create Bushes
	for _, point in pairs(BushPointTable) do
		Bush.CreateNewBush(BushFolder, point)
	end
	
end
