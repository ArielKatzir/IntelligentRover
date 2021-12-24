// Agent agent_1_maze in project ia_submission

/* Initial beliefs and rules */

// list of junctions and their explorations status
junctions([]).
nearby_scans([]).
possible_routes([]).
currect_direction(_).

/* Initial goals */

!move_around.

/* Plans */

+!move_around : true <- 
	.print("hello maze.")
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	-+nearby_scans([]);
	-+possible_routes([]);
	Possible_paths = [[0,1], [0,-1], [1,0], [-1,0]];
	scan(Scanrange);
	?nearby_scans(Scans);
	?currect_direction(Direction);
	.difference(,Possible_paths,X);
	.


@resource_found[atomic]
+ resource_found (ResourceType, Quantity, XDist, YDist) : true <-
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	rover.ia.get_map_size(Width,Height);
		
	?nearby_scans(List);
	.concat(List, [[ResourceType, XDist, YDist]], List_prime);
	-+nearby_scans(List_prime);
	
	.