function detected_labels = detectImage(test_image, model, levels, vocab)

  % returns a matrix of predicted labels, which is 1 if we decided an object (teapot) is in that region, at each level
  % the second dimension is each region in column order 
  %    -------------
  %   |  1 | 3 | ..
  %   |----|---|---
  %   |  2 | 4 | ..
  %    -------------
  detected_labels = [];
  decision_vals = [];

  for i=1:levels

    bins = zeros(i*i, size(vocab, 1));

    % for each level, distribute the sift descriptors into their corresponding 
    % region, or bin, spatially (based on x, y)
    x_bins = assign2bins(test_image.vldsift.x, i);%TODO issue with assign2bins range
    y_bins = assign2bins(test_image.vldsift.y, i);
    for row = 1:i
      for col = 1:i
        binDescs = test_image.vldsift.desc(:, (x_bins == col) & (y_bins == row));
        if (size(binDescs, 2) == 0)
          bins(row + (col-1)*i,:) = zeros(size(vocab,1),1);
        else
          bins(row + (col-1)*i, :) = computeBoWHistogram(binDescs, vocab);
        end
      end
    end

    % run SVM on the regions to get prediction for each region'
    [predictions, accuracy, prob_estimates] = predict(zeros(i*i,1), sparse(bins), model);
    detected_labels = [detected_labels; predictions];
    decision_vals = [decision_vals; prob_estimates];

  end % end level
  % surppress uncertain detections, unless it's the highest detection
  detected_labels(decision_vals < 0.5 & decision_vals ~= max(decision_vals)) = 0;

% Potentially useful function:
% creates nb uniform bins within range of x and assigns each x to a bin
% example usage:
% myhistogram = assign2bins(data_vector, number_of_bins)
% myhistogram is now an array of the same length as data_vector, in which
% all entries now correspond to their bin index.
function b = assign2bins(x, nb)
b = min(max(ceil((x-min(x))/(max(x)-min(x))*nb), 1), nb);
