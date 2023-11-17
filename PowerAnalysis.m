% powerAnalysis.m
radius = 0.3175; % m/s
pwrdata = readtable("2023-11-13-201932-WAHOOAPPIOS2292-4-0 (4)-record.csv",VariableNamingRule="modify");

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
times = 0:1:seconds(pwrtimedata(end) - pwrtimedata(1));

% figure;
figure('Name',"Measured Values")
tiledlayout(4,1)

nexttile
plot(times,pwrdata.power)
title("power")
ylabel("Watts");

nexttile
plot(times,omega)
title("omega")
ylabel("rad/s");

nexttile
plot(times,alpha)
title("alpha")
ylabel("rps");
nexttile
plot(times,torque)
title("torque")

% nexttile
% plot(times,MOI)
% title("MOI")

% [~,Idx] = max(MOI);
% 
% moi = pwrdata.power(Idx) / (omega(Idx) * alpha(Idx));
moi = 7.33333333333;

%% Derived Values
revTimes = readmatrix("Onland_Testing_Data\KB\KB_1.txt");
% revTimes = revTimes(4:end);
revTimes = revTimes - revTimes(1);

rpm = 60 ./ gradient(revTimes);
w = ((pi/30) .* rpm) .* 1.1;  % radians per second
    
% Spline Interpolation
xq = linspace(revTimes(1),revTimes(end),numel(revTimes));


% ww = interp1(revTimes,w,xq,"spline");

ww = fit(revTimes,w,'smoothingspline','Normalize','on'); 

W = feval(ww,xq);

a = gradient(W);  % radians per second squared​​
t = moi .* a;
P = t .* W;
P = abs(P) + abs(min(P));

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
% plot(revTimes, w,'o');
% plot(ww,xq);
plot(ww,xq,w)
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


%% %%
% M = (pwrdata.power)' ./ (ww .* a);
% m = (pwrdata.power) ./ (omega .* alpha);
% M(isinf(M)|isnan(M)) = 0;
% m(isinf(m)|isnan(m)) = 0;
% cFa = mean(abs(M));
% cFb = mean(abs(m));
% figure;
% tiledlayout(2,1)
% nexttile
% plot(times(1:118),M);
% nexttile
% plot(times,m)
%%
w = (pi/30) .* rpm;  % radians per second
    
% Spline Interpolation
xq = linspace(revTimes(1),revTimes(end),numel(revTimes));


% ww = interp1(revTimes,w,xq,"spline");

ww = fit(revTimes,w,'smoothingspline','Normalize','on');
W = feval(ww,xq);

figure;...
plot(ww,xq,w)