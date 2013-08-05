function [] = KyleParadigm()
    %PsychPortAudio('close')
    %% Basic config
    NumberOfTrials = 140;
    StimulusPath='/usr/local/Utilities/russian/sounds/';
%     StimulusPath='D:\Documents and Settings\demarco\Desktop\kyleparadigm\sounds\';
    StimulusList=textread('stimulilist.txt','%s','delimiter','\n');
    TR=3.0000;
    TrialStimDelay=2.0000; % let's assume that we're presenting a stimulus 2 seconds into the scan instead of at 0.
    TriggerKey=KbName('t');
    QuitKey=KbName('q');
    %% Read in stimuli
    for i=1:NumberOfTrials % read in the actual audio data
        %exist(strcat(StimulusPath,StimulusList{i},'.wav'))
        if strcmp(StimulusList{i},'null') % if a line says "null"
            BufferedAudioFiles{i} = (0); % we'll call this an "empty" buffer (i.e. no sound played)
        else % otherwise read in the data (the last Fs read in will be used for all sounds)
            [CurSound,Fs] = wavread(strcat(StimulusPath,StimulusList{i},'.wav'));
            BufferedAudioFiles{i} = CurSound(1:min(numel(CurSound),Fs)); % only take at max the first second...
        end
    end
    %% Configure and initialize sound stuff
    InitializePsychSound;
    nchannels = 1;
    pahandle = PsychPortAudio('Open', 2, [], 2, Fs, nchannels);

    if 1 == 2 % if we want to use the screen...
        [DisplayWindow]=Screen('OpenWindow', 0,0); % This is what's shown onscreen.
        HideCursor;
        %Screen('FillRect',w.buffer,[255 255 255],w.rect); % clean up
    end
    trigger=0;
    while ~trigger % wait for trigger
        [trigger,StartTime,KeyCodes]=KbCheck; % fix my last parameters
        if isempty(intersect(find(KeyCodes),[TriggerKey QuitKey])) % any overlapping values?
            trigger=0; % (ignore this keypress and keep scanning)
        end
    end

    if find(KeyCodes) == QuitKey % then the user has aborted at the "hang screen -- QUIT."
        try PsychPortAudio('close'), end; % try to close the audioport
        try Screen('CloseAll'), end; % try to close the screen
        return; % kill the script, and go back to the command line.
    end

    EndOfTR=StartTime; % we'll increment this in each trial loop
    for trials=1:NumberOfTrials
        EndOfTR=EndOfTR+TR;
        PlaySoundTime=EndOfTR-(TR-TrialStimDelay);
        disp(['Volume ' num2str(trials) ' begins at ' num2str(GetSecs-StartTime)])
        t = PsychPortAudio('FillBuffer', pahandle, BufferedAudioFiles{trials}'); % fill the buffer
        while GetSecs < PlaySoundTime, end; % hang until those two seconds elapse...
        if numel(BufferedAudioFiles{trials}) > 1 % (i.e. if it's more than our fake 0 value from earlier)
            disp(['Sound began to play at ' num2str(GetSecs-StartTime)])
            PsychPortAudio('Start', pahandle, 1, 0, 1); % Play the sound....
        end
        while GetSecs < EndOfTR, end; % wait for the TR to "finish"
    end
   %% Clean up parsimoniously
   try PsychPortAudio('close'), end;
   try Screen('CloseAll'), end;
end