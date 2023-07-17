-- DO NOT COPY --
function AVL.PlayerInitialSpawn(ply)
	if ply.has_been_initialzed then return end
	if ply:IsBot() then
		return
	end

	ply.avl = {}
	ply.avl.dets = {}

	ply.avl.inited   = false
	ply.avl.jointime = CurTime()
	ply.avl.lastping = CurTime() + AVL.config.max_join_time
	ply.avl.report = {}
	ply.avl.funcs = {}
	ply.avl.luastosend = {}

	ply.has_been_initialzed = true

	if ply:OwnerSteamID64() ~= ply:SteamID64() then
		-- Family shared
		if AVL.config.disable_family_sharing then
			AVL:AddDetection(ply, "Игрок использует Family Sharing", "OSID="..ply:OwnerSteamID64())
			return
		end
		local sid = util.SteamIDFrom64(ply:OwnerSteamID64())
		if AVL.IsSteamIDBanned(sid) then
			AVL:AddDetection(ply, "Игрок использует забаненную Family Sharing", "OSID="..ply:OwnerSteamID64())
		end
	end

	AVL.players[ply] = ply
end
hook.Add("PlayerInitialSpawn", "AVL PlayerInitialSpawn", function(ply)
	AVL.PlayerInitialSpawn(ply)
end)

hook.Add("PlayerDisconnected", "AVL PlayerDisconnected", function(ply)
	AVL.players[ply] = nil
end)


gameevent.Listen("player_changename")

hook.Add("player_changename", "AVL player_changename", function(data)
	local ply = Player(data.userid)
	if AVL.config.max_steamname_changes == 0 then
		AVL:AddDetection(ply, "Игрок поменял свой ник в стиме", "ON="..data.oldname.." ;NN="..data.newname)
		return
	end
	if not isnumber(ply.avl.changedname) then
		ply.avl.changedname = 1
	else
		ply.avl.changedname = ply.avl.changedname + 1
	end
	if ply.avl.changedname >= AVL.config.max_steamname_changes then
		AVL:AddDetection(ply, "Игрок поменял свой ник в стиме слишком много раз!", "CS="..ply.avl.changedname)
	end
end)

timer.Create("AVL TimerCheckPings", 5, 0, function()
	for k,ply in pairs(player.GetHumans()) do
		if not ply.avl.inited then
			if (CurTime() - ply.avl.jointime) > AVL.config.max_join_time then
				AVL:AddDetection(ply, "Клиент не присоединился вовремя", "JT="..(CurTime() - ply.avl.jointime))
			end
			return
		end
		if (CurTime() - ply.avl.lastping) > AVL.config.max_ping_time then
			AVL:AddDetection(ply, "Клиент не отправил ping вовремя", "PT="..(CurTime() - ply.avl.jointime))
		else
			if #ply.received_parts == 0 then
				if (CurTime() - ply.avl.lastping) > 30 then
					AVL.FlushReport(ply)
				end
			end
		end
	end
end)