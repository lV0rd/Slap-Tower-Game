return {
    --[[
    OnSpawn ONLY WHEN ITS SUPPOSED TO RUN AFTER CHARACTER SPAWN
    OnJoin ONLY WHEN ITS SUPPOSED TO RUN ON JOIN

    You cannot have both OnJoin and OnSpawn set to true for the same gamepass.
    If you want to run something on join and spawn, use OnSpawn ONLY!
    ]]

    ["Admin"] = {
        ID = 1039509747;
        OnJoin = true;
        OnSpawn = false;
        Callback = function(Player, PlayerData)
            print("YAY")
        end
    },
}