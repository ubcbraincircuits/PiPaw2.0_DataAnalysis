function dist = dtwDistance(a, b)
    a = a{1}(:, 2);  % extract the lever position trajectory
    %b = b{1}(:, 2); 
    %d = dtw(a, b);
    m2 = size(b,1);
    dist = zeros(m2,1);
    parfor i=1:m2
        dist(i) = dtw(a,b{i}(:,2));
        disp(i)
    end



end
