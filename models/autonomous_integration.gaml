/**
* Name: autonomousintegration
* Based on the internal empty template. 
* Author: nta
* Tags: 
*/


model autonomousintegration

global{
	// files
	//shape file of the building to experiment a specific city
	file shapefile_building <- file("../includes/buildings.shp");
	//shape file of the road to carry cars and inhabitants
	file shapefile_road <- file("../includes/roads.shp");
	//definition of the experiment canvas based on the shape files
	geometry shape <- envelope(shapefile_building + shapefile_road);
	// definition of the network of roads
	graph road_network;
	
	// constants
	//experiment time span of a frame. the smallest, the more realistic
	float step <- 10#s;
	//max_speed of the agent should correspond to the highest realistic speed of the studied city
	float max_speed <- 130#km/#h;
	
	// init parameters
	//total population for the experiment (no create, no die)
	int population_size <- 200;
	//int car_size <- 100;
	
	//base initial money amount
	float start_money <- 12000.0;
	//percentage of delta for the start_money
	float proba_delta_money <- 0.5 min:0.0 max:1.0;
	//base salary for every cycle
	float salary <- 10.0;
	//percentage of delta for the salary
	float proba_delta_salary <- 0.5 min:0.0 max:1.0;
	
	//base inhabitant speed for walking
	float inhabitant_speed <- 5#km/#h;
	//base car speed on a common road
	float car_speed <- 50#km/#h;
	//decrease step for fiability variable at each cycle
	float fiability_delta <- 0.001;
	//percentage of chance to pay for maintenance instead of waiting for breakdown
	float proba_maintain_car <- 0.5 min:0.0 max:1.0;
	//base manual car cost
	float car_cost <- 10000.0;
	//base autonomous car cost
	float car_cost_auto <- 15000.0;
	//percentage of delta for car cost (all types)
	float proba_delta_car_cost <- 0.1 min:0.0 max:1.0;
	//maximum possible cost of a car (necessary amount to consider buying a car)
	float max_car_cost <- max([car_cost,car_cost_auto])*(1+proba_delta_car_cost) 
	update:max([car_cost,car_cost_auto])*(1+proba_delta_car_cost);
	
	//percentage of car_type at the beginning of the experiment (will change to schelling)
	float start_proba_car_type <- 0.1 min:0.0 max:1.0;
	//probability of autonomous or manual car type creation
	float proba_car_type <- 0.5 min:0.0 max:1.0;
	
	//radius of accident 
	float accident_size <- 50#m;
	//probability of causing an accident 
	float proba_accident <- 0.5 min:0.0 max:1.0;
	//number of cars in a radius to prodiuce an accident
	int car_in_accident <- 4 min:1 max:20;
	
	//count number of newly bought cars
	int new_car <- 0;
	
	
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
	float speed <- inhabitant_speed;
	float money <- start_money * rnd(proba_delta_money,1+proba_delta_money);
	list<accident> accident_history;
	float proba_choose_car_type <- 0.5;
	
	car personal_car;
	//float distance_self_car <- 0.0 update:self distance_to personal_car;
	
	init{
		do debug(name+"start money "+money);
		if(self.money>max_car_cost){
			do deliver_car(true);
		}
	}
	
	reflex dump_car when:dead(personal_car){
		personal_car <- nil;
	}
	reflex define_car_type when:personal_car!=nil{
		proba_choose_car_type <- personal_car.car_type 
		? proba_car_type-0.1*length(accident_history) 
		: proba_car_type+0.1*length(accident_history);
	}
	
	
	action deliver_car(bool init_delivery<-false){
		do debug(" max_car_cost "+max_car_cost);
		create car number:1 returns: created_car{
			car_type <- init_delivery ? flip(start_proba_car_type) : flip(myself.proba_choose_car_type);
			location <- myself.location;
			car_owner <- myself;
		}
		new_car <- new_car+1;
		personal_car <- first(created_car);
		money <- self.money - personal_car.purchase_cost;
		do debug(" purchase_cost "+personal_car.purchase_cost);
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
	reflex maintain_car when:flip(proba_maintain_car) and personal_car!=nil and money>personal_car.purchase_cost{
		if(personal_car.fiability<=0.0){
			ask personal_car{
				do die;
			}
			return;
		}
		float maintenance_cost <- personal_car.purchase_cost * (1-personal_car.fiability);
		money <- money - maintenance_cost;
		personal_car.fiability <- 1.0;
		
		do debug("maintenance applied "+maintenance_cost);
		
	}
	
	aspect default{
		draw circle(10#m) color:#cornflowerblue ;
	}
}
species car skills:[moving]{
	float speed <- car_speed;
	bool is_free <- true;
	bool car_type <- false;
	
	float fiability <- 1.0;
	float car_proba_accident <- 0.5 update: proba_accident*(1-fiability);
	inhabitant car_owner <- nil;
	
	float purchase_cost <- car_type 
	? car_cost*rnd(proba_delta_car_cost,1+proba_delta_car_cost) 
	: car_cost_auto*rnd(proba_delta_car_cost,1+proba_delta_car_cost);
	
	reflex drive when:speed>0.0{
		fiability <- fiability - fiability_delta;
	}
	
	reflex brake_down when:fiability<=0.0{
		do die;
	}
	
	reflex create_accident when:car_in_accident<length(self neighbors_at (accident_size)) and flip(self.car_proba_accident){
		create accident number:1 returns:current_accident{
			location <- myself.location;
		}
		car_owner.accident_history << first(current_accident);
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
	//parameter "" var: min: max: category: ;
	parameter "population size" var:population_size step:1 min:50 category:"init";
	parameter "starting money per person" var:start_money step:1 category:"init";
	parameter "proba delta money" var:proba_delta_money min:0.0 max:1.0 category:"init";
	parameter "proportion of car_type" var:start_proba_car_type category:"init";
	
	parameter "manual base car cost" var:car_cost step:1 category:"delta";
	parameter "autonomous base car cost" var:car_cost_auto step:1 category:"delta";
	parameter "delta car cost" var:proba_delta_car_cost category:"delta";
	parameter "base salary per cycle" var:salary min:1.0 step:1  category:"delta";
	parameter "proba delta salary" var:proba_delta_salary category:"delta";
	parameter "delta car fiability" var:fiability_delta min:0.0 category:"delta";
	parameter "proba maintain car" var:proba_maintain_car category:"delta";
	
	parameter "base car speed" var:car_speed max:max_speed category:"more";
	parameter "base inhabitant speed" var:inhabitant_speed max:max_speed category:"more";
	parameter "accident radius" var:accident_size min:10.0 category:"more";
	
	
	output synchronized: true{
		monitor length_accident value:length(accident) refresh:every(1#cycle);
		monitor length_car value:length(car) refresh:every(1#cycle);
		monitor new_car value:new_car refresh:every(1#cycle);
		monitor length_inhabitant value:length(inhabitant) refresh:every(1#cycle);
		monitor max_car_cost value:max_car_cost refresh:every(1#cycle);
		
		layout vertical([0::5,horizontal([1::6,2::4])::5]);
		
		display map type:2d axes:false background:#black{
			species building;
			species road;
			species accident;
			species car;
			species inhabitant;
		}
		display chart_species {
			chart "monitor count for each species" type:series{
				data "inhabitant" value:length(inhabitant);
				data "car" value:length(car);
				data "new_car" value:new_car;
				data "accident" value:length(accident);
			}
		}
		display chart_car {
			chart "percentage of cars" type:series{
				data "manual count cars" value:car count !each.car_type;
				data "auto count cars" value:car count each.car_type;
				data "amount of cars" value:length(car);
				data "negative money" value:length(inhabitant where (each.money<0));
				data "average accident per habitant" value:mean(inhabitant collect length(each.accident_history));
			}
		}
	}
}