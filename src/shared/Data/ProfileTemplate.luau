export type data = {
    Wins : number,
    FirstLogin : number,
    Playtime : number,
    InGroup : boolean,
    Gamepasses : {[string] : boolean},
    PurchaseIdCache : {any},
}
return {
    Wins = 0;
    FirstLogin = 0;
    Playtime = 0;
    InGroup = false;

    Gamepasses = {},
    PurchaseIdCache = {},
} :: data