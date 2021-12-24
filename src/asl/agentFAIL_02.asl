// Agent blank in project ia_submission



/*
 * move right unless moved across the map, in that case move down.
 * scan 
 * 		if found:	
 * 					- go to it and collect as much as possible
 * 					- go back to base, deposit what the rover has and return to the gold
 * 					- repeat until there is no gold left
 * 					- once deposited all the gold, return to where the rover first scanned the gold (not where the gold was)
 * 		if not found:
 * 					- keep moving
 */	



// TODO
// If agent finds two resources, how to tell it to ignore one of them?


/* Initial beliefs and rules */

carrying(0).
location_counter(0).
moved_xy(0,0).
distance_from_base(0,0).
shift_to_gold(0,0).

/* Initial goals */

!move_around.

+! move_around : true
	<- 
	scan(3)
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	rover.ia.get_map_size(Width,Height);
	Times_to_move_x = math.round(Width/(Scanrange))-1;
	Times_to_move_y = math.round(Height/(Scanrange))-1;
	
	 ?moved_xy(X,Y);
	 ?distance_from_base(A,B);
	
	
	if(X <= Times_to_move_x-1){
		move(Scanrange,0);
		rover.ia.log_movement(Scanrange,0);
		-+distance_from_base(A+Scanrange,B+0);
		-moved_xy(_,_);
		+moved_xy(X+1,Y);
		
		scan(Scanrange);
		
		
	}else{
		move(0,2*Scanrange);
		rover.ia.log_movement(0,2*Scanrange);
		-+distance_from_base(A+0,B+2*Scanrange);
		-moved_xy(_,_);
		+moved_xy(0,Y+1);
		scan(Scanrange);
		
	}
	
	?distance_from_base(A_,B_);
	.print(A_,B_);
	
	.

//@return_to_base[atomic]
+! deposit : true <- 
	rover.ia.get_map_size(Width,Height);
	rover.ia.check_config(Capacity,Scanrange,Resourcetype);
	rover.ia.get_distance_from_base(XDistance,YDistance);
	
	?carrying(GoldAmount);
	
	if (-XDistance>Width/2){
		X=Width+XDistance;
	}else{
		X=XDistance;
	}
	if (-YDistance>Height/2){
		Y=Height+YDistance;
	}else{
		Y=YDistance;
	}
	
	move(X,Y);
	
	if (GoldAmount == Capacity){
		for(.range(D ,1 , GoldAmount)){
			deposit("Gold");
		}
		move(-X,-Y);
		scan(Scanrange);
		
	}else{
		if (GoldAmount == 1){
			deposit("Gold");
		}else{
			for(.range(D ,1 , GoldAmount)){
			deposit("Gold");
			}
		}
		move(-X,-Y);
		scan(Scanrange);
	}		
	.
	
-! move_around: true <- 
	rover.ia.check_status(E);
	if (E<10){
		.print("No energy");
	}
	.

+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
+ insufficient_energy(move) <-
	.print("No energy");
	.
	

// move around if no resource found
+ resource_not_found : true <-
		!move_around
	.
	
// go to resource found
@resource_found[atomic]
+ resource_found (ResourceType, Quantity, XDist, YDist) : true <- 
		rover.ia.check_config(Capacity,Scanrange,Resourcetype);
		
		?distance_from_base(A,B);
		
		move(XDist, YDist);
		-+shift_to_gold(XDist, YDist);
		rover.ia.log_movement(XDist,YDist);
		-+distance_from_base(A+XDist,B+YDist);
		
		if (Quantity < Capacity){
			Max_to_collect = Quantity;
		}else{
			Max_to_collect = Capacity;
	
		}
				
		if (Max_to_collect==1){
			collect("Gold");
			-+carrying(1);
		}else{
			for(.range(U ,1 , Max_to_collect)){
			collect("Gold");
			-+carrying(Max_to_collect);
			}
		}
		
		?distance_from_base(A_,B_);
		.print(A_, " ", B_);
				
		!deposit;
	.
