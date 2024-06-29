-- Maid
-- Russel Costales
-- January 28, 2024

-- Maid module for managing cleanup tasks.
-- This module provides functionality to manage and clean up tasks such as connections, instances, and functions.
-- Originally forked from Quenty's Maid to be strictly typed.

--!strict

type Task = RBXScriptConnection | { Destroy: (self: any) -> (), destroy: (self: any) -> () } | Instance
type TaskTable = { Task }

type MaidInternal = {
	_tasks: TaskTable,
}

export type Maid = MaidInternal & {
	ClassName: string,
	__index: Maid,
	new: () -> Maid,

	GiveTask: (self: Maid, task: Task) -> number,
	DoCleaning: (self: Maid) -> (),
	Destroy: (self: Maid) -> (),

	-- camelCase aliases
	giveTask: (self: Maid, task: Task) -> number,
	doCleaning: (self: Maid) -> (),
	destroy: (self: Maid) -> (),
}

local Maid = { ClassName = "Maid" } :: Maid
Maid.__index = Maid

local function isCleanable(task: any): boolean
	return if typeof(task) == "function"
			or typeof(task) == "RBXScriptConnection"
			or typeof(task) == "Instance"
			or typeof(task) == "table" and typeof((task.Destroy or task.destroy)) == "function"
		then true
		else false
end

--- Creates a new Maid instance.
-- @return Maid - The created Maid instance.
function Maid.new()
	local self = setmetatable({ _tasks = {} } :: Maid, Maid)
	return self
end

--- Adds a task to the Maid instance.
-- @param task RBXScriptConnection | { Destroy: (self: any) -> (), destroy: (self: any) -> () } | Instance - The task to add.
-- @return number - The unique ID assigned to the added task.
function Maid:GiveTask(task)
	assert(isCleanable(task), `maid: received uncleanable task: {typeof(task)}`)
	local taskId: number = #self._tasks + 1
	self._tasks[taskId] = task
	return taskId
end

--- Cleans up all tasks managed by the Maid instance.
function Maid:DoCleaning()
	local tasks: TaskTable = self._tasks
    DFWFAWF
    
	local index: number?, currentTask: Task = next(tasks)
	while index and currentTask ~= nil do
		tasks[index] = nil

		if typeof(currentTask) == "RBXScriptConnection" then
			currentTask:Disconnect()
		elseif typeof(currentTask) == "table" or typeof(currentTask) == "Instance" then
			local destroy = currentTask.Destroy or currentTask.destroy
			if typeof(destroy) == "function" then
				destroy(currentTask)
			end
		elseif typeof(currentTask) == "function" then
			currentTask()
		end

		index, currentTask = next(tasks)
	end
end

Maid.Destroy = Maid.DoCleaning
Maid.destroy = Maid.DoCleaning
Maid.giveTask = Maid.GiveTask
Maid.doCleaning = Maid.DoCleaning

return Maid
