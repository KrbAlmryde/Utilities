function [] = RussEventfMRI()
    %PsychPortAudio('close')
    %% Basic config
    NumberOfTrials = 140;
    StimulusPath='/home/kyle/stimuli/';
    StimulusList=dlmread('mystimuli.txt'); % if it's delimited... otherwise readtext(), etc.
    TriggerSymbol='t';
    TR=3000;
    TrialStimDelay=2000; % let's assume that we're presenting a stimulus 2 seconds into the scan instead of at 0.
    %% Read in stimuli
    for i=1:NumberOfTrials % read in the actual audio data
        [BufferedAudioFiles{i},Fs] = wavread([StimulusPath StimulusList(i)]);
    end
    %% Configure and initialize sound stuff
    InitializePsychSound;
    [AudioStim,fs] = wavread(audio);
    nchannels = 1;
    pahandle = PsychPortAudio('Open', 2, [], 2, fs, nchannels);
    %SoundDur=size(AudioStim,1)/fs; % duration of sound in secs

    %% Open up window (we do this early so we can buffer up the text "images")
    %Resolutions = Screen('Resolutions',0);
    %Resolution.choice=24; % This is an 800x600 setting, but is likely machine specific.
    %oldResolution=Screen('Resolution', 0, Resolutions(Resolution.choice).width, Resolutions(Resolution.choice).height,Resolutions(Resolution.choice).hz,Resolutions(Resolution.choice).pixelSize);
    [DisplayWindow]=Screen('OpenWindow', 0,0); % This is what's shown onscreen.
    %w.buffer=Screen('OpenOffScreenWindow',w.w,0,w.rect); % This is where we'll store our buffer.
    HideCursor;

    trigger=false;
    while ~trigger % wait for trigger
        [trigger]=PsychHID('KbCheck',[],[]); % fix my last parameters
        % also look for q (to quit)
        %scanlist=zeros(1,256);scanlist(84)=1;keyIsDown=false,pause(0.05),while ~keyIsDown,[keyIsDown, keyTime, keyCode, deltaSecs] = KbCheck([],scanlist), end
    end

    StartTime=GetSecs; % mark the onset of the scanner trigger (onset of first volume)
    PlaySoundTime=StartTime; % marks the time to play the first sound!
    EndOfTR=StartTime+TR; % i.e. 3000
    for trials=1:NumberOfTrials
        t = PsychPortAudio('FillBuffer', pahandle, AudioStim'); % fill the buffer
        PlaySoundTime=PlaySoundTime+TrialStimDelay; % increase this play time by the stim delay
        EndOfTR=EndOfTR+TR;
        while GetSecs < PlaySoundTime, end; % hang until those two seconds elapse...
            PsychPortAudio('Start', pahandle, 1, 0, 1); % Play the sound....
        while GetSecs < EndOfTR, end; % wait for the TR to "finish"
        % the sound should be done by now, but we'll hard code a stop if need by..
    end

%     while getsecs <= endtime; % sound is playing
%         Screen('FillRect',w.buffer,[255 255 255],w.rect); % clean up
%         if CurTag < numel(TagList)
%             if GetSecs > starttime + TagList(CurTag+1).start
%                 Screen(w.buffer,'TextSize',CurFont)
%                 Screen(w.w,'TextSize',CurFont)
%             elseif GetSecs > starttime + TagList(CurTag).end
%                 Screen('FillRect',w.buffer,[255 255 255],w.rect); % clean up
%                 Screen('CopyWindow',w.buffer,w.w,w.rect,w.rect); % Copy buffer to onscreen window
%                 onsettime = Screen('Flip',w.w); % Unveil BLANK
%             elseif GetSecs > starttime + TagList(CurTag).start
%                 Screen('FillRect',w.buffer,[255 255 255],w.rect); % clean up
%                 DrawFormattedText(w.buffer, TagList(CurTag).title, 'center', 'center');
%                 Screen('CopyWindow',w.buffer,w.w,w.rect,w.rect); % Copy buffer to onscreen window
%                 onsettime = Screen('Flip',w.w); % Unveil BLANK
%             end
%         end
%     end
    %% Clean up parsimoniously
    PsychPortAudio('close')
%   Screen('CloseAll') % Close screen
end
