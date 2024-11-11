function BATTLEPASS.SpawnSecretItems()
    local diamond = ents.Create("battlepass_borger")
    diamond:SetPos(Vector(0, 0, 0))
    diamond:Spawn()

    local doll = ents.Create("battlepass_hula")
    doll:SetPos(Vector(0, 0, 0))
    doll:Spawn()

    local shoe = ents.Create("battlepass_shoe")
    shoe:SetPos(Vector(0, 0, 0))
    shoe:Spawn()
    local apple = ents.Create("battlepass_water")
    apple:SetPos(Vector(0, 0, 0))
    apple:Spawn()
end
hook.Add("InitPostEntity", "BATTLEPASS:SpawnSecretItems", BATTLEPASS.SpawnSecretItems)