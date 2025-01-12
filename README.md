# Autonomous Cars Modeling Project (WorkInProgress)

# Context

This repo is a modeling project for a master 2 class "Modeling and simulation of complex systems". It is done using Gama software and presents a report in this readme. 

## USTH December 2024

Nathan Choukroun \- USTH ICT M2 / ESILV A5 Embedded  
Supervised by Alexis Drogoul and Arthur Brugiere \- IRD

- [Autonomous Cars Modeling Project (WorkInProgress)](#autonomous-cars-modeling-project-workinprogress)
- [Context](#context)
  - [USTH December 2024](#usth-december-2024)
  - [Project topic presentation](#project-topic-presentation)
  - [Installation and setup](#installation-and-setup)
  - [Presentation](#presentation)
- [Introduction](#introduction)
- [The model](#the-model)
  - [The population](#the-population)
  - [The cars](#the-cars)
  - [The management](#the-management)
  - [Improvements](#improvements)
- [Steps and features of conception](#steps-and-features-of-conception)
  - [Steps](#steps)
  - [Difficulties and choices](#difficulties-and-choices)
  - [Experiments and interactions](#experiments-and-interactions)
  - [Cities and improvements](#cities-and-improvements)
  - [Code commenting for documentation](#code-commenting-for-documentation)
- [Experimentation of the model](#experimentation-of-the-model)
  - [Explanation of the experiments](#explanation-of-the-experiments)
  - [Calibration](#calibration)
  - [Discussion of the results](#discussion-of-the-results)
- [Conclusion](#conclusion)
- [Sources](#sources)


## Project topic presentation

What financial incentives should be provided to move a city to autonomous cars? 

With the rise of AI models and car technology development, 2020 marked the start of a new kind of driving for our roads. After experiencing and optimizing driving help functions, engineers developed better levels of self-driving autonomous cars. Even though it has not reached full control and reliable driving, we can already experience self-driving mechanisms and take a look at the ongoing transition of the market. 

The role of the model would be to optimize the integration of autonomous vehicles into a manual car system, by understanding the response of the agents in the system and the funding of new vehicles. It could show the impact of adding gradually or suddenly autonomous cars into a city, even how fast can autonomous cars integrate a long-lasting steady car market. 

To make the most realistic model: – it should start with an initial state based on a study location, probabilities of financial and decisional government actions and current price and availability of car configuration. – It should compute different speed, number of passengers, cost of purchase and maintenance, probabilities of crashes or breakdowns. – It will result in a model capable of testing and experimenting different contexts and aspects of the problem to help answer the integration and the democratization of autonomous vehicles. 

Output could be displayed either as a batch experiment to determine the precise financial assessments for the costs and the choices of funding or penalties. Or by an interactive map of a city district showing residents and vehicles controlled by input parameters. 

Extension 1: Make the experiment reflect different cities and compare them. It could try to compare highly different conditions like a reproduction of Paris, Hanoi, Beijing or even Los Angeles. 

Extension 2: Take into account law, criminality, salaries, experience and segregation. 

Extension 3: Adding different car companies with different car models that react differently to their inputs. 

## Installation and setup

The model can be run by: installing Gama software; downloading ``` autonomous_integration.gaml```; importing the model to a new project; running the ```visual``` experiment; modify the parameters depending on the context; 

## Presentation

Slides to present the problematic, the conception difficulties and the results. 

Video of the model running on specific parameters.

# Introduction

Problematic: 
What financial incentives should be provided to move a city to autonomous cars? 

Reasons and objectives  
- understand the reason of buying a new kind of car
- imitate the stakeholders 
- understand the impact of the transition
- optimize the transition

# The model

Goals of the model
- decrease accidents on the roads
- find the best proportion of car type 
- try different financial plans 
- adapt it to any city context

implementation of a function that determine the probability of buying a car type
This starting income will determine if they are able to buy a car or not.   
Other criteria (segregation, money cap, fear of accident) will conclude on choosing autonomous or manual cars.   
People are walking or taking cars to go to work. 

I have to move around the city
Having a car is easier
I want to buy a car
I can buy the car when:?
I want a specific car type
The price of the car is around the market price, maybe not in my budget
I buy the car
I get a salary to increase my money
I can maintain my car based on my preference
If my car is not maintained higher risk of accident
if my car is autonomous, lower risk of accident
If my car is in an accident
I loose my car
I had an accident with a manual car, 
I may be able to buy a new car
and repeat the process

added timing to accident to reflect the impact of autonomous to the safeness of the city

![Diagram of the interactions between  species of the model](assets/diagram_model.png)

## The population

Segregation of choice for the type of car  
Start by walking and increase car desire 
compute number of accident > more accident influence the proba desire_autonomous

## The cars

Manage purchase price and maintenance price  
Accidents happens when too many cars are too close together   
Or too high of proba\_brake\_law  
Or too low of fiability caused by long distance driven
Gets money
The type of the car is defined by the main proba_car_type (which could be a general parameter based on government influence, marketing and advertising influense) and the number of accident a resident has been part of. for each accident the probaility to move to autonomous is increased.

## The management

\-manage salaries  
\-choose start help   
\-manage proba brake law  
\-choose accident help  
All based on auto or not

## Improvements

constant speed, possibility of crashes, cars without passengers, more expensive, new models  
folllow the law or not, but autonomous always follows  
proba brake\_law \> proba accident  
proba neighbors cars for brake\_law  
people make choices , not auto  
choosing to buy auto or not based on proba price and accident for each type  
car brake down of a car  
Level of autonomous (https://en.wikipedia.org/wiki/Self-driving\_car\#Level\_5)  
matrix of proba for levels,

neighborhood of electric or not  
whith differente schelling population (the moderns, the olds, the mids to buy auto)  
they evolve base on the proba of price and accident  
accident with auto so decrese proba of buy auto

memory optimisation for running better model performance

# Steps and features of conception

progress report with steps and list of features  
and documentation of the model and comment in the code

## Steps

\-define constants  
\-define variables and parameters based on the context  
\-generate the city, import buildings and roads  
\-add habitant (to buildings and cars, maybe not visible but update color of parent location)  
Where is a person going? How does he go there?   
\-add cars (move based on people needs)  
\-add accident species 
\-add money problems (purchase, condition of the car) gain money for each trip  
\-implement accidents (caused by too many neighbours, low condition, bad people)  
\-implement accident history: it is a list of accident for an inhabitant if his car was part of the accident
\-implement segregation and motivation to buy auto  
\-add probability of breaking the law and causing accident  
\-maybe implement speed of car based on urgency and law causing accident or more money
\-find realistic parameters for the model (probabilities, prices, salaries, maintenance reccurence)

## Difficulties and choices

the difficulty to make choices about the system. everything cannot be represent in the model so the developper needs to make choices and aim for the parameters that will represent best the hypothesis. for example it was choosen to implement population movement by walk and in cars but there are not following a common pattern of planning.  

## Experiments and interactions

one batch extension  
Paris to hanoi to LA  
one interaction

## Cities and improvements

Population is starting with a relative wealth depending on their neighborhood and their building.   
Cars can go out by themselves to train and analyse data, to turn and speed up by themselves. 

## Code commenting for documentation

# Experimentation of the model

## Explanation of the experiments

explanation and discussion of the experiments  
you are the goverment

## Calibration

need some real data
calibration the input parameter  
at a rate  
compare the real data to the correct percentage of the model

## Discussion of the results

stats and proba to compare with results  
I made modeling choices and i justify by

We can also observe an effect of the accident localisation. The impact of the grid structure and complexity makes some roads more open to traffic and therefore to accidents. The model could be improved by adding a more realistic road network and a more realistic population movement. It would be helpful to start an anylisis of the traffic network and key points on reduicing accidents in the city. 

# Conclusion

how to reason about the model and the results  
but synthetic  

debrief learning gama (java?, use of gama, understanding modeling, useful application, somewhat easy coding)

# Sources

[Autonomous vehicles worldwide - statistics & facts](https://www.statista.com/topics/3573/autonomous-vehicle-technology/#topicOverview)
[The powerful role financial incentives can play in a transformation](https://www.mckinsey.com/capabilities/transformation/our-insights/the-powerful-role-financial-incentives-can-play-in-a-transformation)
[On the performance of shared autonomous bicycles: A simulation study](https://www.sciencedirect.com/science/article/pii/S2772424722000166)
[Urban Mobility Swarms](https://ieeexplore.ieee.org/abstract/document/10421869)