% this function computes histograms for each image in SIFT and returns a 
% k x n matrix, where k is the number of vocabulary and n is the number of images

function histogram = computeHistograms(sifts, vocabulary)
  histogram = zeros(size(vocabulary, 1), size(sifts, 1));
  global display_sift;
  
  for i=1:size(sifts,1)     
    [histogram(:,i), sift_to_word] = computeBoWHistogram(sifts(i).vldsift.desc, vocabulary);
    if (display_sift && i < 4)
      filepath = ['./images/' sifts(i).ID '.JPEG'];
      try 
          img = imread(filepath);
          [Inr, Inc, nb] = size(img);
          figure; imagesc(img); hold on;
          %plot((sifts(i).vldsift.x' * Inc), (sifts(i).vldsift.y' * Inr), 'none.dr');
          features = [];
          features = [features (sifts(i).vldsift.x' * Inc)];
          features = [features (sifts(i).vldsift.y' * Inr)];
          features = [features ones(size(sifts(i).vldsift.x, 2),1)];%2.0.^(-1.0 * sifts(i).vldsift.scale(1:1000)')];%sifts(i).vldsift.scale(1:10)'];
          plotsiftdescriptor(sifts(i).vldsift.desc, features');
          hold off;
      catch e
          disp('image read didnt work');
      end
    end     
  end
end
