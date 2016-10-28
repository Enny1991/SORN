
%% -------------------------
% BEFORE I print some stuff
% ----------------------------
FILENAME_HEADER = randi(100,1,1);
NETWORK = 200;
DURATION = 5;
ENDCLASS = 10;
BOTH = 1;
TRAIN = 7;
NETFILE = 'nnn';
LAMBDA = 0.1;
NOISE = 30;
fprintf('Filename header: %s.\n', FILENAME_HEADER);
fprintf('Ne: %i.\n', NETWORK);
fprintf('Duration set to: %2.3f.\n', DURATION);
fprintf('Number classes: %i.\n', ENDCLASS);
fprintf('Both 0-No 1-Yes: %i.\n', BOTH);
fprintf('Number Train: %i.\n',TRAIN)
%fprintf('Lambda: %.7f\n',LAMBDA)
fprintf('File to test: %s.\n', NETFILE);
SAVEVARS = {'result','Network'};
%% ----------------------------
% EXECUTE
% -----------------------------
%cd .. 
%addpath(genpath('.'))
current = zeros(1,1);

for j = 1:1 % number of repetetion
        
Network.Ne = NETWORK;
Network.Nu = ceil(Network.Ne*0.025);
Network.Temax = 0.3; 
Network.Timax = .7;
Network.eta = 0.0001;
switch NETWORK
	case 200
		Network.lambda = LAMBDA;
	case 400
		Network.lambda = LAMBDA;
	case 800
		Network.lambda = LAMBDA;
	case 1200
		Network.lambda = LAMBDA;
end
Network.nWords = 7500;
Network.discountFactor = [.85 .9];

%FLAGS
Network.classifier = 1; %1 for LR / 2 for SVM / 3 for PPs
Network.single = 1; %1 for multiple 2 for single
Network.classToSee = 1;
Network.plastOn = 1;
Network.STDP = 1;
Network.iSTDP=0;
Network.SP = 0;
Network.IP = 1;
Network.noise = 0;
Network.testOnline = 1;
Network.analogInput = 0;
Network.runType = 1; % 1 for LONG / 2 for SHORT
Network.classes =[1:ENDCLASS];%s((j-1)*20+1:j*20);%wow(j);
Network.nTest = 1;
Network.nTrain = TRAIN;
Network.space = 20;
Network.both = BOTH; %men and female
Network.noise = NOISE;
Network.seed  = str2double(FILENAME_HEADER);
%%

[inputMatrix] = createRealInput(Network,1);
Network = SORNPlasticity(Network,inputMatrix');

current(j) = Network.res;


end
    result(1)=mean(current);
    result(2)=std(current);
    


%% ----------------------
% POST EXECUTE
% -----------------------
whos
% Grab a date part
%filename_datepart = datestr(now(),'yy_mm_dd-HH_MM_SS');
% Grab Ne to put in the filename
filename_Ne_part = sprintf('Ne_%i', NETWORK);
filename_lambda_part = sprintf('Lambda_%.6f',LAMBDA);
filename_both_part = sprintf('Both_%i', BOTH);
filename_train_part = sprintf('Train_%i',TRAIN);
filename_class_part = sprintf('Classes_%i',ENDCLASS);
%static = sprintf('%2.2f',Network.static);
if NOISE~=30
filename_noise_part = sprintf('Noise_%i',NOISE);
else
filename_noise_part = sprintf('clean');
end
% put perf
filename_perf_part = sprintf('Perf_%2.2f', result(1));
% Put it all together
full_filename = sprintf('%i_%s_%s_%s_%s_%s_%s.mat',FILENAME_HEADER,filename_Ne_part,filename_class_part,filename_lambda_part, filename_both_part,filename_train_part,filename_perf_part);
% And save the data
fprintf('SAVING OUTPUT: %s.\n', full_filename);
save(full_filename, SAVEVARS{:});
%% EXIT AND END
fprintf('Done.\n');



