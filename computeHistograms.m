% this function computes histograms for each image in SIFT and returns a 
% k x n matrix, where k is the number of vocabulary and n is the number of images

function histogram = computeHistograms(sifts, vocabulary)
  histogram = zeros(size(vocabulary, 1), size(sifts, 1));
  for i=1:size(sifts,1)
    if (i < 11)
      img = ['./images/' sifts(i).ID '.jpg']
    end
    histogram(:,i) = computeBoWHistogram(sifts(i).vldsift.desc, vocabulary);
  end
end
