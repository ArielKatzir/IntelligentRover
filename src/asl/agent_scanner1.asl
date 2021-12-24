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
 
 
 //TODO GET IT TO WORK ON DYNAMIC - 4 
 
 
scanned_gold_locations([]).
scanned_diamond_locations([]).
obstacles([]).
times_moved(0,0).
bool_is_duplicate(0).
counter(_).
travel_direction(_).
initial_scan(false).
found_nearest_gap(false).
gap([]).
sent_info(true).
recieved_resource_locations_d([0]).
recieved_resource_locations_g([0]).
stuck_in_place(false).
switch(1).


 // TODO scan2 not workign when moving scan*2-2 in the y axis

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
	?initial_scan(M);
	if(not(M)){
		-+counter(0);
		.print("initial scan for agent 1");
		-+initial_scan(true);
		scan(Scanrange);
	}
	
	if(H < Times_to_move_x){
		move(Scanrange*2-4, 0);
		-+ times_moved(H+1,V);
		rover.ia.log_movement(Scanrange*2-4,0);
	}else{
		if (V < Times_to_move_y){
			-+times_moved(0,V+1);
			move(0, Scanrange*2-2);
			rover.ia.log_movement(0,Scanrange*2-2);
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
	

	
	.send(agent_d_collector1, tell, diamond_locations(D));
	.send(agent_g_collector1, tell, gold_locations(G));	
	-+sent_info(false);

	
	.kill_agent(agent_scanner1);
.
	


	
	
	