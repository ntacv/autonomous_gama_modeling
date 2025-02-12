/**
* Name: autonomousintegration
* Author: nta
* Tags: autonomous, city, car
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
	float step <- 10#m;
	//max_speed of the agent should correspond to the highest realistic speed of the studied city
	float max_speed <- 130#km/#h;
	
	// init parameters
	
	//total population for the experiment (no create, no die)
	int population_size <- 500;
	//base initial money amount
	float start_money <- 10000.0;
	//percentage of delta for the start_money
	float proba_delta_money <- 0.5 min:0.0 max:1.0;
	
	// parameters
	
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
	float proba_maintain_car <- 0.08 min:0.0 max:1.0;
	//base manual car cost
	float car_cost_manual <- 10000.0;
	//base autonomous car cost
	float car_cost_auto <- 15000.0;
	//percentage of delta for car cost (all types)
	float proba_delta_car_cost <- 0.5 min:0.0 max:1.0;
	//maximum possible cost of a car (necessary amount to consider buying a car)
	float max_car_cost <- max([car_cost_manual,car_cost_auto])*(1+proba_delta_car_cost) 
	update:max([car_cost_manual,car_cost_auto])*(1+proba_delta_car_cost);
	
	//percentage of car_type at the beginning of the experiment (will change to schelling)
	float init_proportion_car_type <- 0.0 min:0.0 max:1.0;
	//probability of autonomous or manual car type creation
	float init_proba_car_type <- 0.5 min:0.0 max:1.0;
	//the multiplier for proba_choose_car_type when experiencing an accident
	float ratio_prefered_car_type <- 0.2 min:0.0 max:5.0;
	//allow proba_choose_car_type to update based on experience, else only follow init_proba_car_type
	bool free_will <- true;
	
	//radius of accident 
	float accident_size <- 10#m;
	//probability of causing an accident 
	float proba_accident <- 0.5 min:0.0 max:1.0;
	//number of cars in a radius to prodiuce an accident
	int car_in_accident <- 2 min:1 max:20;
	//lowering of the probability of an accident for a autonomous vehicle compared to manual
	float proba_accident_autonomous <- 0.05 min:0.0 max:1.0;
	
	//count number of newly bought cars
	int new_car <- 0;
	//count number of car died of fiability too low
	int broke_down <- 0;
	
	//average ratio of intention to buy a specific car type
	float mean_choice <- 0.0 update: mean(inhabitant collect each.proba_choose_car_type);
	//update: free_will ? flip(proba_choose_car_type) : flip(init_proba_car_type) mean(inhabitant collect each.new_car_type);
	
	
	init{
		create building from:shapefile_building;
		create road from:shapefile_road;

		//residents start the simulation in their house
		create inhabitant number:population_size{
			location <- one_of(building).location;
			//personal_car <- one_of(car where(each.is_free = true));
			//ask personal_car{is_free <- false;}
		}
		//cars and residents will be able to navigate on the roads
		road_network <- as_edge_graph(road);
	}
	
	//condition to end the simulation 
	//if every resident have bought an autonomous car, it means the market has shifted and the debt are less than max_car_cost
	reflex end_simulation when:length(inhabitant) < length(car where(each.car_type)){
		do pause;
	}
}

species building{
	aspect default{
		draw shape color:#lightgray;
	}
}
species road{
	aspect default{
		draw shape color:#gray;
	}
}
species inhabitant skills:[moving]{
	//resident have a constant goal to move around the city, going buildings to buildings
	point target <- any_location_in(any(building));
	float speed <- inhabitant_speed;
	//instantiate random money amount at resident creation
	float money <- start_money * rnd(1-proba_delta_money,1+proba_delta_money);
	list<accident> accident_history;
	//define the probability to choose a specific car type
	float proba_choose_car_type <- 0.5 update: free_will ? proba_choose_car_type : init_proba_car_type;
	bool new_car_type <- false update: free_will ? flip(proba_choose_car_type) : flip(init_proba_car_type);
	float new_car_price <- 0.0 update: new_car_type 
			? car_cost_auto*rnd(1-proba_delta_car_cost,1+proba_delta_car_cost) 
			: car_cost_manual*rnd(1-proba_delta_car_cost,1+proba_delta_car_cost);
	
	//a resident can have only one car at a time
	car personal_car;
	list<car> car_history;
	list<bool> car_type_history;
	
	init{
		//buy a car if the price is acceptable
		if(self.money>new_car_price){
			do deliver_car;
		}
	}
	action deliver_car{
		create car number:1 returns: created_car{
			car_type <- myself.new_car_type;
			location <- myself.location;
			purchase_cost <- myself.new_car_price;
			car_owner <- myself;
		}
		new_car <- new_car+1;
		//attribute the car to its owner
		personal_car <- first(created_car);
		money <- self.money - personal_car.purchase_cost;
		car_history << personal_car;
		car_type_history << personal_car.car_type;
	}
	
	//remove a broken car to allow to buy a new one
	reflex dump_car when:dead(personal_car){
		personal_car <- nil;
	}
	
	//increase money with random salary in the range
	reflex make_money {
		money <- money + salary*rnd(1-proba_delta_salary,1+proba_delta_salary);
	}
	
	reflex buy_car when:personal_car=nil and self.money>new_car_price{
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
		//approximate cost of maintenance of a car. Before broke down, cost of repair is cost of car
		float maintenance_cost <- personal_car.purchase_cost * (1-personal_car.fiability);
		money <- money - maintenance_cost;
		personal_car.fiability <- 1.0;
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
	float car_proba_accident_car_type <- 1.0 update:car_type ? proba_accident_autonomous : 1.0 ;
	float car_proba_accident <- 0.5 update: proba_accident*(1-fiability)*car_proba_accident_car_type;
	inhabitant car_owner <- nil;
	
	float purchase_cost;
	
	reflex drive when:speed>0.0{
		fiability <- fiability - fiability_delta;
	}
	
	reflex brake_down when:fiability<=0.0{
		broke_down <- broke_down + 1;
		do die;
	}
	
	//model can use one of the two ways of affecting the choice function (addition or multiplication of a probality)
	action update_owner_proba_adding(inhabitant owner){
		owner.proba_choose_car_type <- last(owner.car_type_history)
		? owner.proba_choose_car_type-ratio_prefered_car_type 
		: owner.proba_choose_car_type+2*ratio_prefered_car_type;
		return owner.proba_choose_car_type;
	}
	action update_owner_proba_double(inhabitant owner){
		owner.proba_choose_car_type <- last(owner.car_type_history)
		? owner.proba_choose_car_type/2 
		: owner.proba_choose_car_type*2;
		return owner.proba_choose_car_type;
	}
	
	reflex create_accident when:car_in_accident<length(self neighbors_at (accident_size)) and flip(self.car_proba_accident){
		create accident number:1 returns:current_accident{
			location <- myself.location;
			habitant_responsible <- myself.car_owner;
			car_responsible <- myself;
			time_accident <- current_date;
			proba_at_accident <- myself.car_proba_accident;
			car_type <- myself.car_type;
			fiability <- myself.fiability;
		}
		car_owner.accident_history << first(current_accident);
		float proba <- update_owner_proba_double(car_owner);
		do debug(" proba accident " +proba);
		do die;
	}
	
	aspect default{
		draw rectangle(15#m,40#m) color:car_type ? #green: #red;
	}
}

species accident{
	inhabitant habitant_responsible;
	car car_responsible;
	point location_accident;
	date time_accident;
	float proba_at_accident;
	bool car_type;
	float fiability;
	float aspect_time <- 0.0;
	bool ended <- false;
	
	reflex count_time{
		aspect_time <- aspect_time+0.1;
	}
	reflex remove_accident when:aspect_time>30 {
		ended <- true;
	}
	
	aspect default{
		draw triangle(60#m) color:ended ? rgb(0,0,0,0) : #yellow;
	}
}

experiment visual type:gui{
	//parameter "" var: min: max: category: ;
	parameter "population size" var:population_size step:1 min:50 category:"init";
	parameter "starting money per person" var:start_money step:1 category:"init";
	parameter "proba delta money" var:proba_delta_money min:0.0 max:1.0 category:"init";
	parameter "proportion of car_type" var:init_proportion_car_type category:"init";
	
	parameter "manual base car cost" var:car_cost_manual step:1 category:"delta";
	parameter "autonomous base car cost" var:car_cost_auto step:1 category:"delta";
	parameter "delta car cost" var:proba_delta_car_cost category:"delta";
	parameter "base salary per cycle" var:salary min:1.0 step:1  category:"delta";
	parameter "proba delta salary" var:proba_delta_salary category:"delta";
	parameter "delta car fiability" var:fiability_delta min:0.0 category:"delta";
	parameter "proba maintain car" var:proba_maintain_car step:0.001 category:"delta";
	parameter "proba create accident" var:proba_accident min:0.0 max:1.0 category:"delta";
	parameter "proba autonomous create accident" var:proba_accident_autonomous category:"delta";
	parameter "ratio_prefered_car_type" var:ratio_prefered_car_type category:"delta";
	
	parameter "accident influence inhabitant car_type" var:free_will category:"more";
	parameter "car_type probaility" var:init_proba_car_type category:"more";
	parameter "base car speed" var:car_speed max:max_speed category:"more";
	parameter "base inhabitant speed" var:inhabitant_speed max:max_speed category:"more";
	parameter "accident radius" var:accident_size min:10.0 category:"more";
	parameter "min car in accident" var:car_in_accident category:"more";
	
	
	output synchronized: false{
		monitor ratio_global_choose_car_type  value: length(inhabitant where (each.proba_choose_car_type>0.5))/length(inhabitant) refresh:every(1#cycle);
		monitor mean_global_choose_car_type  value: mean(inhabitant collect each.proba_choose_car_type) refresh:every(1#cycle);
		monitor ratio_car_type value: (car count each.car_type)/((car count !each.car_type) + (car count each.car_type)) refresh:every(1#cycle);
		monitor length_accident value:length(accident) refresh:every(1#cycle);
		monitor length_car value:length(car) refresh:every(1#cycle);
		monitor new_car value:new_car refresh:every(1#cycle);
		monitor max_car_cost value:max_car_cost refresh:every(1#cycle);
		
		layout vertical([horizontal([0::5,3::5])::5,vertical([1::5,2::5])::7]);
		
		display map type:2d axes:false background:#black{
			species building;
			species road;
			species accident;
			species car;
			species inhabitant;
		}
		display chart_species {
			chart "monitor count for each species" type:series{
				data "inhabitant" value:length(inhabitant) color:#cornflowerblue;
				data "car" value:length(car);
				data "new_car" value:new_car;
				data "accident" value:length(accident) color:#yellow;
				data "car_brake_down" value:broke_down color:#brown;
				data "accident manu" value:accident count !each.car_type color:#red;
				data "accident auto" value:accident count each.car_type color:#green;
			}
		}
		display chart_car {
			chart "percentage of cars" type:series{
				data "amount of cars" value:length(car) color:#cornflowerblue;
				data "manual count cars" value:car count !each.car_type color:#red;
				data "auto count cars" value:car count each.car_type color:#green;
				data "negative money" value:length(inhabitant where (each.money<0));
				data "average accident per habitant" value:mean(inhabitant collect length(each.accident_history));
			}
		}
		display mean_type {
			chart "probability to choose a car_type" type:pie position:{0,0} size: {0.5, 0.5} {
				data "manual" value: 1-mean(inhabitant collect each.proba_choose_car_type);
				data "autonomous" value: mean(inhabitant collect each.proba_choose_car_type) color:#green;
			}
			chart "proportion of car type" type:pie position:{0.5,0} size: {0.5, 0.5}{
				data "manual" value: length(car)!=0 ? (car count !each.car_type)/(length(car)) : 0;
				data "autonomous" value: length(car)!=0 ? 1-(car count !each.car_type)/(length(car)) : 0 color:#green;
			}
		}
	}
}