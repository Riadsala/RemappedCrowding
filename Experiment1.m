function Experiment1

addpath('scripts/');

trialsPerCondition = 10; % so total trials = this x 4 x 2 x nBlocks
nBlocks = 10;

% get subject number and randomise random seed
subjNum = input('input subject number: ');
RandStream('mt19937ar', 'Seed', subjNum);

% open file for writing results
fid = fopen(['results/' int2str(subjNum) '_results.txt'], 'w');
fprintf(fid, 'person blockN blockType trial flankerSide targetSide respG respC targOri saccStart targDisplayLat dotRemoveTimeStamp targOnTimeStamp targOffTimeStamp\n');

% get parameters for experiment
params = getParams;

%% Set-up stuff!
% set up screen
stimuliScrn = Screen('OpenWindow', 1, params.bkgrndColour);%
[params.width, params.height]=Screen('WindowSize', stimuliScrn); %screen returns the size of the window
params.midX = round(params.width/2);
params.midY = round(params.height/2);
% set up eyelink
iLink.edfdatafilename = strcat('cwdrmp', int2str(subjNum), '.edf');
iLink = InitEyeLink(iLink, stimuliScrn);
% change font
Screen('TextFont', stimuliScrn, 'Helvetica');
Screen('TextSize', stimuliScrn, 30);
Screen('TextColor', stimuliScrn, [255 255 255]);


%% some information and practise
RunIntro(params, iLink, stimuliScrn);
% now do some practise trials
nPrac = 10;
for pp = 1:nPrac
    doATrialP(0, params, 'none', stimuliScrn, iLink)
end
for pp = 1:nPrac
    if rand<0.5
        flankerCond = 'inner';
    else
        flankerCond = 'outer';
    end
    doATrialP(0, params, flankerCond, stimuliScrn, iLink)
end
%  practise eye movements
DisplayMessage('We will now practise making eye movements to the target square. Enjoy', params, stimuliScrn);
WaitSecs(1)
KbWait;
for pp = 1:nPrac
    doATrialE(1, params, 'none', stimuliScrn, iLink);
end
%         

%% RUN BLOCKS
blocks = repmat([1,2], [1,nBlocks]);
blkN = 0;
for blk = blocks
    blkN = blkN+1;
    
    % calibrate eyetracker
    EyelinkDoTrackerSetup(iLink.el);
    
    %% introduce and initalise block
    stim = 50 * ones(params.height, params.width, 3);
    stim(:,:,2) = 100;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    
    % display block intro message
     if blk == 1
        DrawFormattedText(stimuliScrn, strcat(int2str(blkN), ...
            ': Block condition: please fixate the target when dot vanishes'), 'center', 'center');
    else
        DrawFormattedText(stimuliScrn, strcat(int2str(blkN), ...
            ': Block condition: please keep fixating the fixation dot'), 'center', 'center');
    end
    Screen(stimuliScrn, 'flip');
    Screen('Close', tex);
    WaitSecs(1);
    KbWait;
 
    % create list of flanker conditions for each trial
    flankerCond = repmat({'both', 'inner', 'outer', 'none'}, [1, trialsPerCondition]);
    flankerCond = flankerCond(randperm(length(flankerCond)));
    
    % create empty arry of saccadic start times for this block
    saccStartTimes = [];
    
    %% Run a block
    for trl = 1:length(flankerCond)
        
        % run a trial
        [targSide, respG, respC, targOri, saccStart, t_dotRemove, t_targOn, t_targOff] = ...
            doATrial(blk, trl, params, flankerCond{trl}, stimuliScrn, iLink);
        
        % save trial data
        fprintf(fid, '%d %d %d %d %s %s %d %s %s %f %f %f %f %f\n', ...
            subjNum, blkN, blk, trl, flankerCond{trl}, targSide, respG, respC, targOri, saccStart, params.targetDisplayLatency, t_dotRemove, t_targOn, t_targOff);
        
        % update estimate of saccadic latency based on trial
        if isfinite(saccStart)
            saccStartTimes = [saccStartTimes, saccStart]; %#ok<AGROW>
            params.targetDisplayLatency = max(0.02, median(saccStartTimes)-0.1);
        end
    end
end

%% Display Thank-you message and end experiment
stim = 50 * ones(params.height, params.width, 3);
tex = Screen('MakeTexture', stimuliScrn, stim);
Screen('DrawTexture', stimuliScrn, tex);
DrawFormattedText(stimuliScrn, 'Thank you for your time!', 'center', 'center');
Screen(stimuliScrn, 'flip');
Screen('Close', tex);
WaitSecs(5);

%% clean-up
Eyelink('ReceiveFile',[iLink.edfdatafilename]);
fclose(fid);
Eyelink('Shutdown')
sca

end



