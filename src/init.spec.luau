return function()
	local maid = require(script.Parent)

	describe("Maid Class", function()
		local myMaid

		beforeEach(function()
			myMaid = maid.new()
		end)

		afterEach(function()
			myMaid:Destroy()
			myMaid = nil
		end)

		it("should add clean connections", function()
			local connection = workspace.ChildAdded:Connect(function()
				print("child added")
			end)

			myMaid:GiveTask(connection)
			myMaid:DoCleaning()

			expect(connection.Connected).to.equal(false)
		end)

		it("should add destroy parts", function()
			local part = Instance.new("Part")
			part.Parent = workspace

			myMaid:GiveTask(part)
			myMaid:DoCleaning()

			expect(part.Parent).never.to.be.ok()
		end)

		it("should clean up objects", function()
			local calledDestroy = false
			local object = {
				destroy = function()
					calledDestroy = true
				end,
			}

			myMaid:GiveTask(object)
			myMaid:DoCleaning()

			expect(calledDestroy).to.equal(true)
		end)

		it("should clean up further objects during cleanup", function()
			local part = Instance.new("Part")
			part.Parent = workspace

			local object = {
				destroy = function()
					myMaid:GiveTask(part)
				end,
			}

			myMaid:GiveTask(object)
			myMaid:DoCleaning()

			expect(part.Parent).never.to.be.ok()
		end)

		it("should error when given a non-task", function()
			local success = pcall(function()
				myMaid:GiveTask(5)
			end)

			expect(success).to.equal(false)
		end)

		it("should have a destroy alias", function()
			expect(maid.Destroy == maid.DoCleaning)
		end)

		it("should have a camel case destroy alias", function()
			expect(maid.destroy == maid.Destroy)
		end)

		it("should have a camel case doCleaning alias", function()
			expect(maid.doCleaning == maid.DoCleaning)
		end)

		it("should have a camel case giveTask alias", function()
			expect(maid.giveTask == maid.GiveTask)
		end)
	end)
end
