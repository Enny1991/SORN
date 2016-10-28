function Wee = sparseEI(Ne,Ni,prob)
Wee = rand(Ne,Ni);

%create sparse
for j=1:Ne
for i=1:Ni 
if(rand(1)<=prob) 
Wee(j,i)=rand(1); 
else Wee(j,i)=0;    
end
end
end

%normalize
Wee = normWeights(Wee);
end