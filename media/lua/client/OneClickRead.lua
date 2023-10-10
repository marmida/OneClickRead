require "TimedActions/ISBaseTimedAction"

-- action definition - is it a timed action? Or do we just invoke other actions?
-- ideally we want the progress bars from the sub-actions, e.g. eating, smoking, and reading

OneClickRead = ISBaseTimedAction:derive("MyTimedAction");

--[[

function AutoSmokePuffAction:perform()
    local buttItemType = self.item:getReplaceOnUseFullType()

    ISEatFoodAction.perform(self)

    if AutoSmoke.Options.characterSpeaks then
        AutoSmoke.Speak.reset()
    end

    if buttItemType then
        local butts = self.character:getInventory():getAllType(buttItemType)
        local butt = butts:get(butts:size() - 1)
        if butt then
            butt:setFavorite(false)
            if AutoSmoke.Options.throwAwayButts then
                self.character:getInventory():DoRemoveItem(butt)
                local x, y = ZombRandFloat(0.1, 0.9), ZombRandFloat(0.1, 0.9)
                local z = self.character:getZ() - math.floor(self.character:getZ())
                self.character:getCurrentSquare():AddWorldInventoryItem(butt, x, y, z)
                triggerEvent("OnContainerUpdate")
            elseif AutoSmoke.Options.removeButts then
                self.character:getInventory():DoRemoveItem(butt)
            elseif AutoSmoke.activeMod.modId == "Smoker" and AutoSmoke.Options.buttsToAshtray then
                local ashtrays = self.character:getInventory():getAllType("SM.Ashtray")
                local ashtray
                for i = 0, ashtrays:size() - 1 do
                    local test = ashtrays:get(i):getItemContainer()
                    if test:hasRoomFor(self.character, butt) then
                        ashtray = test
                        break
                    end
                end
                if not ashtray then
                    local containers = getPlayerLoot(self.character:getPlayerNum()).inventoryPane.inventoryPage.backpacks
                    for _, v in ipairs(containers) do
                        local test = v.inventory
                        if test and test:getType() == "Ashtray" then
                            if test:hasRoomFor(self.character, butt) then
                                ashtray = test
                                break
                            end
                        end
                    end
                end

                if ashtray then
                    ashtray:AddItem(butt)
                    --ISTimedActionQueue.add(ISInventoryTransferAction:new(self.character, butt, self.character:getInventory(), ashtray))
                end
            end
        end
    end
end

function AutoSmokePuffAction:new(character, item, percentage)
    local o = ISEatFoodAction:new(character, item, percentage)
    setmetatable(o, self)
    self.__index = self
    return o
end


-- example 2




function MyTimedAction:isValid() -- Check if the action can be done
    return true;
end

function MyTimedAction:update() -- Trigger every game update when the action is perform
    print("Action is update");
end

function MyTimedAction:waitToStart() -- Wait until return false
    return false;
end

function MyTimedAction:start() -- Trigger when the action start
    print("Action start");
end

function MyTimedAction:stop() -- Trigger if the action is cancel
    print("Action stop");
    ISBaseTimedAction.stop(self);
end

function MyTimedAction:perform() -- Trigger when the action is complete
    print("Action perform");
    ISBaseTimedAction.perform(self);
end

function MyTimedAction:new(character) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.maxTime = 30; -- Time take by the action
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end

]]

-- associate context menu

local function OneClickReadAddContextMenuEntry(player, context, items)
    print("OneClickRead: context menu fn")
    --[[
    local items = ISInventoryPane.getActualItems(items)
    for _, item in ipairs(items) do
        if item:getFullType() == 'YourModule.YourItemType' then
            -- todo: translation: getText('IGUI_YourEntryTranslationString')
            context:addOption("OneClickRead", getSpecificPlayer(player), YourCallbackFunctionWhenClickedTheMenuEntry)
        end
    end
    ]]
end

Events.OnFillInventoryObjectContextMenu.add(OneClickReadAddContextMenuEntry)
