--!nonstrict

local replicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(replicatedStorage.TestEZ)

TestEZ.TestBootstrap:run({
	replicatedStorage.Maid,
})
