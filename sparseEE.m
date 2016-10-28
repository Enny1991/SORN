
function Wee = sparseEE(Ne,lambda,seed)
rand('seed',seed)
Wee = rand(Ne,Ne);

%create sparse
for j=1:Ne
for i=1:Ne 
    if i ~= j
if(Wee(j,i) <= lambda) 
Wee(j,i)=rand(1); 
else Wee(j,i)=0;    
end
    else
        Wee(j,i)=0; %% no self connections
    end
end
end

%normalize
Wee = normWeights(Wee);
end
