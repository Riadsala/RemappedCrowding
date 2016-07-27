%% How long (in seconds) is the target frame shown for?
params.targDisplayTime = .05;

%% cross paramters, in pixels!
params.w = 4;       % width of lines
params.offset = 6;  % pixel offset to define target
params.letterSpace = 9;
params.flankerIntensity = 168;
params.targetIntensity  = 168;

%% define box locations and line width
params.N = 38;
params.delta = 2*params.N;
params.boxW = 2;
params.boxN = 28;

%% define box colours
params.bkgrndColour = 125;
params.boxColour = [50, 50, 50];
params.tboxColourSacc = [175, 25, 50];
params.tboxColourFix = [25, 50, 200];

%% how accurate do eyemovements have to be (in pixels)
params.saccadeThresh = 100;
% guess saccadic latency
params.initSaccadeLatencyEst = 0.2;
params.targetDisplayLatency = params.initSaccadeLatencyEst - 0.1;

%% other
params.chinrestDist = 550;
params.noiseMaskStd = 25;
params.gaborAngles = [-pi/4, pi/4];
