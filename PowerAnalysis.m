% powerAnalysis.m
load OnlandTestingData.mat
radius = 0.3175; % radius of wheel
pwrdata = readtable("2023-11-13-201932-WAHOOAPPIOS2292-4-0 (4)-record.csv",VariableNamingRule="modify"); %data from trainer

% P = torque * v/r 
pwrdata.power(isnan(pwrdata.power)) = 0;
pwrdata.enhancedSpeed(isnan(pwrdata.enhancedSpeed)) = 0;

omega = pwrdata.enhancedSpeed ./ radius;
alpha = gradient(omega);
MOI = pwrdata.power ./ (omega .* alpha);
torque = pwrdata.power ./ omega;
MOI(isnan(MOI) | isinf(MOI)) = 0;
torque(isnan(torque) | isnan(torque)) = 0;

pwrtimedata = datetime(extractBefore(convertCharsToStrings(pwrdata.timestamp),".000Z"));
times = (0:1:seconds(pwrtimedata(end) - pwrtimedata(1)))';

% figure;
figure('Name',"Measured Values")
dV = tiledlayout(3,1);
title(dV,'Measured Values')

nexttile
plot(times,pwrdata.power)
title("power")
ylabel("Watts");

nexttile
plot(times,omega)
title("omega")
ylabel("rad/s");

nexttile
plot(times,torque)
title("torque")

% MOI rough calc, obtained by mean(torque) / mean(alpha)
% [~,Idx] = max(MOI);
% 
% moi = pwrdata.power(Idx) / (omega(Idx) * alpha(Idx));
moi = 7.33333333333;

%% Derived Values
revTimes = OnlandTestingData.KB{1};
[w, t, P, xq] = deriveValues(revTimes, moi);

figure('Name',"Derived Values");
dV = tiledlayout(3,1);
title(dV,'Derived Values')

% Plot Power
nexttile
plot(xq, P);
title("Power");
xlabel("Time (s)");
ylabel("Power");

% Plot w
nexttile
% plot(revTimes, w,'o');
% plot(ww,xq);
plot(xq,w)
title("\omega");
xlabel("Time (s)");
ylabel("rpm");


% Plot Torque
nexttile
plot(xq, t);
title("Torque");
xlabel("Time (s)");
ylabel("Torque");
