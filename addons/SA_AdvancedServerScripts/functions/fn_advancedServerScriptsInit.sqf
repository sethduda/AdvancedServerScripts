
if (!isServer) exitWith {};

SA_Advanced_Server_Scripts_Install = {

if(!isNil "SA_SERVER_SCRIPTS_INIT") exitWith {};
SA_SERVER_SCRIPTS_INIT = true;

diag_log "Advanced Server Scripts Loading...";

// Wait for player to be initialized
if (!isDedicated) then {waitUntil {!isNull player && isPlayer player};};

SA_Mine_Respawn_Install = {
	if(isDedicated) exitWith {};
	player addEventHandler [ 'Respawn',
		 {
			{
				player addOwnedMine _x;
			} forEach getAllOwnedMines (_this select 1);
		 }
	];
};

SA_Ear_Plug_Install = {
	if(isDedicated) exitWith {};
	// Adapted from http://www.armaholic.com/page.php?id=26624
	SA_Ear_Plug_Action = ["Put On Ear Plugs",{
		private ["_user","_actionId"];
		_user = _this select 1;
		_actionId = _this select 2;
		if (soundVolume > 0.25) then {
			1 fadeSound 0.25;
			_user setUserActionText [_actionId,"Take Off Ear Plugs"]
		} else {
			1 fadeSound 1;
			_user setUserActionText [_actionId,"Put On Ear Plugs"]
		}
	},[],-90,false,true];
	player addAction SA_Ear_Plug_Action;
	player addEventHandler ["Respawn",{
		1 fadeSound 1;
		(_this select 0) addAction SA_Ear_Plug_Action;
	}];
};

SA_Squad_Join_Install = {
	if(isDedicated) exitWith {};
	
	SA_Get_Near_Entities = {
		params ["_position",["_radius",50],["_function",{true}]];
		private ["_filteredEntities","_allObjects"];
		_allObjects = nearestObjects [_position, [], _radius];
		_filteredEntities = [];
		{
			if(alive _x) then {
				if([] call _function) then {
					_filteredEntities pushBack _x;
				};
			};
		}	
		forEach _allObjects;
		_filteredEntities;
	};
	
	[] spawn {
		while {true} do {
			_allAiUnits = [getPos player, 30, {alive _x}] call SA_Get_Near_Entities;
			{
				if( side player == side _x && alive _x && group _x != group player && leader player == player && _x isKindOf "Man" && vehicle _x == _x && (leader _x != _x || count (units group _x) == 1) ) then {
					if(isNil {_x getVariable "sa_join_squad_action_id"}) then {
						_actionId = _x addAction ["Join My Squad", { 
							if(isNil {(_this select 0) getVariable "sa_original_group"}) then {
								(_this select 0) setVariable ["sa_original_group",group (_this select 0)];
							};
							[_this select 0] join player; 
							(_this select 0) removeAction (_this select 2);
							(_this select 0) setVariable ["sa_join_squad_action_id",nil];
						}, nil, 0, false];
						_x setVariable ["sa_join_squad_action_id",_actionId];
					};
				} else {
					if(!isNil {_x getVariable "sa_join_squad_action_id"}) then {
						_x removeAction (_x getVariable "sa_join_squad_action_id");
						_x setVariable ["sa_join_squad_action_id",nil];
					};
				};
				
				if( side player == side _x && alive _x && group _x == group player && leader player == player && _x isKindOf "Man" && vehicle _x == _x && _x != player ) then {
					if(isNil {_x getVariable "sa_leave_squad_action_id"}) then {
						_actionId = _x addAction ["Leave My Squad", { 
							if(!isNil {(_this select 0) getVariable "sa_original_group"}) then {
								[_this select 0] join ((_this select 0) getVariable "sa_original_group"); 
								(_this select 0) setVariable ["sa_original_group",nil];
							} else {
								[_this select 0] join grpNull; 
							};
							(_this select 0) removeAction (_this select 2);
							(_this select 0) setVariable ["sa_leave_squad_action_id",nil];
						}, nil, 0, false];
						_x setVariable ["sa_leave_squad_action_id",_actionId];
					};
				} else {
					if(!isNil {_x getVariable "sa_leave_squad_action_id"}) then {
						_x removeAction (_x getVariable "sa_leave_squad_action_id");
						_x setVariable ["sa_leave_squad_action_id",nil];
					};
				};
				
			} forEach _allAiUnits;
			sleep 5;
		};
	};
};

[] call SA_Mine_Respawn_Install;
//[] call SA_Ear_Plug_Install;
//[] call SA_Squad_Join_Install;

diag_log "Advanced Server Scripts Loaded";

};

publicVariable "SA_Advanced_Server_Scripts_Install";

[] call SA_Advanced_Server_Scripts_Install;
// Install Advanced Urban Rappelling on all clients (plus JIP) //
remoteExecCall ["SA_Advanced_Server_Scripts_Install", -2,true];

