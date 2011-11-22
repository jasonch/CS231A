% this function computes histograms for each image in SIFT and returns a 
% k x n matrix, where k is the number of vocabulary and n is the number of images

function histogram = computeHistograms(sifts, vocabulary)
  histogram = zeros(size(vocabulary, 1), size(sifts, 1));
  global display_sift;
  
  for i=1:size(sifts,1)
    if (display_sift && i < 3)
      filepath = ['./images/' sifts(i).ID '.JPEG'];
      try 
          img = imread(filepath);
          [Inr, Inc, nb] = size(img);
          figure; imagesc(img); hold on;
          features = [];
          features = [features (sifts(i).vldsift.x' * Inc)];
          features = [features (sifts(i).vldsift.y' * Inr)];
          features = [features ones(size(sifts(i).vldsift.x, 2),1)];%2.0.^(-1.0 * sifts(i).vldsift.scale(1:1000)')];%sifts(i).vldsift.scale(1:10)'];
          plotsiftdescriptor(sifts(i).vldsift.desc, features');
          hold off;
      catch e
      end
    end      
    histogram(:,i) = computeBoWHistogram(sifts(i).vldsift.desc, vocabulary);
  end
end
