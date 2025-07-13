local on_new_objective_original = CivilianLogicFlee.on_new_objective
function CivilianLogicFlee.on_new_objective(data, ...)
	if not data.forced_police_call_attention or managers.groupai:state():enemy_weapons_hot() then
		return on_new_objective_original(data, ...)
	end
end
