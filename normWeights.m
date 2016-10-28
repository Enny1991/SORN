function out = normWeights(M)
%% Use a matrix operation to normalize weights:
%   Spdiags makes a sparse matrix.  The row-wise sum is placed along the
%   diagonal of this matrix, and then the backslash operator is used to
%   ensure that it is 0-safe and prevent NaNs.
numrows = size(M,1);
out = spdiags(sum(M,2), 0, numrows, numrows) \ M ;
end