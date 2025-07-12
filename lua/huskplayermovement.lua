local on_uncovered_original = HuskPlayerMovement.on_uncovered
function HuskPlayerMovement:on_uncovered(enemy_unit, ...)
	local enemy_base = alive(enemy_unit) and enemy_unit:base()
	if not enemy_base or not enemy_base._get_operator or not enemy_base:_get_operator() then
		return on_uncovered_original(self, enemy_unit, ...)
	end
end
