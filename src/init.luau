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

function Maid.new()
	local self = setmetatable({ _tasks = {} } :: Maid, Maid)
	return self
end

function Maid:GiveTask(task)
	assert(isCleanable(task), `maid: received uncleanable task: {typeof(task)}`)
	local taskId: number = #self._tasks + 1
	self._tasks[taskId] = task
	return taskId
end

function Maid:DoCleaning()
	local tasks: TaskTable = self._tasks

	local index: number?, currentTask: Task = next(tasks)
	while index and currentTask ~= nil do
		tasks[index] = nil

		if typeof(currentTask) == "RBXScriptConnection" then
			currentTask:Disconnect()
		elseif typeof(currentTask) == "table" then
			local destroy = currentTask.Destroy or currentTask.destroy
			if typeof(destroy) == "function" then
				destroy(currentTask)
			end
		elseif typeof(currentTask) == "function" then
			currentTask()
		end
	end
end

Maid.Destroy = Maid.DoCleaning
Maid.destroy = Maid.DoCleaning
Maid.giveTask = Maid.GiveTask
Maid.doCleaning = Maid.DoCleaning

return Maid

--[[
local Maid = {} :: Maid
Maid.ClassName = "Maid"

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new()
	local self = setmetatable({ _tasks = {} } :: Maid, Maid)
	return self
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up
-- @usage
-- Maid[key] = (function)         Adds a task to perform
-- Maid[key] = (event connection) Manages an event connection
-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
--                                it is destroyed.
function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]
	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
	assert(task, "Task cannot be false or nil")

	local taskId = (#self._tasks + 1)
	self[taskId] = task

	if type(task) == "table" and not task.Destroy then
		warn("[Maid.GiveTask] - Gave table task without .Destroy\n\n" .. debug.traceback())
	end

	return taskId
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index :: number] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
		index, task = next(tasks)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

return Maid

]]
