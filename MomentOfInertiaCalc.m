% assume you get power data at a matrix of times and power
% generate omega & alpha from calculations from Jermey's code
% use this to output moment of inertia (avg of them all)

clc;
clear;

% temporary example vectors
t = [1;2;3;4;5;6;7;8;9;10]; % data from bike trainer, assumed collects faster than rpm
T = [2;3;6;7]; % times bike pedal passes sensor (from arduino data)
pwr = [1;2;1;4;3;1;3;5;1;4]; % power readings from trainer
om = [2;4;5;6]; % omega values, calculated externally
al = [1;2;-1;3]; % alpha values, calculated externally


powerData = [t, pwr]; % where t is time col vector, pwr is data from machine
omega = [T, om];
alpha = [T, al];

powerVals = powerData(:,2);
indicies = ismember(powerData(:,1),alpha(:,1)); % t values that are in omega/alpha calcs

% only the power values we need (where omega and alpha are calculated)
newArray = powerVals(logical(indicies));

% get average of all MoI calcs (P/aw)
MoI = mean(newArray.*(1./(omega(:,1).*alpha(:,1))));

% kg * m^2 bc power is in W (according to Ben)
disp("Moment of Inertia: "+MoI+" kg * m^2")