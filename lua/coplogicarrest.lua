local _upd_enemy_detection_original = CopLogicArrest._upd_enemy_detection
function CopLogicArrest._upd_enemy_detection(data, ...)
	if not data.forced_police_call_attention then
		return _upd_enemy_detection_original(data, ...)
	end

	local my_data = data.internal_data
	if managers.groupai:state():can_police_be_called() and not managers.groupai:state():is_police_called() and not my_data.calling_the_police then
		CopLogicArrest._call_the_police(data, my_data, true)
	end
end
