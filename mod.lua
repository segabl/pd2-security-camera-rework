if not SecurityCameraRework then

	SecurityCameraRework = {}
	SecurityCameraRework.mod_path = ModPath
	SecurityCameraRework.required = {}

end

if RequiredScript and not SecurityCameraRework.required[RequiredScript] then

	local fname = SecurityCameraRework.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

	SecurityCameraRework.required[RequiredScript] = true

end
