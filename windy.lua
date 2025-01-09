repeat task.wait() until game:IsLoaded()
print("Windy Bee Hopper Loaded!")

local httpService = game:GetService("HttpService")
local placeID = game.PlaceId
local teleportService = game:GetService("TeleportService")
local Found = false

local function notify(title, text)
    game.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 30
    })
end

local function createBoundingBox(target)
    local billboardGui = Instance.new("BillboardGui", target.Head)
    billboardGui.Size = UDim2.new(0, 100, 0, 100)
    billboardGui.Adornee = target
    billboardGui.AlwaysOnTop = true

    local frame = Instance.new("Frame", billboardGui)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 4
    frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
end

local function checkForWindyBee()
    for _, child in ipairs(game:GetService("Workspace").NPCBees:GetChildren()) do
        if string.find(child.Name, "Windy") then
            Found = true
            notify("Windy Bee Found", child.Name)
            createBoundingBox(child)
            return true
        end
    end
    return false
end

local function hop()
    local success, site = pcall(function()
        return httpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeID .. '/servers/Public?sortOrder=Asc&limit=100'))
    end)
    
    if not success or not site or not site.data then return end
    
    for _, serverData in pairs(site.data) do
        if serverData.maxPlayers > serverData.playing then
            local serverID = tostring(serverData.id)
            local hopSuccess, errorMessage = pcall(function()
                if Found then return true end
                notify("Windy Bee Not Found", "No Windy Bee on this server. Hopping to the next...")
				wait(1)
                teleportService:TeleportToPlaceInstance(placeID, serverID, game.Players.LocalPlayer)
            end)
            
            if hopSuccess then break end
            if string.find(errorMessage, "Unauthorized") then
                print("Unauthorized teleport attempt. Trying another server...")
            end
        end
    end
end

game:GetService("Workspace").NPCBees.ChildAdded:Connect(function(child)
    if string.find(child.Name, "Windy") then
        Found = true
        notify("Windy Bee Found", child.Name)
        createBoundingBox(child)
    end
end)

if not checkForWindyBee() then
    hop()
else
    notify("Windy Bee Hopper", "Windy Bee Has Been Found!")
end
