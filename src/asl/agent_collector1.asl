// Agent agent000 in project ia_submission


/* Initial beliefs and rules */

resource_locations([]).
next_to_collect(_,0,0,0).
go_to(_,0,0,0).
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
resource_type(_).
/* Initial goals */


!get_locations.

/* Plans */

+! get_locations : true <-	
	// Wait until the scanning rovers have finished scanning
	.print("waiting for locations");
	.wait({+resource_locations(LocationList)});
	.print("recieved locations: " , LocationList);
	
	
	// kill agent if no resource is found
	if (LocationList == []){
		.kill_agent(agent_collector);
	}
	
	!move_to_resource;
	.

+! move_to_resource : true <-
	?resource_locations(L);
	.print("recieved locations: " , L);
	rover.ia.get_map_size(Width,Height);
	.nth(0,L,T);
	.nth(1,L,Quantity);
	.nth(2,L,X);
	.nth(3,L,Y);	
	
	if (T = "G"){Type = "Gold"}
	elif (T = "D"){Type = "Diamond"}
	
		
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
	-+next_to_collect(Type,Log_x,Log_y,Quantity);
	-+go_to(Type,Log_x,Log_y,Quantity);
	
	!collect_resource;
        
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

@collect_resource[atomic]
+! collect_resource : deposited(true) <- 
	-+deposited(false);
	?next_to_collect(Type,X,Y,Quantity);
	-+go_to(X,Y,Quantity);
	.print("moving to collect at: " , X , " " , Y);
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	Hor = "horizontal";
	Ver = "vertical";
	//moves in seperate to know in which direction it hit the wall
	//move to resource and record the movement
	
	.print("attempting to move " , X , " in the x direction and " , Y , " in the y direction. code -  001");
	move(X,Y);
	
	
	
	// know how much is it possible to collect
	if (Quantity < Capacity) {Amount_to_collect = Quantity;}
	else {Amount_to_collect = Capacity;}
	.print("collecting1");
	// collect resource
	if (Quantity == 1){
		collect(Type);
	}else{
		for(.range(U ,1 , Amount_to_collect)){
			collect(Type);
		}
	}
	-+carrying(true);
	-+go_to(Type,-X,-Y,Amount_to_collect);
	-+didnt_collect(false);
	
	.print("attempting to move back to base with " , -X , " in the x direction and " , -Y , " in the y direction. code -  002");
	//move back to base
	move(-X,-Y);
	
	.print("depositing");
	// deposit in base
	if (Amount_to_collect == 1){
		deposit(Type);
	}else{
		for(.range(U2 ,1 , Amount_to_collect)){
			deposit(Type);
		}
	}
	-+carrying(false);
	-+deposited(true);
	-+didnt_collect(true);
	-+go_to(Type, 0,0,0);
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
			-+next_to_collect(Type,X,Y,Quantity-Amount_to_collect);
			
		}
	}
	
	.

-! collect_resource : true <-
	.print("failed to collect resource");
	.
	


@attempt_to_move[atomic]
+! attempt_to_move : true <-
	?hug_direction_h(Xh,Yh);
	?hug_direction_v(Xv,Yv);
	?attempted_move(B);
	?go_to(Type,Xgo,Ygo,Q);
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
	?go_to(T,X_left,Y_left,Quantity)
	
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
	
	-+go_to(Type,X_input, Y_input, Quantity);
	.print("new distance: " , X_input, " ", Y_input, ". Waiting... code - 003, you can pause now");
	-+attempted_move(true);
	.
	
-! attempt_to_move : true <-
	.print("fail attempt_to_move")
	.
	
		

+obstructed(X_travelled,Y_travelled,X_left, Y_left) <-
	?direction(D);
	?managed_to_move(B);
	?go_to(T,X,Y,Q);
	if(not(B)){
		-+attempted_move(false);
		-+go_to(T,X-X_travelled, Y-Y_travelled , Q);
	}else{
		-+go_to(T,X_left,Y_left,Q);
	}
	.print("obstructed");
	.print("stuck in direction: " , D , " with " ,X_left , " ",Y_left, " to go. - code 006");

	
	!attempt_to_move;
	!go_to_resource_after_obstuction;
	
	.
	
-! go_to_resource_after_obstuction : true <-
	.print("go_to_resource_after_obstuction failed");
	.
	
	
@go_to_resource_after_obstuction[atomic]
+! go_to_resource_after_obstuction : true <- 
	Hor = "horizontal";
	Ver = "vertical";
	?go_to(T,X,Y,Quantity);
	?next_to_collect(Type,Xbase,Ybase,Q);
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
		// collect resource
		if (Q == 1){
			collect(Type);
		}else{
			for(.range(U ,1 , Amount_to_collect)){
				collect(Type);
			}
		}
		-+carrying(true);
		-+didnt_collect(false);
		-+go_to(-Xbase,-Ybase,Quantity);
		!back_to_base;
	}else{
		.print(X," ",Y);
		-+go_to(T,X,Y,Q);
	}
	
	
	.print("moving back to base. code - 004");
	!back_to_base;
	
	.print("depositing");
	// deposit in base
	if (Amount_to_collect == 1){
		deposit(Type);
	}else{
		for(.range(U2 ,1 , Amount_to_collect)){
			deposit(Type);
		}
	}
	-+go_to(T,0,0,0);
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
			-+next_to_collect(Type,X,Y,Q-Amount_to_collect);
		}
		
	}
	
	
	.
	
	

// psudo
/*
 * gets locations
 * waits and lets the other agent to go first
 * for every diamond location:
 * 		1 . try to move to the diamond:
 * 			1.1 success: collect diamond
 * 			1.2 fail:	1.21	set new go_to (resource) location to whats left in the failed movement
 * 						1.22   if attempted to move already: move the opposite perpendicular direction to the one previously moved
 * 						1.23	else move in the direction perpendicular to the wall
 * 								--move fail :	1.231 go back to stage 1
 * 								--move success: 1.232 set go_to location to the old go to location minus what was moved in stages 2 or 3 
 * 												1.233 return to stage 1 with go_to directions
 *		2.collect:
 * 			fail: go back to base and search for another diamond location
 * 			success: stage 3.
 * 		3. return to base:
 * 			3.1 success: deposit and get new location
 * 			3.2 fail, go to stage 1.2.		
 * 		
 */
	
	
	
	
	
	
	
	
	
	