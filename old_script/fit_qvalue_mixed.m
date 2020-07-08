% --------------------------------------------------------------------
% This script finds the best fitting QValues           
% --------------------------------------------------------------------

close all
clear all

addpath './fit'
addpath './plot'
addpath './data'
addpath './'

% --------------------------------------------------------------------
% Set parameters
% --------------------------------------------------------------------
conf = 'block';
feedback = 'complete_mixed';

displaywin = 'on';
catch_threshold = 1.;
rtime_threshold = 100000;

folder = 'data/';
data_filename = sprintf('%s_%s', conf, feedback);
fit_folder = 'data/fit/qvalues/';
fit_filename = sprintf('%s_%s', data_filename, 'learning');

colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730];

blue_color = [0.0274 0.427 0.494];
blue_color_min = [0 0.686 0.8];

% create a default color map ranging from blue to dark blue
len = 8;
blue_color_gradient = zeros(len, 3);
blue_color_gradient(:, 1) = linspace(blue_color_min(1),blue_color(1),len)';
blue_color_gradient(:, 2) = linspace(blue_color_min(2),blue_color(2),len)';
blue_color_gradient(:, 3) = linspace(blue_color_min(3),blue_color(3),len)';


% --------------------------------------------------------------------
% Load experiment data
% --------------------------------------------------------------------
[data, sub_ids, idx] = DataExtraction.get_data(...
    sprintf('%s%s', folder, data_filename));

% --------------------------------------------------------------------
% Set exclusion criteria
% --------------------------------------------------------------------
n_best_sub = 0;
optimism = 1;
allowed_nb_of_rows = [258, 288, 255, 285, 376, 470];

%------------------------------------------------------------------------
% Exclude subjects and retrieve data 
%------------------------------------------------------------------------
[sub_ids, corr_catch] = DataExtraction.exclude_subjects(...
    data, sub_ids, idx, catch_threshold, rtime_threshold,...
    n_best_sub, allowed_nb_of_rows);

folder = 'data/';
data_filename = sprintf('%s_%s', conf, feedback);
fit_folder = 'data/fit/qvalues/';
fit_filename = sprintf('%s_%s', data_filename, 'elicitation');

[corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    DataExtraction.extract_sym_vs_sym_post_test(...
    data, sub_ids, idx);

% set ntrials
ntrials = size(cho, 2);
subjecttot = length(sub_ids);
nz = [8, 1];
cont1(ismember(cont1, [6, 7, 8, 9])) = ...
    cont1(ismember(cont1, [6, 7, 8, 9]))-1;
cont2(ismember(cont2, [6, 7, 8, 9])) = ...
    cont2(ismember(cont2, [6, 7, 8, 9]))-1;

% concat
%out = out1;

% --------------------------------------------------------------------
% Run
% --------------------------------------------------------------------
fprintf('N = %d \n', length(sub_ids));
fprintf('NTrial = %d \n', ntrials);
fprintf('Catch threshold = %.2f \n', catch_threshold);
fprintf('Fit filename = %s \n', fit_filename);



[parameters1, ll] = runfit(...
    subjecttot,...
    cont1,...
    cont2,...
    cho,...
    ntrials,...
    nz,...
    fit_folder,...
    fit_filename);


[corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    DataExtraction.extract_elicitation_data(...
    data, sub_ids, idx, 0);

% set ntrials
ntrials = size(cho, 2);
subjecttot = length(sub_ids);
nz = [8, 1];
cont1(ismember(cont1, [6, 7, 8, 9])) = ...
    cont1(ismember(cont1, [6, 7, 8, 9]))-1;

cont2 = ev2;

[parameters2, ll] = runfit(...
    subjecttot,...
    cont1,...
    cont2,...
    cho,...
    ntrials,...
    nz,...
    fit_folder,...
    fit_filename);
 
d{1} = parameters1(:, 1:8)';
d{2} = parameters2(:, 1:8)';

figure('Renderer', 'painters',...
    'Position', [690,328,832,550], 'visible', displaywin)
eu = [-0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8];
order = [5, 6, 7, 8, 4, 3, 2, 1];
skyline_comparison_plot(d{1}, d{2}, [blue_color_gradient(8, :);[0.8500, 0.3250, 0.0980]], -1.1, 1.1, 13,...
    '', 'Symbol Expected Value', 'Qvalue', eu, 1);
yline(0, 'LineStyle', ':', 'LineWidth', 2.4);
set(gca, 'FontSize', 19);
%legend('Description vs Experience', 'Experience vs Experience', 'Location', 'southeast');
saveas(gcf, sprintf('fig/fit/%s/elicitation_fitted_qvalue.png', data_filename));

% --------------------------------------------------------------------
% FUNCTIONS USED IN THIS SCRIPT
% --------------------------------------------------------------------
function [parameters, ll] = ...
    runfit(subjecttot, cont1, cont2, cho, ntrials, nz, folder, fit_filename)

    parameters = zeros(subjecttot, 8);
    ll = zeros(subjecttot, 1);
    
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    for sub = 1:subjecttot
        
        waitbar(...
            sub/subjecttot,...  % Compute progression
            w,...
            sprintf('%s%d', 'Fitting subject ', sub)...
            );
           
            [
                p,...
                l,...
                rep,...
                output,...
                lmbda,...
                grad,...
                hess,...
            ] = fmincon(...
                @(x) qvalues(...
                    x,...
                    cont1(sub, :),...
                    cont2(sub, :),...
                    cho(sub, :),...
                    nz,...
                   ntrials),...
                zeros(8, 1),...
                [], [], [], [],...
                ones(8, 1) .* -1,...
                ones(8, 1),...
                [],...
                options...
                );
            parameters(sub, :) = p;
            ll(sub) = l;

    end
    %% Save the data
    data = containers.Map({'parameters', 'll'},...
        {parameters, ll});
    save(sprintf('%s%s', folder, fit_filename), 'data');
    close(w);
    
end
