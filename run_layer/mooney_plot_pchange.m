clear;

cd /Users/insubkim/Documents/experiment/mooney/

masterpath='/Users/insubkim/Documents/experiment/mooney/';
addpath(genpath('/Users/insubkim/Documents/experiment/mooney/mooney_script'))
subj = {'JEH', 'HSY', 'LYR' };
nsub = length(subj);
%%

%dataGrab = getAllFiles(dataDir,'*.txt',1);

for ss = 1:nsub
    dataDir=['/Users/insubkim/Documents/experiment/mooney/' subj{ss} '/results'];
    dataGrab = getAllFiles(dataDir,'*I*.txt',1);
    for ff=1:length(dataGrab)
        
        load(dataGrab{ff})
        
        FileNames = strsplit(dataGrab{ff},'/'); FileNames = FileNames{end};
        varName_t = strsplit(FileNames,'.'); varName = varName_t{1};
        values = {eval(varName)};
        
        data(ff).name=varName_t(1);
        data(ff).value=values;
    end
    %
    all_data(ss).subj=data;
end


varNames = [data.name];
dataValue = [data.value];

%% % BOLD each image



cols=cbrewer('qual','Set2',3);
images = {'I1','I2','I3','I4'};
conds = {'M1','M2','O'};

mb = cell(nsub,length(images));
mv = cell(nsub,length(images));
counter = 1;
figure()
for ss = 1:nsub
    data = all_data(ss).subj;
    for ii = 1:length(images)
        subplot(nsub,4,counter)
        
        idx =find(contains(varNames,'BOLD') + contains(varNames,images{ii}) == 2);
        idx2 =find(contains(varNames,'VASO') + contains(varNames,images{ii}) == 2);

        mb{ss,ii} = cell2mat([data(idx).value]');
        mv{ss,ii} = cell2mat([data(idx2).value]');

        for cond = 1:length(idx)
            plotname =cellfun(@(s) strsplit(s, '_'), [data(idx).name], 'UniformOutput', false); %or use regexp
            
            p= plot(data(idx(cond)).value{1}, ...
                'LineWidth',3, ...
                'Color',cols(cond,:)); hold on
            if counter < 5
                title([plotname{1}{1} ' ' plotname{1}{3}])
            elseif counter > (nsub-1)*length(images)
                xlabel('depth')
            end
            ylabel([subj{ss} ' Beta'])
            
            %         xlim([0 9])
        end
        counter = counter + 1;
        
        
    end
    
    
end
legend({'M1','M2','original'},'Location','north')
legend('boxoff')


savename = [masterpath 'figures/layer_profile/BOLD_each_image.png'];
saveas(gcf,savename)


%% BOLD mooney effect

mooneyeffect =cellfun(@(x) x(2,:)-x(1,:), mb, 'UniformOutput', false); %or use regexp


figure()
counter = 1;
for ss = 1:nsub
    mooneyeffect_mean{ss,1} = mean(cell2mat(mooneyeffect(ss,:)'));
    for ii = 1:length(images)
        subplot(nsub,4,counter)
        
        
        plot(mooneyeffect{ss,ii}, ...
            'LineWidth',3, ...
            'Color','black'); hold on
        hline(0,'k--');


        if counter < 5
            title(['BOLD' ' ' images{ii}])
        elseif counter > (nsub-1)*length(images)
            xlabel('depth')
        end
        ylabel([subj{ss} ' Beta'])
        ylim([-5 5])
        
        counter = counter + 1;
        %
        
    end
    
    
end

% suptitle('M2 minus M1 effect')

savename = [masterpath 'figures/layer_profile/BOLD_each_image_mooney_effect.png'];
saveas(gcf,savename)


%% VASO each image

figure()
counter = 1;
for ss = 1:nsub
    data = all_data(ss).subj;
    for ii = 1:length(images)
        subplot(nsub,4,counter)
        
        idx =find(contains(varNames,'BOLD') + contains(varNames,images{ii}) == 2);
        idx2 =find(contains(varNames,'VASO') + contains(varNames,images{ii}) == 2);

        mb{ss,ii} = cell2mat([data(idx).value]');
        mv{ss,ii} = cell2mat([data(idx2).value]');

        for cond = 1:length(idx2)
            plotname =cellfun(@(s) strsplit(s, '_'), [data(idx2).name], 'UniformOutput', false); %or use regexp
            
            p= plot(data(idx2(cond)).value{1}, ...
                'LineWidth',3, ...
                'Color',cols(cond,:)); hold on
            if counter < 5
                title([plotname{1}{1} ' ' plotname{1}{3}])
            elseif counter > (nsub-1)*length(images)
                xlabel('depth')
            end
            ylabel([subj{ss} ' Beta'])
            
            %         xlim([0 9])
        end
        counter = counter + 1;
        
        
    end
    
    
end
legend({'M1','M2','original'},'Location','north')
legend('boxoff')


savename = [masterpath 'figures/layer_profile/VASO_each_image.png'];
saveas(gcf,savename)

%% VASO mooney effect
mooneyeffect=[];
mooneyeffect =cellfun(@(x) x(2,:)-x(1,:), mv, 'UniformOutput', false); 

figure()
counter = 1;
for ss = 1:nsub
    mooneyeffect_mean{ss,2} = mean(cell2mat(mooneyeffect(ss,:)'));
    for ii = 1:length(images)
        subplot(nsub,4,counter)
        
        
        plot(mooneyeffect{ss,ii}, ...
            'LineWidth',3, ...
            'Color','black'); hold on
        hline(0,'k--');


        if counter < 5
            title(['VASO' ' ' images{ii}])
        elseif counter > (nsub-1)*length(images)
            xlabel('depth')
        end
        ylabel([subj{ss} ' Beta'])
        ylim([-5 5])
        
        counter = counter + 1;
        %
        
    end
    
    
end

% suptitle('M2 minus M1 effect')

savename = [masterpath 'figures/layer_profile/VASO_each_image_mooney_effect.png'];
saveas(gcf,savename)


%%
figure('Renderer', 'painters', 'Position', [10 10 200 400])
counter = 1;
for ss = 1:nsub
    for bb  = 1:2
        subplot(nsub,2,counter)
        
        plot(mooneyeffect_mean{ss,bb}, ...
            'LineWidth',3, ...
            'Color','black'); hold on
        hline(0,'k--');
        ylim([-1.8 1.8])
        ylabel([subj{ss} ' Beta'])
        
        if counter ==1
            title(['BOLD'])
        elseif counter ==2
            title(['VASO'])
                        
        end
        %
        %         if counter < 5
        %             title(['BOLD' ' ' images{ii}])
        %         elseif counter > (nsub-1)*length(images)
        %             xlabel('depth')
        %         end
        %
        counter = counter + 1;
        %             axis tight;
        %
    end
end


savename = [masterpath 'figures/layer_profile/mean_mooney_effect.png'];
saveas(gcf,savename)







%%

% plot(t,sin(2*t),'-mo',...
%     'LineWidth',2,...
%     'MarkerEdgeColor','k',...
%     'MarkerFaceColor',[.49 1 .63],...
%     'MarkerSize',10)


%%



% %
%  T = array2table(dataValue);
%  T.Properties.VariableNames(1:end) = varNames;
%  writetable(T,'myData.csv','Delimiter',',','QuoteStrings',true)
%

%
