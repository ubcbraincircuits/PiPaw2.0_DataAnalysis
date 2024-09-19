function [tau_values, yfit] = fit_exponential_decay(matrix)
% This script is to calculate the decay rate of an exponential
    % Number of rows in the matrix
    numRows = size(matrix, 1);

    % Initialize an array to hold the tau values and fitted y-values
    tau_values = zeros(numRows, 1);
    yfit = cell(numRows, 1);

    % Exponential decay function
    expfun = @(p, x) p(1)*exp(-x/p(2));  % y = A*exp(-x/tau)

    % Time vector (assuming time steps of 1, change as necessary)
    x = 1:size(matrix, 2);

    % Loop over each row
    for i = 1:numRows
        % Observed data for this row
        y = matrix(i, :);

        % Initial guess (you may need to adjust this)
        p0 = [y(1), numel(x)/2];  % [A, tau]

        % Least squares fit
        p = lsqcurvefit(expfun, p0, x, y);

        % Retrieve the tau value and calculate the fitted y-values
        tau_values(i) = p(2);
        yfit{i} = expfun(p, x);
    end
end
