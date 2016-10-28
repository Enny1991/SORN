function [inputMatrix,teacherMatrix,randOrder,index] = createRealInput(Network,testOFF)
%% createRealInput v2.5
%  Creates and input and a teacher matrix for the SORN.
%  Depending on the value of Network.runType it can create:
%  1 - Create an input of Network.nWords randomly selected from the chosen
%  Dataset (LONG)
%  2 - A random arrangement of all the words in the Dataset (SHORT)

%load COMPLETE_7_SP
rand('seed',Network.seed);
if Network.noise~=30
toLoad = sprintf('TI46_%iDB.mat',Network.noise);
else
 toLoad = sprintf('FASTER_SINGLE_TI46.mat');
end
switch testOFF
    case 0
        load strDATA
        MFCC = STR_TRAIN;
    case 1
        MFCC_M = cell(0,0);
        MFCC_F = cell(0,0);
        load(toLoad)
	%charge male
        for i=[1,2,3,5,6,7,8]
            for j=1:length(Network.classes)
                for k=1:25
                MFCC_M=[MFCC_M,MALE{i}{Network.classes(j)}(:,k)];
                end
            end
        end
	for i = [1:7]
	    for j = 1:length(Network.classes)
		for k=1:25
		MFCC_F=[MFCC_F,FEMALE{i}{Network.classes(j)}(:,k)];
		end
	    end
	end
	


        MFCC(:,1:25*length(Network.classes)*Network.nTrain)=MFCC_M;
        if Network.both == 1 
            MFCC(:,25*length(Network.classes)*Network.nTrain+1:25*length(Network.classes)*Network.nTrain*2)=MFCC_F;
        end
    case 2
         MFCC_M = cell(0,0);
        MFCC_F = cell(0,0);
        load(toLoad)
            for j=1:length(Network.classes)
                for k=1:25
                MFCC_M=[MFCC_M,MALE{4}{Network.classes(j)}(:,k)];
                end
            end
	    for j=1:length(Network.classes)
		for k=1:25
		MFCC_F = [MFCC_F,FEMALE{8}{Network.classes(j)}(:,k)];
		end
	    end
        MFCC(:,1:25*length(Network.classes)*Network.nTest)=MFCC_M;
        if Network.both == 1
            MFCC(:,25*length(Network.classes)*Network.nTest+1:25*length(Network.classes)*Network.nTest*2)=MFCC_F;
        end
        %MFCC =  MFCC(:,10*2*max(cell2mat(MFCC(1,:)))+1 : 10*4*max(cell2mat(MFCC(1,:))));
end

%     c = setdiff(1:size(NINE_C_SEVEN_SP,2),Network.leaveOut); 
%     MFCC = NINE_C_SEVEN_SP(:,c);
 % MFCC = ALL_MEN_TEST(:,cell2mat(ALL_MEN_TEST(2,:))~=11);
   


%MFCC = MFCC(:,Network.current);

%MFCC = MFCC(:,cell2mat(MFCC(2,:))~=11);
% MFCC = TEN_C_SEVEN_SP;
posMFCC =  2;

%MFCC =F{1};
switch Network.Ne
    case 100
        for i = 1:size(MFCC,2)
        MFCC{posMFCC,i}=MFCC{posMFCC,i}(:,mod([1:Network.Ne*4],2)==0);
        MFCC{posMFCC,i}=MFCC{posMFCC,i}(:,mod([1:200],5)==0);
        MFCC{posMFCC,i}=expand(MFCC{posMFCC,i},[1 Network.Nu]);
        MFCC{posMFCC,i}=MFCC{posMFCC,i}(:,1:100);
        %MFCC{posMFCC,i}(:,mod([1:12*Network.Nu],Network.Nu)~=0)=0;
        end
        
    case 200
        for i = 1:size(MFCC,2)
        MFCC{posMFCC,i}=MFCC{posMFCC,i}(:,mod([1:Network.Ne*2],2)==0);
        %MFCC{posMFCC,i}(:,mod([1:12*Network.Nu],Network.Nu)~=0)=0;
        end
    case 400
%          for i = 1:size(MFCC,2)
%         MFCC{posMFCC,i}=expand(MFCC{posMFCC,i},[1 2]);
%         end
    case 800
        for i = 1:size(MFCC,2)
        MFCC{posMFCC,i}=expand(MFCC{posMFCC,i},[1 2]);
        end
    case 1200
         for i = 1:size(MFCC,2)
        MFCC{posMFCC,i}=expand(MFCC{posMFCC,i},[1 3]);
        end
end

% for i=1:size(MFCC,2)
%    if MFCC{2,i}==9
%        MFCC{2,i}=3;
%    end
% end
switch Network.runType
    case 1
        randOrder = randi(size(MFCC,2),Network.nWords,1);
    case 2
        randOrder = randperm(size(MFCC,2));
end
%randi(1,Network.nWords,1);
%randOrder = randi(size(MFCC,2),1,1);

nSteps=0;
for i= 1:length(randOrder)
    nSteps=nSteps+size(MFCC{posMFCC,randOrder(i)},1);
end

space = Network.space;
Nout = 11;
teacherPixel = eye(Nout);


inputMatrix = zeros(nSteps+space*length(randOrder),Network.Ne);
    count = 0;
switch Network.single 
    case 1 % A single vector of classes (1->n) in case of SVM
    teacherMatrix = zeros(nSteps+space*length(randOrder),Nout);
    for k=1:length(randOrder)
        ll = size(MFCC{posMFCC,randOrder(k)},1);
        teach = zeros(ll,Nout);
        teach(1:end-1,:)=repmat(teacherPixel(1,:),ll-1,1);
        teach(end,:)=teacherPixel(MFCC{1,randOrder(k)}+1,:);
        teach(end,1)=Nout+1;
        inputMatrix(count+1:count+ll,:) = MFCC{posMFCC,randOrder(k)};
        teacherMatrix(count+1:count+ll,:) = teach;
        teacherMatrix(count+ll+1:count+ll+space,:) = repmat(teacherPixel(1,:),space,1);
        count = count+ll+space;
    end

    %teacherMatrix=[teacherMatrix(1:end-1,:);zeros(1,Nout)];
    teacherMatrix(1,1)=1;
    %inputMatrix = [inputMatrix;zeros(1,Network.Ne)];
    index = find(teacherMatrix(:,1)==Nout+1);
    teacherMatrix(index,1)=0;
 
    case 2  % A matrix of binary vectors, one per class 
    teacherMatrix = ones(nSteps+space*length(randOrder),1);

    for k=1:length(randOrder)
        
        ll = size(MFCC{posMFCC,randOrder(k)},1);
        teach = ones(ll,1);
        teach(end)=MFCC{1,randOrder(k)}+1;
        inputMatrix(count+1:count+ll,:) = MFCC{posMFCC,randOrder(k)};
        teacherMatrix(count+1:count+ll,:) = teach;
        count = count+ll+space;
    end
    % teacherMatrix=[1;teacherMatrix(1:end-1,:);1];
    %inputMatrix = [inputMatrix;zeros(1,Network.Ne)];
    index = find(teacherMatrix(:,1)~=1);
end
end
