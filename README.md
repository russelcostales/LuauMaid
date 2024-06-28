# TypedMaid
## Overview

The Maid module is designed to manage and clean up tasks in Roblox Lua scripting. It helps to automatically disconnect events, destroy instances, and execute cleanup functions when they are no longer needed. This guide will walk you through using the Maid module effectively. 

Forked from Quenty's original module to be strictly typed.

## Installation

To use the Maid module, follow these steps:

1. **Download**: Obtain the Maid module script from its source or repository.
2. **Integration**: Integrate the script into your Roblox game's scripting environment. You can place it directly into a Script or ModuleScript object as needed.

## Example Usage

### Creating a Maid Instance

To begin using the Maid module, create a new instance of the Maid:

```lua
local Maid = require(path.to.Maid)
local maid = Maid.new()
```

### Adding Tasks
Tasks can be added to the Maid instance using the giveTask method. Tasks can include connections, instances, or functions that need cleanup:
```lua
local part = Instance.new("Part")
part.Parent = game.Workspace

local connection = part.Touched:Connect(function(hit)
    print("Part touched by", hit.Name)
end)

maid:giveTask(part)
maid:giveTask(connection)
```

### Cleaning Up
When you no longer need these tasks, call doCleaning or destroy on the Maid instance to clean up all managed tasks:
This will automatically disconnect events, destroy instances, and execute cleanup functions associated with the tasks managed by the Maid instance.

```lua
maid:doCleaning()
-- or equivalently
maid:destroy()
```

## Additional Notes

- **Error Handling:** Ensure tasks added to the Maid are cleanable. The Maid module checks for valid tasks before adding them.
- **Aliases:** Methods like giveTask, doCleaning, and destroy have camelCase aliases (GiveTask, DoCleaning) for convenience.

## Conclusion

The Maid module simplifies managing cleanup tasks in Roblox Lua scripting. By using Maid instances to manage tasks, you can ensure that your game's scripts remain clean and efficient, reducing memory leaks and improving performance.

For more details, refer to the Maid module's documentation or comments within the script itself.