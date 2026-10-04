print("=== REMOTE EVENTS ===")
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        print("[RemoteEvent] " .. v:GetFullName())
    end
end
print("=== DONE ===")
