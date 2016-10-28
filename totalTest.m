function [score,Network,class,randOrder] = totalTest(Network,Matricies)

if(nargin==1)
    Network.nWords = 300;
    Network.runType = 2;
    [inputMatrix1,teacherMatrix1,~,index1] = createRealInput(Network,0); 
    [inputMatrix2,teacherMatrix2,randOrder,index2] = createRealInput(Network,0); 
else
   inputMatrix1=Matricies.in1;
   inputMatrix2=Matricies.in2;
   teacherMatrix1=Matricies.tea1;
   teacherMatrix2=Matricies.tea2;
   randOrder=Matricies.ran;
   index1=Matricies.ind1;
   index2=Matricies.ind2; 
end

score = cell(1,11);
Network = SORNTraining(Network,inputMatrix1',teacherMatrix1,index1);
Network = SORNTesting(Network,inputMatrix2',teacherMatrix2,index2);
%labels = Network.predLab;
%Y = Network.Y;
switch Network.classifier
    case 1
        %score{1}=0;
        
        shotMatrix1 = sign(...
        Network.outputMatrix1 - repmat(max(Network.outputMatrix1),size(teacherMatrix2(index2,2:end),2),1)...
        )+1;
        shotMatrix2 = sign(...
        Network.outputMatrix2 - repmat(max(Network.outputMatrix2),size(teacherMatrix2(index2,2:end),2),1)...
        )+1;
        shotMatrix1(shotMatrix1 == 1) = Network.outputMatrix1(shotMatrix1 == 1); 
        shotMatrix2(shotMatrix2 == 1) = Network.outputMatrix2(shotMatrix2 == 1); 

        single1 = sum(shotMatrix1);
        single2 = sum(shotMatrix2);
        maximum = single1>single2;
        compressedT = zeros(1,length(index2));
        finalShot = zeros(1,length(index2));
        tt = teacherMatrix2(index2,2:end);
        for i = 1: length(index2)
           compressedT(i) = find(tt(i,:)==1); 
        end
        for i = 1:length(index2)
           if(maximum(i))
               finalShot(i) = find(shotMatrix1(:,i)~=0);
           else
               finalShot(i) = find(shotMatrix2(:,i)~=0);
           end
        end
        
        error = finalShot - compressedT;
        
        score{1} = 100 - (numel(find(error ~= 0)))/length(index2)*100;
        
    case 2
        diff  = Network.predLab1 - Network.predLab2;
        listDiff = find(diff~=0);
        listVal1 = Network.predLab1(listDiff);
        listVal2 = Network.predLab2(listDiff);
        finalLab = zeros(1,500);
        finalLab(diff==0) = Network.predLab1(diff==0);
        for i = 1:length(listDiff)
            if Network.prob1(listDiff(i),listVal1(i))>Network.prob2(listDiff(i),listVal2(i))
                finalLab(listDiff(i)) = Network.predLab1(listDiff(i));
            else
                finalLab(listDiff(i)) = Network.predLab2(listDiff(i));
            end
        end
        
        
        for i = 1:length(listDiff)
            if Network.prob1(listDiff(i),listVal1(i)-1)>Network.prob2(listDiff(i),listVal2(i)-1)
                finalLab(listDiff(i)) = Network.predLab1(listDiff(i));
            else
                finalLab(listDiff(i)) = Network.predLab2(listDiff(i));
            end
        end
        error = Network.Y - finalLab';
        score{1}=100 - (numel(find(error ~= 0)))/length(index2)*100;
    case 3
        shotMatrix = sign(sign(Network.outputMatrix - repmat(max(Network.outputMatrix),size(teacherMatrix2(index2,2:end),2),1))+1);
        aaa=teacherMatrix2(index2,2:end)' - shotMatrix;
        b = sum(abs(aaa));
        score{1} = 100-size(find(b~=0),2)/length(b)*100;
end
      

%% SAVE OPTIONS
% Saving at this point is necessary in order to get all the information
% about the network at the point during plasticity 
class = datestr(now);

end
