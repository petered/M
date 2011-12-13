
cd(fileparts(mfilename('fullpath')));
close all hidden; clear classes; clc;

S=Simulation;

%% Initialize stimulation

S.nSteps=50;


%% Initialize world.

% Most 
Wo=World;

% Generate Banks
Bi=Bank().initializer;
Bi.liquid=@(N)gammaDraw(10000,3,N);     % Initial bank liquid assets
Wo.B=Bi.init(Bi,6);                     % Number of banks to initialize

% Generate Mortgage Types, associate with Banks
MTi=MortgageType;                       % Initiation of mortgage types

% Generate HomeOwners
Oi=HomeOwner().initializer;
Oi.salary=@(N)gammaDraw(20/12,2,N);     % $20k annual mean housing
Oi.cash=@(N)gammaDraw(20,2,N);          % $20k in savings.
Oi.correlate('cash',Oi.salary,.8);      % Because people with more savings generally make more 
Wo.O=HomeOwner().init(Oi,2000);         % Initiate N homeowners

% Generate Houses
Hi=House().initializer;
Hi.worth=@(N)gammaDraw(200,2,N);        % $200k mean house cost
Wo.H=House().init(Hi,1000);             % $Start with N Houses

% Link Houses to people
Hlinked=link(Wo.H,'O',Wo.O,'H',true,.9);                        % Link 90% of homes to homeowners.
Hlinked.correlate('worth',arrayfun(@(h)h.O.salary,Hlinked),.7); 

% Generate Mortgages for some percentage of linking houses







