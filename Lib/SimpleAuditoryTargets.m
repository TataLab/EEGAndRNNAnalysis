%a simple "experiment" to demonstrate auditory ERP and event-related
%spectral perturbation

eeg=1;  %flag to toggle on setup for netstation

if(eeg)
netstationHost='142.66.137.15';
NetStation('Connect',netstationHost); %initialize a connection to the acquisition software
NetStation('Synchronize');
NetStation('StartRecording');
end

commandwindow;  %make sure focus is on the command window so we don't get keypresses sneaking into anything anywhere
ListenChar(2); %suppress keyboard events to the command window

%some parameters
kNumTrials = 25;
kNumBlocks = 1;
kNumTargets=5;
kNumNontargets=20; %kNumTargets + kNumNontargets should = kNumTrials

if(kNumTargets+kNumNontargets)~=kNumTrials display('Error.  Try adding again.');end;

kTargFreq = 1000;
kNonTargFreq=600;
kSampleRate = 44100;
kNumSamplesInRamps = floor(kSampleRate*0.01);  %a 5 millisecond onset and offset ramp
interStimInterval = 2.5;  %time in seconds to wait between the onsets of each tone  ... 2.5 seconds should be good...plenty of time to respond but it keeps the experiment going quickly...note the time between the offset of one tone and the onset of the next will be interStimInterval - the tone duration


%Event Lists
%This could be preallocated if you don't need access to the events list
%during the session
targetEvents = uint64(zeros(2,kNumTargets)); %hold the time stamps of events in row 1 and whether the subject pressed a key in row 2
nontargetEvents=uint64(zeros(2,kNumNontargets));
targetEventIndex = 0; %keep track of where to put target event times and responses
nontargetEventIndex=0; %keep track of where to put nontarget event times and responses


%**********Build the target and nontarget signals*************
t=0:2*pi/kSampleRate:2*pi; %1 second time vector
t(end) = []; %we don't actually want 44101 samples so trim this last sample
onramp = linspace(0,1,kNumSamplesInRamps); %a 5millisecond onset ramp
offramp = linspace(1,0,kNumSamplesInRamps);%a 5 millisecond offset ramp


%the target
targSignal=sin(kTargFreq*t); 
targSignal=(targSignal-mean(targSignal))/abs(max(targSignal)); %zero it and scale between -1 and +1 (convenient to leave this step for cases when noise is added)
targSignal(1: kNumSamplesInRamps) = targSignal(1: kNumSamplesInRamps)  .* onramp; %now it's got a nice  ramp at either end to avoid transients
targSignal(length(targSignal) - kNumSamplesInRamps+1: end) = targSignal(length(targSignal) - kNumSamplesInRamps+1: end)  .* offramp; %now it's got a nice gaussian ramp at either end to avoid transients

%targSignal(2,:) = zeros(1,length(targSignal(1,:))); %copy it to the other channel
targSignal(2,:) = targSignal(1,:); %copy it to the other channel

%the nontarget
nontargSignal=sin(kNonTargFreq*t); %the sine signal at 6 hz with some noise added
nontargSignal=(nontargSignal-mean(nontargSignal))/abs(max(nontargSignal)); %zero it and scale between -1 and +1 (convenient to leave this step for cases when noise is added)
nontargSignal(1: kNumSamplesInRamps) = nontargSignal(1: kNumSamplesInRamps)  .* offramp; %now it's got a nice gaussian ramp at either end to avoid transients
nontargSignal(length(nontargSignal) - kNumSamplesInRamps+1: end) = nontargSignal(length(nontargSignal) - kNumSamplesInRamps+1: end)  .* offramp; %now it's got a nice gaussian ramp at either end to avoid transients

%nontargSignal(2,:) = zeros(1,length(nontargSignal(1,:))); %copy it to the other channel
nontargSignal(2,:) = nontargSignal(1,:); %copy it to the other channel
%******************************


%******Set up Audio**************

%we'll be using the PsychSound routines in Psychophysics Toolbox

%initialize psych sound
InitializePsychSound;
targAudioHandle = PsychPortAudio('open',[],[],0,kSampleRate,2); %configure the audio hardware
nontargAudioHandle = PsychPortAudio('open',[],[],0,kSampleRate,2); %configure the audio hardware
readyAudioHandle = PsychPortAudio('open',[],[],0,kSampleRate,2); %configure the audio hardware

PsychPortAudio('FillBuffer',targAudioHandle,targSignal); %load the target signal
PsychPortAudio('FillBuffer',nontargAudioHandle,nontargSignal); %load the target signal


pause(1); %give the hardware a moment

 %call start and stop on the port to "prime it"


 display('Initializing audio buffers');
 PsychPortAudio('Start',targAudioHandle,1,[],[],[],[]); %start playback
PsychPortAudio('Stop',targAudioHandle,1,0,[],[]); %schedule to stop playback when last sample is reached

pause(1); %give the hardware a moment

%call start and stop on the port to "prime it"
PsychPortAudio('Start',nontargAudioHandle,1,[],[],[],[]); %start playback
PsychPortAudio('Stop',nontargAudioHandle,1,0,[],[]); %schedule to stop playback when last sample is reached
pause(1); %give the hardware a moment

%*******************************

display('Audio ready');
pause(1);

clc; %clear the display
display('In this experiment you will press the "t" key when you hear a "target" sound.');
display('Do not press anything if you hear other sounds.');
display('Press the "t" key now to hear the target.  Press the "s" key to start the experiment');

isBlocked  = 1; %wait for a keypress

while isBlocked ==1;
    KbWait;
    [~,~,keyCode] = KbCheck; %get recent keycode
    
    if strcmp(KbName(keyCode),'t')
        
        %call start and stop on the target sound
        PsychPortAudio('Start',targAudioHandle,1,[],[],[],[]); %start playback
        PsychPortAudio('Stop',targAudioHandle,1,0,[],[]); %schedule to stop playback when last sample is reached

        pause(1); %give the hardware a moment
        
        clc; %clear the display
        
        
    elseif   strcmp(KbName(keyCode),'s')
        isBlocked=0;
        clc; %clear the display
        display('Get Ready')
        pause(2);
    end
    
    
    
end

%************Run some blocks**************



%generate a  vector to control what kind of stimulus to display 
 targetVector = [];
 targetVector(1:kNumTargets) = ones(1,kNumTargets); %start with the targets
 targetVector(kNumTargets+1:kNumTrials) = zeros(1,kNumNontargets);

 for blockNum = 1:kNumBlocks
clc;%clear the display


targetVector=Shuffle(targetVector); %shuffle the vector controlling which stimulus to display on each trial    
    
pause(2.5);
      
    isBlocked = 0; %we'll use this to control experiment flow
    
    for trialNum=1:kNumTrials
        
        %decide if this trial should be a target or non target
        
        if targetVector(trialNum) == 1 % target
            targetEventIndex = targetEventIndex +1; %increment the target event index
            targetEvents(1,targetEventIndex) = uint64(tic);
            trigTime=PsychPortAudio('Start',targAudioHandle,1,[],1,[],[]); %start playback
            NetStation('Event','targ', trigTime); %send a trigger
            display(['Sent trigger targ at time ' num2str(trigTime)]);
    
        elseif targetVector(trialNum) == 0 %a non-target
            nontargetEventIndex = nontargetEventIndex +1; %increment the nontarget event index
            nontargetEvents(1,nontargetEventIndex) = uint64(tic);
            trigTime=PsychPortAudio('Start',nontargAudioHandle,1,[],1,[],[]); %start playback
            NetStation('Event','ntrg', trigTime); %send a trigger
            display(['Sent trigger ntrg at time ' num2str(trigTime)]);

        else
            
            display('you have a problem');  %something is wrong, you shouldn't ever get in here
            
        end
        
        keepLooping  = 1; %wait for the interStimInterval
        
        
        %scan for a keypress event and flag row 2 of the appropriate event
        %list
        
        %a timer:
        
        sTime = tic; %grab the current time
        while keepLooping ==1;
            
            if toc(sTime) > interStimInterval %keep comparing the current time to the start time and exit the loop if the ISI is elapsed (tic and toc are nice, eh)
                keepLooping = 0;
            end
            
            %handle whatever the subject does on the keyboard
            [~,~,keyCode,~] = KbCheck; %get most recent keycode
            if strcmp(KbName(keyCode),'t'); %if the keyCode vector has a "t" in it
                if targetVector(trialNum) == 1; %flag the target event list to indicate that a response was made (i.e. this is a correct-response trial also called a "hit")
                    targetEvents(2,targetEventIndex) = 1;
                elseif targetVector(trialNum) == 0; %flag the nontarget event list to indicate that a response was made (i.e. this is a kind of error called a "false alarm")
                    nontargetEvents(2,nontargetEventIndex)=1;
                end
            end
        end
        
       
        
        clc;  %keep clearing the display
        
        
    end %%%%%%%%%%%  end of the trial loop  %%%%%%%%%%
        
    %if we haven't done all the blocks then this is a rest, otherwise carry
    %on and get out of this loop
   
    if blockNum<kNumBlocks
       clc;%clear the display
        display('This is a rest break.  Press the s key to start again');
    
        isBlocked = 1;
         
        while isBlocked ==1;
            KbWait;
            [~,~,keyCode] = KbCheck; %get recent keycode
            
            if strcmp(KbName(keyCode),'s'); isBlocked=0; end; %compare and unblock if necessary
        end
    else
        clc; %clear the display
        display('You are done.  Thanks');
    end

 end %%%%%%%  end of the block loop  %%%%%%%%%%

PsychPortAudio('Close', targAudioHandle);
PsychPortAudio('Close', nontargAudioHandle);
PsychPortAudio('Close', readyAudioHandle);


%write the event lists to files

fid=fopen('targetEvents.tim','w');
fwrite(fid,targetEvents','uint64'); %transpose because fwrite works on columns, this will write all the times then all the response flags,  parse it when you fread later
fclose(fid);

fid=fopen('nontargetEvents.tim','w');
fwrite(fid,nontargetEvents','uint64');%transpose because fwrite works on columns, this will write all the times then all the response flags, parse it when you fread later
fclose(fid);

%%%%% cleanup
NetStation('StopRecording');
NetStation('Disconnect');

ListenChar(0); %reenable keyboard events to the command window