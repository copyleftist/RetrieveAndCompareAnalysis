clear all
%------------------------------------------------------------------------
data = load('partialdata');
data = data.learningdatarandc1(:, :);

%----------------------------------
%sem = @(x) std(x)./sqrt(size(data,2));

% get parameters
%------------------------------------------------------------------------
ncond = max(data(:, 13));
nsession = max(data(:, 20));
sub_ids = unique(data(:, 1));
%sub_ids = sub_ids(2);
sim = 1;
choice = 2;

%------------------------------------------------------------------------
% Define idx columns
%------------------------------------------------------------------------
idx.rtime = 6;
idx.cond = 13;
idx.sess = 20;
idx.trial_idx = 12;
idx.cho = 9;
idx.out = 7;
idx.corr = 10;
idx.rew = 19;
idx.catch = 25;
idx.elic = 3;
idx.sub = 1;
idx.p1 = 4;
idx.p2 = 5;
idx.ev1 = 23;
idx.ev2 = 24;
idx.dist = 28;
idx.plot = 29;
idx.cont1 = 14;
idx.cont2 = 15;
%------------------------------------------------------------------------

corr_catch = extract_catch_trials(data, sub_ids, idx);
[cho1, out1, corr1, rew] = extract_learning_data(...
    data, ncond, nsession, sub_ids, idx);
[corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2] = extract_elicitation_data(...
    data, sub_ids, idx, 0);


%figure
%bar(mean(corr{:, 1}));
%errorbar(mean(corr{:, 1}), std(corr{:, 1}));

%------------------------------------------------------------------------
% Compute corr choice rate
%------------------------------------------------------------------------
corr_rate = zeros(size(corr1, 1), 30, 4);

for sub = 1:size(corr1, 1)
    for t = 1:30
        for j = 1:4
            corr_rate(sub, t, j) = mean(corr1(sub, 1:t, j) == 1);
        end
    end
end

%------------------------------------------------------------------------
% PLOT
%------------------------------------------------------------------------
%i = 1;
titles = {'-0.8 vs 08', '-0.6 vs 0.6', '-0.4 vs 0.4', '-0.2 vs 0.2'};
figure;
for cond = 1:4
    subplot(1, 4, cond)
    options.error = 'sem';
    options.handle = 1;
    options.color_area = [0.4660    0.6740    0.1880];
    options.alpha = 0.4;
    options.color_line = [0.4660    0.6740    0.1880];
    options.line_width = 0.8;

    %options.handle = cond;
    %i = i + 1;
    plot_areaerrorbar(...
            corr_rate(:, :, cond), options...
    );
    xlabel('trials');
    ylabel('correct choice rate');
    title(titles{cond});
    ylim([-0.01, 1.01])
end


% ----------------------------------------------------------------------
% Compute for each symbol p of chosing depending on described cue value
% ------------------------------------------------------------------------
pcue = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
cont = unique(cont1);
plearn = zeros(length(pcue), length(cont));
for i = 1:size(corr, 1)
    for j = 1:length(pcue)
        for k = 1:length(cont)
            temp = cho(i, logical((p2(i, :) == pcue(j)) .* (cont1(i, :) == cont(k))));
            plearn(i, j, k) = temp == 1;
        end
    end
end


X = repmat(pcue, size(cho, 1), 1);
pp = zeros(length(cont), length(pcue));
for i = 1:length(cont)
    Y = plearn(:, :, i);
    disp(i);
    %     [B,dev,stats] = mnrfit(X, Y);
    %     pp(i, :) = mnrval(B, plearn(:, :, i));
    [logitCoef,dev] = glmfit(pcue', mean(plearn(:, :, i), 1)','binomial','logit');
    pp(i, :) = glmval(logitCoef,pcue','logit');
end

figure
titles = [1:9]./10;

for i = 1:length(cont)
    subplot(4, 4, i)
    plot(...
        pcue,  pp(i, :), 'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
        [0.4660    0.6740    0.1880], 'Color', [0.4660    0.6740    0.1880] ...
        );
    ylabel('P(choose learnt value)');
    xlabel('Described cue win probability');
    title(sprintf('%0.1f', titles(i)));
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
end

%set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

function [cho, out, corr, rew] = extract_learning_data(data, ncond, nsession, sub_ids, idx)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    mask_sub = data(:,1) == sub;
    if ismember(sum(data(:, 1) == sub), [255, 285])
        for cond = 0:ncond
            mask_cond = data(:, idx.cond) == cond;
            mask_sess = ismember(data(:, idx.sess), [0]);
            mask = logical(mask_sub .* mask_cond .* mask_sess);
            [noneed, trialorder] = sort(data(mask, idx.trial_idx));
            tempcho = data(mask, idx.cho);
            cho(i, 1:30, cond+1) = tempcho(trialorder);
            tempout = data(mask, idx.out);
            out(i, 1:30, cond+1) = tempout(trialorder);
            tempcorr = data(mask, idx.corr);
            corr(i, 1:30, cond+1) = tempcorr(trialorder);
            temprew = data(mask, idx.rew);
            rew(i, 1:30, cond+1) = temprew(trialorder);
        end
        i = i+1;
    end
end
end

function [corr_catch] = extract_catch_trials(data, sub_ids, idx)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    if ismember(sum(data(:, 1) == sub), [255, 285])
        for eli = [0, 2]
            
            mask_eli = data(:, idx.elic) == eli;
            if eli == 0
                eli = 1;
            end
            mask_sub = data(:, idx.sub) == sub;
            mask_catch = data(:, idx.catch) == 1;
            mask_sess = ismember(data(:, idx.sess), [0]);
            mask = logical(mask_sub .* mask_sess .* mask_catch .* mask_eli);
            [noneed, trialorder] = sort(data(mask, idx.trial_idx));
            temp_corr = data(mask, idx.corr);
            corr_catch{i, eli} = temp_corr(trialorder);
        end
        i = i + 1;
    end
end
end

function [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    extract_elicitation_data(data, sub_ids, idx, eli)
i = 1;
for id = 1:length(sub_ids)
    sub = sub_ids(id);
    if ismember(sum(data(:, 1) == sub), [255, 285])
        
        mask_eli = data(:, idx.elic) == eli;
        mask_sub = data(:, idx.sub) == sub;
        mask_catch = data(:, idx.catch) == 0;
        mask_sess = ismember(data(:, idx.sess), [0]);
        mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch);
        
        [noneed, trialorder] = sort(data(mask, idx.trial_idx));
        
        temp_corr = data(mask, idx.corr);
        corr(i, :) = temp_corr(trialorder);
        
        temp_cho = data(mask, idx.cho);
        cho(i, :) = temp_cho(trialorder);
        
        temp_out = data(mask, idx.out);
        out(i, :) = temp_out(trialorder);
        
        temp_ev1 = data(mask, idx.ev1);
        ev1(i, :) = temp_ev1(trialorder);
        
        temp_catch = data(mask, idx.catch);
        ctch(i, :) = temp_catch(trialorder);
        
        temp_cont1 = data(mask, idx.cont1);
        cont1(i, :) = temp_cont1(trialorder);
        
        temp_ev2 = data(mask, idx.ev2);
        ev2(i, :) = temp_ev2(trialorder);
        
        temp_cont2 = data(mask, idx.cont2);
        cont2(i, :) = temp_cont2(trialorder);
        
        temp_p1 = data(mask, idx.p1);
        p1(i, :) = temp_p1(trialorder);
        
        temp_p2 = data(mask, idx.p2);
        p2(i, :) = temp_p2(trialorder);
        
        i = i + 1;
        
    end
end
end

