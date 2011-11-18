% this function accepts SIFTs as a Nx128 matrix, where each row is a SIFT feature
% and uses K-means to compute K-clusters on the matrix
% returns the centroids of each cluster in the Kx128 result

function vocabulary = computeVocabularySet(sifts,k)
  siftMatrix = convertSIFT2Matrix(sifts);
  [placeholder, vocabulary] = kmeans(siftMatrix, k);
  vocabulary = vocabulary';
end


function siftMatrix = convertSIFT2Matrix(siftsObj)
  siftMatrix = [];
  for i=1:size(siftsObj,1)
    siftMatrix = [siftMatrix; siftsObj(i).vldsift.desc'];
  end
end
