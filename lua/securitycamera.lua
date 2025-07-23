function SecurityCamera:_get_operator()
	if not self._operator_triggers then
		return
	end

	for trigger in pairs(self._operator_triggers) do
		for _, id in pairs(trigger._values.elements or {}) do
			local element = managers.mission:get_element_by_id(id)
			for _, unit in pairs(element and element._units or {}) do
				if alive(unit) then
					return unit
				end
			end
		end
	end
end

local _sound_the_alarm_original = SecurityCamera._sound_the_alarm
function SecurityCamera:_sound_the_alarm(detected_unit, ...)
	if self._alerted_op or self._alarm_sound then
		return
	end

	local operator = self:_get_operator()
	if not operator then
		return _sound_the_alarm_original(self, detected_unit, ...)
	end

	self._alerted_op = true

	local susp_data = managers.groupai:state()._suspicion_hud_data
	local obs_susp_data = susp_data and susp_data[self._unit:key()]
	if obs_susp_data then
		if obs_susp_data.icon_id then
			managers.hud:remove_waypoint(obs_susp_data.icon_id)
		end
		if obs_susp_data.icon_id2 then
			managers.hud:remove_waypoint(obs_susp_data.icon_id2)
		end
		susp_data[self._unit:key()] = nil
		managers.network:session():send_to_peers_synched("suspicion_hud", self._unit, 0)
	end

	self:set_detection_enabled(false, nil, nil)

	if not operator:movement():cool() then
		return
	end

	local brain = operator:brain()
	local logic_data = brain._logic_data

	brain:set_objective(nil)
	logic_data.forced_police_call_attention = brain._current_logic.identify_attention_obj_instant(logic_data, detected_unit:key())
	operator:movement():set_cool(false, managers.groupai:state().analyse_giveaway(operator:base()._tweak_table, detected_unit))
	if brain._logics.arrest then
		brain:set_logic("arrest")
		CopLogicArrest._mark_call_in_event(logic_data, logic_data.internal_data, logic_data.forced_police_call_attention)
		CopLogicArrest._call_the_police(logic_data, logic_data.internal_data)
	elseif brain._logics.flee then
		brain:set_logic("flee")
		CivilianLogicFlee.clbk_chk_call_the_police(nil, logic_data)
	end

	self:_send_net_event(self._NET_EVENTS.alarm_start)
	self._alarm_sound = self._unit:sound_source():post_event("camera_alarm_signal")

	local id = "cam_stop_sound" .. tostring(self._unit:key())
	managers.enemy:add_delayed_clbk(id, callback(self, self, "_stop_all_sounds"), TimerManager:game():time() + 1.5)
end
