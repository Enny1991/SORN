function TrainedNetwork = SORNTraining(Network,Input,Teacher,index)
%% SORNTraining v1.2
%  This function takes in input 
%  - A SORN network 
%  - An Input Matrix 
%  - A Teacher Matrix
%  - The indeces of where every sample in the input finishes
%  Runs the inputs into the Network, collects necessry data (Activation or 
%  Decay Vector) and trains the chosen classifier. 
TrainedNetwork = Network;
xt1 = zeros(Network.Ne,1);
inAct = zeros(Network.Ni,1);
X = zeros(Network.Ne,size(Input,2));
M1=zeros(Network.Ne,size(Input,2));
M2 = zeros(Network.Ne,size(Input,2));
switch Network.classifier
    case 1
        Y = Teacher(index,2:end)';
    case 2
        Y = Teacher(index,:)';
end
Wout = rand(Network.Ne-12*Network.Nu+1,10);

for i = 1: size(Input,2)
    newInput = Input(:,i);
    if Network.analogInput == 1
    newInput(newInput==1) = rand(1)*Network.excursionAnalog +(1-Network.excursionAnalog);
    newInput(newInput==0) = rand(1)*Network.excursionAnalog;
    end
    a = Network.Wee*xt1  - Network.Wie*inAct - Network.The ;
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
	X(:,i) = xt2;%internal;%(12*Network.Nu+1:end);
    xt1 = xt2;
end

%TrainedNetwork.activityDuringTrain = X;

% Extracting Decay Vector
M1 = X;
M2 = X;
for i = 2:size(Input,2)
    M1(:,i)=(M1(:,i-1)*Network.discountFactor(1)+M1(:,i));
    M2(:,i)=(M2(:,i-1)*Network.discountFactor(2)+M2(:,i));
end


%% CLASSIFICATION
switch Network.classifier 
    case 1 %% LINEAR REGRESSION
        %reg = 1e-8;  % regularization coefficient
        M1 = M1(:,index);
        M1=[ones(1,size(M1,2));M1];
        TrainedNetwork.Wout1 = Y * pinv(M1);
        M2 = M2(:,index);
        M2=[ones(1,size(M2,2));M2];
        TrainedNetwork.Wout2 = Y * pinv(M2);
    case 2 %% SVM
        %X = X(:,index);
	M1 = M1(:,index);
	M2 = M2(:,index);
        %% MULTIPLE SVMs
        %for i=1:5
        %    TrainedNetwork.model{i} = svmtrain(Y(i+1,:)',M','-q -t 2');
        %end 
        %% SIGNLE SVM
        %TrainedNetwork.model = svmtrain(Y',X', '-q -s 0 -t 2 -c 100'); 
        TrainedNetwork.model1 = svmtrain(Y',M1', '-q -s 0 -t 2 -c 1 -b 1');
        TrainedNetwork.model2 = svmtrain(Y',M2', '-q -s 0 -t 2 -c 1 -b 1');
    case 3 %% PARALLEL PERCEPTRON
        tic
        X=[ones(1,size(X,2));X];
        X = X(:,index);
        for i = 1:length(index)
            input = X(:,i);
            label = Y(:,i);
            out = input'*Wout;
            err = label - out';
            upW = repmat(input,1,10).*Wout;
            deltaW = 0.001*err;
            Wout = Wout + upW.*repmat(deltaW',Network.Ne-12*Network.Nu+1,1);
            Wout = min(ones(size(Wout)),Wout);
        end
        TrainedNetwork.Wout = Wout;
end
end
