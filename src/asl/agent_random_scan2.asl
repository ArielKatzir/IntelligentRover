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
	
	rover.ia.check_status(X);
	// likely to be enegry related issue
	if (X < 70){
			
	?scanned_gold_locations(G);
	?scanned_diamond_locations(D);
	?recieved_resource_locations_d(D_);
	?recieved_resource_locations_g(G_);
	
	.print("here");
	
	if(G_ == [0] & D_ = [0]){
		.wait({+recieved_resource_locations_d(LocationListD)});
		.wait({+recieved_resource_locations_g(LocationListG)});
	}else{
		LocationListD = D_;
		LocationListG = G_;
	}
	
	
	.print("recieved");
	
	.print(LocationListD , "---" , D);
	.print(LocationListG , "---" , G);
	
	.union(LocationListD,D,Union_diamond);
	.union(LocationListG,G,Union_gold);
	
	if(B){
		.print(Union_diamond);
		.print(Union_gold);
		.send(agent_d_collector1, tell, diamond_locations(Union_diamond));
		.send(agent_g_collector1, tell, gold_locations(Union_gold));	
		.kill_agent(agent_random_scan2);
		-+sent_info(false);
	}
	
	
		
	}
	
	?first_move(B);
	if(not(B)){
		// initial move will be down and left
		-+first_move(true);
		.print("making an initial move of right-up");
		move(Scanrange*2-2,-Scanrange*2-2);
		rover.ia.log_movement(Scanrange*2-2,-Scanrange*2-2);
		
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
	// likely to be enegry related issue
	if (X < 70){
				
		?scanned_gold_locations(G);
		?scanned_diamond_locations(D);
		?recieved_resource_locations_d(D_);
		?recieved_resource_locations_g(G_);
		
		.print("here");
		
		if(G_ == [0] & D_ = [0]){
			.wait({+recieved_resource_locations_d(LocationListD)});
			.wait({+recieved_resource_locations_g(LocationListG)});
		}else{
			LocationListD = D_;
			LocationListG = G_;
		}
		
		
		.print("recieved");
		
		.print(LocationListD , "---" , D);
		.print(LocationListG , "---" , G);
		
		.union(LocationListD,D,Union_diamond);
		.union(LocationListG,G,Union_gold);
		
		if(B){
			.print(Union_diamond);
			.print(Union_gold);
			.send(agent_d_collector1, tell, diamond_locations(Union_diamond));
			.send(agent_g_collector1, tell, gold_locations(Union_gold));	
			.kill_agent(agent_random_scan2);
			-+sent_info(false);
		}
	}else{
		!move_around;
	}
	
	
	.
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
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

+obstructed(X_travelled,Y_travelled,X_left, Y_left) <-
	rover.ia.check_status(E);
	.print("in obstructed");
	// log missing movement
	rover.ia.log_movement(X_travelled,Y_travelled);
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	//scanning to find nearby walls
	if (E > 70){
		.print(" ");
	}else{
		?scanned_gold_locations(G);
		?scanned_diamond_locations(D);
		?recieved_resource_locations_d(D_);
		?recieved_resource_locations_g(G_);
		
		.print("here");
		
		if(G_ == [0] & D_ = [0]){
			.wait({+recieved_resource_locations_d(LocationListD)});
			.wait({+recieved_resource_locations_g(LocationListG)});
		}else{
			LocationListD = D_;
			LocationListG = G_;
		}
		
		
		.print("recieved");
		
		.print(LocationListD , "---" , D);
		.print(LocationListG , "---" , G);
		
		.union(LocationListD,D,Union_diamond);
		.union(LocationListG,G,Union_gold);
		
		if(B){
			.print(Union_diamond);
			.print(Union_gold);
			.send(agent_d_collector1, tell, diamond_locations(Union_diamond));
			.send(agent_g_collector1, tell, gold_locations(Union_gold));	
			.kill_agent(agent_random_scan2);
			-+sent_info(false);
		}
	}
	.
	
// move around if no resource found
+ resource_not_found : true <-
		!move_around;
	.

-obstructed : true <-
	rover.ia.check_status(X);
	// likely to be enegry related issue
	if (X < 70){
				
		?scanned_gold_locations(G);
		?scanned_diamond_locations(D);
		?recieved_resource_locations_d(D_);
		?recieved_resource_locations_g(G_);
		
		.print("here");
		
		if(G_ == [0] & D_ = [0]){
			.wait({+recieved_resource_locations_d(LocationListD)});
			.wait({+recieved_resource_locations_g(LocationListG)});
		}else{
			LocationListD = D_;
			LocationListG = G_;
		}
		
		
		.print("recieved");
		
		.print(LocationListD , "---" , D);
		.print(LocationListG , "---" , G);
		
		.union(LocationListD,D,Union_diamond);
		.union(LocationListG,G,Union_gold);
		
		if(B){
			.print(Union_diamond);
			.print(Union_gold);
			.send(agent_d_collector1, tell, diamond_locations(Union_diamond));
			.send(agent_g_collector1, tell, gold_locations(Union_gold));	
			.kill_agent(agent_random_scan2);
			-+sent_info(false);
		}
	}else{
		!move_around;
	}
	.
	
+ insufficient_energy : true <-
		
	?scanned_gold_locations(G);
	?scanned_diamond_locations(D);
	?recieved_resource_locations_d(D_);
	?recieved_resource_locations_g(G_);
	
	.print("here");
	
	if(G_ == [0] & D_ = [0]){
		.wait({+recieved_resource_locations_d(LocationListD)});
		.wait({+recieved_resource_locations_g(LocationListG)});
	}else{
		LocationListD = D_;
		LocationListG = G_;
	}
	
	
	.print("recieved");
	
	.print(LocationListD , "---" , D);
	.print(LocationListG , "---" , G);
	
	.union(LocationListD,D,Union_diamond);
	.union(LocationListG,G,Union_gold);
	
	if(B){
		.print(Union_diamond);
		.print(Union_gold);
		.send(agent_d_collector1, tell, diamond_locations(Union_diamond));
		.send(agent_g_collector1, tell, gold_locations(Union_gold));	
		.kill_agent(agent_random_scan2);
		-+sent_info(false);
	}
	
	
	.
	


	
	
	