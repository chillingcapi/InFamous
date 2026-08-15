-- public

if game.CreatorId == 5212858 then
    local Executor = identifyexecutor and identifyexecutor() or ""
    if Executor == "Real" then
        game:GetService("Players").LocalPlayer:Kick("Evenesce did not load.\n\nReal gets you banned from Deepwoken. Use a different executor for this game.")
        return
    end
end

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/chillingcapi/InFamous/refs/heads/main/Loading.lua"))()
end)

loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/bbb9e167f6d5801e97294a2b01dd1fa6.lua"))()
