
for k= 10
Collection = cell(1,100);
    
for i = 1:100
   
    [WORD1BINARY,WORD1VARIABLE,TEACHER1] = createSymbol(k,6,5);
    [WORD2BINARY,WORD2VARIABLE,TEACHER2] = createSymbol(k,6,5);
    [WORD3BINARY,WORD3VARIABLE,TEACHER3] = createSymbol(k,6,5);
    %[WORD4BINARY,WORD4VARIABLE,TEACHER4] = createSymbol(k,6,5);
    Collection{i}{1} = WORD1BINARY;
    Collection{i}{2} = WORD2BINARY;
    Collection{i}{3} = WORD3BINARY;
    %Collection{i}{4} = WORD4BINARY;
    Collection{i}{4} = WORD1VARIABLE;
    Collection{i}{5} = WORD2VARIABLE;
    Collection{i}{6} = WORD3VARIABLE;
    %Collection{i}{8} = WORD4VARIABLE;
    Collection{i}{7} = TEACHER1;
    Collection{i}{8} = TEACHER2;
    Collection{i}{9} = TEACHER3;
    %Collection{i}{12} = TEACHER4;
end


saveto = sprintf('Pack_%i_6p_3s.mat',k);
save(saveto,'Collection')
end



