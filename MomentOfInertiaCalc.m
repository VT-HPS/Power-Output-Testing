% MomentOfInteriaCalc.m
% generate omega & alpha from calculations from PowerOutputTesting.m
% use this to output moment of inertia (avg of them all)

% kemper - max power = 428, mean = 238


% clc;
% clear;
load PowerOutputTesting.mat revTimes omega alpha
% revTimes - times bike pedal passes sensor from arduino data
% omega - angular velocity values (rad/s), calculated from arduino data
% alpha - angular accelerationg values (rad/s^2), calculated from arduino data

pwrdata = readtable("2023-10-29-204844-FITNESS 1466-1-0-record.csv"); %update with file name

%fix data
pwrdata.power(isnan(pwrdata.power)) = 0;
pwrtimedata = datetime(extractBefore(convertCharsToStrings(pwrdata.timestamp),".000Z"));

start = find(pwrdata.power,1);
pwrtimewindow = pwrtimedata(start:end);
pwrTimes = seconds(time(between(pwrtimewindow(1), pwrtimewindow,"time")));

pwr = pwrdata.power(start:end); % power readings from trainer

indicies = ismembertol(pwrTimes,revTimes,0.5); % t values that are in omega/alpha calcs
timesOverlap = pwr(indicies); % only the power values we need (where omega and alpha are calculated)

% get average of all MoI calcs (P/aw)
moi = mean(timesOverlap.*(1./(omega.*alpha)));

% kg * m^2 bc power is in W (according to Ben)
disp("Moment of Inertia: "+moi+" kg * m^2")
