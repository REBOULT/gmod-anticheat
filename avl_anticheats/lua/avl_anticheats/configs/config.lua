
-- Maximum amount of time a player can take to join the server
AVL.config.max_join_time = 600

-- Maximum amount of time a player can take to send back a ping
AVL.config.max_ping_time = 190

-- Maximum angle per tick before being snapping
AVL.config.max_angle = 60

-- Maximum number of perfect bhops
AVL.config.max_bhops = 50

-- How many time a player can change steam name (0 = none)
AVL.config.max_steamname_changes = 15

-- Alert everyone when a cheater is detected
AVL.config.alert_everyone_on_det = true

-- Disable family sharing
AVL.config.disable_family_sharing = false
-- Only if owner is banned
AVL.config.df_only_onwer_banned = true -- Will only kick family shared accounts if the owner is banned

-- Disablow alt accounts
AVL.config.disablow_alt_accounts = false
-- Only if main is banned
AVL.config.da_only_main_banned = true

-- Try to block net backdoors
AVL.config.block_backdoors = true

-- Warn convars (Warn you if a bad ConVar has the bad value (ex: sv_cheats 1))
AVL.config.warn_convars = true

-- Message to kick cheater
AVL.config.kick_message = "Тебя кикнул античит\nЕсли это ошибка, напиши разработчику!"

-- Cheater alert message
AVL.config.alert_message = "%name% Использует посторонние LUA файлы."

-- Ban cheater with : ULX, SAM, FADMIN, MAESTRO, D3A, ServerGuard, gBan, source
AVL.config.ban_type = "ULX"

-- How much time to ban cheaters (0 = perma)
AVL.config.ban_time = 0

-- Try to fix CUserCmds modified by a cheat
AVL.config.fix_usercmd = true

-- Names of admin groups
AVL.config.admin_groups = {
	["superadmin"] = true,
	["root"] = true,
	["curator"] = true,
}

-- Can admin bypass detections
AVL.config.admins_bypass = false

-- Take a screenshot when a player is kicked
AVL.config.take_screenshot = true

-- WARNING: Will lag on startup if you have a lot of addons !
-- Detect foreign luas executed on a client
AVL.config.detect_foreign_lua = false

-- Log to console when a player is caching a file
AVL.config.fl_log_caching = false

-- Disallow VPNs and Proxies (some VPN may bypass this)
AVL.config.disallow_vpn_and_proxies = false

-- Help tracking file steals by putting infos in the file "lua/autorun/bad_dragon_cac_anticheat.lua"
AVL.config.track_file_steals = true

-- Disable net verifier
AVL.config.disable_net_verifier = true

-- Test mode : Disable all detections
AVL.config.test_mode = (function()
	if GetHostName() == "!" then
		return true -- My server
	end
	return false
end)()

-- Log detections
AVL.config.log_detection_to = "avl_detections_logs.txt"

-- Punishments :
--[[
	AVL.PunishmentType.
						Kick = Kick the cheater with kick_message (always with source)
						Ban  = Ban the cheater with kick_message (using ban_type)
						None = Does nothing, used to disable the module
						Warn = Print to server's console and alert if 'alert_everyone_on_det' is enabled !
]]
AVL.config.punishments = {
	["Клиент не присоединился вовремя"] = AVL.PunishmentType.Kick,
	["Клиент не отправил ping вовремя"] = AVL.PunishmentType.Kick,
	
	["Игрок подделывает нетворки (Tick manipulation)"] = AVL.PunishmentType.Kick,
	["Игрок подделывает нетворки (Autofire)"] = AVL.PunishmentType.Kick,
	["Игрок подделывает нетворки (Autostrafe)"] = AVL.PunishmentType.Kick,
	["Игрок подделывает нетворки (BunnyHop)"] = AVL.PunishmentType.Kick,
	["Игрок подделывает нетворки (Snapping)"] = AVL.PunishmentType.Kick,
	["Игрок подделывает нетворки (Snapping to player)"] = AVL.PunishmentType.Kick,
	["Игрок подделывает нетворки (UseSpam)"] = AVL.PunishmentType.Kick,
	["Игрок подделывает нетворки (FixMove)"] = AVL.PunishmentType.Kick,

	["Игрока обнаружил античит"] = AVL.PunishmentType.Ban,
	["Обнаружены строки кода не похожего на GLUA!"] = AVL.PunishmentType.Kick,
	["Нетворки не могут быть проверены"] = AVL.PunishmentType.Kick,

	["ConVar был подделан"] = AVL.PunishmentType.Ban,

	["Игрок изменил свой ник в стиме"] = AVL.PunishmentType.Kick,
	["Игрок изменил свой ник в стиме слишком много раз"] = AVL.PunishmentType.Kick,

	["Игрок использует Family Sharing"] = AVL.PunishmentType.Kick,
	["Игрок использует Family Sharing для обхода бана"] = AVL.PunishmentType.Kick,

	["Игрок использует фейк аккаунт"] = AVL.PunishmentType.Kick,
	["Игрок использует фейк аккаунт для обхода бана"] = AVL.PunishmentType.Kick,

}

-- Disable client-side detections
AVL.config.enabled = {
	["Graphite"] = true,
	["Tampering with anticheats"] = true,
	["debug.sethook tampered with"] = true,
	["Lua:RunStringEx tampered with"] = true,
	["A function has been tampered with"] = true,
	["C++ interferences (EnginePrediction)"] = true,
	["C++ interferences (FunctionCall)"] = true,
	["Call from bad source"] = true
}

-- Client-side function that should be native
-- type='advanced' (The function will be called with args)
-- type='simple'   (Less reliable, function will not be called)
-- type='disabled' (Function will not be tested at all)
AVL.config.native_functions = {

	["net.Start"] = {type="simple"},
	["net.SendToServer"] = {type="simple"},
}


AVL.config.protected_convars = {
	"sv_allowcslua",
	"sv_cheats"
}

AVL.config.thresholds = {
	fixmove_violations = 10,
	tickmanip_violations = 10,
	autofire_violations = 20,
	autostrafe_violations = 20,
	snap_violations = 20,
	usespam_violations = 20,
}


AVL.config.CUSTOM_INF = {
	["LUA_README"]  = [=[--[[:flushed: owwww don't look at meeee]]]=]
}