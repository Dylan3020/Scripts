print("mspaint loaded")

loadstring(game:HttpGet("https://raw.githubusercontent.com/notpoiu/mspaint/main/main.lua"))()

game.Lighting.Sky:Remove()
game.Lighting.Bloom:Remove()
game.Lighting.Caves:Remove()
game.Lighting.ColorCorrection:Remove()
game.Lighting.MainColorCorrection:Remove()
game.Lighting.OxygenBlur:Remove()
game.Lighting.OxygenCC:Remove()
game.Lighting.Sanity:Remove()
game.Lighting.XBoxColor:Remove()
game.ReplicatedStorage.FloorReplicated.PreRunCutscene:Remove()
