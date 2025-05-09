local aux = {}

local getGc = getgc
local getInfo = debug.getinfo or getinfo
local getUpvalue = debug.getupvalue or getupvalue or getupval
local getConstants = debug.getconstants or getconstants or getconsts
local isXClosure = is_synapse_function or issentinelclosure or is_protosmasher_closure or is_sirhurt_closure or istempleclosure or checkclosure
local isLClosure = islclosure or is_l_closure or (iscclosure and function(f) return not iscclosure(f) end)

assert(getGc and getInfo and getConstants and isXClosure, "Your exploit is not supported")

local placeholderUserdataConstant = newproxy(false)

-- Vérification de la correspondance des constantes
local function matchConstants(closure, list)
    if not list then
        return true
    end
    
    local constants = getConstants(closure)
    
    for index, value in pairs(list) do
        if constants[index] == nil or (constants[index] ~= value and value ~= placeholderUserdataConstant) then
            return false
        end
    end
    
    return true
end

-- Recherche de la closure correspondant aux critères
local function searchClosure(script, name, upvalueIndex, constants, returnMultiple, ignoreX, verbose)
    local results = {}
    
    for _, v in pairs(getGc()) do
        local success, env = pcall(getfenv, v)
        if not success or type(env) ~= "table" then
            continue
        end

        local parentScript = rawget(env, "script")

        if type(v) == "function" and 
            isLClosure(v) and 
            (not ignoreX or not isXClosure(v)) and
            (
                (script == nil and parentScript.Parent == nil) or script == parentScript
            ) 
            and pcall(getUpvalue, v, upvalueIndex)
        then
            local matched = false
            if name and name ~= "Unnamed function" then
                if (getInfo(v).name or "") == name then
                    matched = true
                end
            elseif not name or name == "Unnamed function" then
                matched = true
            end

            if matched and matchConstants(v, constants) then
                if verbose then
                    print("Matched closure:", getInfo(v).name, constants)
                end

                if returnMultiple then
                    table.insert(results, v)
                else
                    return v
                end
            end
        end
    end

    return returnMultiple and results or nil
end

aux.placeholderUserdataConstant = placeholderUserdataConstant
aux.searchClosure = searchClosure

return aux
