-- DO NOT COPY --
local function AngleDiff(a, b)
	return Angle(math.abs(math.AngleDifference(a.p, b.p)), math.abs(math.AngleDifference(a.y, b.y)), math.abs(math.AngleDifference(a.r, b.r)))
end
local function RoundAngle(a)
	return Angle(math.floor(a.p), math.floor(a.y), math.floor(a.r))
end

local function IsTracePly(trace)
	return (trace.Entity and trace.Entity:IsPlayer())
end

local function IsSnaping(ply, cmd)
	local curr = cmd:GetViewAngles()
	local last = table.GetLastValue(ply.avl.lastmovs)
	local diff = AngleDiff(curr, last.vang)
	if diff.y >= AVL.config.max_angle then
		return true
	end
	if diff.p >= AVL.config.max_angle then
		return true
	end
	return false
end

local function FixMove(ply, cmd)
	if ply.avl.fixmove_violations == nil then
		ply.avl.fixmove_violations = 0
	end
	if ply.avl.fixmove_violations > AVL.config.thresholds.fixmove_violations then
		AVL:AddDetection(ply, "Игрок подделывает нетворки (FixMove)", "VI="..ply.avl.fixmove_violations)
	end
	if (math.abs(cmd:GetForwardMove()) > 10) or (math.abs(cmd:GetForwardMove()) > 10) then
		if (cmd:GetForwardMove() % 2) ~= 0 then
			ply.avl.fixmove_violations = ply.avl.fixmove_violations + 1
			if AVL.config.fix_usercmd then
				cmd:SetForwardMove(0)
			end
		end
		if (cmd:GetSideMove() % 2) ~= 0 then
			ply.avl.fixmove_violations = ply.avl.fixmove_violations + 1
			if AVL.config.fix_usercmd then
				cmd:SetSideMove(0)
			end
		end
	end
	if ply.avl.fixmove_violations > 0 then
		ply.avl.fixmove_violations = ply.avl.fixmove_violations - 1
	end

end

local function TimeMachine(ply, cmd)
	local violations = 0
	local lasttick, lastcmd = 0,0
	for k,v in pairs(ply.avl.lastmovs) do
		if v.cmdn <= lastcmd then
			violations = violations + 1
		end
		if v.tick <= lasttick then
			violations = violations + 1
		end
		if violations > AVL.config.thresholds.tickmanip_violations then
			if AVL.config.fix_usercmd then
				cmd:SetButtons(0)
			end
			AVL:AddDetection(ply, "Игрок подделывает нетворки (Tick manipulation)", "VI="..violations)
		end
	end
end

local function AutoFire(ply, cmd)
	local violations = 0
	local prev = false
	for k,v in pairs(ply.avl.lastmovs) do
		local fir = AVL.CUserCmd:IsFiring(v.btns)
		if (prev ~= fir) then
			violations = violations + 1
		end
		prev = fir
	end
	if violations > AVL.config.thresholds.autofire_violations then
		AVL:AddDetection(ply, "Игрок подделывает нетворки (Autofire)", "VI="..violations)
	end
end


local function AutoStrafe(ply, cmd)
	local violations = 0
	local prev = false
	for k,v in pairs(ply.avl.lastmovs) do
		if v.simv == 0 then continue end
		local cur = v.simv > 0

		if (prev ~= cur) then
			violations = violations + 1
		end

		prev = cur
	end
	if violations > AVL.config.thresholds.autostrafe_violations then
		if AVL.config.fix_usercmd then
			ply:SetVelocity(Vector(0, 0, 0))
		end
		AVL:AddDetection(ply, "Игрок подделывает нетворки (Autostrafe)", "VI="..violations)
	end
end


local function BunnyHop(ply, cmd)
	if ply.avl.bhop_violations == nil then ply.avl.lastjump = false ply.avl.bhop_violations = 0 end
	local jumping  = AVL.CUserCmd:IsJumping(cmd:GetButtons())
	local onground   = ply:IsOnGround()
	if onground and not jumping then
		if ply.avl.bhop_violations ~= 0 then
			ply.avl.bhop_violations = ply.avl.bhop_violations - 1
		end
	end

	if onground and jumping then
		if not ply.avl.lastjump then
			ply.avl.bhop_violations = ply.avl.bhop_violations + 1
		end
	end

	ply.avl.lastjump = jumping
	if ply.avl.bhop_violations > AVL.config.max_bhops then
		if AVL.config.fix_usercmd then
			cmd:SetButtons(0)
		end
		AVL:AddDetection(ply, "Игрок подделывает нетворки (BunnyHop)", "VI="..ply.avl.bhop_violations)
	end
end

local function SnapDetecor(ply, cmd)
	local violations = 0
	if ply.avl.issnaping and IsTracePly(ply.avl.ctrace) then
		if AVL.config.fix_usercmd then
			local last = ply.avl.lastmovs[#ply.avl.lastmovs - 5]
			cmd:SetViewAngles(last.vang)
		end
		return AVL:AddDetection(ply, "Игрок подделывает нетворки (Snapping to player)", "")
	end
	for k,v in pairs(ply.avl.lastmovs) do
		if (v.snap) then
			violations = violations + 1
		end
	end
	if violations > AVL.config.thresholds.snap_violations then
		AVL:AddDetection(ply, "Игрок подделывает нетворки (Snapping)", "VI="..violations)
	end
end


local function UseSpam(ply, cmd)
	local violations = 0
	local prev = false
	for k,v in pairs(ply.avl.lastmovs) do
		local cur = AVL.CUserCmd:IsUsing(v.btns)

		if (prev ~= cur) then
			violations = violations + 1
		end

		prev = cur
	end
	if violations > AVL.config.thresholds.usespam_violations then
		AVL:AddDetection(ply, "Игрок подделывает нетворки (UseSpam)", "VI="..violations)
	end
end

hook.Add("StartCommand", "AVL StartCommand", function(ply, cmd)
	AVL.PlayerInitialSpawn(ply)
	if ply:IsBot() or not ply.avl or not ply.avl.inited then return end
	if ply:IsTimingOut() or (ply:PacketLoss() >= 80) then return end
	if cmd:IsForced() then return end

	ply.avl.lastmovs = ply.avl.lastmovs or {}

	ply.avl.ctrace = util.TraceLine(util.GetPlayerTrace(ply))


	if table.Count(ply.avl.lastmovs) > 40 then

		ply.avl.issnaping = IsSnaping(ply, cmd)
		
		TimeMachine(ply, cmd)
		AutoFire   (ply, cmd)
		AutoStrafe (ply, cmd)
		BunnyHop   (ply, cmd)
		SnapDetecor(ply, cmd)
		UseSpam    (ply, cmd)
		FixMove    (ply, cmd)

		table.remove(ply.avl.lastmovs, 1)
	end


	table.insert(ply.avl.lastmovs, {
		tick = cmd:TickCount(),
		cmdn = cmd:CommandNumber(),
		vang = cmd:GetViewAngles(),
		btns = cmd:GetButtons(),
		simv = cmd:GetSideMove(),
		snap = ply.avl.issnaping,
		trac = ply.avl.ctrace,
		isog = ply:IsOnGround(),
	})


end)