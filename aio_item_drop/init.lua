--[[
    What does it do:
        After digging the node you chose to override it will drop it on the ground
        instead of going to the inventory automaticly.

    Known limitations: (There can be more but I am maybe not aware of those yet)
    - Only works with nodes that have been registered to the game that have a string value in node.drop 
      e.g. drop = "default:dirt"
    
    Todo:
    - 
]]

-- Construct a starting table
local aio = {
    nodes_to_override = {  -- Write here the nodes you want to override
        "default:stone",
        "default:cobble",
        "default:dirt",
        "default:dirt_with_grass",
    },
    drop_list = {}, -- Initialize a empty droplist
}

-- This function construct the drop_list 
-- def = core.registered_nodes[nodename] 

function aio.construct_drop_list(def)
   -- Initialize the drop list to create tables with the nodename as key
   aio.drop_list[def.name] = {}

   -- Checks if the drop argument is a string, 
   -- if it is then it inserts it into droplist table as an item
   if type(def.drop) == "string" then
        table.insert(aio.drop_list[def.name], ItemStack(def.drop))
   end
end

function aio.precompute()

    --iterates over the list of nodes to override
    for _, nodename in ipairs(aio.nodes_to_override) do
        
        -- Get the node information
        local def = core.registered_nodes[nodename]
        
        --If there is any info
        if def then

            -- If there is not any drop specified or an empty string it will drop the node itself
            if def.drop == nil or def.drop == "" then
                
                -- Create a temporary node definition table 
                local tempdef = {
                    name = def.name,
                    drop = def.name
                }

                -- Create the drop_list table with the temporary info
                aio.construct_drop_list(tempdef)
            else
                -- Create the drop_list with the original info
                aio.construct_drop_list(def)
            end

            -- Store the orinal to use afterwards so it wont break other mods
            local original_after_dig = def.after_dig_node

            -- Create the definition with the field that needs to be changed
            local new_def = {
                drop = "",
                after_dig_node = function(pos, oldnode, oldmetadata, digger)
                    local drop_pos = vector.add(pos, {x=0, y=0.5, z=0})
                    for _, item_stacks in ipairs(aio.drop_list[oldnode.name]) do
                        local item = core.add_item(drop_pos, item_stacks)
                        if item then
                            local velocity = {
                                x = math.random(-1, 1),
                                y = math.random(0.5, 1),
                                z = math.random(-1, 1),
                            }
                            item:set_velocity(velocity)
                        end
                        -- if there is a original after_dig stored before
                        if original_after_dig then
                            -- Call the original function
                            original_after_dig(pos, oldnode, oldmetadata, digger)
                        end
                    end
                end,
                }
                -- overrides the item with the new information of the specified fields
                core.override_item(def.name, new_def)
        end
    end
end

-- It wil start creating the table and changing the nodes and field
aio.precompute()

