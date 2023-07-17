
AVL.PunishmentType = {}

AVL.PunishmentType.None  = 0
AVL.PunishmentType.Kick  = 1
AVL.PunishmentType.Ban   = 2
AVL.PunishmentType.Warn  = 3

AVL.CUserCmd = {}

function AVL.CUserCmd:IsFiring(btn)
	return bit.band(btn, IN_ATTACK) == 1
end

function AVL.CUserCmd:IsJumping(btn)
	return bit.band(btn, IN_JUMP) == 2
end

function AVL.CUserCmd:IsUsing(btn)
	return bit.band(btn, IN_USE)
end

function AVL.PlayerInitialSpawn(ply) end

function AVL.IsSteamIDBanned(sid)
	if ULib and ULib.bans[sid] then
		return true
	end
	local flbans = file.Read("cfg/banned_user.cfg", "GAME")
	if isstring(sid) then
	 	if string.find(flbans, sid) then
			return true
		end
	end
	if istable(sid) then
		for k,v in pairs(sid) do
			if string.find(flbans, v) then
				return true
			end
		end
	end
	return false
end


AVL.Info = {
	UID = "{{ user_id }}",
	VER = "{{ script_version_id }}",
	SID = "{{ script_id }}"
}

function AVL.GetSteamIDFromUIID(uiid, default)
	uiid = tostring(uiid)
	local fluiid = file.Read("avl_uiids.json", "DATA") or "{}"
	local uiids = util.JSONToTable(fluiid)
	for k,v in pairs(uiids) do
		k = tostring(k)
		if k == uiid then return v end
 	end
	uiids[uiid] = {}
	uiids[uiid][default] = true
	file.Write("avl_uiids.json", util.TableToJSON(uiids))
	return {default}
end

-- Transforme a fast lookup table to a normal one
function AVL.FLToNormal(tbl)
	if isstring(tbl) then
		return {tbl}
	end
	local ret = {}
	for k,v in pairs(tbl) do
		table.insert(ret, k)
	end
	return ret
end

function AVL.IsAdmin(ply)
	return AVL.config.admin_groups[ply:GetUserGroup()]
end

function AVL.Xor(str, key)
	local ret = {}
	for i=1,#str do
		table.insert(ret, string.char(bit.bxor(string.byte(str[i]), string.byte(key[i % #key]))))
	end
	return table.concat(ret)
end
