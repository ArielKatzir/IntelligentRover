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
obstacles([]).
times_moved(0,0).
bool_is_duplicate(0).
counter(_).
move_around_obstacle([]).
travel_direction(_).
initial_move(false).
found_nearest_gap(false).
gap([]).
sent_info(true).
stuck_in_place(false).





/* Initial goals */

!move_around.



/* Plans */

+!move_around : true <- 
	
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	rover.ia.get_map_size(Width,Height);
	Times_to_move_x = math.round(Width/(Scanrange*2-2));
	Times_to_move_y = math.round((Height)/(Scanrange*2-2))-1;
	
	rover.ia.check_status(X);
	// likely to be enegry related issue
	if (X < 100){
		.print("no energy to scan");
		!send_info;
	}
	
	
	?times_moved(H,V);
	?travel_direction(Previous_direction);
	?initial_move(M);
	if(not(M)){
		-+counter(0);
		.print("initial vertical move for agent 2");
		-+initial_move(true);
		move(0, -Scanrange*2-2);
		rover.ia.log_movement(0,-Scanrange*2-2);
		scan(Scanrange);
	}
	
	if(H < Times_to_move_x){
		move(Scanrange*2-4, 0);
		-+ times_moved(H+1,V);
		rover.ia.log_movement(Scanrange*2-4,0);
	}else{
		if (V < Times_to_move_y){
			-+times_moved(0,V+1);
			move(0, -Scanrange*2-2);
			rover.ia.log_movement(0,-Scanrange*2-2);
		}else{
			// At this point the rover scanned its share of the map
			// and is sending the information to the gold collector
			.print("scanned the map");
			
			!send_info;
		}
	}
	
	// checking if should move the other direction if faster
	rover.ia.get_distance_from_base(Xbase,Ybase);
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
	
	scan(Scanrange);
	
	!move_around;
	.


-! move_around : true <-
	.print(" ");
	.
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
+ insufficient_energy(move) <-
	.print("No energy");
	!send_info;
	.
	
+! move_around_obstacle : true <-
	?move_around_obstacle(X_to_gap,Y_to_gap,New_desired_x,New_desired_y);
	?travel_direction(D);
	?stuck_in_place(S);
	.drop_all_desires;
	.drop_all_events;
	.drop_all_intentions;
	rover.ia.check_status(X);
	// likely to be enegry related issue
	if (X < 100){
		!send_info;
	}
	
	
	// if rover has been stuck in a wall and hasnt moved, move it back and left by 5 units
	if(S){
		?switch(Sw);
		-+switch(-1*Sw);
		if(D == "up"){
			.print("moving down and left");
			move(0,5*Sw);
			rover.ia.log_movement(0,5*Sw);
			move(-5*Sw,0);
			rover.ia.log_movement(-5*Sw,0);
		}
		if(D == "right"){
			.print("moving left and up");
			move(-5*Sw,0);
			rover.ia.log_movement(-5*Sw,0);
			move(0,-5*Sw);
			rover.ia.log_movement(0,-5*Sw);
		}
	}else{
		-+stuck_in_place(true);
		if(D == "up"){
			// move to gap
			move(X_to_gap,0);
			-+stuck_in_place(false);
			rover.ia.log_movement(X_to_gap,0);
			move(0,New_desired_y);
			rover.ia.log_movement(0,New_desired_y);
			
			// attempt to move back to the same y position it was before
			move(-X_to_gap,0);
			rover.ia.log_movement(-X_to_gap,0);
		}elif(D == "right"){
			// move to gap 
			move(0,Y_to_gap);
			-+stuck_in_place(false);
			rover.ia.log_movement(0,Y_to_gap);
			move(New_desired_x,0);
			rover.ia.log_movement(New_desired_x,0);
			
			// attempt to move back to the same y position it was before
			move(0,-Y_to_gap);
			rover.ia.log_movement(0,-Y_to_gap);
		}
	}
	-+found_nearest_gap(false);
	!move_around
	.
	

	
-! move_around_obstacle : true <-
	rover.ia.check_status(X);
	// likely to be enegry related issue
	if (X < 100){
		!send_info;
	}
	.

-obstructed : true <-
	rover.ia.check_status(X);
	// likely to be enegry related issue
	if (X < 100){
		.print("no energy to scan");
		!send_info;
	}
	.

+obstructed(X_travelled,Y_travelled,X_left, Y_left) <-
	// deleting all the previously scanned walls
	-+obstacles([]);
	rover.ia.get_map_size(Width,Height);
	rover.ia.check_status(E);
	
	// log missing movement
	rover.ia.log_movement(X_travelled,Y_travelled);
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	//scanning to find nearby walls
	if (E > 40){
		scan(Scanrange);
	}else{
		!send_info;
	}
	
	
	?obstacles(Scanned_Obstacles);
		
	// setting the desired location 
	if(X_left > Width/2){
		Desired_location_x = X_left-Width;
	}
	else{
		if(X_left < -Width/2){
			Desired_location_x = X_left+Width;
		}
		else{Desired_location_x = X_left;
		}
	}
	if(Y_left > Height/2){Desired_location_y = Y_left-Height;
	}
	else{
		if(Y_left < -Height/2){Desired_location_y = Y_left+Height;
		}
		else{Desired_location_y = Y_left;
		}
	}
	?counter(C);
	
	// if the desired location is a wall, add 1 for x and y
	if (.member([Desired_location_x,Desired_location_y], Scanned_Obstacles)){
		while(counter(C) & .member([Desired_location_x+C,Desired_location_y+C], Scanned_Obstacles)) { 
	       -+counter(C+1);
     	}
	}
	?counter(Dist);
	New_desired_x = Desired_location_x + Dist;
	New_desired_y = Desired_location_y + Dist;
		
	-+counter(0);
	
	// if rover attempted to move horizontal
	if (Y_travelled-New_desired_y == 0){
		// finding the nearest gap in wall
		for (.range(I,1,Scanrange)){
			?found_nearest_gap(Bool);
			if(Bool==false){
				if(not(.member([1,I],Scanned_Obstacles))){
					-+gap([1,I]);
					-+found_nearest_gap(true);
				}
				if(not(.member([1,-I],Scanned_Obstacles))){
					-+gap([1,-I]);
					-+found_nearest_gap(true);
				}
			}
		}
		
		-+travel_direction("right")
		?gap(Gap);
		.nth(0,Gap,X_to_gap);
		.nth(1,Gap,Y_to_gap);
		
		-+move_around_obstacle(X_to_gap,Y_to_gap,New_desired_x,New_desired_y);
		!move_around_obstacle;
		
		
		
	// if rover attempted to move vertically	
	}else{
		// finding the nearest gap in wall
		for (.range(I,1,Scanrange)){
			?found_nearest_gap(Bool);
			if(Bool==false){
				if(not(.member([I,1],Scanned_Obstacles))){
					-+gap([I,1]);
					-+found_nearest_gap(true);
				}
				if(not(.member([-I,1],Scanned_Obstacles))){
					-+gap([-I,1]);
					-+found_nearest_gap(true);
				}
			}
		}
		-+travel_direction("up");
		?gap(Gap);
		.nth(0,Gap,X_to_gap);
		.nth(1,Gap,Y_to_gap);
		
		-+move_around_obstacle(X_to_gap,Y_to_gap,New_desired_x,New_desired_y);
		!move_around_obstacle;
		
		
	}
	.

 @resource_found[atomic]
+ resource_found (ResourceType, Quantity, XDist, YDist) : true <-
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	rover.ia.get_map_size(Width,Height);
	rover.ia.get_distance_from_base(Xbase,Ybase);
	?scanned_gold_locations(List_g);
	?scanned_diamond_locations(List_d);
	
	if (not(ResourceType == "Obstacle")){
		.print("found ",ResourceType," at: " , XDist-Xbase, " " , YDist-Ybase);
	}
	
	// Adds the new gold location to the list of locations
	if (ResourceType == "Gold"){
		if (.empty(List_g)){
			-+scanned_gold_locations([[ResourceType,Quantity, XDist-Xbase, YDist-Ybase]]);
		}else{
			// checking if already scanned before 
			for ( .member(I,List_g) ) {
				.nth(1,I,Quantity_prime);
				.nth(2,I,X_prime);
				.nth(3,I,Y_prime)
				
				// if object is at -width/2 and width/2 (same location) it wont realise its a duplicate
				if	(Quantity_prime==Quantity & 
					(X_prime==XDist-Xbase | (X_prime==-(XDist-Xbase)) & X_prime == Width/2 ) &
					(Y_prime==YDist-Ybase | (Y_prime==-(YDist-Ybase)) & Y_prime == Height/2)
					){
					-+bool_is_duplicate(1);
				}
				
				elif (X_prime==XDist-Xbase + Width & Y_prime==YDist-Ybase |
					X_prime==XDist-Xbase - Width & Y_prime==YDist-Ybase |
					Y_prime==YDist-Ybase + Height & X_prime==XDist-Xbase |
					Y_prime==YDist-Ybase - Height & X_prime==XDist-Xbase 
				){
					-+bool_is_duplicate(1);
				}
				
     		}
			 
			?bool_is_duplicate(Bool);
     		if(Bool==0){
     			.concat(List_g, [[ResourceType, Quantity,  XDist-Xbase, YDist-Ybase]], List_prime_g);
				-+scanned_gold_locations(List_prime_g);
     		}
		}
	}
	// Adds the new diamond location to the list of locations
	elif (ResourceType == "Diamond"){
		if (.empty(List_d)){
			-+scanned_diamond_locations([[ResourceType,Quantity, XDist-Xbase, YDist-Ybase]]);
		}else{
			// checking if already scanned before 
			for ( .member(I,List_d)) {
				.nth(1,I,Quantity_prime);
				.nth(2,I,X_prime);
				.nth(3,I,Y_prime);
				
				
				// if object is at -width/2 and width/2 (same location) it wont realise its a duplicate
				if	(Quantity_prime==Quantity & 
					(X_prime==XDist-Xbase | (X_prime==-(XDist-Xbase)) & X_prime == Width/2 ) &
					(Y_prime==YDist-Ybase | (Y_prime==-(YDist-Ybase)) & Y_prime == Height/2)
					){
					-+bool_is_duplicate(1);
				}
				
				elif (X_prime==XDist-Xbase + Width & Y_prime==YDist-Ybase |
					X_prime==XDist-Xbase - Width & Y_prime==YDist-Ybase |
					Y_prime==YDist-Ybase + Height & X_prime==XDist-Xbase |
					Y_prime==YDist-Ybase - Height & X_prime==XDist-Xbase 
				){
					-+bool_is_duplicate(1);
				}
     		}
     		?bool_is_duplicate(Bool);
     		if(Bool==0){
     			.concat(List_d, [[ResourceType, Quantity,  XDist-Xbase, YDist-Ybase]], List_prime_d);
				-+scanned_diamond_locations(List_prime_d);
     		}
		}
	}
	
	elif (ResourceType == "Obstacle"){
		?obstacles(Obs_list);
		.concat(Obs_list, [[XDist, YDist]], Obs_list_prime);
		-+obstacles(Obs_list_prime);
	}
	
	
	-+bool_is_duplicate(0);
	.

	
// move around if no resource found
+ resource_not_found : true <-
		?counter(D);
	.
@send_info[atomic]
+! send_info : true <-
		
		?scanned_gold_locations(G);
		?scanned_diamond_locations(D);
		.print("sending");
		?sent_info(B);
		
		
		if(B){
			.print("sending d : " , D);
			.print("sending g : " , G);
			.send(agent_scanner1, tell, recieved_resource_locations_d(D));
			.send(agent_scanner1, tell, recieved_resource_locations_g(G));	
			
			.print("sent");
			-+sent_info(false);
		}
		
		.kill_agent(agent_scanner2);
	.
	


	
	
	