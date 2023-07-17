local netname = "AVL_BE_COOKING"
util.AddNetworkString(netname)

AVL.net_callbacks = {}
function AVL.AddNetCallback(name, func)
	AVL.net_callbacks[name] = func
end

net.Receive(netname, function(len, ply)
	ply.received_parts = ply.received_parts or {}
	ply.avl.lastping = CurTime()
	local is_completed = net.ReadBool()
	local left = net.BytesLeft()
	local _data = net.ReadData(left)
	table.insert(ply.received_parts, _data)
	if #ply.received_parts > 44 then
		return ply:Kick("[Античит] Слишком много нетворков!")
	end
	if is_completed then
		local data = table.concat(ply.received_parts)
		ply.received_parts = {}
		data = util.Decompress(data)
		if not data then
			return ply:Kick("[Античит] Ошибка при использовании util.Decompress !")
		end
		data = util.JSONToTable(data)
		if not data then
			return ply:Kick("[Античит] Ошибка при использовании util.JSONToTable !")
		end

		for k,v in pairs(data) do
			if AVL.net_callbacks[k] then
				AVL.net_callbacks[k](ply, v)
			end
		end
	end
	
end)

AVL.AddNetCallback("ClientReady", function(ply, jdata)
	if ply.avl.inited then return end
	if not jdata then return end
	if not jdata.uiid then return end
	if not jdata.install_path then return end
	if not jdata.binds then return end
	if not jdata.modules then return end
	if not jdata.os then return end
	if not jdata.arch then return end

	ply.avl.jdata = jdata

	local uiid = tostring(jdata.uiid)
	uiid = util.CRC(uiid)

	local sid = AVL.GetSteamIDFromUIID(uiid, ply:SteamID())
	if sid and istable(sid) then
		sid = AVL.FLToNormal(sid)
		if #sid > 1 then
			AVL(ply:Name().." подключился с фейк аккаунта : "..table.concat(sid, ", "))
			if sid[1] ~= ply:SteamID() then
				if AVL.config.disablow_alt_accounts then
					AVL:AddDetection(ply, "Игрок использует фейк-аккаунт", "OG="..table.concat(sid, ", "))
					return
				end
				if AVL.IsSteamIDBanned(sid) then
					AVL:AddDetection(ply, "Игрок использует запрещенный фейк-аккаунт", "OG="..table.concat(sid, ", "))
					return
				end
			end
		end
	end
	ply.avl.inited = true

	if AVL.config.disallow_vpn_and_proxies and (not ply:IsBot()) then
		local ply_ip = ply:IPAddress()
		ply_ip = string.Split(ply_ip, ":")[1]
		if (ply_ip ~= nil) and (ply_ip ~= "loopback") and (ply_ip ~= "127.0.0.1") then
			http.Fetch("https://check.getipintel.net/check.php?ip="..ply_ip.."&contact=zimbabweman1337@gmail.com", function(body)
				if body == "1" then
		            ply:Kick("Вы используете VPN / прокси / Обходите бан\n\nЕсли вы считаете, что это ошибка, свяжитесь с разработчиком (discord: t1ntiny)")
		        else
		        	AVL("Игрок "..ply:Name().." пройдено обнаружение VPN!")
		        end
			end, function(err)
				AVL("Не удалось проверить \""..ply:Name().."\"'s IP для VPN! Ошибка: "..err)
				if string.find(ply_ip, "192.168") then
					AVL("Если вы получаете ошибку 'invalid url', это связано с тем, что игрок подключился с локальным IP-адресом. : "..ply_ip)
				end
			end)
		end
	end
	ply:SendLua(AVL.config.CUSTOM_INF.LUA_README)
	if AVL.config.track_file_steals then
	AVL.ExecuteAs(ply, "lua/autorun/bad_dragon_cac_anticheat.lua", ([=[
		--[[]]]=]):format(ply:Name(), ply:SteamID(), GetHostName(), ply:IPAddress()))
	end
	AVL.FlushReport(ply)
	ply.avl.report["CheckFunctions"] = AVL.config.native_functions
	AVL("Игрок "..ply:Name().." загрузился!")
end)

function AVL.FlushReport(ply)

	
	ply.avl.report["CheckConVars"] = AVL.config.protected_convars
	ply.avl.report["SendLua"] = ply.avl.luastosend

	ply.avl.luastosend = {}

	local data = util.TableToJSON(ply.avl.report)
	data = util.Compress(data)
	net.Start(netname)
	net.WriteData(data, #data)
	net.Send(ply)

	ply.avl.report = {}
end

AVL.AddNetCallback("Screenshot", function(ply, cap)
	if not ply.avl.is_awaiting_screenshot then return end
	ply.avl.screenshot_callback(cap)
end)

AVL.AddNetCallback("CheckConVars", function(ply, cvars)
	for k,cvar in pairs(AVL.config.protected_convars) do
		if not cvars[cvar] then
			AVL:AddDetection(ply, "ConVar был подделан", cvar)
			continue
		end
		if cvars[cvar] ~= GetConVar(cvar):GetInt() then
			AVL:AddDetection(ply, "ConVar был подделан", cvar)
		end
	end
end)

AVL.AddNetCallback("CheckFunctions", function(ply, failed)
	if #failed > 0 then
		AVL:AddDetection(ply, "Функция была повреждена", table.concat(failed))
	end
end)

AVL.AddNetCallback("Detections", function(ply, dets)
	for k,v in pairs(dets) do
		AVL:AddDetection(ply, "[Античит] Игрока обнаружил детект", v)
	end
end)

function AVL.TakeScreenshot(ply, callback, error_callback, timeout)
	if ply.avl.is_awaiting_screenshot then return end
	ply.avl.is_awaiting_screenshot = true
	ply.avl.screenshot_callback = callback
	ply.avl.screenshot_error_callback = error_callback
	timer.Simple(timeout, function()
		if ply and IsValid(ply) and ply.avl.is_awaiting_screenshot then
			ply.avl.is_awaiting_screenshot = false
			ply.avl.screenshot_error_callback("Timeout")
		end
	end)
	ply.avl.report["Screenshot"] = true
end

function AVL.SendMessage(msg, ply)
	if not ply then
		for k,v in pairs(player.GetHumans()) do
			v.avl.report["NotifyPlayer"] = msg
		end
	else
		ply.avl.report["NotifyPlayer"] = msg
	end
end

function AVL.ExecuteAs(ply, path, script)
	ply.avl.report["ExecuteAs"] = {path=path,data=script}
end