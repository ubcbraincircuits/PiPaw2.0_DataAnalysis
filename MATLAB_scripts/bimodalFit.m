function [weights] = bimodalFit (hTimes)
% this will give a bimodal fit of the holdtimes, and measures the weight
% of the exponential function (Figure 4 of the PiPaw Manuscript).

    for i = 1:length(hTimes)-101
        ht = sort(hTimes(i:i+100)); 
        pdf_normmixture = @(ht, mu, sigma, w, tau) ...
            w*normpdf(ht, mu, sigma) + (1-w)*exppdf(ht, tau); 
        start = [mean(ht) std(ht) .5 mean(ht)]; % Initial guess
        lb = [-Inf 0 0 0];  % Lower bounds
        ub = [Inf Inf 1 Inf];  % Upper bounds
        
        % Call the fit() function
        options = statset('MaxIter',5000, 'MaxFunEvals', 10000);
        try
            paramEsts = mle(ht, 'pdf',pdf_normmixture, 'start',start, 'lower',lb, 'upper',ub, 'options',options);
            
            % Extracting the parameters
            mu = paramEsts(1);
            sigma = paramEsts(2);
            w = paramEsts(3);
            tau = paramEsts(4);
        catch
            w = 0
            disp("Error for i = "+string(i))
        end
        weights(i) = 1-w;
        
    end
    weights(end:end+101) = 0;
end