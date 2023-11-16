% powerAnalysis.m
radius = 0.3175; % m/s
pwrdata = readtable("2023-11-13-201932-WAHOOAPPIOS2292-4-0 (4)-record.csv");

% P = torque * v/r 
pwrdata.power(isnan(pwrdata.power)) = 0;

omega = pwrdata.enhancedSpeed ./ radius;

alpha = gradient(omega);

MOI = pwrdata.power ./ (omega .* alpha);

torque = pwrdata.power ./ omega;

MOI(isnan(MOI) | isinf(MOI)) = 0;
torque(isnan(torque) | isnan(torque)) = 0;

pwrtimedata = datetime(extractBefore(convertCharsToStrings(pwrdata.timestamp),".000Z"));
times = 0:1:seconds(pwrtimedata(end) - pwrtimedata(1));

% figure;
figure('Name',"Measured Values")
tiledlayout(5,1)

nexttile
plot(times,pwrdata.power)
title("power")

nexttile
plot(times,omega)
title("omega")

nexttile
plot(times,alpha)
title("alpha")

nexttile
plot(times,torque)
title("torque")

nexttile
plot(times,MOI)
title("MOI")

% [~,Idx] = max(MOI);
% 
% moi = pwrdata.power(Idx) / (omega(Idx) * alpha(Idx));
moi = 68.9662;

%% Derived Values
revTimes = readmatrix("Onland_Testing_Data\MD\MD_1.txt");
revTimes = revTimes(6:end);
revTimes = revTimes - revTimes(1);
rpm = 60 ./ diff(revTimes);
w = (pi/30) .* rpm;  % radians per second
    
% Spline Interpolation
xq = revTimes(2):1:revTimes(end);
ww = interp1(revTimes(2:end),w,xq,"linear");


a = gradient(ww, xq);  % radians per second squared​​
t = moi .* a;
P = t .* ww;

figure('Name',"Derived Values");
tiledlayout(4,1)

% Plot Power
nexttile
plot(xq, P);
title("Power");
xlabel("Time (s)");
ylabel("Power");

% Plot w
nexttile
plot(revTimes(2:end), w,'o');
plot(xq,ww);
title("\omega");
xlabel("Time (s)");
ylabel("rps");

% Plot a
nexttile
plot(xq, a);
title("\alpha");
xlabel("Time (s)");
ylabel("rps2");


% Plot Torque
nexttile
plot(xq, t);
title("Torque");
xlabel("Time (s)");
ylabel("Torque");



