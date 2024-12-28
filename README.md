# Autonomous Cars Modeling Project
# WorkInProgress

# Context

This repo is a modeling project for a master 2 class "Modeling and simulation of complex systems". It is done using Gama software and presents a report in this readme. 

# USTH December 2024

Nathan Choukroun \- USTH ICT M2 / ESILV A5 Embedded  
Supervised by Alexis Drogoul and Arthur Brugiere \- IRD

- [Autonomous Cars Modeling Project](#autonomous-cars-modeling-project)
- [WorkInProgress](#workinprogress)
- [Context](#context)
- [USTH December 2024](#usth-december-2024)
- [Project topic presentation](#project-topic-presentation)
- [todo](#todo)
- [! Presentation](#-presentation)
- [The model](#the-model)
  - [Introduction](#introduction)
  - [The map](#the-map)
  - [The road network](#the-road-network)
  - [The population](#the-population)
  - [The cars](#the-cars)
  - [The management](#the-management)
  - [Improvements](#improvements)
- [Step and features of conception](#step-and-features-of-conception)
  - [Steps](#steps)
  - [Experiment and interactions](#experiment-and-interactions)
  - [Cities and improvements](#cities-and-improvements)
  - [Code commenting for documentation](#code-commenting-for-documentation)
- [Experimentation of the model](#experimentation-of-the-model)
  - [Explanation of the experiments](#explanation-of-the-experiments)
  - [Calibration](#calibration)
  - [Discussion of the results](#discussion-of-the-results)
- [Conclusion](#conclusion)


# Project topic presentation

What financial incentives should be provided to move a city to autonomous cars? 

With the rise of AI models and car technology development, 2020 marked the start of a new kind of driving for our roads. After experiencing and optimizing driving help functions, engineers developed better levels of self-driving autonomous cars. Even though it has not reached full control and reliable driving, we can already experience self-driving mechanisms and take a look at the ongoing transition of the market. 

The role of the model would be to optimize the integration of autonomous vehicles into a manual car system, by understanding the response of the agents in the system and the funding of new vehicles. It could show the impact of adding gradually or suddenly autonomous cars into a city, even how fast can autonomous cars integrate a long-lasting steady car market. 

To make the most realistic model: – it should start with an initial state based on a study location, probabilities of financial and decisional government actions and current price and availability of car configuration. – It should compute different speed, number of passengers, cost of purchase and maintenance, probabilities of crashes or breakdowns. – It will result in a model capable of testing and experimenting different contexts and aspects of the problem to help answer the integration and the democratization of autonomous vehicles. 

Output could be displayed either as a batch experiment to determine the precise financial assessments for the costs and the choices of funding or penalties. Or by an interactive map of a city district showing residents and vehicles controlled by input parameters. 

Extension 1: Make the experiment reflect different cities and compare them. It could try to compare highly different conditions like a reproduction of Paris, Hanoi, Beijing or even Los Angeles. 

Extension 2: Take into account law, criminality, salaries, experience and segregation. 

Extension 3: Adding different car companies with different car models that react differently to their inputs. 

# todo
- [X] check car proba_accident and fiability
- [ ] realistic input parameters for salary, maintenance time (auto proba accident)
- [X] maintenance price
- [X] parameters
- [X] owner of a car
- [X] move accident to car
- [X] starting car_type proportion
- [X] change car_type proba accident_history
- [ ] change car_type proba schelling
- [ ] accident proba per car_type
- [ ] init create car location is random

proba_choose_car_type depend on accident_history and schelling
car_type not the same proba_accident
so if more autonomous on roads, less accident, so less go back to manual (but possible)


# \! Presentation

slides to follow the report and live interaction or video  
10-15min  
explain the problematic and the results to answer the problem  
and the difficulties

add pictures and code to explain
debrief learning gama (java?, use of gama, understanding modeling, useful application, somewhat easy coding)

# The model

running model and interactions  
github repo for the model  
presentation: slides to follow the report and live interaction or video
the difficulty to make choices about the system. everything cannot be represent in the model so the developper needs to make choices and aim for the parameters that will represent best the hypothesis. for example it was choosen to implement population movement by walk and in cars but there are not following a common pattern of planning.  

## Introduction

Problematic  
Reasons and objectives  
1 objective reason of buying  
2 add new thing  
3 external like government

Population is starting with a relative wealth depending on their neighborhood and their building.   
This starting income will determine if they are able to buy a car or not.   
Other criteria (segregation, money cap, fear of accident) will conclude on choosing autonomous or manual cars.   
People are taking their cars or not to go to work.   
Cars can go out by themselves to train and analyse data, to turn and speed up by themselves. 

## The map

## The road network

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

# Step and features of conception

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

## Experiment and interactions

one batch extension  
Paris to hanoi to LA  
one interaction

## Cities and improvements

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

# Conclusion

how to reason about the model and the results  
but synthetic  
