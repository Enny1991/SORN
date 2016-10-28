function TrainedNetwork = SORNTesting(Network,Input,Teacher,index)
%% SORNTesting v1.2
%  This function takes in input 
%  - A SORN network 
%  - An Input Matrix 
%  - A Teacher Matrix
%  - The indeces of where every sample in the input finishes
%  Runs the inputs into the Network, collects necessry data (Activation or 
%  Decay Vector) and extracts the output depending on the classifier chosen. 
TrainedNetwork = Network;
xt1 = zeros(Network.Ne,1);
inAct = zeros(Network.Ni,1);
outputMatrix = zeros(Network.Ne,size(Input,2));
% M1 = zeros(Network.Ne,size(Input,2));
% M2 = zeros(Network.Ne,size(Input,2));
Y = Teacher(index,:);

for i = 1: size(Input,2)
    a = Network.Wee*xt1  - Network.Wie*inAct - Network.The ;
    newInput = Input(:,i);
    if Network.analogInput == 1
    newInput(newInput==1) = rand(1)*Network.excursionAnalog +(1-Network.excursionAnalog);
    newInput(newInput==0) = rand(1)*Network.excursionAnalog;
    end
    
    if Network.noise == 1
    n = Network.sigmaE*randn(12,1);
    n = expand(n,[Network.Nu 1]);
    noise = [n;zeros(Network.Ne-12*Network.Nu,1)];
    xt2 = sign(sign(a + noise + newInput)+1); 
    inAct = sign(sign(Network.Wei*xt2  - Network.Thi ) +1);
    else
    xt2 = sign(sign(a + newInput)+1); 
    inAct = sign(sign(Network.Wei*xt2  - Network.Thi) +1);
    end
    %internal = sign(sign(a)+1); 
    outputMatrix(:,i) = xt2;%internal;%(12*Network.Nu+1:end)';
    xt1 = xt2;
end

% Extracting Decay Vector
M1 = outputMatrix;
M2 = outputMatrix;
for i = 2:size(Input,2)
    M1(:,i)=(M1(:,i-1)*Network.discountFactor(1)+M1(:,i));
    M2(:,i)=(M2(:,i-1)*Network.discountFactor(2)+M2(:,i));
end

M1 = M1(:,index);
M2 = M2(:,index);
%realOut=outputMatrix;

TrainedNetwork.states = M2;
%TrainedNetwork.rr = realOut;
switch Network.classifier
    case 1 %% LINEAR REGRESSION
        TrainedNetwork.outputMatrix1 =  Network.Wout1 * [ones(1,size(M1,2));M1];
        TrainedNetwork.outputMatrix2 =  Network.Wout2 * [ones(1,size(M2,2));M2];

    case 2 %% SVM
        %% MULTIPLE SVMs
        %for i=1:5
         %   [TrainedNetwork.predLab{i},~,TrainedNetwork.prob{i}] = svmpredict(Y(:,i+1),realOut',Network.model{i},'-q');
        %end
        %% SIGNLE SVM
        [TrainedNetwork.predLab1,TrainedNetwork.acc1,TrainedNetwork.prob1] = svmpredict(Y,M1',Network.model1,'-q -b 1');
	[TrainedNetwork.predLab2,TrainedNetwork.acc2,TrainedNetwork.prob2] = svmpredict(Y,M2',Network.model2,'-q -b 1');
        TrainedNetwork.Y =Y;
    case 3 %% PARALLELE PERCEPTRON
        TrainedNetwork.outputMatrix = Network.Wout'*[ones(1,size(outputMatrix(:,index),2));outputMatrix(:,index)];
end

end
