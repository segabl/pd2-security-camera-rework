local _upd_enemy_detection_original = CopLogicArrest._upd_enemy_detection
function CopLogicArrest._upd_enemy_detection(data, ...)
	if not data.forced_police_call_attention then
		return _upd_enemy_detection_original(data, ...)
	end

	if not managers.groupai:state():can_police_be_called() or managers.groupai:state():is_police_called() then
		return
	end

	local my_data = data.internal_data
	if not my_data.calling_the_police and not data.unit:movement():chk_action_forbidden("action") then
		CopLogicArrest._call_the_police(data, my_data, true)
	end
end
