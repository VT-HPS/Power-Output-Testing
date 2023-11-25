%% Single Run Analysis
% This file only runs one set of data within the onland testing files. The
% goal of this file is to assist with rapid modeling for various
% possibilities in the model outlined in DataModel.png. Change the numbers
% on lines 12 and 13 to vary the person and their trial number

%% Load in Data and Graph Angular Velocity
load OnlandTestingData.mat


% Change these numbers to choose a person and their data
personNum = 1;
trialNum = 1;
fields = fieldnames(OnlandTestingData);
dataName = sprintf('%s_%d', fields{personNum}, trialNum);

% Get the raw revolution data and convert to rpm and times, then omega
revTimes = OnlandTestingData.(fields{personNum}){trialNum};
[rpm, times] = rpmGen(revTimes);
rpm(isnan(rpm) | isinf(rpm)) = 0;
omega = rpm .* (pi/30);

% Plot the omega data
figure('Name', "RPM Data from " + dataName);
plot(times, omega);
xlabel("Time (s)");
ylabel("Angular Velocity (rad/s)");
title("Untampered Angular Velocity Data");
legend(dataName);

%% Develop Model
% The high level comments (those with underlines) should not be changed
% unless the overall model changes. Each of these represent either a
% processing, derivative, or model block in DataModel.png. Here is how to
% select each layer
%
% Processing Blocks
%   I would reccomend using a Savitzky-Golay filter (sgolayfilt function),
%   or another data smoothing option. sgolayfilt with order = 3 and
%   framelen = 11 seems to work well.
%
% Derivative Block
%   Use the derivative function (in derivative.m) and experiment with the
%   different options.
%
% Model Block
%   Use either a custom fit or just use parameters computed from
%   PowerAnalsysis.m

% Stage 1 Processing
% -------------------------------------------------------------------------
processedOmega = sgolayfilt(omega, 3, 11);

% Differentiation
% -------------------------------------------------------------------------
alpha = derivative(processedOmega, times, "linReg", 5);

% Stage 2 Processing
% -------------------------------------------------------------------------
processedAlpha = sgolayfilt(alpha, 3, 11);

% Model
% -------------------------------------------------------------------------
% Using a simple linear fit
moi = 6.22237374355685;
torqueFriction = 7.03166504279402;
% torque = moi.*alpha + torqueFriction;
torque = moi.*processedAlpha + torqueFriction;
% Stage 3 Processing
% -------------------------------------------------------------------------
processedTorque = sgolayfilt(torque, 3, 11);

% Power Computation (can use raw OR processed omega)
% -------------------------------------------------------------------------
power = processedTorque .* processedOmega;

%% View Model Result
figure();
t = tiledlayout(4, 1);
title(t, dataName + " Model Results");
xlabel(t, "Time (s)");

% Omega Plot
nexttile(1);
plot(times, omega, times, processedOmega);
ylabel("Omega (rad/s)");
legend(["Raw", "Processed"]);
title("Omega");

% Alpha Plot
nexttile(2);
plot(times, alpha, times, processedAlpha);
ylabel("Alpha (rad/s^2)");
legend(["Raw", "Processed"]);
title("Alpha");

% Torque Plot
nexttile(3);
plot(times, torque, times, processedTorque);
ylabel("Torque (N - m");
legend(["Raw", "Processed"]);
title("Torque");

% Power Plot
nexttile(4);
plot(times, power);
ylabel("Power (W)");
title("Power");

%% Crazy Control Theory/Vibration Mapping
% Yeah, this one is wild. We will attempt to fit the omega graph to that of
% a critically damped response and use crazy math magic! This function
% will simply take omega and times and attempt to fit it to the following
% equation:
%
%   w(t) = w_ss - (w_ss + c2*t) * exp(-wn*t)
%
% Where w_ss is steady state (stable in theory) angular acceleration omega,
% w_n is the natural frequency (somehow) and c2 is just a constant. This is
% def not a good idea but I put it here anyways. First we will fit this
% equation to our omega data.

fo = fitoptions('Method','NonlinearLeastSquares',...
               'StartPoint',[-alpha(1), 0.5, mean(omega(150:end))]);
ft = fittype('wss - (wss + c*x) * exp(-wn*x)', 'options',fo);
[omegaFit, omegaGOF, omegaOutput] = fit(times, omega,ft);
figure();
hold off;
plot(times, omega);
hold on;
plot(omegaFit);

% Now the math magic comes in, where we can compute discrete functions for
% alpha, torque, and power. here they are:
%
%   alpha(t) = (w_ss*w_n - c2 - c2*w_n*t) * exp(-w_n)*t
%   torque(t) = I * alpha(t) + torque_friction
%   power(t) = omega(t) * torque(t)
%
% So these are computed and graphed cause why not

% Get parameters from best fit and torque fitting
omegaFitParams = coeffvalues(omegaFit);
c2 = omegaFitParams(1);
wn = omegaFitParams(2);
wss = omegaFitParams(3);

I = 6.22237374355685;
torqueFriction= 7.03166504279402;

% Create equations
alphaFit = @(t) (wss.*wn - c2 - c2.*t).*exp(-wn*t);
torqueFit = @(t) I .* alphaFit(t) + torqueFriction;
powerFit = @(t) omegaFit(t) .* torqueFit(t);

% Plot
figure();
t = tiledlayout(3, 1);
title(t, dataName);
xlabel(t, "Time (s)");

% Plot alpha
nexttile(1);
plot(times, alphaFit(times));
ylabel("Alpha (rad/s^2)");

% Plot torque
nexttile(2);
plot(times, torqueFit(times));
ylabel("Torque (N - m)");

% Plot power
nexttile(3);
plot(times, powerFit(times));
ylabel("Power (W)");