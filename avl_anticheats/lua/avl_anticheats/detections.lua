hook.Add("AVLPlayerDetectedOnce", "LogToFile", function(ply, det, data)
	if string.len(AVL.config.log_detection_to) ~= 0 then
		local ttime = util.DateStamp()
		local str = string.format("[%s] %s (%s) был обнаружен : %s (%s)\r\n", ttime, ply:Name(), ply:SteamID(), det, data)
		file.Append(AVL.config.log_detection_to, str)
	end
end)

function AVL:AddDetection(ply, det_string, data)
	if AVL.config.test_mode then print(det_string, data) return end
	if AVL.config.admins_bypass then
		if AVL.IsAdmin(ply) then
			return
		end
	end
	hook.Run("AVLPlayerDetected", ply, det_string, data)
	local pun = AVL.config.punishments[det_string]
	if pun == nil then pun = AVL.PunishmentType.Kick end

	if pun == AVL.PunishmentType.None then
		return
	end
	ply.avl.detected = ply.avl.detected or {}
	if ply.avl.detected[det_string] then return end
	ply.avl.detected[det_string] = true

	hook.Run("AVLPlayerDetectedOnce", ply, det_string, data)
	AVL(ply:Name().." возможно использует читы ("..det_string..")("..data..")")
	if AVL.config.alert_everyone_on_det then
		local msg = AVL.config.alert_message
		msg = string.Replace(msg, "%name%", ply:Name())
		AVL.SendMessage(msg)
	end
	if pun == AVL.PunishmentType.Warn then
		if AVL.config.take_screenshot then
			AVL.TakeScreenshot(ply, function(screenshot)
				if (not ply) or (not IsValid(ply)) then return end

				file.Write("avl_screenshots/"..ply:SteamID64()..".jpg", screenshot)
				
				AVL(ply:Name().." - скриншот сохранён")
				AVL("Снимок экрана можно найти в data/avl_screenshots/"..ply:SteamID64()..".jpg")
			end,function(err)
				if (not ply) or (not IsValid(ply)) then return end
				AVL("Ошибка при создании снимка экрана "..ply:Name()..": "..err)
			end, 300)
		end
		return
	end
	
	if pun == AVL.PunishmentType.Kick then
		if (det_string == "Клиент не отправил пинг вовремя.") or (det_string == "Клиент не присоединился вовремя") then
			return ply:Kick("Превышено время ожидания | Попробуй перезайти.")
		end
		if AVL.config.take_screenshot then
			AVL.TakeScreenshot(ply, function(screenshot)
				if (not ply) or (not IsValid(ply)) then return end

				file.Write("avl_screenshots/"..ply:SteamID64()..".jpg", screenshot)

				AVL(ply:Name().."'s screenshot received ! Kicking. . .")
				AVL("Снимок экрана можно найти в data/avl_screenshots/"..ply:SteamID64()..".jpg")

				ply:Kick(AVL.config.kick_message)
			end,function(err)
				if (not ply) or (not IsValid(ply)) then return end

				AVL("Ошибка при создании снимка экрана "..ply:Name()..": "..err)
				ply:Kick(AVL.config.kick_message)
			end, 60)
			return
		end
		ply:Kick(AVL.config.kick_message)
		return
	end
	if pun == AVL.PunishmentType.Ban then
		AVL:Ban(ply, ply:SteamID64(), AVL.config.kick_message)
		return
	end

end

function AVL:Ban(ply, sid64, reason)
	AVL("Баним "..ply:Name())
	if AVL.config.ban_type == "source" then
		ply:Ban(AVL.config.ban_time, false)
		ply:Kick(reason)
	end
	if AVL.config.ban_type == "ULX" then
		ULib.ban(ply, AVL.config.ban_time, reason)
	end
	if AVL.config.ban_type == "SAM" then
		RunConsoleCommand("sam", "banid", ply:SteamID(), AVL.config.ban_time, reason)
	end
	if AVL.config.ban_type == "FADMIN" then
		RunConsoleCommand("_FAdmin", "ban", ply:SteamID(), "execute", AVL.config.ban_time, reason)
	end
	if AVL.config.ban_type == "gBan" then
		gBan:PlayerBan(nil, ply, AVL.config.ban_time, reason)
	end
	if AVL.config.ban_type == "MAESTRO" then
		maestro.ban(ply:SteamID(), AVL.config.ban_time, reason)
	end
	if AVL.config.ban_type == "ServerGuard" then
		serverguard:BanPlayer(nil, ply:SteamID(), AVL.config.ban_time, reason, nil, nil, "AVL Anti-Cheats")
	end
	if AVL.config.ban_type == "D3A" then
		if AVL.config.ban_time == 0 then
			RunConsoleCommand("d3a", "perma", ply, reason)
		else
			RunConsoleCommand("d3a", "ban", ply, AVL.config.ban_time, "minutes", reason)
		end
	end

end