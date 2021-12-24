// Agent agent000 in project ia_submission


/*
 * move up. move right unless moved across the map, in that case move up. Then scan 
 * 		if found:	
 * 					- go to it and collect as much as possible
 * 					- go back to base, deposit what the rover has and return to the gold
 * 					- repeat until there is no gold left
 * 					- once deposited all the gold, return to where the rover first scanned the gold (not where the gold was)
 * 		if not found:
 * 					- keep moving
 */	

/* Initial beliefs and rules */

times_moved(0,0).
shift_to_gold(0,0).
moved_up_first(0).



/* Initial goals */

!move_around.

/* Plans */

+!move_around : true <- 
	
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	rover.ia.get_map_size(Width,Height);
	Times_to_move_x = math.round(Width/(Scanrange*2-1));
	Times_to_move_y = math.round(Height/(Scanrange*2-1));
	
	?times_moved(H,V);
	
	?moved_up_first(Bool_moved)
	if(Bool_moved == 0){
		move(0, -Scanrange*2+1);
		rover.ia.log_movement(0, -Scanrange*2+1);
		- + times_moved(0,V+1);
		- + moved_up_first(1);
		
	}
	if(H < Times_to_move_x){
		move(Scanrange*2-1, 0);
		rover.ia.log_movement(Scanrange*2-1,0);
		- + times_moved(H+1,V);
	}else{
		move(0, -Scanrange*2-1);
		rover.ia.log_movement(0,-Scanrange*2-1);
		- + times_moved(0,V+1);
	}
	
	scan(Scanrange);
	.
	
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
+ insufficient_energy(move) <-
	.print("No energy here");
	.

@resource_found[atomic]
+ resource_found (ResourceType, Quantity, XDist, YDist) : true <-
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	rover.ia.get_map_size(Width,Height);
	
	// move to gold and record the movement
	move(XDist, YDist);
	- + shift_to_gold(XDist, YDist);
	
	// know how much is it possible to collect
	if (Quantity < Capacity) {Amount_to_collect = Quantity;}
	else {Amount_to_collect = Capacity;}
	
	// collect gold
	if (Quantity == 1){
		collect("Gold");
	}
	
	else{
		for(.range(U ,1 , Amount_to_collect)){
			collect("Gold");
		}
	}
	
	// move back to original position (before shifted to gold)
	move(-XDist, -YDist);
	
	// get distance from base
	rover.ia.get_distance_from_base(Xbase,Ybase);
	
	
	// checking if should move the other direction if faster
	if (Xbase > Width/2){Log_x = Xbase-Width}
	else{
		if (Xbase < -Width/2){Log_x = Xbase+Width}
		else{Log_x = Xbase}
	}
	
	if (Ybase > Height/2) {Log_y = Ybase-Height}
	else{
		if (Ybase < -Height/2){Log_y = Ybase+Height}
		else{Log_y = Ybase}
	}
	
	
	// change direction if needed
	rover.ia.clear_movement_log;
	rover.ia.log_movement(-Log_x, -Log_y);
	
	
	// move back to base
	move(Log_x, Log_y);
	
	// deposit gold
	if (Quantity == 1){
		deposit("Gold");
	}
	
	else{
		for(.range(U ,1 , Amount_to_collect)){
			deposit("Gold");
		}
	}
	
	// move back to location next to gold
	move(-Log_x, -Log_y);
	
	- + shift_to_gold(_,_);
	
	scan(Scanrange);
	.

	
// move around if no resource found
+ resource_not_found : true <-
		!move_around
	.
	
	
	
	
	