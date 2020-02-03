%%  Behaviour Data Post Processing
% emat(:,1) :: imgNum
% emat(:,2) :: Img Sequance //  1:object1 2: object2 3:animate1 4:animate1
% emat(:,3) :: image Category // 0 object / 1 human / 2 animal
% emat(:,4) :: accuracy
% emat(:,5) :: second response

clear;
tempSubs={'YYH','IGY','YJY','SSH'};

subName='LYR';
genDir = '/Users/insubkim/Documents/experiment/mooney/';
addpath(genpath('/Users/insubkim/Documents/experiment/mooney/mooney_script'))

dataDir = fullfile(genDir,'behavior',subName);

dataGrab = getAllFiles(dataDir,'*.mat',1);
for eN=1:length(dataGrab)
    FileNames=strsplit(dataGrab{eN},'_');
    load(dataGrab{eN})
    runNum=strsplit(FileNames{end},'.mat');
    data(eN).subject=FileNames{2};
    data(eN).name=FileNames{end-1};
    data(eN).run=str2num(runNum{1});
    data(eN).emat=emat;
    
    
    category = {'animate1','animate2','inanimate1','inanimate2'};
    
    trLen = 4;
    ImgLen=trLen*4;
    RstLen=trLen*4;
    repetition = 4;
    
    trialDur=(ImgLen+RstLen);
    nTrials = repetition*length(category);
    TotalDur=(trialDur*nTrials+RstLen)/60; % in secs
    TotalTR=(trialDur*nTrials+RstLen)/trLen; % in secs
    
    
    StimDur=ImgLen;
    TimeSeq= [0:StimDur:TotalDur*60];
    On=[]; Off=[];
    
    %TimeMat
    TimeMat.OffTime = TimeSeq(1:2:end)';
    TimeMat.OnTime = TimeSeq(2:2:end-1)';
    emat(:,end+1)=TimeMat.OnTime;
    
    accCut=50;
    pemat{1}=emat;
    pemat{2}=emat(emat(:,4)>accCut,:); % high Accuracy Only
    
    %imageWise
    for tt=1:2
        Img=unique(emat(:,1));
        ImgWiseMat=[];
        for i = 1:length(Img)
            OnTemp=pemat{tt}(:,5);
            ImgWiseMat{i,1}=OnTemp(find(pemat{tt}(:,1)==Img(i)))';
        end
        ImgTimeMat{tt}=ImgWiseMat;
        TimeMat.ImgNum=Img';
        TimeMat.Img = ImgTimeMat;
        
        %CategoryWise
        cat=unique(emat(:,3));
        if max(cat) == 1
            CatNames={'object', 'human'};
        else
            CatNames={'object', 'animal'};
        end
        catWiseMat=[];
        
        for i = 1:length(cat)
            OnTemp=pemat{tt}(:,5);
            catWiseMat{i,1}=OnTemp(find(pemat{tt}(:,3)==cat(i)))';
        end
        catTimeMat{tt}=catWiseMat;
        
        TimeMat.catName=CatNames;
        TimeMat.cat=catTimeMat;
        
        
    end
    data(eN).time=TimeMat;
end

%% Save

onName = fullfile(sprintf('on.txt'));
offName = fullfile(sprintf('off.txt'));

onfid = fopen(onName,'w');
offfid = fopen(offName,'w');
fprintf(onfid,[repmat('%f ',1,length(data(1).time.OnTime)),'\n'],data(1).time.OnTime);
fprintf(offfid,[repmat('%f ',1,length(data(1).time.OffTime)),'\n'],data(1).time.OffTime);
fclose('all');

NumImg=sort(data(1).time.ImgNum);

imgSaveName = fullfile(dataDir,sprintf('%s_ImgList.txt',data(1).subject));
fid = fopen(imgSaveName,'w');
fprintf(fid,[repmat('%d ',1,length(NumImg)),'\n'], NumImg');
fclose('all');


%%
for i = 1:length(data)
    if strcmp(data(i).name,'original')
        oriRuns(i)=data(i).run;
        minOri=min(nonzeros(oriRuns));
        maxOri=max(nonzeros(oriRuns));
        
    end
end
%%
ImgList=[];
Original_ImgList=[]; mooney_ImgList=[]; mooney_ImgList2=[];
for i = 1:length(data)
    for ee =1:length(data(1).time.Img{1})
        if strcmp(data(i).name,'original')
            Original_ImgList{i,ee}=data(i).time.Img{1}{ee,:};
        elseif strcmp(data(i).name,'mooney') && data(i).run<minOri
            mooney_ImgList{i,ee}=data(i).time.Img{1}{ee,:};
        elseif strcmp(data(i).name,'mooney') && data(i).run>minOri
            mooney_ImgList2{i,ee}=data(i).time.Img{1}{ee,:};
        end
    end
end

%%
Original_ImgList=Original_ImgList(~cellfun(@isempty, Original_ImgList(:,1)), :);
mooney_ImgList=mooney_ImgList(~cellfun(@isempty, mooney_ImgList(:,1)), :);
mooney_ImgList2=mooney_ImgList2(~cellfun(@isempty, mooney_ImgList2(:,1)), :);
for ee =1:length(data(1).time.Img{1})
    markerFileName = fullfile(dataDir,sprintf('%s_%s_img%d.txt',data(1).subject,'mooney1',data(1).time.ImgNum(ee)));
    fid = fopen(markerFileName,'w');
    fprintf(fid,[repmat('%f ',1,length(Original_ImgList{1,1})),'\n'], mooney_ImgList{:,ee});
    markerFileName2 = fullfile(dataDir,sprintf('%s_%s_img%d.txt',data(1).subject,'original',data(1).time.ImgNum(ee)));
    fid2 = fopen(markerFileName2,'w');
    fprintf(fid2,[repmat('%f ',1,length(Original_ImgList{1,1})),'\n'], Original_ImgList{:,ee});
    markerFileName3 = fullfile(dataDir,sprintf('%s_%s_img%d.txt',data(1).subject,'mooney2',data(1).time.ImgNum(ee)));
    fid3 = fopen(markerFileName3,'w');
    fprintf(fid3,[repmat('%f ',1,length(Original_ImgList{1,1})),'\n'], mooney_ImgList2{:,ee});
    fclose('all');
end
%%
MatA{1}=cell2mat(Original_ImgList);
MatA{2}=cell2mat(mooney_ImgList);
MatA{3}=cell2mat(mooney_ImgList2);

for i =1:length(MatA)
    half=length(MatA{i})/2;
    category1{i} =MatA{i}(:,1:half);
    category2{i} =MatA{i}(:,half+1:end);
end


for tt =1:length(category1)
    if tt ==1
        markerFileName1 = fullfile(dataDir,sprintf('%s_%s_%s.txt',data(1).subject,'original',data(1).time.catName{1}));
        markerFileName2 = fullfile(dataDir,sprintf('%s_%s_%s.txt',data(1).subject,'original',data(1).time.catName{2}));
        
    elseif tt==2
        markerFileName1 = fullfile(dataDir,sprintf('%s_%s_%s.txt',data(1).subject,'mooney1',data(1).time.catName{1}));
        markerFileName2 = fullfile(dataDir,sprintf('%s_%s_%s.txt',data(1).subject,'mooney1',data(1).time.catName{2}));
        
    else tt==3
        markerFileName1 = fullfile(dataDir,sprintf('%s_%s_%s.txt',data(1).subject,'mooney2',data(1).time.catName{1}));
        markerFileName2 = fullfile(dataDir,sprintf('%s_%s_%s.txt',data(1).subject,'mooney2',data(1).time.catName{2}));
    end
    fid1 = fopen(markerFileName1,'w');
    fid2 = fopen(markerFileName2,'w');
    
    fprintf(fid1,[repmat('%f ',1,length(category1{tt})),'\n'], category1{tt}');
    fprintf(fid2,[repmat('%f ',1,length(category2{tt})),'\n'], category2{tt}');
    fclose('all');
    
    
end

%%


%
% markerFileName = fullfile(dataDir,sprintf('%s_%s_img%d.txt',data(i).subject,data(i).name,data(i).time.ImgNum(1)))
% fid = fopen(markerFileName,'w');
% fprintf(fid,'%s\n',cellfun(@(x,:) x,Original_ImgList,'UniformOutput',false));
% fprintf(fid,'%s\n',double(cellfun(@(x) double(x),Original_ImgList,'UniformOutput',false)));
%
% fprintf(fID,[repmat('%f ',1,length(Original_ImgList{1,1})),'\n'], Original_ImgList{:,1});
% markerFileName = fullfile(dataDir,sprintf('%s_%s_run0%d_img%d.txt',data(i).subject,data(i).name,data(i).run,data(i).time.ImgNum(1)))
%
%     fID = fopen(markerFileName,'w');
%     fprintf(fID,[repmat('%f ',1,length(data(i).time.Img{1}{1,:})),'\n'],data(i).time.Img{1}{1,:}');



%
%     for ee =1:length(data(1).time.Img{1})
%         fID = fopen(markerFileName,'w');
%         fprintf(fID,[repmat('%f ',1,length(data(i).time.Img{1}{1,:})),'\n'],data(i).time.Img{1}{1,:}');
%     end
%
%

% fclose(fID);

