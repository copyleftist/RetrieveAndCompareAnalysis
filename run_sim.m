%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
exp_num = 3;
sess = 0;
model = 1;
decision_rule = 1;

% load data
name = char(filenames{round(exp_num)});

data = d.(name).data;
sub_ids = d.(name).sub_ids;

beta_dist = [1, 1];
gam_dist = [1.2, 5];

options.alpha1 = betarnd(beta_dist(1),...
                        beta_dist(2), [d.(name).nsub, 1]);
options.beta1 = gamrnd(gam_dist(1),...
                         gam_dist(2), [d.(name).nsub, 1]);
%options.beta1 = ones(d.(name).nsub, 1);
options.degradors = ones(d.(name).nsub, 2);
options.degradors(:, 2) = betarnd(6,...
                     2, [d.(name).nsub, 1]);
options.degradors(:, 1) = betarnd(6,...
                     2, [d.(name).nsub, 1]);        
[cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(...
    name, exp_num, d, idx, sess, model, decision_rule, 10, options);

 pcue = unique(p2)';
 psym = unique(p1)';
    
    chose_symbol = zeros(d.(name).nsub, length(pcue), length(psym), 1);
    for i = 1:d.(name).nsub
        for j = 1:length(pcue)
            for k = 1:length(psym)
                temp = ...
                    cho(i, logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));
                for l = 1:length(temp)
                    chose_symbol(i, j, k, l) = temp(l) == 1;
                end
            end
        end
    end
    
    nsub = size(cho, 1);
    k = 1:nsub;
    
    prop = zeros(length(psym), length(pcue));
    temp1 = cho(k, :);
    for j = 1:length(pcue)
        for l = 1:length(psym)
            temp = temp1(...
                logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
            prop(l, j) = mean(temp == 1);
            err_prop(l, j) = std(temp == 1)./sqrt(length(temp));
            
        end
    end
    
    figure('Renderer', 'painters',...
    'Position', [145,157,900,600], 'visible', 'on')

    pwin = psym;
    
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1), psym(end), 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    hold on
    
    for i = 1:length(pwin)
               
        lin3 = plot(...
            pcue,  prop(i, :),...
            'Color', orange_color, 'LineWidth', 4.5...% 'LineStyle', '--' ...
            );
        
        lin3.Color(4) = alpha(i);
        
        %ind_point1(i) = interp1(lin3.YData,lin3.XData, 0.5);

        hold on

        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        box off
    end

   set(gca, 'fontsize', fontsize)
