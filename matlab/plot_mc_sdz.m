%% Monte Carlo Final Impact Location - Safety Danger Zone (SDZ) Plot
% Run this section right after mcDataProcess2.m (numruns set to the
% 1000-run PitchInit sweep tuned to FYMn ~= 15 km). It reuses the
% variables mcDataProcess2.m already produces:
%   FinalX, FinalY  - per-run impact crossrange/downrange (km)
%   FXMn,  FYMn     - mean crossrange/downrange (m)
%   FYStd           - StdDev of Downrange (km)
% and adds FXStd the same way FYStd is computed, then plots the SDZ.

% Sigma value for FinalX, computed the same way FYStd is (std of the raw
% km values, not the *1000 "meters" versions like FXMn/FYMn).
FXStd = std(FinalX);   % StdDev of Crossrange (km) - sigma value for FinalX

% FXMn/FYMn are stored in meters (existing *1000 convention from
% mcDataProcess2.m); convert back to km to match FinalX/FinalY for plotting.
meanX = FXMn / 1000;    % km
meanY = FYMn / 1000;    % km

figure('Name', 'Monte Carlo Final Impact Location');
hold on;

% Raw impact scatter: one 'x' per MC run at its (FinalX, FinalY) landing point.
plot(FinalX, FinalY, 'x', 'Color', [0 0.2 0.6], 'DisplayName', 'Monte Carlo Impacts');
% Single marker at the mean impact location (centroid of the dispersion).
plot(meanX, meanY, '+', 'Color', [0.85 0.33 0.1], 'MarkerSize', 10, 'LineWidth', 2, ...
    'DisplayName', 'Mean Impact Location');

% Colors/labels/multipliers for the three sigma boundaries, indexed together
% so sigmaColors{k}/sigmaLabels{k}/sigmaMult(k) describe the same boundary.
sigmaColors = {[0.47 0.67 0.19], [0.30 0.75 0.93], [0.64 0.08 0.18]};
sigmaLabels = {'1\sigma Boundary', '3\sigma Boundary', '5\sigma Boundary'};
sigmaMult   = [1 3 5];

% Draw a matched pair of vertical lines (mean - k*sigma, mean + k*sigma) for
% each multiplier, so the dispersion is bracketed symmetrically about meanX.
for k = 1:numel(sigmaMult)
    % Left boundary gets the legend entry (DisplayName).
    xline(meanX - sigmaMult(k)*FXStd, '--', 'Color', sigmaColors{k}, ...
        'LineWidth', 1.2, 'DisplayName', sigmaLabels{k});
    % Right boundary reuses the same color but is hidden from the legend
    % (HandleVisibility off) so each sigma level only appears once.
    xline(meanX + sigmaMult(k)*FXStd, '--', 'Color', sigmaColors{k}, ...
        'LineWidth', 1.2, 'HandleVisibility', 'off');
end

% Axis limits define the Safety Danger Zone (SDZ) grid itself.
xlim([-3 3]);
ylim([0 18]);
xlabel('Crossrange (km)');
ylabel('Downrange (km)');
title(sprintf('%d-Sample Monte Carlo Final Impact Location', numel(FinalX)));
legend('show', 'Location', 'northeastoutside');
grid on;
hold off;

%% Safety check - alert if any impact is outside 5-sigma or outside the SDZ
% Two independent failure conditions, checked per-run:
%  1) the impact's crossrange is more than 5 sigma from the mean, or
%  2) the impact lands outside the SDZ box entirely (beyond the plotted grid).
outside5Sigma = abs(FinalX - meanX) > 5*FXStd;
outsideSDZ    = FinalX < -3 | FinalX > 3 | FinalY < 0 | FinalY > 18;
violations    = find(outside5Sigma | outsideSDZ);

% Any run tripping either condition means a call is required; list the
% offending runs so it's clear which ones to check first.
if ~isempty(violations)
    warning('SAFETY ALERT: %d impact(s) fall outside 5-sigma or the SDZ boundary. CALL REQUIRED.', numel(violations));
    for idx = violations
        fprintf('  Run %d: FinalX = %.4f km, FinalY = %.4f km\n', idx, FinalX(idx), FinalY(idx));
    end
else
    fprintf('All %d impacts are within 5-sigma and inside the SDZ. No call needed.\n', numel(FinalX));
end
