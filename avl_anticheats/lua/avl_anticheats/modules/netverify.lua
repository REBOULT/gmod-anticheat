if AVL.config.disable_net_verifier then return end

local _netIncoming = net.Incoming
local _netReadHeader = net.ReadHeader

local current_net = -1
function net.ReadHeader()
	if current_net == -1 then
		return _netReadHeader()
	end
	return current_net -- I don't know if you have to do that, but just to be sure. . .
end
function net.Incoming(len, ply)
	current_net = _netReadHeader()
	if not ply.avl then
		AVL.PlayerInitialSpawn(ply)
		return _netIncoming(len, ply)
	end
	local str = util.NetworkIDToString(current_net)
	if str ~= "AVL_BE_COOKING" then
		ply.avl.used_nets = ply.avl.used_nets or {}
		ply.avl.used_nets[str] = true
	end
	return _netIncoming(len, ply)
end
AVL.AddNetCallback("NetVerify", function(ply, nets)
	for k,v in pairs(ply.avl.used_nets) do
		if not nets[k] then
			AVL:AddDetection(ply, "Непроверяемые нетворки", k)
		end
	end
	ply.avl.used_nets = {}
end)