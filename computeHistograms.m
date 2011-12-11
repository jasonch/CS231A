% this function computes histograms for each image in SIFT and returns a 
% k x n matrix, where k is the number of vocabulary and n is the number of images

function histogram = computeHistograms(sifts, vocabulary, data_path, levels)
  global display_sift;
  global jitter_on;
  global jitter_grid_size;
  
  if jitter_on
    histogram = zeros(size(vocabulary,1)*sum(4.^(0:levels-1)), size(sifts, 1));   
  else
    histogram = zeros(size(vocabulary,1)*sum(4.^(0:levels-1)), jitter_grid_size^2 * size(sifts, 1));
  end
  
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
  global jitter_on;
  global jitter_grid_size;
  
  vocab_size = size(vocab,1);
  if jitter_on
    histogram = zeros(vocab_size*sum(4.^(0:levels-1)), 1);
  else
    histogram = zeros(vocab_size*sum(4.^(0:levels-1)), jitter_grid_size^2);
  end
  gridnum = 1;

  % find bounding box of our object
  minX = min(sifts.x);
  maxX = max(sifts.x);
  minY = min(sifts.y);
  maxY = max(sifts.y);
  
  if jitter_on
    jitter_half_size = (jitter_grid_size - 1)/2;
  else
    jitter_half_size = 0;
  end

  for i=-jitter_half_size:jitter_half_size
      for j=-jitter_half_size:jitter_half_size
          for lv=1:levels
            xbounds = linspace(minX,maxX+0.1,2^(lv-1)+1);
            ybounds = linspace(minY,maxY+0.1,2^(lv-1)+1);
            jitter_x = i * (maxX - minX) * 2^(1-lv) * (2^-4);
            jitter_y = j * (maxY - minY) * 2^(1-lv) * (2^-4);
            jitter_idx = (i+jitter_half_size)*jitter_grid_size + j + jitter_half_size + 1;
            for col=1:2^(lv-1)
              for row=1:2^(lv-1)
                indices = (sifts.x + jitter_x) >= xbounds(col) ...
                        & (sifts.x + jitter_x) <  xbounds(col+1) ...
                        & (sifts.y + jitter_y) >= ybounds(row) ...
                        & (sifts.y + jitter_y) <  ybounds(row+1);
                [bow_histogram, ~] = computeBoWHistogram(sifts.desc(:, indices), vocab);
                if jitter_on
                  histogram(vocab_size*(gridnum-1)+1: gridnum*vocab_size, jitter_idx) = bow_histogram;
                else
                  histogram(vocab_size*(gridnum-1)+1: gridnum*vocab_size) = bow_histogram;
                end
                gridnum = gridnum+1;
              end
            end
          end
      end
  end
end
