if not AVL.config.block_backdoors then return end
local _netReadString = net.ReadString
local _stringlen = string.len
local _CompileString = CompileString
local _isfunction = isfunction
local _debugTrace = debug.Trace
local _stringStartWith = string.StartWith
local _stringfind = string.find
function net.ReadString()
	local str = _netReadString()
	if _stringlen(str) <= 6 then
		return str
	end
	if _stringStartWith(str, "--") or _stringStartWith(str, "//") then
		if not _stringfind(str, "\n") then
			return str -- If it's LUA code, it's only a comment, so no worries
		end
	end
	local func = _CompileString(str, "AVL-AntiBackdoor", false)
	if _isfunction(func) then
		-- Is actual lua code
		AVL("Остановлен код LUA из сети, см. трассировку стека :")
		_debugTrace()
		return [==[--[[ [AX] LUA code has been transmited tought net, if this is an error, disable the anti backdoor in the config file !]] ]==]
	end
	return str
end