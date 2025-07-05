export type data = {
    Wins : number,
    Coins : number,
    Slaps : number,

    FirstLogin : number,
    Playtime : number,

    HasPremium : boolean,
    Followed : boolean,
    InGroup : boolean,

    Gamepasses : {[string] : boolean},
    PurchaseIdCache : {any},

    SlapsOwned : {[string] : boolean},
}
return {
    Wins = 0;
    Coins = 100;
    Slaps = 0;

    FirstLogin = 0;
    Playtime = 0;

    HasPremium = false;
    Followed = false;
    InGroup = false;

    Gamepasses = {},
    PurchaseIdCache = {},

    SlapsOwned = {},
} :: data