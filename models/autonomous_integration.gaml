/**
* Name: autonomousintegration
* Based on the internal empty template. 
* Author: nta
* Tags: 
*/


model autonomousintegration

global{
	// files
	file shapefile_building <- file("../includes/buildings.shp");
	file shapefile_road <- file("../includes/roads.shp");
	
	geometry shape <- envelope(shapefile_building + shapefile_road);
	graph road_network;
	
	// constants
	float step <- 10#s;
	float max_speed <- 50#km/#h;
	
	// init parameters
	int population_size <- 200;
	int car_size <- 100;
	
	float car_speed <- 50#km/#h;
	
	float start_money <- 10000.0;
	// percentage of delta for the input money;
	float proba_delta_money <- 0.5;
	float salary <- 100.0;
	float proba_delta_salary <- 0.5;
	
	float proba_car_type <- 0.5;
	float car_cost <- 10000.0;
	float car_cost_auto <- 15000.0;
	float proba_delta_car_cost <- 0.1;
	float max_car_cost <- 0.0 update:max([car_cost,car_cost_auto])*(1+proba_delta_car_cost);
	
	float accident_size <- 50#m;
	float proba_accident <- 0.5 ;
	
	int new_car <- 0;
	
	// parameters
	
	
	// update:people count each.infected;
	
	init{
		
		create building from:shapefile_building;
		create road from:shapefile_road;
		//among car (inhabitant where: each.money > 20000);
		//create car number:car_size{
		//	location <- one_of(road).location;
		//}
		create inhabitant number:population_size{
			location <- one_of(building).location;
			//personal_car <- one_of(car where(each.is_free = true));
			//ask personal_car{is_free <- false;}
		}
		road_network <- as_edge_graph(road);
	}	
}

species building{
	aspect default{
		draw shape color:#lightgray ;
	}
}
species road{
	aspect default{
		draw shape color:#gray ;
	}
}
species inhabitant skills:[moving]{
	point target <- any_location_in(any(building));
	float inhabitant_speed <- 5#km/#h;
	float money <- start_money * rnd(proba_delta_money,1+proba_delta_money);
	
	
	car personal_car;
	//float distance_self_car <- 0.0 update:self distance_to personal_car;
	
	init{
		if(self.money>max_car_cost){
			do deliver_car;
		}
	}
	
	reflex dump_car when:dead(personal_car){
		personal_car <- nil;
	}
	
	action deliver_car{
		create car number:1 returns: created_car{
			car_type <- flip(proba_car_type);
			location <- self.location;
			//car_owner <- self
		}
		new_car <- new_car+1;
		personal_car <- first(created_car);
		money <- self.money - personal_car.purchase_cost;
	}
	
	reflex make_money {
		money <- money + salary*rnd(proba_delta_salary,1+proba_delta_salary);
	}
	
	reflex buy_car when:personal_car=nil and money>max_car_cost{
		do deliver_car;
	}
	
	reflex move when:target!=nil{
		do goto target:target on:road_network;
		if(location=target){
			target<-any_location_in(any(building));
		}
	}
	reflex in_car when:personal_car!=nil {
		ask personal_car {
			location <- myself.location;
		}
	}
	reflex create_accident when:personal_car != nil 
	and 5<length(car at_distance accident_size)
	and flip(personal_car.car_proba_accident){
		create accident{
			location <- myself.location;
		}
		ask personal_car {
			do die;
		}
	}
	
	
	aspect default{
		draw circle(10#m) color:#cornflowerblue ;
	}
}
species car skills:[moving]{
	bool is_free <- true;
	bool car_type <- false;
	
	float fiability <- 1.0;
	float car_proba_accident <- 0.5 update: proba_accident+ proba_accident*fiability;
	
	float purchase_cost <- car_type 
	? car_cost*rnd(proba_delta_car_cost,1+proba_delta_car_cost) 
	: car_cost_auto*rnd(proba_delta_car_cost,1+proba_delta_car_cost);
	
	reflex drive when:speed>0.0{
		fiability <- fiability - 0.01;
	}
	reflex brake_down when:fiability<=0.0{
		do die;
	}
	
	reflex train_itself{
		
	}
	
	aspect default{
		draw rectangle(15#m,40#m) color:car_type ? #green: #red;
	}
}

species accident{
	aspect default{
		draw triangle(60#m) color:#yellow;
	}
}

experiment visual type:gui{
	parameter "population size" var:population_size step:1;
	
	output{
		monitor length_accident value:length(accident) refresh:every(1#cycle);
		monitor length_car value:length(car) refresh:every(1#cycle);
		monitor new_car value:new_car refresh:every(1#cycle);
		monitor length_inhabitant value:length(inhabitant) refresh:every(1#cycle);
		
		display map type:2d axes:false background:#black{
			species building;
			species road;
			species accident;
			species car;
			species inhabitant;
		}
		display charts {
			chart "monitor count for each species" type:series{
				data "inhabitant" value:length(inhabitant);
				data "car" value:length(car);
				data "new_car" value:new_car;
				data "accident" value:length(accident);
			}
		}
	}
}