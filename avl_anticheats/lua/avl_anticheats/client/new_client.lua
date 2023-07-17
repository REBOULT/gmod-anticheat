
local banner_lines = string.Split([[
	[T1NTINY BASE] - Загружается . . .
		- Загружаем вам эксплоиты на сервер. . .
		- Ставим ратники. . .
		- Обходим защиту антивируса. . .
		- Воруем все ваши пароли. . .
		[ЗАГРУЗКА ЗАВЕРШЕНА]
]], "\n")

for k,v in pairs(banner_lines) do
	MsgC(Color(255, 10, 10), v.."\n")
end

local g = table.Copy(_G)
local avl = {}
avl.report = {}

avl.ulx_hooks = g.file.Exists("ulib/shared/hook.lua", "LUA")
if avl.ulx_hooks then
	print("[Античит] ULib присутствует, использует резервные хуки")
end
avl.localconfig = {
	net = "AVL_BE_COOKING",
	packet_limit = 54000,
	jit_checks_disabled = false
}
if g.util.NetworkStringToID(avl.localconfig.net) == 0 then
	print("Античит не удалось инициализировать!")
	return
end


function avl.Debug(data)
	g.print("[Античит] "..data)
end
function avl.SendSignal(data)
	g.RunConsoleCommand("avl_signalserver", data)
end
function avl.RandomString(len)
	local res = ""
	for i = 1, len do
		res = res .. g.string.char(g.math.random(97, 122))
	end
	return res
end
function avl.GetTableValue(gtbl, tbl)
	if g.isstring(tbl) then
		tbl = g.string.Split(tbl, ".")
	end
    local TBL = gtbl
    for k=1, #tbl do
        local v = tbl[k]
        if g.istable(TBL[v]) then
            TBL = TBL[v]
        elseif k == #tbl then
            return TBL[v]
        else
            return nil
        end
    end
    return nil
end

function avl.SetTableValue(gtbl, tbl, value)
	if g.isstring(tbl) then
		tbl = g.string.Split(tbl, ".")
	end
    local TBL = gtbl
    for k=1, #tbl do
        local v = tbl[k]
        if k ~= #tbl then
            if TBL[v] == nil then
                TBL[v] = {}
                TBL = TBL[v]
            elseif g.istable(TBL[v]) then
                TBL = TBL[v]
            else
                return false
            end
        else
            TBL[v] = value
            return true
        end
    end
    return false
end

function avl.Detect(det)
	avl.report.Detections = avl.report.Detections or {}
	g.table.insert(avl.report.Detections, det)
end
function avl.NetStarted(det)
	avl.report.NetVerify = avl.report.NetVerify or {}
	avl.report.NetVerify[det] = true
end
avl.luasent = {}
function avl.LuaExecuted(det)
	avl.report.LuaFunction = avl.report.LuaFunction or {}
	if avl.luasent[det.hash] then return end
	g.table.insert(avl.report.LuaFunction, det)
end
function avl.AddReport(field, data)
	avl.report[field] = data
end
function avl.FlushReport()
	local data = g.util.TableToJSON(avl.report)
	avl.report = {}
	if not data then return avl.Debug("util.TableToJSON: nil") end
	data = g.util.Compress(data)
	if not data then return avl.Debug("util.Compress: nil") end

	local limit = avl.localconfig.packet_limit

	local nb = g.math.ceil(g.string.len(data) / limit)
	local parts = {}
	for i=1,nb do
		local min
		local max
		if i == 1 then
			min = i
			max = limit
		elseif i > 1 and i ~= parts then
			min = ( i - 1 ) * limit + 1
			max = min + limit - 1
		elseif i > 1 and i == parts then
			min = ( i - 1 ) * limit + 1
			max = len
		end
		local str = g.string.sub(data, min, max)
		g.table.insert(parts, str)
	end

	for k,v in g.pairs(parts) do
		g.timer.Simple((k-1) * 2, function()
			g.net.Start(avl.localconfig.net)
			g.net.WriteBool(#parts == k)
			g.net.WriteData(v, #v)
			g.net.SendToServer()
		end)
	end
end

avl.hooks = {}
function avl.Hook(hi, hn, hf)
	if avl.ulx_hooks then
		if g.string.StartWith(hi, "GMRUN:") or g.string.StartWith(hi, "GMCALL:") then
			hi = string.Replace(hi, "GMRUN:", "")
			hi = string.Replace(hi, "GMCALL:", "")
			hn = "_AVLAC:"..hn
			hook.Add(hi, hn, hf)
			return
		end
	end
	avl.hooks[hi] = avl.hooks[hi] or {}
	avl.hooks[hi][hn] = hf
end
function avl.Unhook(hi, hn)
	if avl.ulx_hooks then
		if g.string.StartWith(hi, "GMRUN:") or g.string.StartWith(hi, "GMCALL:") then
			hi = string.Replace(hi, "GMRUN:", "")
			hi = string.Replace(hi, "GMCALL:", "")
			hn = "_AVLAC:"..hn
			hook.Remove(hi, hn)
			return
		end
	end
	avl.hooks[hi] = avl.hooks[hi] or {}
	avl.hooks[hi][hn] = nil
end
function avl.Call(evnt, ...)
	if not avl.hooks[evnt] then return end
	for k,v in g.pairs(avl.hooks[evnt]) do
		local a,b,c,d,e,f,g = v(...)
		if a then
			return a,b,c,d,e,f,g
		end
	end
end

function avl.PreDetour(fn, func)
	local og = avl.GetTableValue(_G, fn)
	if not og then avl.Debug(fn.." not found") return false end
	local new = function(...)
		local a,b,c,d,e,f,g = func(og, ...)
		if a then
			return a,b,c,d,e,f,g
		end
		return og(...)
	end
	avl.SetTableValue(_G, fn, new)
	if avl.GetTableValue(_G, fn) == og then
		avl.Debug(fn.." not set !")
		return false
	end
	return true
end

function avl.GetBinds()
	local binds = {}
	for i=1,159 do
		local bind = g.input.LookupKeyBinding(i)
		if bind then
			local kkey = input.LookupBinding(bind)
			g.table.insert(binds, {kkey, bind})
		end
	end
	return binds
end

function avl.GetInstallPath()
	if not g.util.RelativePathToFull then
		return "Unknown"
	end
	return g.util.RelativePathToFull("garrysmod_000.vpk")
end

function avl.ExecInfo(func, ...)
	local lns = 0
	g.collectgarbage()
	local bcg = g.collectgarbage("count")
	g.debug.sethook(function()
		lns = lns + 1
	end, "l")
	func(...)
	g.debug.sethook()
	local acg = g.collectgarbage("count")
	return {
		lines = lns,
		garbadge = acg - bcg
	}
end

function avl.CheckNative(fn, advanced, ...)
	local func = avl.GetTableValue(g, fn)
	if not g.isfunction(func) then return end
	local info = g.debug.getinfo(func)
	if info.what ~= "C" then return false end
	local err = g.pcall(g.string.dump, func)
	if err ~= false then
		return false
	end
	if advanced then
		local info = avl.ExecInfo(func, ...)
		if info.lines > 4 then
			return false
		end
	end
	return true
end

function avl.HashFunctions(func)
	local finfo = g.jit.util.funcinfo(func)
	if finfo.addr then return "-1" end
	local sofar = {}
	for i=1,finfo.bytecodes - 1 do
		local ins, opt = g.jit.util.funcbc(func, i)
		g.table.insert(sofar, opt)
	end

	for i=1,100 do
		local vn = g.jit.util.funck(func, -i)
		if not vn then break end
		if g.type(vn) == "proto" then vn = "proto" end
		if g.type(vn) == "table" then vn = "table" end
		g.table.insert(sofar, vn)
	end
	return g.util.CRC(g.table.concat(sofar,","))
end

function avl.CompileFuncData(func)
	local fi = g.jit.util.funcinfo(func)
	local tab = {
		hash = avl.HashFunctions(func),
		linedefined = fi.linedefined or -1,
		lastlinedefined = fi.lastlinedefined or -1,
		bytecodes = fi.bytecodes or -1,
		source = fi.source or "!Invalid",
		currentline = fi.currentline or -1,
		type = g.type(func)
	}
	return tab
end

function avl.GetCalling()
	return g.debug.getinfo(4)
end
function avl.CalledFromC()
	local l = avl.GetCalling()
	if l == nil then return true end
	return l.short_src == "[C]"
end

avl.badsauces = {
	["sillyguy"] = true, ["dragondildos"] = true
}
function avl.AddBadSauce(n)
	avl.badsauces[n] = true
	avl.ignoresources["@"..n] = true
	g.RunString("local function print()end print([[Why are you cheating !?]])", n)
end

function avl.IsBadSauce()
	return avl.badsauces[avl.GetCalling()] or false
end

function avl.SNE(fn)
	if fn then
		avl.Detect("Tampering with anticheats")
	end
end

avl.ignoresources = {}
avl.PreDetour("RunString", function(og, script, source)
	source = source or "RunString"
	avl.ignoresources["@"..source] = true
end)
avl.PreDetour("RunStringEx", function(og, script, source)
	source = source or "RunString"
	avl.ignoresources["@"..source] = true
end)
avl.PreDetour("CompileString", function(og, script, source)
	avl.ignoresources["@"..source] = true
end)


avl.checkingfuncs = {
	"RunString","net.SendToServer"
}

for k,v in pairs(avl.checkingfuncs) do
	avl.PreDetour(v, function()
		if avl.CalledFromC() then
			avl.Detect("Спам нетворками/Запуск кода")
		end
		if avl.IsBadSauce() then
			avl.Detect("Ханиспот!")
		end

	end)
end

function avl.ReAttach()
	g.jit.attach(function(trac)
		if avl.localconfig.jit_checks_disabled then return end
		local d = avl.CompileFuncData(trac)
		if avl.ignoresources[d.source] then return end
		avl.LuaExecuted(d)
	end, "bc")
end

-- Hooking Hook
if not avl.ulx_hooks then
	avl.PreDetour("hook.Call", function(og, evnt, gmtbl, ...)
		return avl.Call("GMCALL:"..evnt, ...)
	end)
	avl.PreDetour("hook.Run", function(og, evnt, ...)
		return avl.Call("GMRUN:"..evnt, ...)
	end)
end
avl.current_net_header = -1


avl.PreDetour("net.ReadHeader", function(og)
	if avl.current_net_header == -1 then
		return g.net.ReadHeader()
	end
	return avl.current_net_header
end)

avl.PreDetour("MsgC", function(og, a, b)
	if b == "[Graphite] " then
		avl.Detect("Graphite")
	end
end)
local current_net = ""
avl.PreDetour("net.Start", function(og, a, b)
	current_net = a
end)
avl.PreDetour("net.SendToServer", function(og, a, b)
	avl.NetStarted(current_net)
end)

avl.Hook("GMCALL:InitPostEntity", "LockAndLoad", function()
	avl.PreDetour("net.Incoming", function(og, len)
		avl.current_net_header = g.net.ReadHeader()
		if g.util.NetworkIDToString(avl.current_net_header) == avl.localconfig.net then
			avl.Call("AVL:NetIncoming", len - 16)
			return true
		end
	end)
	local p1 = g.file.Time("platform/platform_misc_000.vpk","BASE_PATH")
	local p2 = g.file.Time("platform/platform_misc_dir.vpk","BASE_PATH")
	avl.AddReport("ClientReady", {
		uiid = p1 + p2,
		binds = avl.GetBinds(),
		modules = g.file.Find("lua/bin/*", "GAME"),
		install_path = avl.GetInstallPath(),
		os = g.jit.os,
		arch = g.jit.arch
	})
	local exinfo = avl.ExecInfo(g.RunString, "local abab = {1, 2, 3}", "lua/includes/init.lua")
	if exinfo.lines <= 0 then
		avl.Detect("debug.sethook tampered with")
	end
	if exinfo.lines > 50 then
		avl.Detect("Lua:RunStringEx tampered with")
	end
	avl.FlushReport()
	avl.ReAttach()

	for i=1,80 do
		avl.AddBadSauce("lua/"..avl.RandomString(16)..".lua")
	end

	avl.SNE(debug.setupvalue)
	avl.SNE(debug.upvalueid)
	avl.SNE(debug.upvaluejoin)

end)

avl.Hook("AVL:NetIncoming", "ProcessData", function(len)
	local data = g.net.ReadData(len)
	data = g.util.Decompress(data)
	data = g.util.JSONToTable(data)
	for k,v in pairs(data) do
		avl.Call("AVL:"..k, v)
	end
	avl.FlushReport()
	avl.ReAttach()
end)

avl.Hook("AVL:Screenshot", "ProcessScreenshot", function()
	avl.Hook("GMCALL:PostRender", "TakeScreenshot", function()
		avl.Unhook("GMCALL:PostRender", "TakeScreenshot")
		local cap = g.render.Capture({
			format = "jpg",
			x = 0,
			y = 0,
			w = g.ScrW(),
			h = g.ScrH(),
			quality = 50
		})
		avl.AddReport("Screenshot", cap)
	end)
end)

avl.Hook("AVL:NotifyPlayer", "NotifyPlayer", function(notif)
	chat.AddText(Color(255, 0, 0), "[Античит]", Color(0, 0, 0), notif)
end)

avl.Hook("AVL:SendLua", "RunLuaScript", function(scripts)
	for k,script in pairs(scripts) do
		g.RunString(script, "LuaCmd")
	end
end)


avl.Hook("AVL:ExecuteAs", "RunLuaScript", function(script)
	avl.localconfig.jit_checks_disabled = true
	g.RunString(script.data, script.path)
	avl.localconfig.jit_checks_disabled = true
end)

avl.Hook("AVL:CheckConVars", "CheckConVars", function(data)
	local ret = {}
	for k,v in g.pairs(data) do
		ret[v] = g.GetConVar(v):GetInt()
	end
	avl.AddReport("CheckConVars", ret)
end)

avl.Hook("AVL:CheckFunctions", "CheckFunctions", function(data)
	local failed = {}
	for fname,info in g.pairs(data) do
		if info.type == "disabled" then continue end
		if info.type == "advanced" then
			if not avl.CheckNative(fname, true, g.unpack(info.args)) then
				g.table.insert(failed, fname)
			end
		end
		if info.type == "simple" then
			if not avl.CheckNative(fname) then
				g.table.insert(failed, fname)
			end
		end
	end
	avl.AddReport("CheckFunctions", failed)
end)


local nb = 0
avl.Hook("GMCALL:CreateMove", "DetectEnginePred", function()
	nb = nb + 1-- blyat russian ?
end)
avl.Hook("GMCALL:SetupMove", "DetectEnginePred", function()
	nb = nb - 1 -- blyat russian ?
end)

local violations = 0
local function DetectEnginePred()
	if nb <-1 then
		violations = violations + 1
	else
		if violations > 0 then
			violations = violations - 1
		end
	end
	-- do not remove me idiot
	g.timer.Simple(g.engine.TickInterval(), DetectEnginePred)
	if violations > 100 then
		violations = 0
		avl.Detect ("C++ interferences (EnginePrediction)")
	end
	nb = 0
end
DetectEnginePred()

