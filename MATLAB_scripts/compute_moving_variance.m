function moving_var = compute_moving_variance(data, start_idx, back_steps, forward_steps, window)
    % start_idx is the index of the successful/unsuccessful trial
    % back_steps is the number of steps back
    % forward_steps is the number of steps forward
    % window is the window size for moving variance

    % Calculate the start and end indices
    idx_start = max(1, start_idx - back_steps);
    idx_end = min(length(data), start_idx + forward_steps);

    % Calculate the moving variance
    moving_var = movvar(data(idx_start : idx_end), window);
end
