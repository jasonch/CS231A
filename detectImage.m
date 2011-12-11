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
  
  % find bounding box of our object
  minX = min(test_image.x);
  maxX = max(test_image.x);
  minY = min(test_image.y);
  maxY = max(test_image.y);

  bins_all_levels = zeros(sum((1:levels).^2), vocab_size);
  
  for i=1:levels

    bins = zeros(i*i, size(vocab, 1));

    % for each level, distribute the sift descriptors into their corresponding 
    % region, or bin, spatially (based on x, y)
    xbounds = linspace(minX,maxX+0.01, i+1);
    ybounds = linspace(minY,maxY+0.01, i+1);
    
    for row = 1:i
      for col = 1:i
        indices = test_image.x >= xbounds(col) ...
                & test_image.x <  xbounds(col+1) ...
                & test_image.y >= ybounds(row) ...
                & test_image.y <  ybounds(row+1);

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
  [predictions, accuracy, dec_vals] = predict(zeros(size(bins_all_levels,1),1), sparse(bins_all_levels), model);
  %detected_labels(vocab_size*(i-1)^2+1:vocab_size*i^2) = predictions;
  %decision_vals(vocab_size*(i-1)^2+1:vocab_size*i^2) = dec_vals;
  detected_labels = [detected_labels; predictions];
  decision_vals = [decision_vals; dec_vals];
  
  % surppress uncertain detections, unless it's the highest detection
  % max(decision_vals)
  % detected_labels(decision_vals ~= min(decision_vals)) = 0;
  %detected_labels(decision_vals < 0.5) = 0;
end
