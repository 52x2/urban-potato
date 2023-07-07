getgenv().loop = true

local target = "Criminal"

if not loop then return end
local Teams = game:GetService('Teams')
local Players = game:GetService('Players')
local Inventory = Players.LocalPlayer.Folder
local stuckbombs = {}

local Spawns = {
    Vector3.new(736, 38, 1111),
    Vector3.new(-235, 18, 1583),
    Vector3.new(-1179, 18, -1579),
    Vector3.new(671, 19, -3550),
    Vector3.new(2115, 19, -2555),
    Vector3.new(-405, 19, -5645),
    Vector3.new(529, 253, -1298)
}

if not fun_loaded then
    for _, v in Spawns do
        Players.LocalPlayer:RequestStreamAroundAsync(v)
        print('Streamed')
    end
end

print('starting...')
getgenv().fun_loaded = true

function clean(c)
	for _, v in c:GetChildren() do
		if v:IsA("BasePart") or v:IsA("Model") then
			v:Destroy()
		end
	end
end

Inventory['C4'].InventoryEquipRemote:FireServer(true)
function findbombs(checkstuck)
	local bombs = {}
	for _, v in workspace:GetChildren() do
		if v.Name == "C4" then
			if not v:FindFirstChild("Stuck") then
				continue
			end

			if checkstuck and (v.Stuck.Value or table.find(stuckbombs, v)) then
				continue
			end

			clean(v)
			bombs[#bombs + 1] = v
		end
	end

	return bombs
end

function resetbombs()
	local bombs = findbombs(false)
	local current = #bombs
	if #bombs >= 8 then task.wait(0.5)
		for _, bomb in bombs do
			if not bomb:FindFirstChild("DetonateRemote") then continue end
			bomb.DetonateRemote:FireServer()
		end
	end

	while #findbombs(true) == current do task.wait() end
	Inventory['C4'].InventoryEquipRemote:FireServer(false)
	Inventory['C4'].InventoryEquipRemote:FireServer(true)
	while #findbombs(true) == 0 do task.wait() end

	stuckbombs = {}
	return findbombs(true)
end

while loop do
	for _, v in Players:GetChildren() do task.wait()
		if v.Team ~= Teams[target] then continue end
		if v == Players.LocalPlayer then continue end
		if not v.Character or not v.Character.PrimaryPart then continue end
		local bombs = findbombs(true)
		if #bombs == 0 then
			print('resetting bombs...')
			bombs = resetbombs()
			print('reset bombs.')
		end

		print(v.Name)
		local bomb = bombs[1]
		bomb.StickRemote:FireServer(v.Character.PrimaryPart, CFrame.new(9e7, -9e7, -9e7))
		stuckbombs[#stuckbombs + 1] = bomb
	end
end
