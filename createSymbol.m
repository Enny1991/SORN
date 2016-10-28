function [symbolsBinary,symbolsVariable,teachers] = createSymbol(length,pools,Nu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function creates random pattern of types:
%   - 'binary': fixed values but with different R
%   - 'variable': valiarble values with different R
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

symbolsBinary = cell(1,5);
symbolsVariable = cell(1,5);
teachers = cell(1,5);
r = 0:0.1:0.4;
base = randi(2,length,pools)-1;

for f = 1:5

    R = r(f);

symbolBinary = zeros(length,pools);
symbolVariable = zeros(length,pools);
activations = eye(2^pools);
lookUpTable = zeros(2^pools,pools);
for i = 1:2^pools;
    lookUpTable(i,:)=str2double(regexp(dec2bin(i-1,pools),'\d','match'));
end

teacher  = zeros(length,2^pools);





symbolBinary(base==1) = R;
symbolBinary(base==0) = 1 - R;

for i=1:length
    for j=1:pools
        if base(i,j) == 0
            symbolVariable(i,j) = rand(1)*(R)+(1-R);
        else
            symbolVariable(i,j) = rand(1)*(R);
        end
    end
end

for i = 1:length
    teacher(i,:) = activations(ismember(lookUpTable,base(i,:),'rows')==1,:);
end



symbolsBinary{f} = expand(symbolBinary,[1,Nu]);
symbolsVariable{f} = expand(symbolVariable,[1,Nu]);
teachers{f} = teacher;


end
