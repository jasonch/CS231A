function [detected_labels, decision_vals] = detectImage(test_image, model, levels, vocab)

  % returns a matrix of predicted labels, which is 1 if we decided an object (teapot) is in that region, at each level
  % the second dimension is each region in column order 
  %    -------------
  %   |  1 | 3 | ..
  %   |----|---|---
  %   |  2 | 4 | ..
  %    -------------
  
  %detected_labels = zeros(sum((1:levels).^2),1);
  %decision_vals = zeros(sum(1:levels).^2,1);
  detected_labels = [];
  decision_vals = [];
  
  vocab_size = size(vocab,1);
  
  bins_all_levels = zeros(sum((1:levels).^2), vocab_size);
  
  for i=1:levels
    % for each level, distribute the sift descriptors into their corresponding 
    % region, or bin, spatially (based on x, y)
    bounds = linspace(0,1, i+1);
    % overlap amount
    overlap = 1/(4*i);
    bounds_2 = linspace(overlap, 1-overlap, i); % offsetted bounds to have overlapping grids
    
    bins = zeros(i*i, size(vocab, 1));    
    for col = 1:i
      for row = 1:i
        indices = test_image.x >= bounds(col) - overlap ...
                & test_image.x <= bounds(col+1) + overlap ...
                & test_image.y >= bounds(row) - overlap...
                & test_image.y <= bounds(row+1) + overlap;

        binDescs = test_image.desc(:, indices);
        if (size(binDescs, 2) == 0)
          bins(row + (col-1)*i,:) = zeros(size(vocab,1),1);
        else
          [bins(row + (col-1)*i, :),~] = computeBoWHistogram(binDescs, vocab);
        end
      end
    end
    
    bins_all_levels(sum((1:i-1).^2)+1: sum((1:i).^2) , :) = bins;
    
  end % end level
  
  % run SVM on the regions to get prediction for each region'
  [detected_labels, accuracy, decision_vals] = predict(zeros(size(bins_all_levels,1),1), sparse(bins_all_levels), model);
  %detected_labels(vocab_size*(i-1)^2+1:vocab_size*i^2) = predictions;
  %decision_vals(vocab_size*(i-1)^2+1:vocab_size*i^2) = dec_vals;
  
  % surppress uncertain detections, unless it's the highest detection
  % max(decision_vals)
  % detected_labels(decision_vals ~= min(decision_vals)) = 0;
  %detected_labels(decision_vals < 0.5) = 0;
end