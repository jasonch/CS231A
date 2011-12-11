% this function computes histograms for each image in SIFT and returns a 
% k x n matrix, where k is the number of vocabulary and n is the number of images

function histogram = computeHistograms(sifts, vocabulary, data_path, levels)
  histogram = zeros(size(vocabulary,1)*sum(4.^(0:levels-1)), size(sifts, 1));
  global display_sift;
  
  size(sifts,1)
  for i=1:size(sifts,1)
    % [histogram(:,i), sift_to_word] = computeBoWHistogram(sifts(i).vldsift.desc, vocabulary);
    histogram(:,i) = spatialHistogramWrapper(sifts(i).vldsift, vocabulary, levels);
    if (display_sift && i < 4)
      filepath = [data_path 'images\' sifts(i).ID '.JPEG'];
      try 
          img = imread(filepath);
          [Inr, Inc, nb] = size(img);
          figure; imagesc(img); hold on;
          plot((sifts(i).vldsift.x' * Inc), (sifts(i).vldsift.y' * Inr), 'none.dr');
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

function histogram = spatialHistogramWrapper(sifts, vocab, levels) 
  vocab_size = size(vocab,1);
  histogram = zeros(vocab_size*sum(4.^(0:levels-1)), 1);
  gridnum = 1;

  % find bounding box of our object
  minX = min(sifts.x);
  maxX = max(sifts.x);
  minY = min(sifts.y);
  maxY = max(sifts.y);

  for lv=1:levels
    xbounds = linspace(minX,maxX+0.1,2^(lv-1)+1);
    ybounds = linspace(minY,maxY+0.1,2^(lv-1)+1);
    for col=1:2^(lv-1)
      for row=1:2^(lv-1)
        indices = sifts.x >= xbounds(col) ...
                & sifts.x <  xbounds(col+1) ...
                & sifts.y >= ybounds(row) ...
                & sifts.y <  ybounds(row+1);
        [bow_histogram, ~] = computeBoWHistogram(sifts.desc(:, indices), vocab);
        histogram(vocab_size*(gridnum-1)+1: gridnum*vocab_size) = bow_histogram;
        gridnum = gridnum+1;
      end
    end
  end
end
