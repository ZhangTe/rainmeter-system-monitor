-- A simple setting script for user to store their configurations
--   permanently in a file.
-- file is in a simple ini style 
--
--     key1 = value1
--     key2 = value2
--         ...
--
-- Author : ztbxxt
--
-- modified by https://docs.rainmeter.net/snippets/read-ini/
-- Regular Expression in Lua script: https://www.lua.org/manual/5.4/manual.html#6.4.1
-- SKIN & SELF object Lua with RM: https://docs.rainmeter.net/manual/lua-scripting/

setting_value = {};
setting_path = "settings.cfg";
log_path = "update.log"
function Initialize()
	setting_path = (SKIN:GetVariable('CURRENTPATH')..setting_path);
	log_path = (SKIN:GetVariable('CURRENTPATH')..log_path);
	ReadIni();
	for key, val in pairs(setting_value) do
		SKIN:Bang("!SetVariable \"" .. key .. "\" \"" .. val .. "\"")
	end
	logging(os.date("\n%Y-%m-%d%H:%M:%S",time_) .. ">> Rainmeter Max Counter Start...")
end

function logging(str)
	local logfile = io.open(log_path, "a")
	logfile:write(str)
	logfile:close(logfile)
end

function updatevalue(argName, Value)
	setting_value[argName] = Value
	print(Value)
	local write_str = ""
	for key, val in pairs(setting_value) do
		write_str =  (key .. "=" .. val) .. "\n" .. write_str
	end
	local X = io.open(setting_path, "w")
	X:write(write_str)
	X:close(X)
	
	SKIN:Bang("!SetVariable \"" .. argName .. "\" \"" .. Value .. "\"")
	SKIN:Bang("!Redraw")
	
	logging(os.date("\n%Y-%m-%d %H:%M:%S",time_) .. ">>   " .. argName .. " = " ..Value)
	
end

function updateIfBigger(argName, Value)
	if (setting_value[argName]==nil) then
		updatevalue(argName, Value)
	else
		val_old = tonumber(setting_value[argName])
		val_new = tonumber(Value)
		if (val_old==nil) then
			updatevalue(argName, Value)
		else
			if ( val_old < val_new  ) then
				updatevalue(argName, Value)
			end
		end
	end
end

function toggle(argName)
	if (setting_value[argName]==nil) then
		updatevalue(argName, 0)
	else
		val_old = tonumber(setting_value[argName])
		if (val_old==nil) then
			updatevalue(argName, 0)
		else
			if ( val_old == 0  ) then
				updatevalue(argName, 1)
				else updatevalue(argName, 0)
			end
		end
	end
end


function ReadIni()
	local file = assert(io.open(setting_path, 'r'), 'Unable to open ' .. setting_path)
	for line in file:lines() do
		if not line:match('^%s-;') then
			local key, command = line:match('^([^=]+)=(.+)')
			if key and command then
				setting_value[key:match('^%s*(%S*)%s*$')] = command:match('^%s*(.-)%s*$')
			end
		end
	end
	file:close()
end