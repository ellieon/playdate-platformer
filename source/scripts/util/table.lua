function table.first(t)
    local keys = {}
    for k,_ in pairs(t) do
        table.insert(keys, k)
    end
    
    table.sort(keys)
    
    return t[keys[1]]
end