if not AVL then
	print("[T1NTINY ANTICHEAT] АНТИЧИТ НЕ ЗАГРУЖЕН!!!")
	return
end

AVL.config = {}
AVL.players = {}


function AVL:LoadFile(file)
	AVL("Loading file '"..file.."'")
	include("avl_anticheats/"..file..".lua")
end


--timer.Simple(0.1, function()
	-- C'est foux comment ULX casse les couilles
	AVL:LoadFile("libs")
	AVL:LoadFile("configs/config")

	AVL:LoadFile("checks")

	AVL:LoadFile("internal")
	AVL:LoadFile("detections")
	AVL:LoadFile("commands")

	AVL:LoadFile("modules/cusercmd")
	AVL:LoadFile("modules/antibackdoor")
	AVL:LoadFile("modules/update")


	AVL:LoadFile("modules/network")


	AVL:LoadFile("modules/luacompile")
	AVL:LoadFile("modules/netverify")
--end)