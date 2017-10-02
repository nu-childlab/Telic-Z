function [] = TelicZ()

%%%%%%FUNCTION DESCRIPTION
%TelicZ is a Telic experiment
%It is not finished
%It is meant for standalone use
%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('Preference', 'SkipSyncTests', 0);
close all;
sca
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
rng('shuffle');
KbName('UnifyKeyNames');

% cond=input('Condition m or c: ', 's');
% cond = condcheck(cond);
% cond2 =input('Condition e or o: ', 's');
% cond2 = cond2check(cond2);
subj=input('Subject Number: ', 's');
subj = subjcheck(subj);
list=input('List color: ', 's');
list = listcheck(list);

%%%%%%%%
%COLOR PARAMETERS
%%%%%%%%
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

%%%Screen Stuff

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
%opens a window in the most external screen and colors it)
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%Anti-aliasing or something? It's from a tutorial
ifi = Screen('GetFlipInterval', window);
%Drawing intervals; used to change the screen to animate the image
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
%The size of the screen window in pixels
[xCenter, yCenter] = RectCenter(windowRect);
%The center of the screen window

%%%%%%
%FINISHED PARAMETERS
%%%%%%
objectLoopTime = .75;
framesPerObjectLoop = round(objectLoopTime / ifi) + 1;

minSpace = 10;
%the minimum possible number of frames between steps

breakTime = .25;
%The number of seconds for each pause

displayTime = 3;
%number of seconds for which to display images

crossTime = 1;
%Length of fixation cross time

pauseTime = .5;
%Length of space between loops presentation

textsize = 22;
textspace = 1.5;

%Matlab's strings are stupid, so I have quotes and quotes with spaces in
%variables here
quote = '''';
squote = ' ''';

%%%%%%
%LISTS
%%%%%%

correlation_list = {'corr';'corr';'corr';'corr';'corr';'corr';'corr';...
    'corr';'corr';'corr';'anti';'anti';'anti';'anti';'anti';'anti';...
    'anti';'anti';'anti';'anti'};

correlation_continuous = [1, 2, 3, 4, 5];

if strcmp(list, 'test')
    trial_list = {[4 5; 5 4;]; [9 7; 7 9]};
    trial_list = [trial_list;trial_list];
    correlation_list = {'corr';'corr';'anti';'anti'};
elseif strcmp(list, 'blue')
    trial_list = {[4 5; 5 4;]; [4 6; 6 4]; [4 7; 7 4]; [4 8; 8 4]; [4 9; 9 4]; ...
        [9 4; 4 9]; [9 5; 5 9]; [9 6; 6 9]; [9 7; 7 9]; [9 8; 8 9]};
    trial_list = [trial_list;trial_list];  
	
elseif strcmp(list, 'pink')
    trial_list = {[5 6; 6 5]; [5 7; 7 5]; [5 8; 8 5]; [5 9; 9 5]; [4 9; 9 4]; ...
        [9 4; 4 9]; [8 4; 4 8]; [8 5; 5 8]; [8 6; 6 8]; [8 7; 7 8]};
    trial_list = [trial_list;trial_list];
    correlation_continuous = circshift(correlation_continuous, 1, 2);
elseif strcmp(list, 'green')
    trial_list = {[6 7; 7 6]; [6 8; 8 6]; [6 9; 9 6]; [5 9; 9 5]; [4 9; 9 4]; ...
        [9 4; 4 9]; [8 4; 4 8]; [7 4; 4 7]; [7 5; 5 7]; [7 6; 6 7]};
    trial_list = [trial_list;trial_list];
    correlation_continuous = circshift(correlation_continuous, 2, 2);
elseif strcmp(list, 'orange')
    trial_list = {[7 8; 8 7]; [6 8; 8 6]; [5 8; 8 5]; [4 8; 8 4]; [4 9; 9 4]; ...
        [9 4; 4 9]; [9 5; 5 9]; [8 5; 5 8]; [7 5; 5 7]; [6 5; 5 6]};
    trial_list = [trial_list;trial_list];
    correlation_continuous = circshift(correlation_continuous, 3, 2);
elseif strcmp(list, 'yellow')
    trial_list = {[4 9; 9 4]; [5 9; 9 5]; [6 9; 9 6]; [7 9; 9 7]; [8 9; 9 8]; ...
        [5 4; 4 5]; [6 4; 4 6]; [7 4; 4 7]; [8 4; 4 8]; [9 4; 4 9]};
    trial_list = [trial_list;trial_list];
    correlation_continuous = circshift(correlation_continuous, 4, 2);
end

shuff = randperm(length(trial_list));
trial_list = trial_list(shuff,:);
correlation_list = correlation_list(shuff);


%%%%%%%Screen Prep
HideCursor;	% Hide the mouse cursor
Priority(MaxPriority(window));

%%%%%%Shape Prep

theImageLocation = 'star.png';
[imagename, ~, alpha] = imread(theImageLocation);
imagename(:,:,4) = alpha(:,:);

% Get the size of the image
[s1, s2, ~] = size(imagename);

% Here we check if the image is too big to fit on the screen and abort if
% it is. See ImageRescaleDemo to see how to rescale an image.
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

% Make the image into a texture
starTexture = Screen('MakeTexture', window, imagename);


scale = screenYpixels / 10;%previously 15

vbl = Screen('Flip', window);

%%%%%%DATA FILES

initprint = 0;
if ~(exist('TelicZData.csv', 'file') == 2)
    initprint = 1;
end
%%%%NOTE TO SELF: Change saving first
dataFile = fopen('TelicZdata.csv', 'a');
subjFile = fopen([subj '.csv'],'a');
if initprint
    fprintf(dataFile, 'subj,trial,time,cond,stim,break,list,loops 1,loops 2,contrast,correlated?,total time 1,total time 2,size change 1,size change 2,contrast-continuous,response\n');
end
fprintf(subjFile, 'subj,trial,time,cond,stim,break,list,loops 1,loops 2,contrast,correlated?,total time 1,total time 2,size change 1,size change yellow 2,contrast-continuous,response\n');
lineFormat = '%s,%6.2f,%6.2f,%s,%s,%s,%s,%d,%d,%d,%s,%6.2f,%6.2f,%6.3f,%6.3f,%6.3f,%s\n';

%%%%%Conditions and List Setup

blockList = {'mass', 'count'};
eBlockList = blockList(randperm(length(blockList)));
oBlockList = blockList(randperm(length(blockList)));

imageFirst = {'object', 'object', 'event', 'event'};
imageFirst = imageFirst(randperm(length(imageFirst)));


correlated_values = [3, 3.75, 4.5, 5.25, 6, 6.75];
anticorrelated_values = [6.75, 6, 5.25, 4.5, 3.75, 3];

correlated_sizes = [4/8, 5/8, 6/8, 7/8, 1, 9/8];
anticorrelated_sizes = [9/8, 1, 7/8, 6/8, 5/8, 4/8];
%This is the amount by which to scale the drawings so that they fit with the
%correlated and anticorrelated sizes recorded on evernote


%%%%%%RUNNING
blockNumber = 0;
instructions(window, screenXpixels, screenYpixels, textsize, textspace)
c = 1;
eventTime = 0;
objectTime = 0;
count = 1;


% i don't even remember what this is for. I think tracking the total
% experiment blocks?
for type = imageFirst
    if strcmp(type, 'event') 
        eventTime = eventTime + 1;
        if eventTime == 1
            condition = eBlockList(1);
        else 
            condition = eBlockList(2);
        end
    else
        objectTime = objectTime + 1;
        if objectTime == 1
            condition = oBlockList(1);
        else
            condition = oBlockList(2);
        end       
    end
    
    if strcmp(condition,'mass')
           breakType = 'random';
        cond = 'mass';
    else
        breakType='equal';
        cond = 'count';
    end
    
    blockNumber = blockNumber + 1;
    blockInstructions(window, screenXpixels, screenYpixels, textsize, textspace, type, eventTime, objectTime, blockNumber)
%     %%%%%TRAINING
% %     if (strcmp(type, 'event') && eventTime == 1) || (strcmp(type, 'object') && objectTime == 1)
% 
% %t is just a trial counter
training_options = [4;5;6;7;8;9];
training_options = training_options(randperm(length(training_options)));
% only the first three numbers
training_options = training_options(1:3, :);
training_list = [training_options;training_options];
% disp(training_list);
training_correlation = {'corr'; 'corr'; 'corr'; 'anti'; 'anti'; 'anti'};
% training_shape = {'star'; 'star'; 'star'; 'star'; 'star'; 'star'};
    for t = 1:length(training_list)
      numberOfLoops = training_list(t);
      if strcmp(training_correlation{t}, 'corr')
          totaltime = correlated_values(numberOfLoops-3);
      else
          totaltime = anticorrelated_values(numberOfLoops-3);
      end

      training_image = starTexture;
      training_color = black;

      if t == 1
          phase = 1;
      elseif t == length(training_list)
          phase = 3;
      else
          phase = 2;
      end

      loopTime = totaltime/numberOfLoops;
      framesPerLoop = round(loopTime / ifi) + 1;
      if strcmp(type, 'object')
         trainObjectSentence(window, textsize, textspace, breakType, screenYpixels, phase)
         displayObjectLoops(numberOfLoops, framesPerObjectLoop, ...
             minSpace, scale, xCenter, yCenter, window, ...
             pauseTime, breakType, screenNumber, displayTime, black, 1)
      else
         trainSentence(window, textsize, textspace, phase, breakType, screenYpixels);        
         animateEventLoops(numberOfLoops, framesPerLoop, ...
             minSpace, scale, xCenter, yCenter, window, ...
             pauseTime, breakType, breakTime, screenNumber, training_image, ...
             ifi, vbl)
      end
    end
     if strcmp(type, 'object')
         testingObjectSentence(window, textsize, textspace, breakType, screenYpixels)
     else
         testingSentence(window, textsize, textspace, breakType, screenYpixels)
     end
% %      end
        %%%%%%RUNNING
    
    
     
    for x = 1:length(trial_list)
        
        %fixation cross
        fixCross(xCenter, yCenter, black, window, crossTime)
        
        %first stimulus
        trial = trial_list{x};
        trial = trial(randi([1,2]),:);
        numberOfLoops1 = trial(1);
        numberOfLoops2 = trial(2);
        contrast = abs(trial(1) - trial(2));
        if numberOfLoops1 < numberOfLoops2
            %If loops1 is smallest...
            if strcmp(correlation_list{x}, 'corr')
                %It takes the minimum spot on the correlation list
                totaltime1 = correlated_values(1);
                sizeChange1 = correlated_sizes(1);
                %The second one takes a spont based on the continuous
                %values assigned to the list
                totaltime2 = correlated_values(1+correlation_continuous(contrast));
                sizeChange2 = correlated_sizes(1+correlation_continuous(contrast));
            else
                %If anticorrelated, the opposite happens
                totaltime1 = anticorrelated_values(1);
                sizeChange1 = anticorrelated_sizes(1);
                totaltime2 = anticorrelated_values(1+correlation_continuous(contrast));
                sizeChange2 = anticorrelated_sizes(1+correlation_continuous(contrast));
            end
        else
            %If loops1 is smallest...
            if strcmp(correlation_list{x}, 'corr')
                %It takes the minimum spot on the correlation list
                totaltime1 = correlated_values(1);
                sizeChange1 = correlated_sizes(1);
                %The second one takes a spont based on the continuous
                %values assigned to the list
                totaltime2 = correlated_values(1+correlation_continuous(contrast));
                sizeChange2 = correlated_sizes(1+correlation_continuous(contrast));
            else
                %If anticorrelated, the opposite happens
                totaltime1 = anticorrelated_values(1);
                sizeChange1 = anticorrelated_sizes(1);
                totaltime2 = anticorrelated_values(1+correlation_continuous(contrast));
                sizeChange2 = anticorrelated_sizes(1+correlation_continuous(contrast));
            end
        end
                
        loopTime1 = totaltime1/numberOfLoops1;
        framesPerLoop1 = round(loopTime1 / ifi) + 1;
        
        loopTime2 = totaltime2/numberOfLoops2;
        framesPerLoop2 = round(loopTime2 / ifi) + 1;
   
        if strcmp(type, 'object')
           displayObjectLoops(numberOfLoops1, framesPerObjectLoop, ...
               minSpace, scale, xCenter, yCenter, window, ...
               pauseTime, breakType, screenNumber, displayTime, black, sizeChange1)
        else
           animateEventLoops(numberOfLoops1, framesPerLoop1, ...
             minSpace, scale, xCenter, yCenter, window, ...
             pauseTime, breakType, breakTime, screenNumber, starTexture, ...
             ifi, vbl)
        end
%         fixation cross
        fixCross(xCenter, yCenter, black, window, crossTime)
    
        %second animation

    
        if strcmp(type, 'object')
           displayObjectLoops(numberOfLoops2, framesPerObjectLoop, ...
               minSpace, scale, xCenter, yCenter, window, ...
               pauseTime, breakType, screenNumber, displayTime, black, sizeChange2)
        else
           animateEventLoops(numberOfLoops2, framesPerLoop2, ...
              minSpace, scale, xCenter, yCenter, window, ...
              pauseTime, breakType, breakTime, screenNumber, starTexture, ...
              ifi, vbl)
        end
        windowFraction1 = sizeChange1 / 5;
        windowFraction2 = sizeChange2 / 5;
        if strcmp(type, 'object')
            [response, time] = getResponse(window, screenXpixels, screenYpixels, textsize, type);
             
            fprintf(dataFile, lineFormat, subj, count, time*1000, cond, 'object', breakType, list, trial(1),...
               trial(2), abs(trial(1) - trial(2)),correlation_list{x},0, 0, windowFraction1, windowFraction2,...
               abs(windowFraction1-windowFraction2), response);
            fprintf(subjFile, lineFormat, subj, count, time*1000, cond, 'object', breakType, list, trial(1),...
               trial(2), abs(trial(1) - trial(2)),correlation_list{x},0, 0, windowFraction1, windowFraction2,...
               abs(windowFraction1-windowFraction2), response);
        
            
        else
          [response, time] = getResponse(window, screenXpixels, screenYpixels, textsize, type);
%         response = 'na';
%         time = 0;
         
           fprintf(dataFile, lineFormat, subj, count, time*1000, cond, 'event', breakType, list, trial(1),...
               trial(2), abs(trial(1) - trial(2)),correlation_list{x},totaltime1,totaltime2, 0, 0,...
               abs(totaltime1-totaltime2), response);
           fprintf(subjFile, lineFormat, subj, count, time*1000, cond, 'event', breakType, list, trial(1),...
               trial(2), abs(trial(1) - trial(2)),correlation_list{x},totaltime1,totaltime2, 0, 0,...
               abs(totaltime1-totaltime2), response);
        end
        count = count + 1;
     end
     if blockNumber ~= 4
           breakScreen(window, textsize, textspace);
     end
     c = c-1;

    
end
    %%%%%%Finishing and exiting

finish(window, textsize, textspace)
sca
Priority(0);
end













%%%%%ANIMATION FUNCTION%%%%%

function [] = animateEventLoops(numberOfLoops, framesPerLoop, ...
    minSpace, scale, xCenter, yCenter, window, ...
    pauseTime, breakType, breakTime, screenNumber, imageTexture, ...
    ifi, vbl)
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey = white/2;
    [xpoints, ypoints] = getPoints(numberOfLoops, framesPerLoop);
    totalpoints = numel(xpoints);
    Breaks = makeBreaks(breakType, totalpoints, numberOfLoops, minSpace);
    xpoints = (xpoints .* scale) + xCenter;
    ypoints = (ypoints .* scale) + yCenter;
    %points = [xpoints ypoints];
    pt = 1;
    waitframes = 1;
    Screen('FillRect', window, grey);
    Screen('Flip', window);
    while pt <= totalpoints
        destRect = [xpoints(pt) - 128/2, ... %left
            ypoints(pt) - 128/2, ... %top
            xpoints(pt) + 128/2, ... %right
            ypoints(pt) + 128/2]; %bottom
        
        % Draw the shape to the screen
        Screen('DrawTexture', window, imageTexture, [], destRect, 0);
        Screen('DrawingFinished', window);
        % Flip to the screen
        vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        pt = pt + 1;
        %If the current point is a break point, pause
        if any(pt == Breaks)
            WaitSecs(breakTime);
        end
        
    end
    Screen('FillRect', window, black);
    vbl = Screen('Flip', window);
    WaitSecs(pauseTime);
end

function [] = displayObjectLoops(numberOfLoops, framesPerLoop, ...
    minSpace, scale, xCenter, yCenter, window, ...
    pauseTime, breakType, screenNumber, displayTime, linColor, sizeChange)
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey = white/2;
    
    [xpoints, ypoints] = getPoints(numberOfLoops, framesPerLoop);
    totalpoints = numel(xpoints);
    Breaks = makeBreaks(breakType, totalpoints, numberOfLoops, minSpace);
    xpoints = (xpoints .* sizeChange);
    ypoints = (ypoints .* sizeChange);
    [xpoints, ypoints] = rotatePoints(xpoints, ypoints, framesPerLoop, Breaks);
    xpoints = (xpoints .* scale) + xCenter;
    ypoints = (ypoints .* scale) + yCenter;
    Screen('FillRect', window, grey);
    Screen('Flip', window);
    savepoint = 1;
    for p = 1:totalpoints - 2
        if ~any(p == Breaks) && ~any(p+1 == Breaks)
            Screen('DrawLine', window, black, xpoints(p), ypoints(p), ...
                xpoints(p+1), ypoints(p+1), 5);
        else
            if strcmp(breakType, 'equal') && p>1
                Screen('DrawLine', window, black, xpoints(p), ypoints(p), ...
                    xpoints(savepoint), ypoints(savepoint), 5);
                savepoint = p+1;
            end
        end
    end
    if strcmp(breakType, 'equal') && p>1
        Screen('DrawLine', window, black, xpoints(totalpoints-1), ypoints(totalpoints-1), ...
                    xpoints(savepoint), ypoints(savepoint), 5);
    end
    Screen('Flip', window);
    WaitSecs(displayTime);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    WaitSecs(pauseTime);
end

%%%%%%INSTRUCTIONS, BREAK, AND FINISH FUNCTION%%%%%%%%%
function [] = instructions(window, screenXpixels, screenYpixels, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    white = WhiteIndex(window);
    textcolor = white;
    xedgeDist = floor(screenXpixels / 3);
    numstep = floor(linspace(xedgeDist, screenXpixels - xedgeDist, 7));
    quote = '''';
    
%     intro = ['In this experiment, you will be asked to consider some images'...
%         ' and animations. Your task is to decide how you would prefer to describe'...
%         ' what is displayed in each image or animation. \n \n'...
%         'You will be able to indicate your preference using the '...
%         quote 'f' quote ' and ' quote, 'j'  quote ' keys.'];
    intro = strcat('In this experiment, you will be asked to consider pairs',...
        ' of images or animations. Your task is to decide, for each pair, how similar',...
        ' what is displayed in the two images or animations is. \n \n',...
        'You will indicate your judgment on a scale from 1-7, where 1 ',...
        ' is "not at all similar" and 7 is "very ',...
        ' similar" using the number keys at the top of the keyboard. While ',...
        ' you will likely see pairs of images that you judge to be at the ',...
        ' endpoints of the scale, you should also see pairs that require ',...
        ' use of the intermediary points. That is, please try to use the',...
        ' range provided by the scale. \n \n',...
        'You will be able to make your judgment only after each pair ',...
        ' of images is displayed. The representation below will appear',...
        ' at that time to remind you of the scale', quote, 's orientation. ');

    DrawFormattedText(window, intro, 'center', 20, textcolor, 70, 0, 0, textspace);

    for x = 1:7
        DrawFormattedText(window, int2str(x), numstep(x), 5*screenYpixels/8, textcolor, 70);
    end
    DrawFormattedText(window, '  not  \n at all \nsimilar', numstep(1) - (xedgeDist / 25), 5*screenYpixels/8 + 30, textcolor);
    DrawFormattedText(window, 'totally \nsimilar', numstep(7) - (xedgeDist / 25), 5*screenYpixels/8 + 30, textcolor);
    
    intro2 = ['Please indicate to the experimenter if you have any questions, '...
        'or are ready to begin the experiment. \n When the experimenter has '...
        'left the room, you may press spacebar to begin.'];
    
    DrawFormattedText(window, intro2, 'center', 4*screenYpixels/5, textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = blockInstructions(window, screenXpixels, screenYpixels, textsize, textspace, type, eventTime, objectTime, blockNumber)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    xedgeDist = floor(screenXpixels / 3);
    quote = '''';
    if strcmp(type, 'object')
        word = 'images';
    else
        word= 'animations';
    end
%     if blockNumber == 1
%         intro = ['In this first block, you will be asked to answer questions about',...
%             ' pairs of ' word ', paired with a sentence containing a novel word. You will now see a few examples of these ' word '.'];
%     elseif blockNumber == 2
%         intro = ['In this second block, you will be asked to answer questions about',...
%             ' more pairs of ' word '.'];
%     elseif blockNumber == 3
%         intro = ['In this third block, you will be asked to answer questions about',...
%             ' pairs of ' word '. You will now see a few examples of these ' word ':'];
%     elseif blockNumber == 4
%         intro = ['In this fourth block, you will be asked to answer questions about',...
%             ' more pairs of ' word '.'];
%     end
%     if (strcmp(type, 'event') && eventTime == 1) || (strcmp(type, 'object') && objectTime == 1)
      intro = ['In this block, you will be asked to compare pairs of ' word '.'...
          ' You will now see a few examples of these ' word '.\n\n',...
           'Ready? Press spacebar.'];
%     else
%         intro = ['In this block, you will be asked to answer questions about',...
%              ' more pairs of ' word '.'];
        
%     end
    DrawFormattedText(window, intro, 'center', 'center', textcolor, 70, 0, 0, textspace);
    

    Screen('Flip', window);
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);

end

function [] = breakScreen(window, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    quote = '''';
    DrawFormattedText(window, ['That' quote 's it for that block! \n\n' ...
        ' Please press the spacebar when you are ready to continue to the next block. '], 'center', 'center',...
        textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = finish(window, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    closing = ['Thank you for your participation.\n\nPlease let the ' ...
        'experimenter know that you are finished.'];
    DrawFormattedText(window, closing, 'center', 'center', textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('ESCAPE'));
    KbStrokeWait;
    Screen('Flip', window);
end


%%%%%%RESPONSE FUNCTION%%%%%
function [response, time] = getResponse(window, screenXpixels, screenYpixels, textsize, cond)
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    xedgeDist = floor(screenXpixels / 3);
    numstep = floor(linspace(xedgeDist, screenXpixels - xedgeDist, 7));
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    if strcmp(cond, 'object')
        intro = 'How similar were those two images?';
    else
        intro = 'How similar were those two animations?';
    end

    DrawFormattedText(window, intro, 'center', screenYpixels/3, textcolor, 70);
    for x = 1:7
        DrawFormattedText(window, int2str(x), numstep(x), 'center', textcolor, 70);
    end
    DrawFormattedText(window, '  not  \n at all \nsimilar', numstep(1) - (xedgeDist / 25), screenYpixels/2 + 30, textcolor);
    DrawFormattedText(window, 'very \nsimilar', numstep(7) - (xedgeDist / 25), screenYpixels/2 + 30, textcolor);
    Screen('Flip',window);

    % Wait for the user to input something meaningful
    inLoop=true;
    oneseven = [KbName('1!') KbName('2@') KbName('3#') KbName('4$')...
        KbName('5%') KbName('6^') KbName('7&')];
%     numkeys = [89 90 91 92 93 94 95];
    starttime = GetSecs;
    while inLoop
        %code = [];
        [keyIsDown, ~, keyCode]=KbCheck;
        if keyIsDown
            code = find(keyCode);
            if any(code(1) == oneseven)
                endtime = GetSecs;
                response = KbName(code);
                response = response(1);
                inLoop=false;
            end
        end
    end
    time = endtime - starttime;
end


function [response, time] = getObjectResponse(window, breakType, textsize, screenYpixels)
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize+6);
    quote = '''';
    if strcmp(breakType, 'random')
        noun = 'gorp';
    else
        noun = 'bamp';
    end
    DrawFormattedText(window, ['Was there more blue ' noun ' than yellow ' noun '?'],...
        'center', 'center', textcolor, 70, 0, 0, 1.5);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, ['Press ' quote 'f' quote ' for YES and ' quote 'j' quote ' for NO'],...
        'center', screenYpixels/2 + 80, textcolor, 70);
    Screen('Flip',window);

    % Wait for the user to input something meaningful
    inLoop=true;
    %response = '-1';
    yesno = [KbName('f') KbName('j')];
    starttime = GetSecs;
    while inLoop
        %code = [];
        [keyIsDown, ~, keyCode]=KbCheck;
        if keyIsDown
            code = find(keyCode);
            if any(code(1) == yesno)
                endtime = GetSecs;
                if code == 9
                    response = 'f';
                    inLoop=false;
                end
                if code== 13
                    response= 'j';
                    inLoop=false;
                end
            end
        end
    end
    time = endtime - starttime;
end


%%%%%%FIXATION CROSS FUNCTION%%%%%

function[] = fixCross(xCenter, yCenter, black, window, crossTime)
    white = WhiteIndex(window);
    Screen('FillRect', window, white/2);
    fixCrossDimPix = 40;
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    lineWidthPix = 4;
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, black, [xCenter yCenter], 2);
    Screen('Flip', window);
    WaitSecs(crossTime);
end


%%%%%SENTENCE/INSTRUCTIONS FUNCTIONS%%%%%

function [] = trainSentence(window, textsize, textspace, phase, breakType, screenYpixels)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize + 5);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    quote = '''';
    if strcmp(breakType, 'random')
        verb = 'gorps';
    else
        verb = 'gleebing';
    end
    
    switch phase
       case 1
           DrawFormattedText(window, ['First you' quote 're going to see the star doing some ' verb],...
               'center', 'center', white, 70, 0, 0, textspace);
       case 2
           DrawFormattedText(window, ['Now you' quote 're going to see the star doing more ' verb],...
               'center', 'center', white, 70, 0, 0, textspace);
       case 3
           DrawFormattedText(window, ['Let' quote 's see that again. You' ...
               quote 're going to see the star doing some ' verb],...
               'center', 'center', white, 70, 0, 0, textspace);
    end
    
    
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, 'Ready? Press spacebar.', 'center', ...
        screenYpixels/2+50, white, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = trainObjectSentence(window, textsize, textspace, breakType, screenYpixels, phase)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize + 5);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    quote = '''';
    if strcmp(breakType, 'random')
        noun = 'bamps';
    else
        noun = 'blick';
    end
    
   switch phase
       case 1
            DrawFormattedText(window, ['First you' quote 're going to see some ' noun '.'],...
                'center', 'center', white, 70, 0, 0, textspace);
       case 2
           DrawFormattedText(window, ['Now you' quote 're going to see more '...
               noun],...
               'center', 'center', white, 70, 0, 0, textspace);
       case 3
            DrawFormattedText(window, ['Let' quote 's see that again. You' ...
                quote 're going to see some ' noun],...
                'center', 'center', white, 70, 0, 0, textspace);
   end
    
    
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, 'Ready? Press spacebar.', 'center', ...
        screenYpixels/2+50, white, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = testingSentence(window, textsize, textspace, breakType, screenYpixels)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    quote = '''';
    
    
    DrawFormattedText(window, ['In this block, you' quote 're going to see pairs of '...
        'animations. For each pair you are going to be asked:'], 'center', screenYpixels/2-(screenYpixels/5), white, 70, 0, 0, textspace);
    
    Screen('TextSize',window,textsize+15);
    DrawFormattedText(window, ['How similar were those two animations?'],...
                'center', 'center', white, 70, 0, 0, textspace);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, 'Ready? Press spacebar.', 'center', ...
        screenYpixels/2+(screenYpixels/5), white, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = testingObjectSentence(window, textsize, textspace, breakType, screenYpixels)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    Screen('FillRect', window, black);
    Screen('Flip', window);
    quote = '''';
    
    DrawFormattedText(window, ['Now you' quote 're going to see pairs of '...
        'images. For each pair, you are '...
        'going to be asked:'], 'center', screenYpixels/2-(screenYpixels/5), white, 70, 0, 0, textspace);
    
    Screen('TextSize',window,textsize+15);
    DrawFormattedText(window, ['How similar were those two images?'],...
                'center', 'center', white, 70, 0, 0, textspace);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, 'Ready? Press spacebar.', 'center', ...
        screenYpixels/2+(screenYpixels/5), white, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end
%%%%%POINTS AND BREAKS FUNCTIONS%%%%%


function [xpoints, ypoints] = getPoints(numberOfLoops, numberOfFrames)
    %OK, so, the ellipses weren't lining up at the origin very well, so
    %smoothframes designates a few frames to smooth this out. It uses fewer
    %frames for the ellipse, and instead spends a few frames going from the
    %end of the ellipse to the origin.
    smoothframes = 0;
    doublesmooth = smoothframes*2;
    xpoints = [];
    ypoints = [];
    majorAxis = 2;
    minorAxis = 1;
    centerX = 0;
    centerY = 0;
    theta = linspace(0,2*pi,numberOfFrames-smoothframes);
    %The orientation starts at 0, and ends at 360-360/numberOfLoops
    %This is to it doesn't make a complete circle, which would have two
    %overlapping ellipses.
    orientation = linspace(0,360-round(360/numberOfLoops),numberOfLoops);
    for i = 1:numberOfLoops
        %orientation calculated from above
        loopOri=orientation(i)*pi/180;

        %Start with the basic, unrotated ellipse
        initx = (majorAxis/2) * sin(theta) + centerX;
        inity = (minorAxis/2) * cos(theta) + centerY;

        %Then rotate it
        x = (initx-centerX)*cos(loopOri) - (inity-centerY)*sin(loopOri) + centerX;
        y = (initx-centerX)*sin(loopOri) + (inity-centerY)*cos(loopOri) + centerY;
        %then push it out based on the rotation
        for m = 1:numel(x)
            x2(m) = x(m) + (x(round(numel(x)*.75)) *1);
            y2(m) = y(m) + (y(round(numel(y)*.75)) *1);
        end

        %It doesn't start from the right part of the ellipse, so I'm gonna
        %shuffle it around so it does. (this is important I promise)  
        %It also adds in some extra frames to smooth the transition between
        %ellipses
        start = round((numberOfFrames-smoothframes)/4);
        x3 = [x2(start:numberOfFrames-smoothframes) x2(2:start) linspace(x2(start),0,smoothframes)];
        y3 = [y2(start:numberOfFrames-smoothframes) y2(2:start) linspace(y2(start),0,smoothframes)];
        %Finally, accumulate the points in full points arrays for easy graphing
        %and drawing
        xpoints = [xpoints x3];
        ypoints = [ypoints y3];
    end
end

function [Breaks] = makeBreaks(breakType, totalpoints, loops, minSpace)
    if strcmp(breakType, 'equal')
        %Breaks = 1 : totalpoints/loops : totalpoints;
        Breaks = linspace(totalpoints/loops, totalpoints+1, loops);
        Breaks = arrayfun(@(x) round(x),Breaks);

    elseif strcmp(breakType, 'random')
        %tbh I found this on stackoverflow and have no idea how it works
        %http://stackoverflow.com/questions/31971344/generating-random-sequence-with-minimum-distance-between-elements-matlab/31977095#31977095
        if loops >1
            numberOfBreaks = loops - 1;
            %The -10 accounts for some distance away from the last point,
            %which I add on separately.
            E = (totalpoints-10)-(numberOfBreaks-1)*minSpace;

            ro = rand(numberOfBreaks+1,1);
            rn = E*ro(1:numberOfBreaks)/sum(ro);

            s = minSpace*ones(numberOfBreaks,1)+rn;

            Breaks=cumsum(s)-1;

            Breaks = reshape(Breaks, 1, length(Breaks));
            Breaks = arrayfun(@(x) round(x),Breaks);
            Breaks = [Breaks totalpoints+1];
        else
            Breaks = [totalpoints+1];
        end
        %I'm adding one break on at the end, otherwise I'll end up with
        %more "pieces" than in the equal condition.

    else
        Breaks = [];
    end
end

function [final_xpoints, final_ypoints] = rotatePoints(xpoints, ypoints, numberOfFrames, Breaks)
    nx = xpoints;
    ny = ypoints;
    halfLoop = floor(numberOfFrames/2);
    totalpoints = length(xpoints);

    petalnum = 0;

    %In this process, I wind up copying things because I might back up to a
    %different point, and I don't want my calculations to mess with each other.
    %(like, if I change a point, I want the calculations for future points to
    %be calculated from the static previous graph, and not from any changes I
    %just made.

    %So, I have a couple variables that are just copies of the point sets. It's
    %important, I promise.

    %Move to origin
    for m = 1:totalpoints-1
        if any(m==Breaks)
            petalnum = petalnum+1;
        end
        nx(m) = xpoints(m) - xpoints(halfLoop + (numberOfFrames * petalnum))/2;
        ny(m) = ypoints(m) - ypoints(halfLoop + (numberOfFrames * petalnum))/2;
    end

    %rotate
    copy_nx = nx;
    copy_ny = ny;
    f = randi(360);

    for m = 1:totalpoints-1
        if any(m == Breaks)
            f = randi(360);
        end 
        copy_nx(m) = nx(m)*cos(f) - ny(m)*sin(f);
        copy_ny(m) = ny(m)*cos(f) + nx(m)*sin(f);
    end

    %push out based on tip direction
    final_xpoints = copy_nx;
    final_ypoints = copy_ny;
    petalnum = 0;

    for m = 1:totalpoints-1
        if any(m == Breaks)
            petalnum = petalnum + 1;
        end
        final_xpoints(m) = copy_nx(m) + (xpoints(halfLoop + (numberOfFrames * petalnum)) *1.5);
        final_ypoints(m) = copy_ny(m) + (ypoints(halfLoop + (numberOfFrames * petalnum)) *1.5);
    end
%     final_xpoints = final_xpoints(1:length(final_xpoints-2));
%     final_ypoints = final_ypoints(1:length(final_ypoints-2));

end

%%%%%%%%%
%INPUT CHECKING FUNCTIONS
%%%%%%%%%

function [subj] = subjcheck(subj)
    if ~strncmpi(subj, 's', 1)
        %forgotten s
        subj = ['s', subj];
    end
    if strcmp(subj,'s')
        subj = input(['Please enter a subject ' ...
                'ID:'], 's');
        subj = subjcheck(subj);
    end
    numstrs = ['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '0'];
    for x = 2:numel(subj)
        if ~any(subj(x) == numstrs)
            subj = input(['Subject ID ' subj ' is invalid. It should ' ...
                'consist of an "s" followed by only numbers. Please use a ' ...
                'different ID: '], 's');
            subj = subjcheck(subj);
            return
        end
    end
    if (exist(['~/Desktop/Data/TELIC/TELICWROCLAW/TelicWroclaw' subj '.csv'], 'file') == 2) && ~strcmp(subj, 's999')...
            && ~strcmp(subj,'s998')
        temp = input(['Subject ID ' subj ' is already in use. Press y '...
            'to continue writing to this file, or press '...
            'anything else to try a new ID: '], 's');
        if strcmp(temp,'y')
            return
        else
            subj = input(['Please enter a new subject ' ...
                'ID:'], 's');
            subj = subjcheck(subj);
        end
    end
end

function [cond] = condcheck(cond)
    while ~strcmp(cond, 'm') && ~strcmp(cond, 'c')
        cond = input('Condition must be m or c. Please enter m (mass) or c (count): ', 's');
    end
end

function [cond] = cond2check(cond)
    while ~strcmp(cond, 'e') && ~strcmp(cond, 'o')
        cond = input('Condition must be e or o. Please enter e (events) or o (objects): ', 's');
    end
end

function [list] = listcheck(list)
    if strcmp(list, 'test')
        check = input('Type y to continue using a test list. Type anything else to abort the program: ', 's');
        if strcmp(check, 'y')
            return
        else
            error('Process aborted')
        end
    end
    while ~strcmp(list, 'blue') && ~strcmp(list, 'pink') && ~strcmp(list, 'green') && ~strcmp(list, 'orange') && ~strcmp(list, 'yellow')
        list = input('List must be a valid color. Please enter blue, pink, green, orange, or yellow: ', 's');
    end
end