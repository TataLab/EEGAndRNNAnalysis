% This code prepare useroptions for the EEG data and all layers of the Network
% @ June 2020
%% Initialisation %%
%%%%%%%%%%%%%%%%%%%%
clc; clear; close all
toolboxRoot = '/Volumes/EEGlab_SH/Saeedeh/rsatoolbox-develop/';
MatlabRoot = '/Volumes/EEGlab_SH/Saeedeh/Saeedeh_Lukas/';
addpath(genpath(toolboxRoot));
addpath(genpath(MatlabRoot));
addpath(genpath('/Volumes/EEGlab_SH/Saeedeh/lib'))

Net = input('Which Network you are ineterested in(1 for TrianedNet, 2 for RandomNet, 3 for PhonemeNet)?'); % 1 for TrianedNet, 2 for RandomNet, 3 for PhonemeNet
if Net == 1
    load('AllStimuliforExp2WithAllEmbeddings')  % For the trained network
elseif Net == 2
    load('AllStimuliforExp2WithAllEmbeddingsRandomNetwork') % For the network that is not trained.
elseif Net ==3
    load('AllStimuliforExp2WithAllEmbeddingsPhonemeNetwork') % For the phonemely-trained network
end
%% Some variables
cd([MatlabRoot 'Data'])
savedFileNames = {'TrainedNetVariables','RandomNetVariables','PhonemeNetVariables'};
load(savedFileNames{Net})
FolderNames = {'TrainedNet','RandomNet','PhonemeNet'};
for lay = 1:num_layers
    cd([MatlabRoot 'Result/RSA/Network_RDMs/' FolderNames{Net}])
    mkdir(['Net_Lay' LayerNames{lay} '_RDMs'])
end
num_stim = 25;
conditionLabels = cell(1,num_stim);
for stim = 1:num_stim
    conditionLabels{1,stim} = ['stim' num2str(stim)];
end
cte = 0; subjectNames = cell(1,15);  % EEG var: 
for subj = [1,3:16]
    cte = cte+1;
    subjectNames{1,cte} = ['subject' num2str(subj)];
end
%% userOptions_common
cd(toolboxRoot);
% Generate a userOptions structure and then change the parameters based of our ineterest.
userOptions_common = projectOptions_demo();

% it says that run the analysis everytime runing this code, even if you have ran and saved it before.
% Remember it will over-write the saved files. Put 'S' instead of 'R', if you don't wanna run it again. 
userOptions_common.forcePromptReply = 'R';
userOptions_common.analysisName = 'EEGandNet';
userOptions_common.rootPath = [MatlabRoot 'Result/RSA'];  % The result path
userOptions_common.conditionLabels = conditionLabels;
userOptions_common.alternativeConditionLabels = cell(1,num_stim);
userOptions_common.conditionColours = linspecer(num_stim);
userOptions_common.convexHulls = 1:num_stim;
% colourScheme ?????????
userOptions_common.colourScheme = zeros(num_stim,3);

%% %%%%%%%%%%%% userOptions for EEG %%%%%%%%%%%%%%%%%

% Change the fields in the userOptions based on our data
userOptions_EEG = userOptions_common;
userOptions_EEG.forcePromptReply = 'S'; % Do not repeat the analysis if the results are already saved
userOptions_EEG.analysisName = 'EEG';
userOptions_EEG.rootPath = [MatlabRoot 'Result/RSA/EEG_RDMs'];  % The result path
userOptions_EEG.betaPath = '/Volumes/EEGlab_SH/Saeedeh/ShwetasData/Beta_SubjectFolders/[[subjectName]]/[[betaIdentifier]]';
userOptions_EEG.subjectNames = subjectNames;
userOptions_EEG.RDMname = 'EEG_RDM';

%% %%%%%%%%%%%% userOptions for Network %%%%%%%%%%%%%%%%%
% Layer 1
userOptions_Net_1 = userOptions_common; 
userOptions_Net_1.analysisName = [FolderNames{Net} '_Lay1'];
userOptions_Net_1.rootPath = [MatlabRoot 'Result/RSA/Network_RDMs/' FolderNames{Net} '/Net_Lay1_RDMs'];  % The result path
userOptions_Net_1.betaPath = [MatlabRoot 'Result/RSA/Network_Betas/' FolderNames{Net} '/Net_Lay1_Betas/[[betaIdentifier]]'];
userOptions_Net_1.subjectNames = {'noSubject'};
userOptions_Net_1.RDMname = [FolderNames{Net} '_Lay1_RDM'];
% Layer 2
userOptions_Net_2 = userOptions_common; 
userOptions_Net_2.analysisName = [FolderNames{Net} '_Lay2'];
userOptions_Net_2.rootPath = [MatlabRoot 'Result/RSA/Network_RDMs/' FolderNames{Net} '/Net_Lay2_RDMs'];  % The result path
userOptions_Net_2.betaPath = [MatlabRoot 'Result/RSA/Network_Betas/' FolderNames{Net} '/Net_Lay2_Betas/[[betaIdentifier]]'];
userOptions_Net_2.subjectNames = {'noSubject'};
userOptions_Net_2.RDMname = [FolderNames{Net} '_Lay2_RDM'];
% Layer 3
userOptions_Net_3 = userOptions_common; 
userOptions_Net_3.analysisName = [FolderNames{Net} '_Lay3'];
userOptions_Net_3.rootPath = [MatlabRoot 'Result/RSA/Network_RDMs/' FolderNames{Net} '/Net_Lay3_RDMs'];  % The result path
userOptions_Net_3.betaPath = [MatlabRoot 'Result/RSA/Network_Betas/' FolderNames{Net} '/Net_Lay3_Betas/[[betaIdentifier]]'];
userOptions_Net_3.subjectNames = {'noSubject'};
userOptions_Net_3.RDMname = [FolderNames{Net} '_Lay3_RDM'];
% Layer RNN
userOptions_Net_RNN = userOptions_common; 
userOptions_Net_RNN.analysisName = [FolderNames{Net} '_LayRNN'];
userOptions_Net_RNN.rootPath = [MatlabRoot 'Result/RSA/Network_RDMs/' FolderNames{Net} '/Net_LayRNN_RDMs'];  % The result path
userOptions_Net_RNN.betaPath = [MatlabRoot 'Result/RSA/Network_Betas/' FolderNames{Net} '/Net_LayRNN_Betas/[[betaIdentifier]]'];
userOptions_Net_RNN.subjectNames = {'noSubject'};
userOptions_Net_RNN.RDMname = [FolderNames{Net} '_LayRNN_RDM'];
% Layer 5
userOptions_Net_5 = userOptions_common; 
userOptions_Net_5.analysisName = [FolderNames{Net} '_Lay5'];
userOptions_Net_5.rootPath = [MatlabRoot 'Result/RSA/Network_RDMs/' FolderNames{Net} '/Net_Lay5_RDMs'];  % The result path
userOptions_Net_5.betaPath = [MatlabRoot 'Result/RSA/Network_Betas/' FolderNames{Net} '/Net_Lay5_Betas/[[betaIdentifier]]'];
userOptions_Net_5.subjectNames = {'noSubject'};
userOptions_Net_5.RDMname = [FolderNames{Net} '_Lay5_RDM'];
% Layer 6
userOptions_Net_6 = userOptions_common; 
userOptions_Net_6.analysisName = 'TrainedNet_Lay6';
userOptions_Net_6.rootPath = [MatlabRoot 'Result/RSA/Network_RDMs/' FolderNames{Net} '/Net_Lay6_RDMs'];  % The result path
userOptions_Net_6.betaPath = [MatlabRoot 'Result/RSA/Network_Betas/' FolderNames{Net} '/Net_Lay6_Betas/[[betaIdentifier]]'];
userOptions_Net_6.subjectNames = {'noSubject'};
userOptions_Net_6.RDMname = [FolderNames{Net} '_Lay6_RDM'];


% Concatenating the layers
userOptions_Net = userOptions_common; 
userOptions_Net.analysisName = [FolderNames{Net} '_allLayers'];
userOptions_Net.rootPath = [MatlabRoot 'Result/RSA/Network_RDMs/' FolderNames{Net} '/Net_allLayers'];  % The result path
userOptions_Net.betaPath = '';
userOptions_Net.subjectNames = {'Layer1','Layer2','Layer3','LayerRNN','Layer5','Layer6'};
userOptions_Net.RDMname = [FolderNames{Net} '_allLayers_RDMs'];
%% save
cd([MatlabRoot 'Result/RSA/userOptions'])
saveFileNames = {'TrainedNet','RandomNet','PhonemeNet'};
save([saveFileNames{Net} '_userOptions'],'userOptions_common','userOptions_EEG','userOptions_Net_1','userOptions_Net_2',...
'userOptions_Net_3','userOptions_Net_5','userOptions_Net_6','userOptions_Net_RNN','userOptions_Net')