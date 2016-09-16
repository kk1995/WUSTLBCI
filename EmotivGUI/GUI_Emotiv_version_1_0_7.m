function [] = GUI_Emotiv_version_1_0_7()
%% Emotiv GUI
% Plot real-time 128 samples, real-time 3 seconds long data, frequency
% analysis, and a picture of brain activity.
% 
% GUI will have four plots:
% 1. Real-time data from Emotiv hardware.
% 2. Three second long data
% 3. Brain map and FFT
% 4. Fourier transform done by Chronux
% 
% Real -time data is called using C++ library in Emotiv SDk.
% EmotivEEG function from Emotiv toolbox (downloaded from matlab user
% community) is used to extract real-time data.
% EEGlab is used for displaying brain map and FFT..
% I refereced codes from Matt Fig, who made GUI tutorial. Most of GUI
% interface has deriven from his code.
% Codes for wait_bar came from Matlab help doc.
% version 1.0.0 - JS
% 
% Main frame and call_back fucntions written by Junwoo Suh 6-3-2014
% VEP function written by Bumjin Park 7-1-14
% VEP implementation done by Nuley Seo 7-1-14
% 
% Attention: This GUI will be the final product. Please add individually
% developed functions to this GUI

%% Updates
% Version 1.0.1 - JS, 7-1-14
% Flip screen between Frequency domain only and brain map is added
% 
% Version 1.0.2 - JS & BP 7-9-14 Implementation of VEP flash screen working
% on the MATLAB session credit to Bumjin for VEP flash screen using control
% *Although her work is not reflected in the version, NS researched parfor
% loop and explored multicore processing, which might come in handy for
% later GUI development (great work!)
% 
% Version 1.0.3 - JS 7-2-14
% Push buttons and features in proportion to the GUI interface.
% GUI figure in proportion to the monitor resolution.
% Delete coordinate system
% Disable double GUI singleton
% 
% Version 1.0.4 - JS 7-3-14
% Enhanced GUI resize function
% bugs with AEP fixed (regarding p300 and initial iteration)
% waitbar consistent with actual GUI process
% 
% Version 1.0.5 - NS 7-9-14
% Added Chronux freq only analysis
% Offline p300 analysis
% 
% Version 1.0.7 - JS Bug fix with initial AEP loop - there still seems to
% be a glitch in few iteration where empty matrix is generated for the
% first iteration of AEP session. Pls take a look and trouble shoot this

%% Create Objects
% First off, I get pixel information of the screen
sSize = get(0,'screensize');
sWidth = sSize(1,3);
sLength = sSize(1,4);
% Set background as an reference to all other push button
bWidth = sWidth;
bLength = sLength;

% Set normal button size and small-screen button size
iSize.buttonLength_n = 100;
iSize.buttonWidth_n = 30;
iSize.listLength_n = 300;
iSize.listWidth_n = 100; %#ok<STRNU>

% Back ground
S.background = figure('units','pixels',...
    'pos',[10, 10, bWidth, bLength],...
    'menubar','none',...
    'name','GUI_Emotiv',...
    'numbertitle','off',...
    'resize','on', ...
    'ResizeFcn',{@resize_call}, ...
    'Tag','Plotting Figure');
% Push this button to start real time data acquisition
S.startButton = uicontrol('style','push', ...
    'string','Start Emotiv',...
    'interruptible','on',...
    'callback',{@start_call},...
    'units','pixels',...
    'fontsize',11,...
    'fontweight','bold',...
    'Interruptible','on', ...
    'position',[10 10 100 30]);


% Push this button to stop real time
S.stopButton = uicontrol('style','push', ...
    'string','Stop Emotiv',...
    'callback',{@stop_call},...
    'units','pixels',...
    'fontsize',11,...
    'fontweight','bold',...
    'interruptible','off',...
    'enable','off',...
    'position',[115 10 100 30]);

% Push this button to start AEP experiment session
S.aep = uicontrol('style','push', ...
    'string','AEP',...
    'callback',{@aep_call},...
    'units','pixels',...
    'fontsize',11,...
    'fontweight','bold',...
    'interruptible','off',...
    'enable','off', ...
    'position',[220 10 100 30]);

% Push button for SSVEP experiment
S.vep = uicontrol('style','push',...
    'string','VEP',...
    'callback',{@vep_call},...
    'units','pixels',...
    'fontsize',11,...
    'fontweight','bold',...
    'interruptible','off',...
    'enable','off',...
    'position',[325 10 100 30]);

% Push this button to end AEP experiment session
S.aepStopButton = uicontrol('style','push', ...
    'string','Stop and Save AEP',...
    'callback',{@endAep_call},...
    'units','pixels',...
    'fontsize',11,...
    'fontweight','bold',...
    'interruptible','off',...
    'enable','off', ...
    'position',[430 10 200 30]);

% Write down the name of the file which you want to save the voltage data
S.saveFileName = uicontrol('style','edit', ...
    'string','Save_file_name', ...
    'units','pixels', ...
    'fontsize',10,...
    'position',[(bWidth-620) (bLength-37) 500 25]);

% Push this button to save data
S.saveData = uicontrol('style','push', ...
    'string','Save Data', ...
    'callback',{@saveData_call}, ...
    'units','pixels', ...
    'fontsize',11,...
    'interruptible','off',...
    'fontweight','bold',...
    'position',[(bWidth-110) (bLength-40) 100 30]);

%Open Offline plot for selected person
S.offline = uicontrol('style','push', ...
    'string','Offline plot', ...
    'callback',{@offline_call}, ...
    'units','pixels', ...
    'fontsize',11,...
    'interruptible','off',...
    'fontweight','bold',...
    'position',[10 (bLength-105) 100 30]);

% Help text
S.guideText1 = uicontrol('style','text',...
    'unit','pix',...
    'position',[10 (bLength-570) 100 65],...
    'string',{'Black: no data'; 'Blue: AEP taken';...
    'Red: VEP taken'; 'Green: Both taken'},...
    'fontsize',10);

S.guideText2 = uicontrol('style','text',...
    'unit','pix',...
    'position',[(bWidth-500) (bLength-55) 330 17],...
    'string','*Please stop Emotiv before proceeding with "Save Data"',...
    'fontsize',10);

S.versionText3 = uicontrol('style','text',...
    'unit','pix',...
    'position',[10 (bLength-70) 100 60],...
    'string','Version 1.0.5   Undergraduate students in Dr. Ching''s lab ',...
    'fontsize',8);

% List of subjects
S.subjectList = uicontrol('style','list',...
    'unit','pix',...
    'position',[10 (bLength-400) 100 290],...
    'min',2,'max',2,...
    'fontsize',11,...
    'string',{''});

% Add new subjects
S.newSubjectName = uicontrol('style','edit',...
    'units','pixels',...
    'position',[10 (bLength-430) 100 25],...
    'string','New_name',...
    'interruptible','off');

% Retrieve edit box string and add new subject to the list
S.newSubject = uicontrol('style','push', ...
    'string','Add new', ...
    'callback',{@newSubject_call}, ...
    'units','pixels', ...
    'fontsize',11,...
    'fontweight','bold',...
    'position',[10 (bLength-465) 100 30]);

% Remove selected subject from the list
S.removeSubject = uicontrol('style','push', ...
    'string','Remove name', ...
    'callback',{@removeSubject_call}, ...
    'units','pixels', ...
    'fontsize',10,...
    'fontweight','bold',...
    'position',[10 (bLength-500) 100 30]);

S.freqOnly = uicontrol('style','push', ...
    'string','Freq Only', ...
    'callback',{@freqOnly_call}, ...
    'units','pixels', ...
    'fontsize',10, ... 
    'fontweight','bold', ... 
    'enable', 'off', ... 
    'position',[940 10 100 30]);

% Creating Checkbox for the different channel required
Data.channelloc = {'AF3', 'F7', 'F3', 'FC5', 'T7', 'P7', ...
    'O1', 'O2', 'P8', 'T8', 'FC6', 'F4', 'F8', 'AF4'};

for x = 1:length(Data.channelloc) 
    if x <= 5
        S.channel(x) = uicontrol('style','check',...
            'string',Data.channelloc(x),...
            'callback',{@channel_call},...
            'units','pixels',...
            'fontsize',10,...
            'position',[225+50*(x-1) (bLength-30) 50 15]);
    elseif 5 < x && x <= 10
        S.channel(x) = uicontrol('style','check',...
            'string',Data.channelloc(x),...
            'callback',{@channel_call},...
            'units','pixels',...
            'fontsize',10,...
            'position',[225+50*(x-6) (bLength-45) 50 15]);
    else
        S.channel(x) = uicontrol('style','check',...
            'string',Data.channelloc(x),...
            'callback',{@channel_call},...
            'units','pixels',...
            'fontsize',10,...
            'position',[225+50*(x-11) (bLength-60) 50 15]);
    end
end

S.selectCheck = uicontrol('style','push',...
    'string','Select All',...
    'callback',{@select_call},...
    'units','pixels',...
    'fontsize',10,...
    'position',[120 bLength-55 100 30]);

% Boolean for stop and start control
S.stopTrigger = 0;
% draw GUI before anything happens
drawnow;
%% Pre-start set ups
% Get background color for the startbutton
col_start = get(S.startButton,'backg');
aepTrigger = 0;
vepTrigger = 0;
freqOnly = 0;
ChannelSelect = 0;
signal = struct;
Channels = [];
Data.signal = {};
cnt = 0;
standardCount = 3;
signal.deviant_temp = [];
superposed = [];
%% Main call back function
% Pressing start button will initiate collection of data
% This is sort of our main fucntion.
    function [] = start_call(varargin)
        %% Start set up
        set(S.startButton,'Enable','off');
        set(S.startButton,'str','RUNNING...','backg','r')
        % Create and update a waitbar.
        wait = waitbar(0,'Please wait...',...
            'Position',[250,320,270,50],...
            'CloseRequestFcn',@close_waitbar);
        
        % Turn on EmotivEEG
        Emotiv = EmotivEEG; % This object-based function will retrieve EEG
        % data in real-time.
        waitbar(1/5,wait)
        Emotiv.Run(); % For more information, open (directory to Emotiv SDK)
        % /doc/exmaples_matlab/EmotivEEG
        % Reinitiate the boolean for stop/start control
        waitbar(2/5,wait)
        S.stopTrigger = 0;
        % Initialize variables that stores data
        signal.freq = [];
        signal.cache = [];
        signal.mark = [];
        waitbar(3/5,wait)
        set(S.stopButton,'Enable','off');
        set(S.saveData,'Enable','off');
        set(S.newSubject,'Enable','off');
        set(S.removeSubject,'Enable','off');
        waitbar(4/5,wait)
        set(S.aep,'Enable','on');
        set(S.vep,'Enable','on');
        set(S.stopButton,'Enable','on');
        set(S.saveData,'Enable','on');
        set(S.newSubject,'Enable','on');
        set(S.removeSubject,'Enable','on');
        trig = 0;
        waitbar(5/5,wait)
        % When waitbar reaches max, close it.
        if ishandle(wait)
            close(wait)
        end
        %% This for loop updates the plot everytime it is called
        for i = 1:inf % This will go on indefintely unless stopped externally      
            %% Checking for any stops
            % check if the stop button is pressed.
            if S.stopTrigger == 1
                Emotiv.Stop();
                break; % break for loop and stop the GUI
            end
            % Check if the figure is closed
            if ~ishandle(S.background)
                Emotiv.Stop();
                break; % break for loop and stop the GUI
            end
            % Wait before enabling freq to brainmap button
            if i > 200 && trig == 1 && i < 300
                set(S.freqOnly, 'enable', 'on');
            end
            %% Update the Emotiv & Simple data packaging
            nSampleTaken = UpdateData(Emotiv);
            % Truncate the gyro and accelometer
            signalt = Emotiv.data(:,4:17);
            % EEG lab requires signals to be formatted in a particular ways
            signal.temp = transpose(signalt);
            % Save signal to seperate variable
            signal.freq = [signal.temp(:,1:nSampleTaken),signal.freq];
            %% AEP
            if aepTrigger == 1
                if cnt == 0
                   %% AEP startup Jargons
                    % Create and update a waitbar.
                    wait = waitbar(0,'Please wait...',...
                        'Position',[250,320,270,50],...
                        'CloseRequestFcn',@close_waitbar);
                    set(S.stopButton,'Enable','off');
                    set(S.saveData,'Enable','off');
                    set(S.aepStopButton,'Enable','off');
                    set(S.newSubject,'Enable','off');
                    set(S.removeSubject,'Enable','off');
                    waitbar(1/3,wait)
                    set(S.stopButton,'Enable','on');
                    set(S.saveData,'Enable','on');
                    set(S.aepStopButton,'Enable','on');
                    set(S.newSubject,'Enable','on');
                    set(S.removeSubject,'Enable','on');
                    waitbar(2/3,wait)
                    deviant_trial = 0;
                    signal.deviant_old = [];
                    cnt = 1;
                    trig = 0;
                    waitbar(3/3,wait)
                    % When waitbar reaches max, close it.
                    if ishandle(wait)
                        close(wait)
                    end
                else
                    signal.stored = [signal.temp(:,1:nSampleTaken),signal.stored];
                    signal.cache = [signal.temp(:,1:nSampleTaken),signal.cache];
                    
                    % Reversed
                    signal.mark = [signal.mark,zeros(1,nSampleTaken)];
                    if exist('standard','var') && standard == -1
                        signal.deviant_temp = [signal.temp(:,1:nSampleTaken), ...
                            signal.deviant_temp];
                    end
                    % make sound, keep track of devaint trial
                    % signal.cache is only for keeping track of number of
                    % samples
                    if (length(signal.cache)>128 || trig == 1)
                        standard = makeSound();
                        % Standard is a constant of -1 or 1
                        % The last index of signal.mark, which is the last
                        % sample taken from emotiv device. (a.k.a. the
                        % newest sample taken) The value of standard
                        % replaces the last mark, thus we keep track of
                        % when the sound happen in terms of sample index
                        signal.mark(length(signal.mark)) = standard;
                        signal.cache = [];
                        % Checking whether the p300 plot or brain map has
                        % been plotted
                        trig = 0;
                        if standard == -1
                            signal.deviant_temp = signal.stored(:,1:27);
                            disp(length(signal.deviant_temp));
                            disp(deviant_trial);
                        else
                            signal.deviant_temp = [];
                        end
                    end
                end
            end
            %% VEP
            if vepTrigger == 1
                if cnt == 0
                    %% VEP startup Jargon
                    % Create and update a waitbar.
                    wait = waitbar(0,'Please wait...',...
                        'Position',[250,320,270,50],...
                        'CloseRequestFcn',@close_waitbar);
                    set(S.stopButton,'Enable','off');
                    set(S.saveData,'Enable','off');
                    set(S.aepStopButton,'Enable','off');
                    set(S.newSubject,'Enable','off');
                    set(S.removeSubject,'Enable','off');
                    waitbar(1/5,wait)
                    deviant_trial = 0;
                    signal.deviant_old = [];
                    cnt = 1;
                    trig = 0;
                    waitbar(2/5,wait)
                    open flicker_6.exe
                    pause(1)
                    waitbar(3/5,wait)
                    set(S.stopButton,'Enable','on');
                    set(S.saveData,'Enable','on');
                    set(S.aepStopButton,'Enable','on');
                    set(S.newSubject,'Enable','on');
                    set(S.removeSubject,'Enable','on');
                    waitbar(4/5,wait)
                    set(S.freqOnly,'Enable','off');
                    waitbar(1,wait)
                    % When waitbar reaches max, close it.
                    if ishandle(wait)
                        close(wait)
                    end
                else
                    
                    signal.stored = [signal.temp(:,1:nSampleTaken),signal.stored];
                    signal.cache = [signal.temp(:,1:nSampleTaken),signal.cache];
                    % make sound, keep track of devaint trial
                    % signal.cache is only for keeping track of number of
                    % samples
                end
            end
            %% Plot the data.
            try
                figure(findobj('Tag','Plotting Figure'));
            catch %#ok<CTCH>
                text(.5,.5,{'Please Close all GUI window' ; 'before opening another'},...
                    'FontSize',14,'HorizontalAlignment','center')
                break
            end
            subplot('Position',[0.12, 0.15, 0.25, 0.7]);
            if find(Channels ~= 0)
                plot(0:1/128:127/128,(signal.temp(Channels,:)))
            end
            
            % Plot p300
            if size(signal.deviant_temp,2) > 130
                signal.deviant_temp = fliplr(signal.deviant_temp(:,length(signal.deviant_temp) ...
                    -129:length(signal.deviant_temp)));
%                 signal.deviant_new = filter_singularity(signal.deviant_temp);
                signal.deviant_new = signal.deviant_temp;
                if signal.deviant_new == 0
                    if deviant_trial > 0
                        deviant_trial = deviant_trial - 1;
                    else
                        deviant_trial = 0;
                    end
                    disp('bad signal');
                    continue
                elseif deviant_trial == 0
                    signal.deviant = signal.deviant_new;
                    deviant_trial = 1;
                    disp('yes')
                else
                    deviant_trial = deviant_trial + 1;
                    signal.deviant_old = signal.deviant;
                    signal.deviant = ((deviant_trial-1)/deviant_trial).* ...
                        signal.deviant_old + (1/deviant_trial).*signal.deviant_new;
                end
                [superposed,time] = filter(signal.deviant',size(signal.deviant,1),5,15);
                cosine = subplot('Position',[0.73, 0.15, 0.25, 0.7]);
                figure(findobj('Tag','Plotting Figure'));
                cla(cosine);
                drawnow;
                if find(Channels ~= 0)
                    plot(time,superposed(Channels,:))
                end
                hold on
                axis([-0.1 0.5 min(min(superposed)-20) max(max(superposed)+20)]);
                plot(time,zeros(1,length(superposed)))
                hold on
                line ([0,0],[min(min(superposed)-50),max(max(superposed)+50)])
                line ([.3,.3],[min(min(superposed)-50),max(max(superposed)+50)])
                title('Deviant: Filtered from 5 Hz to 15 Hz')
                xlabel('Time in second');
                ylabel('Amplitude');
            end

            % With sample rate of 128, 128*3 samples will be approx. 3
            % seconds. Skip this when ploting p300 because p300 already
            % takes too much time.
            
            % Plot brainmap
            if length(signal.freq) > 128*3 && freqOnly ~= 1
                % Create a struct that is compatible with EEG lab pop
                % functions
                
                subplot('Position',[0.45, 0.25, 0.20, 0.6]);
                text(.5,.5,{'Preparing Brain Map...'},...
                    'FontSize',14,'HorizontalAlignment','center')
                hold on
                EEG = pop_importdata('data', fliplr(signal.freq), 'srate',128);
                % Loads the chanlocation of EEG
                EEG.chanlocs=pop_chanedit(EEG.chanlocs, 'load',{ 'emotivLocation.locs', ...
                    'filetype',  'autodetect'});
                figure(findobj('Tag','Plotting Figure'));
                % Draw brain map
                pop_spectopo(EEG, 1, [1 128],'EEG','electrodes', 'on','freq',[10 20 40]);
                % Empty signal.freq
                signal.freq = [];
                trig = 1;
            elseif (length(signal.freq) >= 128*3) && (freqOnly == 1 || vepTrigger == 1)
                figure(findobj('Tag','Plotting Figure'));
                if vepTrigger == 1
                    h1 = subplot('Position',[0.73, 0.15, 0.25, 0.7]);
                else
                    h1 = subplot('Position',[0.45,0.15,0.25,0.7]);
                end
                cla(h1);
                
                y = fliplr(signal.freq);
                %  CAR
                for k=1:size(y,1)
                    y(k,:) = y(k,:)-mean(y(k,:));
                end
%                 plot(y')
                params.Fs = 128;
                params.tapers = [5 9];
                [spec,f] = mtspectrumc(y',params);
                % Plot single-sided amplitude spectrum.
                plot(f,20*log10(spec))
                title('Power Spectrum')
                xlabel('Frequency (Hz)')
                ylabel('Power')
                axis tight
                % Empty signal.freq
                signal.freq = [];
                trig = 1;
            end
            
            % Give time for GUI to update plots
            pause(0.01)
        end
    end
%% Other call back functions
% stop_call back function
    function [] = stop_call(varargin)
        endAep_call();
        set(S.startButton,'Enable','on');
        set(S.stopButton,'Enable','off');
        set(S.aep,'Enable','off');
        set(S.aepStopButton,'Enable','off');
        set(S.startButton,'str','Start','backg',col_start)
        set(S.vep,'Enable','off');
        S.stopTrigger = 1; % externally stops for loop
        aepTrigger = 0;
        set(S.aep,'string','AEP','backg',col_start)
        vepTrigger = 0;
        set(S.vep,'string','VEP','backg',col_start)
    end
% Plot Offline data
    function [] = offline_call(varargin)
        stop_call();
        % Retrieve data from the selected person from the list
        subject = get(S.subjectList,{'string','value'});
        hFig = figure(2);
        set(hFig,'Position',[100 100 1000 500])
        subplot('Position',[0.075, 0.125, 0.40 0.77])
        plot(0:1/128:(size(Data.signal{subject{2},2},2)-1)/128, ... 
            Data.signal{subject{2},2}');
        name = subject{1}(subject{2});
        realname = name{1}(28:length(name{1})-14);
        title(['EEG Raw data of ' realname]);
        xlabel('Time (s)');
        ylabel('Voltage (mV)');
        
        subplot('Position',[0.55, 0.125, 0.40 0.77])
        time = -.2:1/130:.8-(1/130);
        plot(time,superposed)
        hold on
        axis([-0.1 0.5 min(min(superposed)-20) max(max(superposed)+20)]);
        plot(time,zeros(1,length(superposed)))
        hold on
        line ([0,0],[min(min(superposed)-50),max(max(superposed)+50)])
        title('Deviant: Filtered from 5 Hz to 15 Hz')
        xlabel('Time in second');
        ylabel('Micro volt ?');
    end
% Save data collected
    function [] = saveData_call(varargin)
        % Retrieve save file name from the text box
        h = get(S.saveFileName,'string');
        % In struct Data, I included electrodes' locations, raw data, AEP data and
        % trial data.
        Data.samplingFreq = 128;
        save(h,'Data');
    end
% Start Auditory evoked potential experiment
    function [] = aep_call(varargin)
        set(S.aep,'Enable','off');
        set(S.vep,'Enable','off');
        set(S.aep,'str','RUNNING...','backg','r')
        set(S.aepStopButton,'Enable','on');
        signal.stored =[];
        aepTrigger = 1;
        cnt = 0;
    end
% Start SSVEP experiment
    function []= vep_call(varargin)
        set(S.vep,'Enable','off');
        set(S.aep,'Enable','off');
        set(S.vep,'str','Running...','backg','r')
        set(S.aepStopButton,'Enable','on');
        signal.stored = [];
        vepTrigger = 1;
        cnt = 0;
    end
% Ends Sensory eveoked potential experiment
    function [] = endAep_call(varargin)
        set(S.aep,'Enable','on');
        set(S.vep,'Enable','on');
        set(S.aep,'string','AEP','backg',col_start)
        set(S.vep,'string','VEP','backg',col_start)
        subject = get(S.subjectList,{'string','value'});
        % Save signal to a designated row of the Data cell
        if aepTrigger == 1
            Data.signal{subject{2},2} = fliplr(signal.stored);
            Data.signal{subject{2},3} = signal.mark;
            str = get(S.subjectList,'String');
            val = get(S.subjectList,'value');
            if length(str{val})>26 && strcmp(str{val}(1:26),'<HTML><BODY bgcolor="red">')
                str{val} = ['<HTML><BODY bgcolor="green">' str{val} ...
                    '</BODY></HTML>'];
            else
                str{val} = ['<HTML><BODY bgcolor="blue">' str{val} ...
                    '</BODY></HTML>'];
            end
            set(S.subjectList, 'String',str)
            
            aepTrigger = 0;
        elseif vepTrigger == 1
            !TASKKILL /IM flicker_6.exe /F
            Data.signal{subject{2},4} = fliplr(signal.stored);
            str = get(S.subjectList,'String');
            val = get(S.subjectList,'value');
            if length(str{val})>27 && strcmp(str{val}(1:27),'<HTML><BODY bgcolor="blue">')
                str{val} = ['<HTML><BODY bgcolor="green">' str{val} ...
                    '</BODY></HTML>'];
            else
                str{val} = ['<HTML><BODY bgcolor="red">' str{val} ...
                    '</BODY></HTML>'];
            end
            set(S.subjectList, 'String',str)
            set(S.freqOnly,'Enable','on');
            vepTrigger = 0;
        end
        set(S.aepStopButton,'Enable','off');
    end
% Add subject to the list
    function [] = newSubject_call(varargin)
        oldstr = get(S.subjectList,'string');
        newstr = get(S.newSubjectName,'string');
        set(S.subjectList,'string',{oldstr{:}, newstr});  %#ok<CCAT>
        subject = get(S.subjectList,{'string','value'});
        Data.signal{length(subject{1}),1} = newstr;
    end
% Remove subject from the list
    function [] = removeSubject_call(varargin)
        remove = get(S.subjectList,{'string','value'});
        if ~isempty(remove{1})
            % remove
            for i = remove{2}:length(remove{1})
                for j = 1:size(Data.signal,2)
                    if i == length(remove{1})
                        Data.signal{i,j} = [];
                    else
                        Data.signal{i,j} = Data.signal{i+1,j};
                    end
                end
            end
            remove{1}(remove{2}) = [];
            set(S.subjectList,'string',remove{1},'val',1)
        end
    end
% Convert FFT/Brain map to a single plot for frequency domain
    function [] = freqOnly_call(varargin)
        if freqOnly == 0
            freqOnly = 1;
            set(S.freqOnly, 'String', 'Brain Map');
        else
            freqOnly = 0;
            set(S.freqOnly, 'String', 'Freq Only');
        end
    end
% Resize call back
    function [] = resize_call(varargin)
        bSize = getpixelposition(S.background);
        bWidth = bSize(1,3);
        bLength = bSize(1,4);
        if bWidth < 1100
            bWidth = 1100;
            set(S.background,'Pos',[bSize(1:2) bWidth bLength]);
        end
        if bLength < 615
            bLength = 615;
            set(S.background,'Pos',[bSize(1:2) bWidth bLength]);
        end
        set(S.saveFileName, 'Position', [(bWidth-620) (bLength-37) 500 25]);
        set(S.saveData, 'position',[(bWidth-110) (bLength-40) 100 30]);
        set(S.guideText1, 'position',[10 (bLength-570) 100 65])
        set(S.guideText2, 'position',[(bWidth-500) (bLength-55) 330 17]);
        set(S.removeSubject, 'position', [10 (bLength-500) 100 30]);
        set(S.newSubject, 'position', [10 (bLength-465) 100 30]);
        set(S.subjectList, 'position', [10 (bLength-400) 100 290])
        set(S.versionText3, 'position', [10 (bLength-70) 100 60])
        set(S.offline, 'position', [10 (bLength-105) 100 30])
        set(S.newSubjectName, 'position', [10 (bLength-430) 100 25])
        for i = 1:length(Data.channelloc)
            if i <= 5
                set(S.channel(i), 'position',[225+50*(i-1) bLength-30 50 15]);
            elseif 5 < i && i <= 10
                set(S.channel(i), 'position',[225+50*(i-6) bLength-45 50 15]);
            else
                set(S.channel(i), 'position',[225+50*(i-11) bLength-60 50 15]);
            end
        end
        set(S.selectCheck, 'position', [120 bLength-55 100 30]);
        % Choosing Channel
    end
% Selecting Channels
    function [] = channel_call(varargin)
        for c = 1:length(Data.channelloc)
            val = get(S.channel(c),'Value');
            if val == 1
                set(S.channel(c),'backg','g')
                chan(c) = c; %#ok<AGROW>
                Channels = chan(find(chan~=0)); %#ok<FNDSB>
            else
                set(S.channel(c),'backg',col_start)
                ch = find(Channels == c);
                chan(ch) = 0; %#ok<FNDSB,AGROW>
                Channels = chan(find(chan~=0)); %#ok<FNDSB>
            end
        end
    end
% Sellecting all or non
    function [] = select_call(varargin)
        if ChannelSelect == 0
            set(S.selectCheck,'str','Select None')
            for q = 1:length(Data.channelloc)
                set(S.channel(q),'value',1,'backg','g')
            end
            Channels = 1:length(Data.channelloc);
            ChannelSelect = 1;
        else
            set(S.selectCheck,'str','Select All')
            for q = 1:length(Data.channelloc)
                set(S.channel(q),'value',0,'backg',col_start)
            end
            Channels = [];
            ChannelSelect = 0;
        end
    end
%% Non call-back functions
% Call function for closing waitbar
    function close_waitbar(~,~)
        delete(gcbf)
    end
% Play sound
    function [standard] = makeSound(varargin)
        freq = [1000,600];
        rfreq=2*pi*freq;
        
        %Calculate modulated signal
        Ts=linspace(0,0.062,5000*0.062); % Arbitruary 5000 for samples of cosine sound wave
        if rand() < 0.3 && standardCount < 1
            snd=cos(rfreq(2)*Ts);
            standardCount = 3;
            standard = -1;
        else
            snd = cos(rfreq(1)*Ts);
            standardCount = standardCount - 1;
            standard = 1;
        end
        %Output
        soundsc(snd,5000);
    end
% filter singularity
    function [output] = filter_singularity(input) %#ok<DEFNU>
        bad = 0;
        channel_num = size(input,1);
        for j = 1:channel_num
            for i = 2:127
                if input(j,i) == input(j,i+1) && input(j,i) == input(j,i+2) ...
                        && input(j,i) == input(j,i+3)
                    bad = 1;
                    break
                elseif abs(input(j,i)) > 1000* abs(input(j,i-1)) ...
                        || abs(input(j,i)) < 0.001* abs(input(j,i-1))
                    bad = 1;
                    break
                end
            end
        end
        if bad == 0
            output = input';
        else 
            output = 0;
        end
    end
    function [superposed,time] = filter (data, ch, low, high)
        FFTprop.deltaF = 1;
        FFTprop.sampleF = 128;
        FFTprop.nfft = FFTprop.sampleF/FFTprop.deltaF;
        FFTprop.window = FFTprop.sampleF/FFTprop.deltaF;
        FFTprop.noverlap = FFTprop.sampleF/(2*FFTprop.deltaF);
        Spec = zeros(FFTprop.noverlap+1,ch);
        mag = [];
        ang = [];
        % Build a filter
        filt = [zeros(low,1);ones(high-low+1,1); ...
            zeros(65-high-1,1)];
        for i = 1:ch
            %  CAR
            for j=1:ch
                data(:,j) = data(:,j)-mean(data(:,j));
            end
            [Spec(:,i),F] = spectrogram(data(:,i),FFTprop.window, ...
                FFTprop.noverlap,FFTprop.nfft,FFTprop.sampleF);
            mag = [mag,abs(Spec(:,i))]; %#ok<AGROW>
            ang = [ang,unwrap(angle(Spec(:,i)))]; %#ok<AGROW>
            % Apply the filter
            mag(:,i) = mag(:,i).*filt;
            ang(:,i) = ang(:,i).*filt;
            % Superpose consine waves
            time = -.2:1/130:.8-(1/130);
            mode = [];
            for j=1:length(mag)
                mode = [mode;mag(j,i)*cos(2*pi*F(j)*time+ang(j,i))]; %#ok<AGROW>
             end
            superposed(i,:) = sum(mode)'; %#ok<AGROW>
        end
    end
end