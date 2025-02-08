local TreeSettings = {}

-- Tree Variables
TreeSettings.trunkMaxHeight = 16
TreeSettings.trunkMinHeight = 6
TreeSettings.widthMultiplier = 0.17
TreeSettings.maxTrunkTilt = math.pi/36 -- rx / rz plane
TreeSettings.trunkLower = 0.5

TreeSettings.maxNewSegmentScaleMultiplier = 0.7875577595
TreeSettings.newSegmentScaleMultiplierDecayRatio = 0.9
TreeSettings.numGuaranteedBranches = 3
TreeSettings.newBranchChance = 4 -- Out of 10
TreeSettings.minBranchWidth = 0.8
TreeSettings.maxBranchTilt = math.pi/4
TreeSettings.branchFailChance = 3 -- Out of 10
TreeSettings.maxMainBranches = 4
TreeSettings.treeColor = {r = 105, g = 64, b = 40}
TreeSettings.maxTreeColorIncr = 70

TreeSettings.leafHeightMultiplier = 0.6
TreeSettings.maxLeafWidthMultiplier = 7
TreeSettings.minLeafWidthMultiplier = 5
TreeSettings.leafRedBlueValue = 65
TreeSettings.minLeafGreen = 100
TreeSettings.maxLeafGreen = 150
TreeSettings.maxLeafTransparency = 0.65
TreeSettings.minLeafTransparency = 0.35

return TreeSettings
