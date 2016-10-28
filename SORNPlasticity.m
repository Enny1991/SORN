function TrainedNetwork = SORNPlasticity(Network,Input)
%% SORNPLasticity v1.8
%  This function takes in input a SORN Network and an Input Matrix which is 
%  n-by-m where n is the number of neuron in the network (so specified 
%  by Network.Ne) and m the number of steps. It can perform different kind
%  of plasticity specified by Network flags (STDP,iSTDP,IP,SP). With the
%  flag Network.testOnline the function tests the Network performance on a 
%  random generated input every 5000 steps. 

%%Set up Network-dependent parameters
TrainedNetwork = Network;
TrainedNetwork.res = [];
TrainedNetwork.states= [];
Ne = Network.Ne;
Ni = floor(0.2*Ne);
TrainedNetwork.Ni = Ni;
lambda = Network.lambda;
Temax = Network.Temax;
Timax = Network.Timax;
plasticitySteps = size(Input,2);
%Excitatory-Inhinitory matricies are specified 'from-to' if one looks at the 
%subscript 
Wei = normWeights(rand(Ni,Ne)); 
if Network.iSTDP == 1
Wie = sparseEI(Ne,Ni,Network.probInhib); %Sparse if Inhibitory plasticity is activated
else
Wie = normWeights(rand(Ne,Ni)); 
end

Wee = sparseEE(Ne,lambda,Network.seed);
The = rand(Ne,1)*Temax; %Excitatory Thresholds 
Thi = rand(Ni,1)*Timax; %Inhibitory Thresholds 
Hip = 2*(Network.Nu/Ne); %Target Activity
ind_w = find(Wee>0);
ind_i = find(Wie>0);
prePlastWee = Wee;

%Saving Parameters into the Structure
Network.Ni = Ni;
Network.Wee = Wee;
Network.Wei = Wei;
Network.Wie = Wie;
Network.The = The;
Network.Thi = Thi;


outputMatrix = zeros(Ne,1);
xt1 = outputMatrix;
inAct = zeros(Ni,1);
%activityInternal = zeros(Ne,plasticitySteps);


% Create input for test online
if Network.testOnline == 1
Network.nWords=6000;

[Matricies.in1,Matricies.tea1,~,Matricies.ind1] = createRealInput(Network,1); 
Network.runType=2;
[Matricies.in2,Matricies.tea2,Matricies.ran,Matricies.ind2] = createRealInput(Network,2); 
end

t0 = clock;
t1=0; 
k=0;

for i = 1:plasticitySteps
    
    newInput = Input(:,i);
    a = Wee*xt1  - Wie*inAct - The ;
    
    if Network.noise == 1 %%%% WITH NOISE
    n = Network.sigmaE*randn(12,1);
    n = expand(n,[Network.Nu 1]);
    noise = [n;zeros(Network.Ne-12*Network.Nu,1)];
    xt2 = sign(sign(a + noise + newInput)+1); 
    inAct = sign(sign(Wei*xt2  - Thi ) +1);
    else  %%%% NO NOISE
    xt2 = sign(sign(a + newInput)+1); 
    inAct = sign(sign(Wei*xt2  - Thi) +1);
    end
    
    %%%%%% STDP
    if Network.STDP == 1
    delta = Network.eta * ( xt2*xt1'- xt1*xt2');
    Wee(ind_w) = Wee(ind_w) + delta(ind_w);        % STDP affects only connected neurons
    Wee   = min(Wee, ones(Network.Ne,Network.Ne));   % clip weights to [0,1] 
    Wee   = max(Wee, zeros(Network.Ne,Network.Ne));
    Wee = normWeights(Wee);
    end
    %%%%%% STDP
    
    %%%% iSTDP
    if Network.iSTDP == 1
    deltaI = Network.eta * ( inAct * (1 - (1 + 1/0.1) * xt2'));
    Wie(ind_i) = Wie(ind_i) + deltaI(ind_i);
    Wie   = min(Wie, ones(Network.Ne,Ni));   % clip weights to [0,1] 
    Wie   = max(Wie, zeros(Network.Ne,Ni));
    Wie = normWeights(Wie);
    end
    %%%% iSTDP
    
    %%%%%%%%% IP
    if Network.IP == 1
    The = The + Network.eta * (xt2 - Hip);
    The   = max(The, zeros(size(The)));
    %evolThe(:,i) = The;
    end
    %%%%%%%%% IP
    
    %%%%%%%%%% SP
    if Network.SP == 1
    if rand(1) <= Network.probNewConn
        [randRow,randRowIndex] = datasample(Wee,1);
        [randPos,randColumnIndex] = datasample(randRow,1);
        while randPos~=0 || randRowIndex==randColumnIndex
            [randRow,randRowIndex] = datasample(Wee,1);
        [randPos,randColumnIndex] = datasample(randRow,1);
        end
        Wee(randRowIndex,randColumnIndex) = Network.eta;
        ind_w = find(Wee>0);
    end
    end
    %%%%%%%%%%% SP
    
    xt1 = xt2;
    %activityInternal(:,i) = xt2;
   
    %% Test during running
    if Network.testOnline == 1
     if i == 1|| mod(i,10000)==0
         
    Network.Wee = Wee;
    Network.Wei = Wei;
    Network.Wie = Wie;
    Network.The = The;
    Network.Thi = Thi;
    Network.prePlastWee = prePlastWee;
    %Network.activityInternal=activityInternal;
    %Network.evolThe = evolThe;
    [actualTest,NN,class] = totalTest(Network,Matricies);
    %[actualTest2,NN,class] = totalTest(Network);
    %TrainedNetwork.Y = NN.Y;
    %TrainedNetwork.labels = NN.predLab; 
    TrainedNetwork.res(k+1)=actualTest{1}(1);
    TrainedNetwork.states{k+1}=NN.states;
    if i == 1
	TrainedNetwork.static = actualTest{1}(1);
    end	
    k=k+1;
    ms1 = round(etime(clock,t0) * 1000);
    ms2=ms1-t1;
    t1=ms1;
    disp(['After ',num2str(i),' steps: ',num2str(actualTest{1}(1)), '%',' @ ',class,' in: ',num2str(floor(ms2/60000)),'m ',num2str(floor(mod(ms2,60000)/1000)),'s '])
    if(actualTest{Network.classToSee}(1)==100)
        TrainedNetwork.res = max(TrainedNetwork.res);
        break
    end
     end
    else
       if i == 100|| mod(i,5000)==0
           disp(num2str(i))
         %[a,b,c]=multipleLyapunovTest(Network);
         %d = pseudoLyapunov(a,b,c);
         %disp(['Actual Lyapunov Exponent: ',num2str(d)])
       end
    end

end

[M,I] = max(TrainedNetwork.res);

TrainedNetwork.res = M;
TrainedNetwork.states = TrainedNetwork.states(I);
TrainedNetwork.Wee = Wee;
TrainedNetwork.Wei = Wei;
TrainedNetwork.Wie = Wie;
TrainedNetwork.The = The;
TrainedNetwork.Thi = Thi;
TrainedNetwork.prePlast = prePlastWee;
%TrainedNetwork.activityInternal=activityInternal;
%TrainedNetwork.evolThe = evolThe;
