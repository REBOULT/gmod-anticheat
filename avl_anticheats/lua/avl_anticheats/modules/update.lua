local url = ""
	
local version = "1.12.5"

local function Message(data)
	AVL("Античит не обновлен, могут быть ошибки!!!")
end


local function CheckUpdate()
	http.Fetch(url, function(data)
		data = util.JSONToTable(data)

		if version == data.version then
			AVL("")
		else
			Message(data)
			timer.Create("AVL-Please-Update", 60*15, 0, function()
				Message(data)
			end)
		end
	end)
end
timer.Simple(3, CheckUpdate)