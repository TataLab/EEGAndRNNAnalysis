% This code reads the file that contains spearman corrcoefs between all eeg
% electrodes and all network layers of trianed and random networks and
% comapres the trained net with random net to finds electrodes with
% significant corr coefs in each layer

clc;clear;close all
toolboxRoot = '/Volumes/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))
%% Variables %%
%%%%%%%%%%%%%%%
num_subj = 16;      % EEG var: Native speakers only
num_rep = 4;        % EEG var: number of repetitions (which will be assumed as session later in the RDM analysis)
num_stim = 25;      % EEG var
num_trials = 100;   % EEG var
trial_length = 8.5; % EEG var: unit(sec)
num_chnl = 128;     % EEG var
num_sh = 100;
num_lay = 5;
LayerName = {'Layer 1','Layer 2','Layer 3','Layer RNN','Layer 5'};
load([MatlabRoot 'Result/RSA/Statistics/corrMats_AllEEGelecs_TrainedNet_RandNet100.mat'])

%% Main %% Ran and saved once
%{
% each 23 x 23 matrix of corrMat_EEG_TrainedNet{ch,1} is arranged as below:
% layer 1, layer 2, ... layer 6, avg_layers, subj 1, subj 3, ..., subj 16, avg_subj 
[h,p] = deal(zeros(num_lay,num_chnl));
ci = zeros(2,num_lay,num_chnl);
stats = cell(num_lay,num_chnl);
for ch = 1:num_chnl
    for lay = 1:num_lay
        x = corrMat_EEG_TrainedNet{ch,1}(lay,8:22);
        y = zeros(1,numel(8:22));
        for sh = 1:num_sh
            y = y + corrMat_EEG_RandNet{ch,sh}(lay,8:22);
        end
        [h(lay,ch),p(lay,ch),ci(:,ch,lay),stats{lay,ch}] = ttest2(x,y);
    end
end
%}
%% save
cd('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/Result/RSA/EEGandNetwork_RDM_Comparison/AllElecs/OnlySigElecs')
save('ElecWithSigSpearmanCorrcoef','h','p','ci','stats')
%% Binning data
bin_boundaries = linspace(-.1,.6,100);
bins = bin_boundaries(1:99)+(bin_boundaries(2)-bin_boundaries(1))./2;
binnum = zeros(129,7);
for lay = 1:5
    x = EEG_TrainedNet(:,lay);
    x(129,:) = [];
    x(~logical(h(lay,:))) = 0;
    for bn = 1:98
        x(x>bins(bn) & x<bins(bn+1),1) = bin_boundaries(bn+1);
        x(x<bins(1)) = bin_boundaries(1);
        x(x>bins(end)) = bin_boundaries(end);
        bnEEG_TrainedNet(:,lay) = x;
        binnum(x>bins(bn) & x<bins(bn+1),lay) = bn;
    end
end
%% plot
Th = [chanlocs.theta];
Rd = [chanlocs.radius];
Thn = -Th + 90;

close all
width = 8;
height = width;
color = linspecer(100);

for lay = 1:num_lay
%     data = bnEEG_TrainedNet(:,lay);
%     data(129,:) = [];
%     data(~logical(h(lay,:))) = 0;
    hfig = figure('NumberTitle','off','Name',LayerName{lay}, ...
        'Units','inches','Position',[0.1,0.5,width,height],'Color','w');
    clf;
    % VREF and Com
    Thn(129) = 0; Thn(130) = 90;
    Rd(129) = 0; Rd(130) = mean(Rd([14,15,17,18,22]));
%     ax = subplot(2,4,[1,2,3,5,6,7]);
ax = axes('Units','inches','Position',[0.1,0.5,width-1,height-1]);
    for ch = 1:num_chnl
        hp = polar(ax,Thn(ch)*pi/180,Rd(ch),'.'); hold on
        %     set(hp,'MarkerSize',70,'Color',[0.6,1,1]*0.95)
        set(hp,'MarkerSize',70,'Color',color(binnum(ch,lay),:))
    end
    for ch = 129:130
        hp = polar(ax,Thn(ch)*pi/180,Rd(ch),'.'); hold on
        set(hp,'MarkerSize',70,'Color',[1,1,1]*0.95)
    end
    title({'Spearman Corcoef between EEG electrodes and' ,['layer ', LayerName{lay}, ' of trained network']})
    % polarscatter(Thn*pi/180,Rd,2)
    
    for k = 1:num_chnl+2
        x = Rd(k)*cosd(Thn(k));
        y = Rd(k)*sind(Thn(k));
        txtStr = sprintf('%d',k);
        if k == 129
            txtStr = 'VREF';
        elseif k == 130
            txtStr = 'Com';
        end
        text(x,y,txtStr,'FontSize',10,...
            'HorizontalAlignment','center','VerticalAlignment','middle')
    end
    % VREF and Com
    axis image
    % colorbar
    ax = axes('Units','inches','Position',[width-0.60,height/2-1,.2,2]);
    image(ax,reshape(color,100,1,3));
    set(ax,'yTick',[],'xTick',[],'ydir','normal')
    yL = get(ax,'ylim'); dy = diff(yL); 
    xL = get(ax,'xlim'); dx = diff(xL);
    xt = mean(xL);
    yt = yL(1)-dy/20;
    txtStr = '-0.1';
    text(xt,yt,txtStr,'FontSize',12,...
        'HorizontalAlignment','center','VerticalAlignment','top')
    yt = yL(2)+dy/20;
    txtStr = '+0.6';
    text(xt,yt,txtStr,'FontSize',12,...
        'HorizontalAlignment','center','VerticalAlignment','baseline')
    % save
    cd('/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/Result/RSA/EEGandNetwork_RDM_Comparison/AllElecs')
    save_plot(gcf,['2D_ComparingSigEEG_and_TrainedNet_' LayerName{lay}])
end
%%
data = EEG_TrainedNet(1:128,1:num_lay);
data(~logical(h')) = 0;
