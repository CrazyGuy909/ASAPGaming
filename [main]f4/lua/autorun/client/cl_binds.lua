
keybinds = keybinds or {}

keybinds.cache = keybinds.cache or {}
keybinds.index = keybinds.index or {}

keybinds.blacklistKeys = {
    KEY_W,
    KEY_A,
    KEY_S,
    KEY_D,
    KEY_LSHIFT,
    KEY_LALT,
    KEY_LCONTROL,
    KEY_ESCAPE,
    KEY_Y,
    KEY_U,
    KEY_ENTER,
    KEY_SPACE,
    KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,
    KEY_C,
    KEY_G
}

// READ ME:
// If you change a UniqueID of any keybind, it will cause the player's keybinds to not work properly.
// Everything here is clientside. Don't do verifications here. 
// You can add blacklist keys in the table above. [ENUM]

function keybinds.RegisterBind(strUnique, helpText, enumKey, funcDown, funcUp)
    
    //if (keybinds.cache[strUnique] ) then return end 

    keybinds.cache[strUnique] = {unique = strUnqiue, help = helpText, defaultKey = enumKey, key = enumKey, funcDown = funcDown, funcUp = funcUp}

    keybinds.index[enumKey] = keybinds.cache[strUnique]

end

function keybinds.setBind(strUnique, enumKey, bClear)
    
    if (table.HasValue(keybinds.blacklistKeys, enumKey)) then return end

    if (bClear) then
        for k,v in pairs(keybinds.index) do
            if (v.id == strUnique) then
                keybinds.index[k] = nil
                keybinds.cache[strUnique].key = nil
            end
            if (v.key == enumKey) then
                keybinds.index[k] = nil
                keybinds.cache[v.id].key = nil
            end
        end

        if (keybinds.cache[strUnique]) then
            keybinds.cache[strUnique].key = nil
        end
        keybinds.index[enumKey] = nil
        return
    end

    keybinds.cache[strUnique].key = enumKey
    keybinds.index[enumKey] = keybinds.cache[strUnique]
end

function keybinds.get(strUnique)
    return keybinds.cache[strUnique] or false
end

function keybinds.getAll()
    return keybinds.cache or {}
end

function keybinds.getBind(buttonID)
    return keybinds.index[buttonID] or false
end

function keybinds.getKey(strUnique)
    return keybinds.cache[strUnique].key and input.GetKeyName( keybinds.cache[strUnique].key  ) or "nil"
end

function keybinds.checkBlacklist(key)
    for k,v in pairs(keybinds.blacklistKeys) do
        if v == key then
            return true
        end
    end

    return false
end

function keybinds.Rebuild(strUnique, enumKey)
    if (strUnique) then
        keybinds.cache[strUnique].key = enumKey
    end
end

function keybinds.ChangeKey(strUnqiue, enumKey)
    local bind = keybinds.get(strUnqiue)

    if (bind) then
        if keybinds.checkBlacklist(enumKey) then return end 

        bind.key = enumKey

        keybinds.Rebuild(strUnqiue, enumKey)

    end
end


hook.Add("PlayerButtonUp", "keybinds.ButtonUp", function(pPlayer, button)
    if not IsFirstTimePredicted() then return end
    if pPlayer ~= LocalPlayer() then return end
    if pPlayer:IsTyping() then return end

    local bind = keybinds.getBind(button)

    if (bind) then
    
        if bind.funcUp() then 

            bind.funcUp(pPlayer)

        end

    end

end)

hook.Add("PlayerButtonDown", "keybinds.ButtonDown", function(pPlayer, button)
    if not IsFirstTimePredicted() then return end
    if pPlayer ~= LocalPlayer() then return end
    if pPlayer:IsTyping() then return end

    local bind = keybinds.getBind(button)

    if (bind) then

        if bind.funcDown then 
        
            bind.funcDown(pPlayer)

        end

    end

end)


// Resets player's keybinds back to the defaults.
function keybinds.resetDefault()
    local different = false
    for k,v in pairs(keybinds.cache) do
        if (v.key != v.defaultKey) then

            keybinds.setBind(k, v.defaultKey)

            different = true

        end

    end

    if (different) then
        // If binds were different then this will return a empty table anyways
        // Which will reset the loading process to {}

        keybinds.saveBinds()

    end

end

function keybinds.modifiedValues()

    local tblBinds = {}

    for k,v in pairs(keybinds.cache) do
        if (v.key != v.defaultKey) then
            tblBinds[k] = v.key or -1
        end
    end

    return tblBinds

end

function keybinds.saveBinds()

    local binds = keybinds.modifiedValues() or {}
    
    binds = util.TableToJSON(binds)

    file.CreateDir("keybinds")

    file.Write("keybinds/keybinds.txt", binds)
end

function keybinds.loadBinds()
    
    local binds = file.Read("keybinds/keybinds.txt", "DATA")

    binds = util.JSONToTable(binds or "[]")

    for k,v in pairs(binds) do

        keybinds.setBind(k, v, v == -1)
        
    end

end

timer.Simple(6, function()
    keybinds.loadBinds()
end)
