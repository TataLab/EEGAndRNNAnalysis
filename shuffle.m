%This is the code that Lukas used to shuffle the input of the network based
%on word or phonemes

shuffle_type = 'word';
dest_dir = strcat('stim_audio_shuffle_', shuffle_type, '_16');

disp(dest_dir);

if strcmp(shuffle_type, 'phn')
    sname = 'cnctPHN';
elseif strcmp(shuffle_type, 'word')
    sname = 'cnctWRD';
end
    
load('StimInfo.mat');

mkdir(dest_dir);

for i = 1:numel(StimInfoStruct)
    fprintf('processing: %i\n', i);
    
    stim = StimInfoStruct(i);
    
    raw_audio = stim.cnctStim;
    feats = stim.(sname);
    
    shuffled_inds = randperm(length(feats));
    
    shuffled_audio = [];
    
    for j =1:numel(shuffled_inds)
        st = feats{shuffled_inds(j), 1}+1;
        nd = min(feats{shuffled_inds(j), 2}+1, length(raw_audio));
        audio_seg = raw_audio(st:nd);
        shuffled_audio = [shuffled_audio, audio_seg.'];
    end
    
    disp(length(raw_audio));
    disp(length(shuffled_audio));
    
    shuffled_audio = shuffled_audio.';
    
    fp = sprintf(strcat(dest_dir, '/audio_%i.wav'), i);
    audiowrite(fp, shuffled_audio, 16000); 
end