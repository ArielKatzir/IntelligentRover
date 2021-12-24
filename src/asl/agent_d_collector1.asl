// Agent agent000 in project ia_submission


/* Initial beliefs and rules */

diamond_locations([]).
next_to_collect(0,0,0).
go_to(0,0,0).
direction("horizontal").
hug_direction_h(-3,0).
hug_direction_v(0,-3).
deposited(true).
attempted_move(false).
first_bool(false).
managed_to_move(false).
didnt_collect(false).
carrying(false).
resource_number(0).
/* Initial goals */


!get_locations.

/* Plans */

+! get_locations : true <-	
	// Wait until the scanning rovers have finished scanning
	.print("waiting for locations");
	.wait({+diamond_locations(LocationList)});
	.print("recieved locations: " , LocationList);
	
	
	// kill agent if no diamond is found
	if (LocationList == []){
		.kill_agent(agent_d_collector);
	}
	
	//.wait(30000); // ensures no collisions
	!move_to_resource;
	.

+! move_to_resource : true <-
	?diamond_locations(L);
	rover.ia.get_map_size(Width,Height);
	?resource_number(N);
	.nth(N,L,I);
	.nth(1,I,Quantity);
	.nth(2,I,X);
	.nth(3,I,Y);	
		
	if (X > Width/2){Log_x = X-Width}
	else{
		if (X < -Width/2){Log_x = X+Width}
		else{Log_x = X}
	}
	
	if (Y > Height/2) {Log_y = Y-Height}
	else{
		if (Y < -Height/2){Log_y = Y+Height}
		else{Log_y = Y}
	}
	?first_bool(B);
	?didnt_collect(BB);
	-+first_bool(true);
	if(B & not(BB)) {
		.print("waiting");
		.wait({+!back_to_base});
		.print("new location added");
	}
	-+next_to_collect(Log_x,Log_y,Quantity);
	-+go_to(Log_x,Log_y,Quantity);
	
	!collect_diamond;
        
	.
	
+ invalid_action(ActionName, Reason) <-
	.print("cant colect");
	-+didnt_collect(true);
	!back_to_base;
	.
@back_to_base[atomic]
+! back_to_base : true <- 
	?go_to(X,Y,Quantity);
	//move back to base
	.print("moving back to base on" , X," ",Y);
	move(X,Y);
	-+deposited(true);
	.	

+ insufficient_energy(move) <-
	.print("No energy");
	.

@collect_diamond[atomic]
+! collect_diamond : deposited(true) <- 
	-+deposited(false);
	?next_to_collect(X,Y,Quantity);
	-+go_to(X,Y,Quantity);
	.print("moving to collect at: " , X , " " , Y);
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	Hor = "horizontal";
	Ver = "vertical";
	//moves in seperate to know in which direction it hit the wall
	//move to diamond and record the movement
	
	.print("attempting to move " , X , " in the x direction and " , Y , " in the y direction. code -  001");
	move(X,Y);
	
	
	
	// know how much is it possible to collect
	if (Quantity < Capacity) {Amount_to_collect = Quantity;}
	else {Amount_to_collect = Capacity;}
	.print("collecting1");
	// collect diamond
	if (Quantity == 1){
		collect("Diamond");
	}else{
		for(.range(U ,1 , Amount_to_collect)){
			collect("Diamond");
		}
	}
	-+carrying(true);
	-+go_to(-X,-Y,Amount_to_collect);
	-+didnt_collect(false);
	
	.print("attempting to move back to base with " , -X , " in the x direction and " , -Y , " in the y direction. code -  002");
	//move back to base
	move(-X,-Y);
	
	.print("depositing");
	// deposit in base
	if (Amount_to_collect == 1){
		deposit("Diamond");
	}else{
		for(.range(U2 ,1 , Amount_to_collect)){
			deposit("Diamond");
		}
	}
	-+carrying(false);
	-+deposited(true);
	-+didnt_collect(true);
	-+go_to(0,0,0);
	?resource_number(N);
	-+resource_number(N+1);
	!move_to_resource;
	// if no more resource left, continue loop in move_to_resource
	// otherwise, collect more from the same resource
	?deposited(Dep);
	if(Dep){
		if (Quantity-Amount_to_collect == 0){
		}else{
			.print("look for me 2");
			-+next_to_collect(X,Y,Quantity-Amount_to_collect);
			
		}
	}
	
	.

-! collect_diamond : true <-
	.print("failed to collect diamond");
	.
	


@attempt_to_move[atomic]
+! attempt_to_move : true <-
	?hug_direction_h(Xh,Yh);
	?hug_direction_v(Xv,Yv);
	?attempted_move(B);
	?go_to(Xgo,Ygo,Q);
	?managed_to_move(D);
	Hor = "horizontal";
	Ver = "vertical";
	.drop_all_desires;
	.drop_all_events;
	.drop_all_intentions

	if(D){
		if (not(B)){
			-+hug_direction_v(-Xv,-Yv);
			X = -Xv;
			Y = -Yv;
		}else{
			X = Xv;
			Y = Yv;
		}
		
	}elif(not(D)){
		if (not(B)){
			-+hug_direction_h(-Xh,-Yh);
			X = -Xh;
			Y = -Yh;
		}else{
			X = Xh;
			Y = Yh;
		}
	}else{
		.print("error fetching direction");
	}
	
	-+direction(D);
	-+managed_to_move(false);
	.print("attempting to hug from: " , X , " " , Y);
	move(X,Y);
	-+managed_to_move(true);
	// only if succesfully moved change the route
	?go_to(X_left,Y_left,Quantity)
	
	rover.ia.get_map_size(Width,Height);
	if(X_left-X > Width/2){
		X_input = (X_left-X)-Width;
	}
	else{
		if(X_left-X < -Width/2){
			X_input = (X_left-X)+Width;
		}
		else{X_input = X_left-X;
		}
	}
	if(Y_left-Y > Height/2){Y_input = (Y_left-Y)-Height;
	}
	else{
		if(Y_left-Y < -Height/2){Y_input = (Y_left-Y)+Height;
		}
		else{Y_input = Y_left-Y;
		}
	}
	
	-+go_to(X_input, Y_input, Quantity);
	.print("new distance: " , X_input, " ", Y_input, ". Waiting... code - 003, you can pause now");
	-+attempted_move(true);
	.
	
-! attempt_to_move : true <-
	.print("fail attempt_to_move")
	.
	
		

+obstructed(X_travelled,Y_travelled,X_left, Y_left) <-
	?direction(D);
	?managed_to_move(B);
	?go_to(X,Y,Q);
	if(not(B)){
		-+attempted_move(false);
		-+go_to(X-X_travelled, Y-Y_travelled , Q);
	}else{
		-+go_to(X_left,Y_left,Q);
	}
	.print("obstructed");
	.print("stuck in direction: " , D , " with " ,X_left , " ",Y_left, " to go. - code 006");

	
	!attempt_to_move;
	!go_to_diamond_after_obstuction;
	
	.
	
-! go_to_diamond_after_obstuction : true <-
	.print("go_to_diamond_after_obstuction failed");
	.
	
	
@go_to_diamond_after_obstuction[atomic]
+! go_to_diamond_after_obstuction : true <- 
	Hor = "horizontal";
	Ver = "vertical";
	?go_to(X,Y,Quantity);
	?next_to_collect(Xbase,Ybase,Q);
	.print("moving to location after hit with directions: " , X , " " , Y , " code - 005");
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	?carrying(C);
	
	
	if (Q < Capacity) {Amount_to_collect = Q;}
	else {Amount_to_collect = Capacity;}
	if(not(C)){
		move(X,Y);
		// know how much is it possible to collect
		
		.print(Q);
		.wait(5000);
		.print("collecting2");
		.print(Q);
		.print(Amount_to_collect);
		// collect diamond
		if (Q == 1){
			collect("Diamond");
		}else{
			for(.range(U ,1 , Amount_to_collect)){
				collect("Diamond");
			}
		}
		-+carrying(true);
		-+didnt_collect(false);
		-+go_to(-Xbase,-Ybase,Quantity);
		!back_to_base;
	}else{
		.print(X," ",Y);
		-+go_to(X,Y,Q);
	}
	
	
	.print("moving back to base. code - 004");
	!back_to_base;
	
	.print("depositing");
	// deposit in base
	if (Amount_to_collect == 1){
		deposit("Diamond");
	}else{
		for(.range(U2 ,1 , Amount_to_collect)){
			deposit("Diamond");
		}
	}
	-+go_to(0,0,0);
	-+deposited(true);
	-+didnt_collect(true);
	-+carrying(false);
	?resource_number(N);
	-+resource_number(N+1);
	!move_to_resource;
	
	
	
	// if no more resource left, continue loop in move_to_resource
	// otherwise, collect more from the same resource
	
	?deposited(Dep);
	if(Dep){
		if (Q-Amount_to_collect == 0){
		}else{
			.print("look for me 1");
			-+next_to_collect(X,Y,Q-Amount_to_collect);
		}
		
	}
	
	
	.
	
	

// psudo
/*
 * recieves locations
 * for every diamond location:
 * 		1 . attempt to move to the diamond:
 * 			1.1 success: collect diamond
 * 			1.2 fail:	1.21	set new go_to (resource) location to with the remaining distance
 * 						1.22   if attempted to move already: move the opposite perpendicular direction to the one previously moved
 * 						1.23	else move in the direction perpendicular to the wall
 * 								--move fail :	1.231 go back to stage 1
 * 								--move success: 1.232 set go_to location to the old go to location minus what was moved in stages 2 or 3 
 * 												1.233 return to stage 1 with go_to directions
 *		2.collect:
 * 			2.1 fail: go back to base and search for another diamond location
 * 			2.2 success: stage 3.
 * 		3. return to base:
 * 			3.1 success: deposit and get new location
 * 			3.2 fail, go to stage 1.2.		
 * 		
 */
	
	
	
	
	
	
	
	
	
	