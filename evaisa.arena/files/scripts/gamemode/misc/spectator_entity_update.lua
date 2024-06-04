local entity = GetUpdatedEntityID()

local inventory = EntityGetFirstComponentIncludingDisabled(entity, "Inventory2Component")

hide_entity = function(entity)
    EntitySetComponentsWithTagEnabled(entity, "enabled_in_world", false)
    EntitySetComponentsWithTagEnabled(entity, "enabled_in_hand", false)
    EntitySetComponentsWithTagEnabled(entity, "enabled_in_inventory", true)
    
    local physics_throwable_comp = EntityGetFirstComponentIncludingDisabled(entity, "PhysicsThrowableComponent")
    if physics_throwable_comp ~= nil then
        EntityRemoveComponent(entity, physics_throwable_comp)
    end

    --[[
    local material_inventory_comp = EntityGetFirstComponentIncludingDisabled(entity, "MaterialInventoryComponent")
    if material_inventory_comp ~= nil then
        ComponentSetValue2(material_inventory_comp, "last_frame_drank", -100)
    end
    ]]

    -- children
    local children = EntityGetAllChildren(entity)
    if children ~= nil then
        for _, child in ipairs(children) do
            hide_entity(child)
        end
    end
end

last_held_entity = last_held_entity or nil

if inventory ~= nil then
    local held_item = ComponentGetValue2(inventory, "mActiveItem")

    if held_item ~= nil and held_item ~= 0 and held_item ~= last_held_entity and EntityGetIsAlive(held_item) then
        -- surely this is sane.
        hide_entity(held_item)
        last_held_entity = held_item
    end
end