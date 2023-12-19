%% Power Analysis
% Load Data and Setup
load ..\OnlandTestingData.mat
radius = 0.3175; % radius of wheel
pwrdata = OnlandTesting.CG(1).trainerData; %data from trainer

% Filter NaN values for power and speed
pwrdata.power(isnan(pwrdata.power)) = 0;
pwrdata.enhancedSpeed(isnan(pwrdata.enhancedSpeed)) = 0;
power = pwrdata.power;

% Compute omega, alpha, and torque (filter NaN and Inf for torque)
omega = pwrdata.enhancedSpeed ./ radius;
alpha = gradient(omega);
torque = pwrdata.power ./ omega;
torque(isnan(torque) | isinf(torque)) = 0;

% Compute the vector of times
pwrtimedata = datetime(extractBefore(convertCharsToStrings(pwrdata.timestamp),".000Z"));
times = (0:1:seconds(pwrtimedata(end) - pwrtimedata(1)))';

%% Create Figure of Raw Data
% Set up tiled graph
figure('Name',"Measured Values");
mV = tiledlayout(4,1);
title(mV,'Measured Values');
xlabel(mV, "Time (s)");

nexttile
plot(times,pwrdata.power);
title("Trainer Power");
ylabel("Watts");

nexttile
plot(times,omega);
title("Angular Velocity");
ylabel("rad/s");

nexttile
plot(times, alpha);
title("Alpha");
ylabel("\omega rad/s^2");

nexttile
plot(times,torque);
title("Torque (calculated from above)");
ylabel("N - m");

%% MOI Derived Values
% MOI rough calc, obtained by mean(torque) / mean(alpha)
% [~,Idx] = max(MOI);
% 
% moi = pwrdata.power(Idx) / (omega(Idx) * alpha(Idx));

moi = 7.33333333333;
revTimes = OnlandTestingData.KB{1};
% [w, t, P, xq] = deriveValues(revTimes, moi); %under construction

figure('Name',"MOI Derived Values");
dV = tiledlayout(3,1);
title(dV,'Derived Values')
xlabel(dV, 'Times (s)')

% Plot Power
nexttile
plot(xq, P);
title("Power");
ylabel("Power (Watts)");

% Plot w
nexttile
% plot(revTimes, w,'o');
% plot(ww,xq);
plot(xq,w)
title("\omega");
ylabel("rpm");


% Plot Torque
nexttile
plot(xq, t);
title("Torque");
ylabel("Torque");

%% Linear Fit Derived Values
% This section simply maps a linear fit between alpha and torque. Note that
% this occurs on the "good" full reference data, hence we are able to
% compare derived versus reference values

% Create a linear fit starting from data peak    
si = 1;
mdl = fitlm(alpha(si:end), torque(si:end)); % **requires Stats & ML toolbox
linearFit = mdl.Coefficients.Estimate;

% Map alpha to derivedTorque
a = linearFit(2);
b = linearFit(1);
derivedTorque = a .* alpha + b;

% Create new tiled plot
figure('Name', 'Linear Fit Derived Torque and Power');
tiledlayout(2, 1);

% Plot reference and derived torque
nexttile(1);
plot(times, torque, times, derivedTorque);
xlabel("Time (s)");
ylabel("Torque (N - m)");
title("Derived vs. Actual Torque");
legend(["Ref Torque", "Derived Torque"]);

% Plot reference and derived power
nexttile(2);
derivedPower = derivedTorque .* omega;
plot(times, power, times, derivedPower);
xlabel("Time (s)");
ylabel("Power (Watts)");
title("Derived vs. Actual Power");
legend(["Ref Power", "Derived Power"]);
