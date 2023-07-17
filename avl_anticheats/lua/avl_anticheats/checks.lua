if (AVL.config.ban_type == "ULX") and not ULib then
	AVL.config.ban_type = "source"
	AVL("ULib не найден! Заменен движок на сурс")
end
if (AVL.config.ban_type == "FADMIN") and not FAdmin then
	AVL.config.ban_type = "source"
	AVL("FADMIN не найден! Заменен движок на сурс")
end

if string.len(AVL.config.kick_message) > 255 then
	AVL("Причина кика слишком длинная, сделайте покороче.")
	AVL.config.kick_message = "Вырубай читы другалёк"
end
if string.len(AVL.config.alert_message) > 255 then
	AVL("Сообщение оповещения слишком длинное, сделайте покороче.")
	AVL.config.alert_message = "%name% - Использует читы!"
end

local function clmap_val(field, min, max)
	if min and (AVL.config[field] < min) then
		AVL.config.max_join_time = min
		AVL("'"..field.."' был ниже "..min..". Изменён '"..field.."' на "..min.."")
	end
	if max and (AVL.config[field] > max) then
		AVL.config.max_join_time = max
		AVL("'"..field.."' был выше "..max..". Изменён '"..field.."' на "..max.."")
	end
end

clmap_val("max_join_time", 90, 600)
clmap_val("max_ping_time", 60, 300)
clmap_val("max_angle", 45, 180)
clmap_val("max_bhops", 50)
clmap_val("ban_time", 0)
clmap_val("max_steamname_changes", 15)


if not file.IsDir("avl_screenshots", "data") then
	file.CreateDir("avl_screenshots")
end

if not string.EndsWith(AVL.config.log_detection_to, ".txt") then
	AVL("ПРЕДУПРЕЖДЕНИЕ: 'log_detection_to' не является файлом, доступным для записи! изменено на '"..AVL.config.log_detection_to..".txt'")
	AVL.config.log_detection_to = AVL.config.log_detection_to .. ".txt"
end

if AVL.config.warn_convars then
	timer.Create("AVL warn about the convars", 60 * 5, 0, function()
		if GetConVar("sv_cheats"):GetInt() == 1 then
			AVL("ВНИМАНИЕ: 'sv_cheats' переменная установлена на 1")
		end
		if GetConVar("sv_allowcslua"):GetInt() == 1 then
			AVL("ВНИМАНИЕ: 'sv_allowcslua' переменная установлена на 1")
		end
	end)
end

if AVL.config.test_mode then
	AVL("ВНИМАНИЕ: Включен тестовый режим, все наказания отключены!")
end

if CurTime() > 30 then
	AVL("Ты пытаешься открыть меня через lua_openscript????!! xd")
end