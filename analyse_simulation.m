close all
clear all

addpath './'

%------------------------------------------------------------------------

folder = 'data/sim/';
data_filename = 'interleaved';

%------------------------------------------------------------------------

[data, sub_ids, exp, sim] = DataExtraction.get_data(...
    sprintf('%s%s', folder, data_filename));
whichmodel = [1 2 5 6 7];
models = {'RW', 'RW\pm',...
    'RW\pm_{\omega^-}', 'RW_\omega', 'RW_\phi',...
    'RW_{\tau}', 'Full', 'Bayesian'};

%------------------------------------------------------------------------
% retrieve data 
%------------------------------------------------------------------------
[cho, out, corr, con, q, p1, p2, ev, phase] = DataExtraction.extract_sim_data(...
    data, whichmodel, sim);

n_best = 0;
if n_best ~= 0
    for m = whichmodel
        temp = mean(corr(:, m, 120:208), 3);
        [throw, order] = sort(temp);
        cho(:, m, :) = cho(order, m, :);
        out(:, m, :) = out(order, m, :);
        con(:, m, :) = con(order, m, :);
        q(:, m, :) = q(order, m, :);
        p1(:, m, :) = p1(order, m, :);
        p2(:, m, :) = p2(order, m, :);
        ev(:, m, :) = ev(order, m, :);
    end 
    cho = cho(end-n_best:end, :, :); 
end
nsub = size(cho, 1);

q = q(:, :, 1:8);
for i = 1:size(q, 1)
    for j = 1:size(q, 2)
        ev1(i, j, 1:8) = [.8, -.8, .6, -.6, .4, -.4, .2, -.2];
    end
end
[throw, idx_ev] = sort(ev1(1, 1, :));
%------------------------------------------------------------------------
% Plot correlations 
% -----------------------------------------------------------------------
for i = whichmodel
    for j = 1:8
        semsub(i, j) = sem(q(:, i, j));
        mnsub(i, j) = mean(q(:, i, j));
    end
end
for i = whichmodel
    X = reshape(ev1(:, i, :), [], 1);
    Y = reshape(q(:, i, :), [], 1);
    
    colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730];
    figure('Renderer', 'painters', 'Position', [326,296,1064,691])
    skylineplot(...
        reshape(q(:, i, idx_ev), [nsub, 8])',...
        colors,...
        -1.1, 1.1, 13,...
        models{i},...
        'Expected Utility',...
        'Q',...
        unique(X));
end


%------------------------------------------------------------------------
% Compute corr rate learning
%------------------------------------------------------------------------
for i = 1:nsub
    for m = whichmodel
        temp = corr(i, m, :);
        
        for c = 1:4
            mask_1 = con(i, m, :) == c;
            mask_2 = phase(i, m, :) == 1;
            mask = logical(mask_1 .* mask_2);
            temp1 = temp(mask);
            for t = 1:30
                corr_rate_learning(i, t, c, m) = temp1(t);
            end
        end
    end
end

%------------------------------------------------------------------------
% PLOT
%------------------------------------------------------------------------
%i = 1;
titles = {'0.9 vs 0.1', '0.8 vs 0.2', '0.7 vs 0.3', '0.6 vs 0.4'};
i = 1;

for m = whichmodel
    
    figure;
    
    for cond = 1:4
        
        subplot(1, 4, cond)
        
        xLabel = '';
        yLabel = '';

        xLabel = 'trials';
        
        if cond == 1
            yLabel = 'correct choice rate';
        end
        
        surfaceplot(...
            corr_rate_learning(:, :, cond, m)',...
            ones(3) * 0.5,...
            [0.4660    0.6740    0.1880],...
            1,...
            0.38,...
            -0.01,...
            1.01,...
            15,...
            titles{cond},...
            xLabel,...
            yLabel);
        
        title(models{m});
        i = i + 1;
    end
end


% ----------------------------------------------------------------------
% Compute for each symbol p of chosing depending on described cue value
% ------------------------------------------------------------------------
pcue = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
psym = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
plearn = zeros(5, nsub, length(pcue), length(psym));

for m = whichmodel
    temp1 = cho(:, m, :);
    for i = 1:nsub
        temp2 = temp1(i, :, :);
        for j = 1:length(pcue)
            for k = 1:length(psym)
                
                temp3 = reshape(...
                    logical(...
                        (p2(i, m, :) == pcue(j)) .* (p1(i, m, :) == psym(k))...
                        .* (phase(i, m, :) == 2)),...
                        [], 1);
                            
                temp3 = reshape(temp3, [], 1);
                
                temp4 = temp2(temp3);
                plearn(m, i, j, k) = temp4 == 1;
            end
        end
    end
end


% titles = {'Low \Delta\alpha', 'High \Delta\alpha'};
% tt = 0;
% ----------------------------------------------------------------------
% PLOT P(learnt value) vs Described Cue
% ------------------------------------------------------------------------
for k = {1:nsub}
    k = k{:};

    for m = whichmodel
        
        prop = zeros(length(psym), length(pcue));
        for j = 1:length(pcue)
            for l = 1:length(psym)
               prop(l, j) = mean(plearn(m, k, j, l));
           end
        end

        X = repmat(pcue, nsub, 1);
        pp = zeros(5, length(psym), length(pcue));
        for i = 1:length(psym)
%            Y = plearn(k, :, i);
            %     [B,dev,stats] = mnrfit(X, Y);
            %     pp(i, :) = mnrval(B, plearn(:, :, i));
            [logitCoef, dev] = glmfit(...
                reshape(X, [], 1), reshape(plearn(m, k, :, i), [], 1), 'binomial','logit');
            pp(m, i, :) = glmval(logitCoef, pcue', 'logit');
        end

        figure
        %text(0.5, 0,  models{m}, 'FontSize', 14', 'FontWeight', 'Bold', ...
        %    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
        pwin = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];

        for i = 1:length(psym)
            subplot(4, 2, i)
            %suptitle(models{m});

            lin = plot(...
                pcue,  reshape(pp(m, i, :), [], 1)',... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
                'Color', [0.4660    0.6740    0.1880] ...
                );
            ind_point = interp1(lin.YData, lin.XData, 0.5);
            hold on
            scatter(ind_point, 0.5, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'w');

            if mod(i, 2) ~= 0
                ylabel('P(choose learnt value)');
            end
            if ismember(i, [7, 8])
                xlabel('Described cue win probability');
            end
            hold on
            scatter(pcue, prop(i, :),...
                'MarkerEdgeColor', 'w',...
                'MarkerFaceColor', [0.4660    0.6740    0.1880]);
    %             'MarkerFaceAlpĥa', 0.8);

            plot(...
                ones(10)*pwin(i),...
                linspace(0.1, 0.9, 10),...
                'LineStyle', '--', 'Color', [0, 0, 0], 'LineWidth', 0.6);

            if i < 6
                text(pwin(i)+0.03, 0.8, sprintf('P(win) = %0.1f', pwin(i)), 'FontSize', 7);
            else

                text(pwin(i)-0.30, 0.8, sprintf('P(win) = %0.1f', pwin(i)), 'FontSize', 7);
            end

            plot(linspace(0, 1, 12), ones(12)*0.5, 'LineStyle', ':', 'Color', [0, 0, 0]);
            ylim([-0.08, 1.08]);
            xlim([-0.08, 1.08]);
            
        end
        text(-0.35, 6,  models{m}, 'FontSize', 14, 'FontWeight', 'Bold', ...
            'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
    end
end