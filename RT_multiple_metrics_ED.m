%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [3];%, 6.2, 7.1, 7.2];
modalities = {'EE', 'ED'};
displayfig = 'off';
x = 'abs(ev1-ev2)';
zscored = 1;

% ------------------------------------------------------------------------%
median = zscored ~= 1;

ee = cell(50, 1);
ed = cell(50, 1);
num = 0;


for exp_num = selected_exp
    num = num + 1;
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    if zscored
        de.zscore_RT(exp_num);
    end
    
%     data_ee = de.extract_EE(exp_num);
    data_ed = de.extract_LE(exp_num);
    
    switch x
        case 'pavlovian'
            sum_ev = unique(round(data_ed.ev1+data_ed.ev2, 1));
            
            X = sum_ev;
            for i = 1:length(sum_ev)
                ed{i} = [ed{i,:}; -data_ed.rtime(round(data_ed.ev1+data_ed.ev2, 1)==sum_ev(i))];
%                 ee{i} = [ee{i,:}; -data_ee.rtime(round(data_ee.ev1+data_ee.ev2, 1)==sum_ev(i))];
                
            end
            
        case 'abs(ev1-ev2)'
            abs_ev = unique(round(abs(data_ed.ev1-data_ed.ev2), 1));
            
            X = abs_ev;
            for i = 1:length(abs_ev)
                ed{i} = [ed{i,:}; -data_ed.rtime(...
                    round(abs(data_ed.ev1-data_ed.ev2), 1)==abs_ev(i)...
                    )];
%                 ee{i} = [ee{i,:}; -data_ee.rtime(...
%                     round(abs(data_ee.ev1-data_ee.ev2), 1)==abs_ev(i)...
%                     )];
            end
        case 'chosenSymbol_{pwin}'
            sym_p = unique([data_ed.p1]);
            X = sym_p;
            
            for i = 1:length(sym_p)
                ed{i} = [ed{i}; -data_ed.rtime(logical(...
                    (data_ed.cho==1).*(data_ed.p1==sym_p(i))))];
%                 ee{i} = [ee{i}; -data_ee.rtime(logical(...
%                     (data_ee.cho==1).*(data_ee.p1==sym_p(i)) + (data_ee.cho==2).*(data_ee.p2==sym_p(i))))];
            end
            
        case 'symbol_{pwin}'
            sym_p = unique([data_ed.p1]);
            X = sym_p;
            
            for i = 1:length(sym_p)
                ed{i} = [ed{i, :}; -data_ed.rtime(logical(...
                    (data_ed.p1==sym_p(i))))];
%                 ee{i} = [ee{i, :}; -data_ee.rtime(logical(...
%                     (data_ee.p1==sym_p(i)) + (data_ee.p2==sym_p(i))))];
%                 
            end
            
        case 'lottery_{pwin}'
            sym_p = unique([data_ed.p2]);
            X = sym_p;
            
            for i = 1:length(sym_p)
                ed{i} = [ed{i, :}; -data_ed.rtime(logical(...
                    (data_ed.p2==sym_p(i))))];
%                 ee{i} = [ee{i, :}; -data_ee.rtime(logical(...
%                     (data_ee.p1==sym_p(i)) + (data_ee.p2==sym_p(i))))];
                
            end
%         case 'estimateLE'
%             
%             sym_p = unique([data_ed.p1]);
%                    
%             for i = 1:length(sym_p)
%                 ed{i} = [ed{i, :}; -data_ed.rtime(logical(...
%                     (data_ed.p1==sym_p(i))
%             )];
%                 ee{i} = [ee{i, :}; -data_ee.rtime(logical(...
%                     (data_ee.p1==sym_p(i)) + (data_ee.p2==sym_p(i))))];
%                 
%             end
    end
      
end


%-------------------------------------------------------------------------%
% Save fig                                             %
% ------------------------------------------------------------------------%
% save fig
ed = ed(~cellfun('isempty',ed));
% ee = {ee{1:length(ed)}}';

varrgin = X;
x_values = 5:100/length(X):110;
x_lim = [0 100];

if zscored
    y_lim = [-.5, .5];
else
    y_lim = [-2500, -500];
end

figure('Position', [0, 0, 800, 800], 'visible', 'off')
%subplot(1, 2, 1)



brickplot(ed, orange_color.*ones(length(ed),1), y_lim, fontsize+2,...
    'ED', x, '-RT (ms)', varrgin, 1, x_lim, x_values,.18, median);
set(gca, 'tickdir', 'out');
box off

% subplot(1, 2, 2)
% brickplot(ee, green_color.*ones(length(ee),1), y_lim, fontsize+2,...
%     'EE', x, '-RT (ms)', varrgin, 1, x_lim, x_values,.18, median);
% 
% set(gca, 'tickdir', 'out');
% box off


suptitle('Pooled exp. 1, 2, 3');

saveas(gcf, sprintf('fig/RT_%s_%d.svg', x, zscored));
