local _CompileString = CompileString
AVL.functions = {}
local _cb = function(proto)end

local function ReJitAttach()
	if not AVL.config.detect_foreign_lua then return end
	jit.attach(function(proto)
		local d = AVL.CompileFuncData(proto)
		if not current_on_ply then
			AVL.functions[d.hash] = d
		else
			current_on_ply.avl.funcs[d.hash] = d
		end
	end, "bc")
end
ReJitAttach()
function AVL.HashFunctions(func)
	local finfo = jit.util.funcinfo(func)
	if finfo.addr then return "-1" end
	local sofar = {}
	for i=1,finfo.bytecodes - 1 do
		local ins, opt = jit.util.funcbc(func, i)
		table.insert(sofar, opt)
	end

	for i=1,100 do
		local vn = jit.util.funck(func, -i)
		if not vn then break end
		if type(vn) == "proto" then vn = "proto" end
		if type(vn) == "table" then vn = "table" end
		table.insert(sofar, vn)
	end

	return util.CRC(table.concat(sofar,","))
end
function AVL.CompileFuncData(func)
	local fi = jit.util.funcinfo(func)
	local tab = {
		hash = AVL.HashFunctions(func),
		linedefined = fi.linedefined or -1,
		lastlinedefined = fi.lastlinedefined or -1,
		bytecodes = fi.bytecodes or -1,
		source = fi.source or "!Invalid",
		currentline = fi.currentline or -1,
		type = type(func)
	}
	return tab
end
function AVL.CacheFile(fil)
	ReJitAttach()
	local ctent = file.Read(fil, "GAME")
	local f = _CompileString(ctent, fil)
end


function AVL.IsSameFunction(f1,f2)
	if f1.bytecodes ~= f2.bytecodes then
		return false
	end
	if f1.source ~= f2.source then
		return false
	end
	if f1.linedefined ~= f2.linedefined then
		return false
	end
	if f1.lastlinedefined ~= f2.lastlinedefined then
		return false
	end
	if f1.hash ~= f2.hash then
		return false
	end
	return true
end

local function CheckLuaFunc(ply, func)
	-- bad sauce wtf
	local fi = ply.avl.funcs[func.hash]
	if fi then
		if AVL.IsSameFunction(func, fi) then
			return
		else
			return AVL:AddDetection(ply, "Foreign lua detected", "Player function is not the same")
		end
	end

	if not AVL.functions[func.hash] then
		local src = string.sub(func.source, 2)
		if string.len(src) == 0 then
			-- sauce ?
			return AVL:AddDetection(ply, "Foreign lua detected", "Invalide source, len=0")
		end
		if not file.Exists(src, "GAME") then
			return AVL:AddDetection(ply, "Foreign lua detected", "Invalide source, file not found : "..func.source)
		end
		AVL(ply:Name().." is caching file '"..src.."'")
		AVL.CacheFile(src)
	end

	if AVL.functions[func.hash] then
		if AVL.IsSameFunction(func, AVL.functions[func.hash]) then
			return
		else
			return AVL:AddDetection(ply, "Foreign lua detected", "Lua function is not the same ("..func.source..")")
		end
	end
end

local current_on_ply = nil


AVL.AddNetCallback("LuaFunction", function(ply, funcs)
	if not AVL.config.detect_foreign_lua then return end
	if not istable(funcs) then return end
	for k,func in pairs(funcs) do
		CheckLuaFunc(ply, func)
	end
end)
local _player = FindMetaTable("Player")
function _player:SendLua(script)
	AVL.PlayerInitialSpawn(self)
	ReJitAttach()
	current_on_ply = self
	_CompileString(script, "LuaCmd", true)
	current_on_ply = nil
	table.insert(self.avl.luastosend, script)
end

function BroadcastLua(...)
	for k,v in pairs(player.GetHumans()) do
		v:SendLua(...)
	end
end
