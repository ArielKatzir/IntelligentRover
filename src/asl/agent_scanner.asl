// Agent agent000 in project ia_submission


/*
 * move across the map, then go down and repeat that movement for top half of the map, scan between movements
 * 		resource found: add the location of the resource to a list of locations for either diamond
 * 		or gold. send full gold location to gold rover and diamond to diamond 
 * 		list to the gold collector rover
 */	

/* Initial beliefs and rules */



/*
 * 
 * move - hit a wall - find the closest gap - move to the closest gap and one unit extra in that direction - attempt to move to the desired location
 * - if a wall is hit, dont go back on the previous direction you came from.  
 * 
 */
 
  
scanned_gold_locations([]).
scanned_diamond_locations([]).
recieved_resource_locations_d([0]).
recieved_resource_locations_g([0]).
first_move(false).
direction("down").


/* Initial goals */

!move_around.




/* Plans */

+!move_around : true <- 
	
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);	
	rover.ia.get_map_size(Width,Height);
	scan(Scanrange);
	
	?first_move(B);
	if(not(B)){
		// initial move will be down and left
		-+first_move(true);
		.print("making an initial move of right-up");
		move(Scanrange*2-2,-Scanrange*2-2);
		rover.ia.log_movement(Scanrange*2-2,-Scanrange*2-2);
		scan(Scanrange);
		
	}
		
	// moving in random direction
	?direction(PD);
	.random(D);
	
	
	if(PD == "right" | PD == "left"){
		if(D < 0.5){
			.print("moving: down");
			-+direction("down");
		}else{
			.print("moving: up");
			-+direction("up");
		}
	}elif(PD == "up" | PD == "down"){
		if(D < 0.5){
			.print("moving: left");
			-+direction("left");
		}else{
			.print("moving: right");
			-+direction("right");
		}
	}
	
	
	
	
	?direction(DD);
	if(DD == "right"){
		move(Scanrange*2-5,0);
		rover.ia.log_movement(Scanrange*2-5, 0);
		
	}elif(DD == "left"){
		move(-Scanrange*2+5,0);
		rover.ia.log_movement(-Scanrange*2+5, 0);
	}elif(DD == "down"){
		move(0,Scanrange*2-5);
		rover.ia.log_movement(0,Scanrange*2-5);
	}else{
		move(0,-Scanrange*2+5);
		rover.ia.log_movement(0,-Scanrange*2+5);
	}
	
	
	
	// checking if should move the other direction if faster
	rover.ia.get_distance_from_base(Xbase,Ybase);
	if (Xbase > Width/2){Log_x = Xbase-Width;}
	else{
		if (Xbase < -Width/2){Log_x = Xbase+Width;}
		else{Log_x = Xbase;}
	}
	
	if (Ybase > Height/2) {Log_y = Ybase-Height;}
	else{
		if (Ybase < -Height/2){Log_y = Ybase+Height;}
		else{Log_y = Ybase;}
	}
	
	// change direction if needed
	rover.ia.clear_movement_log;
	rover.ia.log_movement(-Log_x, -Log_y);
	
	scan(Scanrange);
	!move_around;
	.


-! move_around : true <-
	rover.ia.check_status(X);
	!move_around;

	
	.
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
	
	
@resource_found[atomic]
+ resource_found (ResourceType, Quantity, XDist, YDist) : true <-
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	rover.ia.get_map_size(Width,Height);
	rover.ia.get_distance_from_base(Xbase,Ybase);
	
	if (not(ResourceType == "Obstacle")){
		.print("found ",ResourceType," at: " , XDist-Xbase, " " , YDist-Ybase);
		if(ResourceType == "Gold"){T = "G"}
		elif(ResourceType == "Diamond"){T = "D"}
		.send(agent_collector1, tell,resource_locations([T, Quantity, XDist-Xbase, YDist-Ybase]));
		
	}
		.

+obstructed(X_travelled,Y_travelled,X_left, Y_left) <-
	
	.print("obstructed");
	.
	
// move around if no resource found
+ resource_not_found : true <-
		!move_around;
	.

-obstructed : true <-
	
	!move_around;
	
	.
	
+ insufficient_energy : true <-
		
	.print("no energy");
	
	
	.
	


	
	
	