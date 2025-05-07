-- Made by Nyzox

local player = game:GetService("Players").LocalPlayer
local userId = player.UserId


local function getPlayerVan()
    for _, van in ipairs(workspace:GetChildren()) do
        if van:IsA("Model") and van.Name == "DeliveryVan" then
            for _, part in ipairs(van:GetChildren()) do
                local ownerUserId = part:GetAttribute("OwnerUserId")
                if ownerUserId and ownerUserId == userId then
                    return van
                end
            end
        end
    end
    return nil
end

local function getPlayerBoxes()
    local names = {"SmallBox", "MediumBox", "LargeBox"}
    local boxes = {}
    for _, box in ipairs(workspace:GetChildren()) do
        if box:IsA("Model") and table.find(names, box.Name) then
            local ownerUserId = box:GetAttribute("OwnerUserId")
            if ownerUserId == userId then
                table.insert(boxes, box)
            end
        end
    end
    return boxes
end

local function getStoragePart(van)
    local size = Vector3.new(8, 1, 18.25)
    for _, part in ipairs(van:GetDescendants()) do
        if part:IsA("BasePart") and part.Size == size then
            return part
        end
    end
    return nil
end

local function moveBoxesToStorage(boxes, storage)
    local offset = Vector3.new(0, 2, 0)
    for _, box in ipairs(boxes) do
        local part = box:FindFirstChild("Box")
        if part and part:IsA("BasePart") then
            part.CFrame = storage.CFrame + offset
        else
            warn("Missing part 'box' in:", box.Name)
        end
    end
end

local van = getPlayerVan()
if not van then
    warn("No van found.")
    return
end

local storage = getStoragePart(van)
if not storage then
    warn("No storage part found in van.")
    return
end

local boxes = getPlayerBoxes()
if #boxes == 0 then
    warn("No boxes found.")
    return
end

moveBoxesToStorage(boxes, storage)


