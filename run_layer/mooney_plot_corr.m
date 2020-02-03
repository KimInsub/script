clear;

cd /Users/insubkim/Documents/experiment/mooney/

masterpath='/Users/insubkim/Documents/experiment/mooney/';
addpath(genpath('/Users/insubkim/Documents/experiment/mooney/mooney_script'))
subj = {'JEH', 'HSY', 'LYR' };
nsub = length(subj);
%%

%dataGrab = getAllFiles(dataDir,'*.txt',1);

typeselect = 2;
saveflag=0;

rois ={'*a_corr*','*d_corr*','*m_corr*','*u_corr*'};
nametype = {'all','deep','middle','up'};

filt = rois{typeselect};
filtname = nametype{typeselect};
savename = [masterpath 'figures/layer_profile/' 'corr_' filtname '.png'];
% 



for ss = 1:nsub
    dataDir=['/Users/insubkim/Documents/experiment/mooney/' subj{ss} '/results'];
    dataGrab = getAllFiles(dataDir,filt,1);
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



images = {'I1','I2','I3','I4'};
conds = {'M1','M2','O'};
seq = {'BOLD','VASO'};
nlayer=3;

%img1-M1-M2_cor,img1-M1-O_cor,img1-M2-O_cor
%img2-M1-M2_cor,img2-M1-O_cor,img2-M2-O_cor,
%img3-M1-M2_cor,img3-M1-O_cor,img3-M2-O_cor,
%img4-M1-M2_cor,img4-M1-O_cor,img4-M2-O_cor"

mb = cell(nsub,length(seq));
mv = cell(nsub,length(seq));
counter = 1;
figure()


mc = cell(nsub,length(seq));

for ss = 1:nsub
    data = all_data(ss).subj;    
    for qq = 1:length(seq)
        subplot(nsub,length(seq),counter)
        

        temp = cell2mat(data(qq).value);
        eachdata = reshape(temp,[3,4])'; % row is img, coloum is M1-M2, M1-O,M2-O 

        mc{ss,qq} = eachdata;
        meaned_data = mean(mc{ss,qq});
            
        bar(meaned_data)
        ylabel([subj{ss} ' correlaton']);
        if counter ==1
            title(['BOLD ' filtname]);
        elseif counter ==2
            title(['VASO ' filtname]);
        end
        
        if qq == 1
            ylim([-1 1])

        elseif qq ==2
            ylim([-1 1])

        end
        set(gca,'xticklabel',{'M1-M2','M1-O','M2-O'})
        counter = counter + 1;
                box off;
    end
    
    
end
% suptitle(['Layer ' filtname])
if saveflag ==1
    savename = [masterpath 'figures/layer_profile/' 'corr_mean_' filtname '.png'];
    saveas(gcf,savename)
end
%%
figure()
cols=cbrewer('qual','Set2',3);
counter=1;


for ss = 1:nsub
    for qq = 1:length(seq)
        subplot(nsub,length(seq),counter)
        
        b= bar(mc{ss,qq},'FaceColor','flat');
        
        for eb = 1:3
            b(eb).FaceColor = cols(eb,:);
        end
        
        if counter ==1
            title(['BOLD ' filtname]);
        elseif counter ==2
            title(['VASO ' filtname]);
        end
          
        if qq == 1
            ylim([-1 1])
        elseif qq ==2
            ylim([-1 1])
        end
        
        ylabel([subj{ss} ' correlaton']);
        set(gca,'xticklabel',{'Image1','Image2','Image3','Image4'})
        box off;

        counter = counter + 1;
            
            
            
    end
end
% suptitle(['Layer ' filtname])
hl = legend({'M1-M2','M1-O','M2-O'},'Location','north','Orientation','horizontal', ...
    'FontSize',7);
legend boxoff                  

if saveflag ==1

savename = [masterpath 'figures/layer_profile/' 'corr_each_' filtname '.png'];
saveas(gcf,savename)
close all

end

% legend({'M1','M2','original'},'Location','north')
% legend('boxoff')
% 
% 
% savename = [masterpath 'figures/layer_profile/BOLD_each_image.png'];
% saveas(gcf,savename)
% 

% you are stessing me out due to your presence ...
% althouh I said nothing.
