local avl_load_from_init = true
if SERVER then
	AVL = {}
	local _avl = {}
	function _avl.__call(s, arg)
		-- Olala les fonctions standard
		print("[Античит] "..arg)
	end
	setmetatable(AVL, _avl)

	AVL("Загружаем античит...")
	AddCSLuaFile "avl_anticheats/client/new_client.lua"
	if avl_load_from_init then
		AddCSLuaFile "includes/init.lua"
		AVL("Античит загружен - init.lua")
	else
		AVL("Античит загружен - autorun/avl_anticheats.lua")
	end
	include "avl_anticheats/loader.lua"
	AVL("АНТИЧИТ ЗАГРУЖЕН!")
	return
end
if not CLIENT then return end


if not avl_load_from_init then
	include "avl_anticheats/client/new_client.lua"
end