concommand.Add("avl", function(ply, cmd, args)
	if not AVL.IsAdmin(ply) then
		--return
	end
	if #args <= 1 then
		return ply:ChatPrint("[Античит] Неверная команда")
	end
	if args[1] == "getinfo" then
		if not args[2] then
			return ply:ChatPrint("[Античит] Пожалуйста, укажите ID игрока (цифра возле ника игрока по команде 'status')")
		end
		local pn = Player(tonumber(args[2]))
		if not pn then
			return ply:ChatPrint("[Античит] Игрок не найден")
		end
		local alts = AVL.GetSteamIDFromUIID(uiid, pn:SteamID())
		alts = AVL.FLToNormal(alts)
		ply:ChatPrint("[Античит] Информация об игроке "..ply:Name().."("..ply:SteamID()..")")
		ply:ChatPrint("IP Адрес: "..pn:IPAddress())
		ply:ChatPrint("Путь установки игры: "..pn.avl.jdata.install_path)
		ply:ChatPrint("Уникальный ID установки: "..pn.avl.jdata.uiid)
		ply:ChatPrint("Список модулей: "..table.concat(pn.avl.jdata.modules, ", "))
		ply:ChatPrint("Список АЛЬТОВ: "..table.concat(alts, ", "))
		ply:ChatPrint("Список биндов: ")
		local cur = ""
		for k,v in pairs(pn.avl.jdata.binds) do
			cur = cur .. ", ["..v[1].."]" .. v[2]
			if k % 8 == 0 then
				ply:ChatPrint(cur)
				cur = ""
			end
		end
	end
end)