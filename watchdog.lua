local component = require("component")
local os = require("os")
local string = require("string")
local tank
local last = 0
local chunk = 0
local count = 1
local rate_msg
local rate
local form
local dif

function mysplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end

if component.isAvailable("gt_machine") then
    tank = component.gt_machine
else
    print("No Tank Attached")
    os.exit()
end

while true do
    -- get tank and get integer of current benzene stored
    local tank_info = tank.getSensorInformation()
    local stored = mysplit(tank_info[4],"§")[2]
    -- local stored = string.sub(tank_info[4],4,12)
    local num = stored:gsub("%,","")
    local number = tonumber(num)

    if string.len(num) <= 9 then
        os.execute("clear)")
        print("Storage is empty!")
        goto continue
    end
    
    -- negative is growth rate, aka producing > using
    rate = last - number

    -- format of screen prints
    form = string.format("Benzene Stored: %d", num)
    dif = string.format("Benzene Change: %f / second", rate)
    
    if rate > 0 then
        rate_msg = string.format("Time until empty: %f seconds", 4000000/rate)
    elseif rate < 0 then
        rate_msg = string.format("Time until full: %f seconds", (4000000-number)/(rate*-1))
    else
        rate_msg = "Storage is full"
    end

    -- print to screen
    os.execute("clear")
    print(form)
    print(dif)
    print(rate_msg)

    -- update last
    last = number
    
    -- handle larger window pane avg
    count = count + 1
    if count > 5 then
        chunk = number
        count = 1
    end
    ::continue::
    os.sleep(1)
end