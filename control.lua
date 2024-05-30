-- Looks like the destruction alert is only generated after on_entity_died handlers run. So I can't register a handler for on_entity_died and use that to delete the alert.
-- So instead we take a different approach: disable the vanilla alert types for every player that joins, then generate custom alerts to replace them.
-- This has a problem: if you start a single-player game without this mod, then later add this mod and load the game, we won't see the "player joining" event. So, every time an alert is generated, we check if we've disabled alerts for that player.

------------------------------------------------------------------------

local playerIndexesAlreadyDisabledAlerts = {}
local alertTypesToDisable = {
	defines.alert_type.entity_destroyed,
	defines.alert_type.entity_under_attack,
	defines.alert_type.turret_fire, -- NOTE not replacing this one with a custom alert.
	-- Not disabling these alert types:
	--defines.alert_type.not_enough_construction_robots,
	--defines.alert_type.no_material_for_construction,
	--defines.alert_type.not_enough_repair_packs,
	--defines.alert_type.no_storage,
	--defines.alert_type.train_out_of_fuel,
	--defines.alert_type.custom
}
local function disableAlerts(player)
	for i, alertType in ipairs(alertTypesToDisable) do
		player.disable_alert(alertType)
	end
	playerIndexesAlreadyDisabledAlerts[player.index] = true
end
script.on_event(defines.events.on_player_joined_game, function(event)
	disableAlerts(game.get_player(event.player_index))
end)

------------------------------------------------------------------------

local function getChunkPos(pos)
	return {pos.x / 32, pos.y / 32}
end

local function isEntityVisible(ent, force)
	return force.is_chunk_visible(ent.surface, getChunkPos(ent.position))
end

------------------------------------------------------------------------

local function customEntityAlert(event, icon, tooltip)
	local ent = event.entity
	if not (ent and ent.valid) then return end
	if not isEntityVisible(ent, ent.force) then return end
	if ent.type == "combat-robot" then return end
	if ent.name == "crash-site-spaceship" then return end
	if ent.force == event.force then return end
	for _, player in pairs(ent.force.players) do
		if player.valid then
			if not playerIndexesAlreadyDisabledAlerts[player.index] then
				disableAlerts(player)
			end
			player.add_custom_alert(ent, icon, tooltip, true)
		end
	end
end

script.on_event(defines.events.on_entity_died, (function(event)
	customEntityAlert(event,
				{type = "virtual", name = "NCAOVR-destroyed-icon"},
				{"gui-alert-tooltip.destroyed", event.entity.localised_name} -- This is Factorio's built-in tooltip for destroyed entities.
		)
end))
script.on_event(defines.events.on_entity_damaged, (function(event)
	customEntityAlert(event,
				{type = "virtual", name = "NCAOVR-danger-icon"},
				{"gui-alert-tooltip.attack", event.entity.localised_name} -- This is Factorio's built-in tooltip for damaged entities.
		)
end))
