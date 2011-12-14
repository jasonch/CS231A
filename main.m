function accuracy = main(num_clusters, pyramid_levels, min_sift_norm, num_vocab_imgs, jitter_size, jitter_amt)

% this file descirbes a detector using BoW histograms with SIFT features....
   %% constants
   % CHECK ALL THESE BEFORE RUNNING!!
  global display_sift; 
  global display_clusters;
  global display_histograms;
  global hist_threshold;
  global jitter_grid_size; % number of steps to jitter x and y by, set to 1 to turn jitter off
  global sp_weight_drop; %smaller sp regions should be weighted less
  global jitter_amount; %proportion of jitter amount to the grid it's jittering, see computeHistogram
  global kmeans_max_itrs;
  kmeans_max_itrs = 90;
  jitter_amount = jitter_amt;%0.0625;
  sp_weight_drop = 0.5; 
  jitter_grid_size = jitter_size;
  display_sift = false;  
  display_clusters = false;
  display_histograms = false;
  hist_threshold = 0.8;
 
  % Parameters (TODO: tune later)
  useMeanshift = false; K = num_clusters;%140; % K for kmeans
  %useMeanshift = true;  K = 0.70; % bandwidth for meanshift
  
  norm_threshold = min_sift_norm; 
  num_vocab_images = num_vocab_imgs;%1500;
  spatial_pyramid_levels = pyramid_levels;%2;

  %TODO: pick good synsets: teapot, revolver, scissors, chain/toyshop
  % Synset ids
  %wordnet_ids = {'n04398044', 'n04086273', 'n04148054', 'n04462240', 'n03376595'};  
  %wordnet_ids = {'n04398044', 'n02992211', 'n03255030', 'n03376595',...
  %               'n04086273', 'n04141076', 'n04148054', 'n04462240'};
  %               teapot       cello        dumbbell     chair 
  %wordnet_ids = {'n04398044', 'n02992211', 'n03376595'};
  %               teapot       cello         chair 
  wordnet_ids = {'n04398044', 'n03376595'}
  %                teapot       chair
  % teapot - n04398044; cello - n02992211; dumbbell - n03255030; chair - n03376595;
  % revolver - n04086273; saxophone - n04141076; scissors - n04148054; toyshop: n04462240
  % Paths to add:
  addPathByPlatform('liblinear-1.8/liblinear-1.8/matlab/');
  addPathByPlatform('normalized_cut/');
  addPathByPlatform('images/');
  addPathByPlatform('siftmatrixes/'); % location for sift feature matrices
  addPathByPlatform('/tmp/'); % location for sift feature matrices
  
   %%
  % segment images
  %disp('Segmenting images...');
  %segmentSynSet([data_path 'images/'], [data_path 'segLabels/'], teapotWnid);
 
  
  %%
  % filter to only images we want and only features in the segment
  % and discard bottom 30% of the features by norm magnitude
  
  filtered_sifts = [];
  noisy_sifts = [];
  trainingLabels = [];
  testingLabels = [];
  
  disp('Filtering clean and noisy sift features...');
  for i=1:size(wordnet_ids, 2)
      wordnet_id = char(wordnet_ids(i));
      image_vldsift = loadSifts(wordnet_id);
      [filteredSifts, noisySifts] = cleanImagesFilter(wordnet_id, image_vldsift);
      tmp =  filterSIFTs(filteredSifts, norm_threshold, false, wordnet_ids(i));
      filtered_sifts = cat(1, filtered_sifts, tmp);

      label=i;
      if (i == 5)
        label=4;
      end

      trainingLabels = [trainingLabels; label * ones(jitter_grid_size^2 * size(tmp, 1), 1)];
      tmp = filterSIFTs(noisySifts, norm_threshold, false, '');%TODO change norm thresh
      noisy_sifts = cat(1, noisy_sifts, tmp);
      testingLabels = [testingLabels; label * ones(size(tmp, 1), 1)];
  end
  
  %%
  %Small tuning modification
  %filtered_sifts = [filtered_sifts; filtered_sifts(230:310)];
  %trainingLabels = [trainingLabels; trainingLabels(230:310)];

  
  %%
  % compute vocabulary set
  disp('Compute vocab set');
  
  allSifts = [filtered_sifts; noisy_sifts];
  randomSiftDescs = allSifts(randsample(size(allSifts,1), num_vocab_images));
  %vocab =   computeVocabularySet(randomSiftDescs, K, useMeanshift);
  vocab =   computeVocabularySet(randomSiftDescs, K, useMeanshift);
  %load('vocabPoint50WindowSize.mat');
 
  %%
  disp('Compute histograms of sifts');
  %vocab(1,:) = 100000*ones(1,128);
  %want jitter on for this bit, to get extra training data out
  random_order = randperm(size(noisy_sifts, 1))';


  trainingLabels = trainingLabels(random_order(1:round(size(random_order)/2)));
  train_sifts = noisy_sifts(random_order(1:round(size(random_order)/2)));
  trainHistograms = sparse(computeHistograms(train_sifts, vocab, spatial_pyramid_levels));

  testingLabels = testingLabels(random_order( (round(size(random_order)/2)+1) :size(random_order,1)));
  test_sifts    = noisy_sifts  (random_order( (round(size(random_order)/2)+1) :size(random_order,1)));
  jitter_grid_size = 1;%don't need jitter for test data
  testHistograms = sparse(computeHistograms(test_sifts , vocab, spatial_pyramid_levels));

  %%
  %visualize sifts on image
  if display_sift
    displaySifts(filtered_sifts);
    %displaySifts(testHistograms);
  end
  %%
  if display_clusters
     displayClusters(vocab); 
  end
  %%
  if display_histograms
     displayHistograms(trainHistograms); 
     %displayHistograms(testHistograms);
  end
  
  %%
  %randomly permute training data:
  [train_data, train_labels] = randomizeTrainingData(trainHistograms, trainingLabels);

  % plug into liblinear - train
  svm_options = ['-e 0.5 -c 10 -s ' int2str(size(wordnet_ids, 2))];
  model = train(train_labels, train_data', svm_options); 
  %model = train([training_labels(1:15)' training_labels(1:15)' training_labels(1:15)']' , [training_data(:, 1:15) training_data(1:15) training_data(1:15)]', '-e 0.1 -v 50 -s 1'); 
  %model = train(repmat(training_labels(1:150), 1, 1), repmat(training_data(:,1:150)', 1, 1), '-e 0.1 -v 30 -s 1');
  
  %%
  %randomly permute test data:
  [test_data, test_labels] = randomizeTrainingData(testHistograms, testingLabels);
  [predicted_label, accuracy, decision_vals] = predict(test_labels, test_data', model);
  accuracy

  %%
  disp('Training num labels 0, 1, 2, ..');
  sum(train_labels == 1)
  sum(train_labels == 2)
  sum(train_labels == 3)  
  sum(train_labels == 4)
  disp('Test num labels 0, 1, 2, ..');
  sum(test_labels == 1)
  sum(test_labels == 2)
  sum(test_labels == 3)  
  sum(test_labels == 4)  
  disp('Predicted num labels 0, 1, 2, ..');
  sum(predicted_label == 1)
  sum(predicted_label == 2)  
  sum(predicted_label == 3)   
  sum(predicted_label == 4)
%{  
  %% 
  % attempt to detect the object in the test image
  disp('Running detector...');
  detector_levels = 3;
  detected_labels = zeros(size(test_sifts, 1), sum((1:detector_levels).^2));
  decision_vals   = zeros(size(test_sifts, 1), sum((1:detector_levels).^2), size(wordnet_ids,2));
  size(decision_vals)
  for i=1:size(test_sifts, 1)
    [detected_labels(i, :), decision_vals(i,:,:)] = detectImage(test_sifts(i).vldsift, model, detector_levels, vocab); 
  end
  % display number of findings
  %[rows, ~] = find(detected_labels == 1);
  %rows = unique(rows);
  %['found ' num2str(size(rows,1)) ' teapots' ...
  %' of ' num2str(size(find(rows < 1367), 1)) ' true positive']

  % plot first few bounding boxes
  %visualizeBBoxes(test_sifts, detected_labels,10, 1);
%}
end
