%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Supervisor for the web application.

-module(web_sup).
-author('author <author@example.com>').

-behaviour(supervisor).

%% External exports
-export([start_link/0, upgrade/0]).

%% supervisor callbacks
-export([init/1]).

%% @spec start_link() -> ServerRet
%% @doc API for starting the supervisor.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @spec upgrade() -> ok
%% @doc Add processes if necessary.
upgrade() ->
    {ok, {_, Specs}} = init([]),

    Old = sets:from_list(
	    [Name || {Name, _, _, _} <- supervisor:which_children(?MODULE)]),
    New = sets:from_list([Name || {Name, _, _, _, _, _} <- Specs]),
    Kill = sets:subtract(Old, New),

    sets:fold(fun (Id, ok) ->
		      supervisor:terminate_child(?MODULE, Id),
		      supervisor:delete_child(?MODULE, Id),
		      ok
	      end, ok, Kill),

    [supervisor:start_child(?MODULE, Spec) || Spec <- Specs],
    ok.

%% @spec init([]) -> SupervisorTree
%% @doc supervisor callback.
init([]) ->
    Ip = case os:getenv("WEBMACHINE_IP") of false -> "0.0.0.0"; Any -> Any end,
    {ok, Dispatch} = file:consult(filename:join(
                         [filename:dirname(code:which(?MODULE)),
                          "..", "priv", "dispatch.conf"])),
    WebConfig = [
		 {ip, Ip},
		 {port, 8000},
                 {log_dir, "priv/log"},
		 {dispatch, Dispatch}],
    Web = {webmachine_mochiweb,
	   {webmachine_mochiweb, start, [WebConfig]},
	   permanent, 5000, worker, dynamic},
           
    %StorageService = {storage, {storage_backend, start_link, []}, permanent, 5000, worker, dynamic},
           
    SkillMaster = {skill_master, {skill_master, start_link, []}, permanent, 5000, worker, dynamic},
           
    SessionMaster = {session_master, {session_master, start_link, []}, permanent, 5000, worker, dynamic},
    
    ZoneSup = {zone_sup, {zone_sup, start_link, []}, permanent, 5000, supervisor, dynamic},
           
    Processes = [SkillMaster, Web, SessionMaster, ZoneSup],
    {ok, {{one_for_one, 10, 10}, Processes}}.
