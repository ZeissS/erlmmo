-module(zone_object_storage).

-include_lib("include/erlmmo.hrl").

-export([load/1]).

load(normal_sun) ->
    #zone_object_prototype{
        name = <<"Sun">>,
        description = <<"A sun of normal size. It's flames are glaring in a hot red">>,
        size = 100,
        image = "normal_sun.png"
    };
    
load(small_planet_m) ->
    #zone_object_prototype{
        name = <<"Planet (M)">>,
        description = <<"A small planet of class M, able to habitate human life.">>,
        size = 40,
        image = "small_planet_m.png"
    };
    
load(player_ship) ->
    #zone_object_prototype{
        name = <<"Player Ship (Mark I)">>,
        description = <<"A small vessel designed to touch outer space.">>,
        size=1,
        image="small_ship.png"
    }.