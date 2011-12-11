% this file descirbes a detector using BoW histograms with SIFT features....
   %% constants
   % CHECK ALL THESE BEFORE RUNNING!!
  global display_sift; 
  global hist_threshold;
  global data_path; % top level path to where SIFT matrices images, and segLabels are stored
  global jitter_on;
  global jitter_grid_size; % number of steps to jitter x and y by
  jitter_grid_size = 3;
  display_sift = false;  
  hist_threshold = 0.8;
  
  % Parameters (TODO: tune later)
  %useMeanshift = false; K = 500; % K for kmeans
  useMeanshift = true;  K = 0.73; % bandwidth for meanshift
  
  norm_threshold = 4; % percentage of maximum norm
  num_vocab_images = 70;
  spatial_pyramid_levels = 3;

  % Synset ids
  wordnet_ids = {'n04398044', 'n02992211', 'n03255030', 'n03376595'};%, 'n02165456'};
  %               teapot       cello        dumbbell     chair 
  %wordnet_ids = {'n04398044', 'n03376595'}
  %                teapot       chair
  % Paths to add:
  addPathByPlatform('liblinear-1.8/liblinear-1.8/matlab/');
  addPathByPlatform('normalized_cut/');
  addPathByPlatform('siftmatrixes/');
  %data_path = '/tmp/';
  data_path = 'siftmatrixes\';
  
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
      image_vldsift = loadSifts(data_path, wordnet_id);
      [filteredSifts, noisySifts] = cleanImagesFilter(wordnet_id, image_vldsift);
      tmp =  filterSIFTs(filteredSifts, norm_threshold, false, wordnet_ids(i));%TODO: look inside filterSIFTs
      filtered_sifts = cat(1, filtered_sifts, tmp);
      if jitter_on
        trainingLabels = [trainingLabels; ((i-1) * ones(jitter_grid_size^2 * size(tmp, 1), 1))];
      else
        trainingLabels = [trainingLabels; ((i-1) * ones(size(tmp, 1), 1))];
      end
      tmp = filterSIFTs(noisySifts, norm_threshold, false, '');%TODO change norm thresh
      noisy_sifts = cat(1, noisy_sifts, tmp);
      testingLabels = [testingLabels; ((i-1) * ones(size(tmp, 1), 1))];
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
  vocab =   computeVocabularySet(randomSiftDescs, K, useMeanshift);
  %load('vocabPoint50WindowSize.mat');
 
  %%
  disp('Compute histograms of sifts');

  %want jitter on for this bit, to get extra training data out
  trainHistograms = sparse(computeHistograms(filtered_sifts, vocab, data_path, spatial_pyramid_levels));
  jitter_grid_size = 1;%don't need jitter for test data
  testHistograms = sparse(computeHistograms(noisy_sifts, vocab, data_path, spatial_pyramid_levels));

  %%
  %randomly permute training data:
  [train_data, train_labels] = randomizeTrainingData(trainHistograms, trainingLabels);

  % plug into liblinear - train
  svm_options = ['-e 0.5 -c 10 -s ' int2str(size(wordnet_ids, 2))];
  model = train(train_labels, train_data', svm_options); 
  %model = train([training_labels(1:15)' training_labels(1:15)' training_labels(1:15)']' , [training_data(:, 1:15) training_data(1:15) training_data(1:15)]', '-e 0.1 -v 50 -s 1'); 
  %model = train(repmat(training_labels(1:150), 1, 1), repmat(training_data(:,1:150)', 1, 1), '-e 0.1 -v 30 -s 1');
  size(trainHistograms)
  
  %%
  %randomly permute test data:
  [test_data, test_labels] = randomizeTrainingData(testHistograms, testingLabels);
  [predicted_label, accuracy, decision_vals] = predict(test_labels, test_data', model);
  accuracy

  %%
  disp('Training num labels 0, 1, 2, ..');
  sum(train_labels == 0)
  sum(train_labels == 1)
  sum(train_labels == 2)
  disp('Test num labels 0, 1, 2, ..');
  sum(test_labels == 0)
  sum(test_labels == 1)
  sum(test_labels == 2)
  disp('Predicted num labels 0, 1, 2, ..');
  sum(predicted_label == 0)
  sum(predicted_label == 1)
  sum(predicted_label == 2)  
  
  %% 
  % attempt to detect the object in the test image
  disp('Running detector...');
  detector_levels = 2;
  detected_labels = zeros(size(noisySifts, 1), sum((1:detector_levels).^2));
  decision_vals   = zeros(size(noisySifts, 1), sum((1:detector_levels).^2), size(wordnet_ids,2));
  for i=1:size(noisySifts, 1)
    [detected_labels(i, :), decision_vals(i,:,:)] = detectImage(noisySifts(i).vldsift, model, detector_levels, vocab); 
  end  
  % display number of findings
  size(find(detected_labels))
