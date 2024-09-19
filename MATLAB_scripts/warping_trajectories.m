

blocks(:, 2) = cellfun(@(x) x(x(:, 1) >= 0, :), blocks(:, 2), 'UniformOutput', false);
numRows = size(blocks, 1);
lengths = zeros(numRows, 1);
for i = 1:numRows
    lengths(i) = size(blocks{i, 2}, 1);
end
avgLength = round(mean(lengths));
warpedData = zeros(numRows, avgLength);
% Interpolate each of the second columns to the average length
for i = 1:numRows
    oldData = blocks{i, 2}(:, 2);
    oldX = linspace(1, lengths(i), lengths(i));
    newX = linspace(1, lengths(i), avgLength);
    warpedData(i, :) = interp1(oldX, oldData, newX, 'linear');
end