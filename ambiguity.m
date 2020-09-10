%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [7.1, 7.2, 8.1, 8.2];
displayfig = 'on';
sessions = [0, 1];
nagent = 10;
color = orange_color;


%-------------------------------------------------------------------------

for exp_num = selected_exp
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    
    % load data
    exp_name = char(filenames{round(exp_num)});
    
    data = d.(exp_name).data;
    sub_ids = d.(exp_name).sub_ids;
    
    figure('Renderer', 'painters',...
    'Position', [145,157,900*2,600], 'visible', 'on')
    subplot(1, 2, 1)
    suptitle(num2str(exp_num));
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_amb_post_test(...
        data, sub_ids, idx, sess);
    
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
    
    nsub = size(cho, 1);
    
    chose_symbol = zeros(nsub, length(p_sym), 2);
    for i = 1:nsub
        for j = 1:length(p_sym)
            temp = ...
                cho(i, logical(...
                (p1(i, :) == p_sym(j))));
            chose_symbol(i, j, :) = temp == 1;
            
        end
    end
    
    temp1 = cho(:, :);
    for i = 1:length(p_sym)
        temp = temp1(...
            logical((p1(:, :) == p_sym(i))));
        prop(i) = mean(temp == 1);
        err_prop(i) = std(temp == 1)./sqrt(length(temp));
        
    end
    
    X = reshape(...
        repmat(p_lot, nsub, 2), [], 1....
        );
    
    Y = reshape(chose_symbol, [], 1);
    
    [logitCoef, dev] = glmfit(X, Y, 'binomial','logit');
    
    pp = glmval(logitCoef, p_lot', 'logit');
    %
    
    %
    %     %alpha = [fli linspace(.5, 1, 2)];
    %
    lin1 = plot(...
        linspace(p_sym(1), p_sym(end), 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    hold on
    
    
    color = green_color;
    
    p1 = plot(p_lot, pp, 'Color', color, 'linewidth', 2);
    hold on
    
    sc1 = scatter(p_lot, prop, 150,...
        'MarkerEdgeColor', 'w',...
        'MarkerFaceColor', light_green,...
        'handlevisibility', 'off');
    
    hold on
    %
    er = errorbar(sc1.XData, prop, err_prop,...
        'Color', light_green, 'LineStyle', 'none', 'LineWidth', 1.7,...
        'handlevisibility', 'off');%, 'CapSize', 2);
    %
    %
    %         try
    %             ind_point = interp1(lin3.YData, lin3.XData, 0.5);
    %             sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
    %             'MarkerEdgeColor', 'w', 'handlevisibility', 'off');
    %             text(...
    %             ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
    %             .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
    %         catch
    %
    %         end
    %
    
    
    ylabel('P(choose experienced cue)', 'FontSize', fontsize);
    
    xlabel('Experienced cue win probability', 'FontSize', fontsize);
    
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
    
    box off
    set(gca, 'Fontsize', fontsize);
    %
    %         plot(p_sym(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', 'k',...
    %             'LineStyle', ':', 'LineWidth', 2.5, 'handlevisibility', 'off');
    hold on
    
    subplot(1, 2, 2);
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_lot_vs_amb_post_test(...
        data, sub_ids, idx, sess);
    
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
    
    nsub = size(cho, 1);
    
    chose_symbol = zeros(nsub, length(p_sym), 2);
    for i = 1:nsub
        for j = 1:length(p_sym)
            temp = ...
                cho(i, logical(...
                (p1(i, :) == p_sym(j))));
            chose_symbol(i, j, :) = temp == 1;
            
        end
    end
    
    temp1 = cho(:, :);
    for i = 1:length(p_sym)
        temp = temp1(...
            logical((p1(:, :) == p_sym(i))));
        prop(i) = mean(temp == 1);
        err_prop(i) = std(temp == 1)./sqrt(length(temp));
        
    end
    
    X = reshape(...
        repmat(p_lot, nsub, 2), [], 1....
        );
    
    Y = reshape(chose_symbol, [], 1);
    
    [logitCoef, dev] = glmfit(X, Y, 'binomial','logit');
    
    pp = glmval(logitCoef, p_lot', 'logit');
    %
    
    %
    %     %alpha = [fli linspace(.5, 1, 2)];
    %
    lin1 = plot(...
        linspace(p_sym(1), p_sym(end), 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    hold on
    
    
    color = green_color;
    
    p1 = plot(p_lot, pp, 'Color', color, 'linewidth', 2);
    hold on
    
    sc1 = scatter(p_lot, prop, 150,...
        'MarkerEdgeColor', 'w',...
        'MarkerFaceColor', light_green,...
        'handlevisibility', 'off');
    
    hold on
    %
    er = errorbar(sc1.XData, prop, err_prop,...
        'Color', light_green, 'LineStyle', 'none', 'LineWidth', 1.7,...
        'handlevisibility', 'off');%, 'CapSize', 2);
    %
    %
    %         try
    %             ind_point = interp1(lin3.YData, lin3.XData, 0.5);
    %             sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
    %             'MarkerEdgeColor', 'w', 'handlevisibility', 'off');
    %             text(...
    %             ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
    %             .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
    %         catch
    %
    %         end
    %
    
    
    ylabel('P(choose described cue)', 'FontSize', fontsize);
    
    xlabel('Described cue win probability', 'FontSize', fontsize);
    
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
    
    box off
    set(gca, 'Fontsize', fontsize);
    %
    %         plot(p_sym(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', 'k',...
    %             'LineStyle', ':', 'LineWidth', 2.5, 'handlevisibility', 'off');
    hold on
    
    clear prop cho pp p_sym p_lot err_prop
    
    saveas(gcf, ...
         sprintf('EA_DA_%s.png', num2str(exp_num)));
    
    figure('Renderer', 'painters',...
    'Position', [145,157,900,600], 'visible', 'on')
    
    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(exp_name, exp_num, d, idx, sess, 3, 1, 1, []);
        % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
    
    nsub = size(cho, 1);
    
    chose_symbol = zeros(nsub, length(p_lot), length(p_sym));
    for i = 1:nsub
        for j = 1:length(p_lot)
            for k = 1:length(p_sym)
                temp = ...
                    cho(i, logical(...
                    (p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
                chose_symbol(i, j, k) = temp == 1;
            end
        end
    end
    
    prop = zeros(length(p_sym), length(p_lot));
    temp1 = cho(:, :);
    for i = 1:length(p_sym)
        for j = 1:length(p_lot)
            temp = temp1(...
                logical((p2(:, :) == p_lot(j)) .* (p1(:, :) == p_sym(i))));
            prop(i, j) = mean(temp == 1);
            err_prop(i, j) = std(temp == 1)./sqrt(length(temp));
            
        end
    end
    
    X = reshape(...
        repmat(p_lot, nsub, 1), [], 1....
        );
    
    pp = zeros(length(p_sym), length(p_lot));
    lin1 = plot(...
        linspace(p_sym(1), p_sym(end), 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    hold on
    for i = 1:length(p_sym)
        
        Y = reshape(chose_symbol(:, :, i), [], 1);
        
        [logitCoef, dev] = glmfit(X, Y, 'binomial','logit');
        
        pp(i, :) = glmval(logitCoef, p_lot', 'logit');
        
    end
    
    alpha = linspace(0.2, 1, length(p_sym));
    for i = 1:length(p_sym)
      
        
        hold on
        hv = 'on';
        
        lin3 = plot(...
            p_lot,  prop(i, :),...
            'Color', green_color, 'LineWidth', 4.5,...% 'LineStyle', '--' ...
            'handlevisibility', hv);
        
        lin3.Color(4) = alpha(i);
        
        hold on
        
        if i == 8
            hv = 'on';
        else
            hv = 'off';
        end
        
     
 

        box off
        set(gca, 'Fontsize', fontsize);

        
    end
    
    ylim([0,1])
    title(num2str(exp_num));
    
    clear prop cho pp p_sym p_lot err_prop
    saveas(gcf, ...
         sprintf('ED_%s.png', num2str(exp_num)));
    
    %
end
%
% mkdir('fig/exp', 'ind_curves_sym_vs_lot_with_likert');
%     saveas(gcf, ...
%         sprintf('fig/exp/ind_curves_sym_vs_lot_with_likert/full.svg'));