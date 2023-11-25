function [fx] = derivative(yData, xData, option, num)
    % DERIVATIVE Computes a derivative of discrete x and y data
    %   [fx] = DERIVATIVE(yData, xData) computes the derivative using the
    %   built in Matlab GRADIENT function.
    %
    %   [fx] = DERIVATIVE(yData, xData, option) compute the derivative using the
    %   specified option as the method of computation.
    %       grad - default method, computes symmetric difference using the Matlab GRADIENT function
    %       largeDiff - computes symmetric difference using data points "num" spaces away
    %       uneven - computes difference quotient using uneven based equation
    %       linReg - computes derivative using "num" data points to the left and right to construct a line of best fit
    %
    %   Inputs:
    %       yData - vector of y-axis or dependent data
    %       xData - vector of x-axis or independent data
    %       option - optional flag for derivative method(default = grad)
    %       num - whole number input required for largeDiff and linReg options
    %
    %   Outputs:
    %       fx - vector of computed derivative values
    %
    %   Example:
    %       % Input vectors for time and position
    %       times = [1, 2, 4, 6, 7];
    %       pos = [4, 6, 7, 9, 8];
    %       
    %       % Compute velocity with different options
    %       gradVelocity = derivative(pos, times, "grad");
    %       largeDiffVelocity = derivative(pos, times, "largeDiff", 2);
    %       unevenVelocity = derivative(pos, times, "uneven");
    %       linRegVelocity = derivative(pos, times, "linReg", 2);
    %
    %   See also:
    %       GRADIENT

    % Validate inputs
    narginchk(2, 4);
    if nargin < 3 % Sets default option to grad
        option = "grad";
    end
    if nargin < 4 || isnan(num) % Sets default numeric to one
        num = 1;
    end
    assert(length(yData) == length(xData), "Mismatched input lengths");

    % Ensure num input is of reasonable length (i.e. it won't overflow)
    if 2*num + 1 > length(yData)
        num = bitshift(length(yData) + 1, -1) - 1;
    end

    % Branch into different options
    if strcmp(option, "largeDiff")
        fx = largeSymDiff(yData, xData, num);
    elseif strcmp(option, "uneven")
        fx = unevenDiff3(yData, xData, num);
    elseif strcmp(option, "linReg")
        fx = linRegDiff(yData, xData, num);
    else
        fx = gradient(yData, xData);
    end

    
end

%% Helper Functions
% This section examines helper functions for some of the derivative methods
% above

function [fx] = largeSymDiff(yData, xData, num)
    % LARGESYMDIFF Compute symmetric difference across longer range then
    % just one values to the left and right. In computes it by finding a
    % point up to num values to the left and right
    
    % Get the length and create output array
    ei = length(yData);
    fx = zeros(ei, 1);

    % Loop through elements and apply
    for i = 1:ei
        startIndex = i - num;
        endIndex = i + num;

        % Checks for out of bounds errors and adjust
        if (startIndex < 1 )
            startIndex = 1;
        end
        if (endIndex > ei)
            endIndex = ei;
        end

        % Compute derivative
        fx(i) = (yData(endIndex) - yData(startIndex)) / (xData(endIndex) - xData(startIndex));
    end
end


function [fx] = unevenDiff3(yData, xData)
    % UNEVENDIFF3 Compute a variation of the symmetric difference quotient
    % using the n=3 approach outline here:
    % http://www.m-hikari.com/ijma/ijma-password-2009/ijma-password17-20-2009/bhadauriaIJMA17-20-2009.pdf
    
    % Set up fx array and other vars
    len = length(yData);
    fx = zeros(len, 1);

    % Handle first edge conditions
    h1 = xData(2) - xData(1);
    h2 = xData(3) - xData(2);
    c1 = - (2*h1 + h2)/(h1*(h1 + h2));
    c2 = (h1+h2)/(h1*h2);
    c3 = - h1/((h1+h2)*h2);
    fx(1) = c1*yData(1) + c2*yData(2) + c3*yData(3);

    % Handle last edge condition
    h1 = xData(end-1) - xData(end-2);
    h2 = xData(end) - xData(end-1);
    c1 = h2 / (h1*(h1+h2));
    c2 = - (h1 + h2) / (h1*h2);
    c3 = (h1 + 2*h2)/(h2*(h1 + h2));
    fx(len) = c1*yData(end-2) + c2*yData(end-1) + c3*yData(end);

    % Handle middles
    for i = 2:(len-1)
        h1 = xData(i) - xData(i-1);
        h2 = xData(i+1) - xData(i);
        c1 = - h2 / (h1*(h1+h2));
        c2 = - (h1-h2) / (h1*h2);
        c3 = h1/((h1+h2)*h2);
        fx(i) = c1*yData(i-1) + c2*yData(i) + c3*yData(i+1);
    end
end


function [fx] = linRegDiff(yData, xData, num)
    % LINREGDIFF Computes derivative by taking the slope of a line of best
    % fit extending up to "num" data points to the right or left
    
    % Get the length and create output array
    ei = length(yData);
    fx = zeros(ei, 1);

    % Loop through elements and apply
    for i = 1:ei
        startIndex = i - num;
        endIndex = i + num;

        % Checks for out of bounds errors and adjust
        if (startIndex < 1 )
            startIndex = 1;
        end
        if (endIndex > ei)
            endIndex = ei;
        end

        % Compute derivative
        mdl = fitlm(xData(startIndex:endIndex), yData(startIndex:endIndex));
        fx(i) = mdl.Coefficients.Estimate(2);
    end
end