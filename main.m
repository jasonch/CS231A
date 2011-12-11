% this file descirbes a detector using BoW histograms with SIFT features....
   %% constants
   % CHECK ALL THESE BEFORE RUNNING!!
  global display_sift; 
  display_sift = true;
  global hist_threshold;
  hist_threshold = 0.8;
  global data_path; % top level path to where SIFT matrices images, and segLabels are stored
  global jitter_on;
  global jitter_grid_size;
  
  data_path = './siftmatrixes/';
  jitter_on = true;
  jitter_grid_size = 3;
  
  %useMeanshift = false; K = 500; % K for kmeans
  useMeanshift = true;  K = 0.73; % bandwidth for meanshift
  
  norm_threshold = 4; % minimum norm to consider 
  num_chair_images = 40;
  num_vocab_images = 80;

  spatialPyramidLevels = 1;
  
  teapotWnid = 'n04398044';
  chairWnid  = 'n03376595';

   %%
  % segment images
  %disp('Segmenting images...');
  addPathByPlatform('normalized_cut/');
  %segmentSynSet([data_path 'images/'], [data_path 'segLabels/'], teapotWnid);
 
  
  %%
  % filter to only images we want and only features in the segment
  % and discard bottom 30% of the features by norm magnitude
  image_vldsift = loadSifts(data_path, teapotWnid); 

  disp('Filtering clean and noisy sift features...');
  [filteredSifts, noisySifts] = cleanImagesFilter(teapotWnid, image_vldsift);
  filteredSifts = filterSIFTs(filteredSifts, norm_threshold, false, teapotWnid);
  noisySifts    = filterSIFTs(noisySifts   , norm_threshold, false, '');
  
  %% load negative images  
  chairSifts = loadSifts(data_path, chairWnid);
  chairSifts = chairSifts(randsample(size(chairSifts,1), num_chair_images));
  chairSifts = filterSIFTs(chairSifts, norm_threshold, false, '');

  %%
  % compute vocabulary set
  disp('Compute vocab set');
  allSifts = [filteredSifts; noisySifts; chairSifts];
  size(allSifts)
  randomSiftDescs = allSifts(randsample(size(allSifts,1), num_vocab_images));
  size(randomSiftDescs);
  vocab =   computeVocabularySet(randomSiftDescs, K, useMeanshift);
  %load('vocabPoint50WindowSize.mat');
 
  %%
  disp('Compute histograms of sifts');
  trainHistograms = sparse(computeHistograms(filteredSifts, vocab, data_path, spatialPyramidLevels));
  trainPosLabels = ones(size(trainHistograms,2), 1);
  %%
  testHistograms = sparse(computeHistograms(noisySifts, vocab, data_path, spatialPyramidLevels));
  testPosLabels = ones(size(testHistograms,2), 1);
  
  %%
  % compute histogram for negative examples
  % use unrelated synset for negative examples. Use the same number of negative examples
  % as positive exapmles
  num_pos_examples = size(trainHistograms,2);
  chairHistograms = sparse(computeHistograms(chairSifts, vocab, data_path, spatialPyramidLevels));
  trainChairHists = chairHistograms(:,1:num_pos_examples);
  trainNegLabels = zeros(num_pos_examples, 1);  
  testChairHists = chairHistograms(:, (1+num_pos_examples):num_chair_images);
  testNegLabels = zeros(num_chair_images-num_pos_examples, 1);
%%
  %randomly permute training data:
  [training_data, training_labels] = randomizeTrainingData([trainHistograms trainChairHists], [trainPosLabels; trainNegLabels]);

  % plug into liblinear - train
  addPathByPlatform('liblinear-1.8\liblinear-1.8\matlab\');
  %model = train(training_labels, training_data', '-e 0.1 -v 100 -s 1')
  model = train(training_labels, training_data');
  %model = train([training_labels(1:15)' training_labels(1:15)' training_labels(1:15)']' , [training_data(:, 1:15) training_data(1:15) training_data(1:15)]', '-e 0.1 -v 50 -s 1'); 
  %model = train(repmat(training_labels(1:150), 1, 1), repmat(training_data(:,1:150)', 1, 1), '-e 0.1 -v 30 -s 1');
  
  %%
  %randomly permute test data:
  [test_data, test_labels] = randomizeTrainingData([testHistograms testChairHists], [testPosLabels; testNegLabels]);
  [predicted_label, accuracy, decision_vals] = predict(test_labels, test_data', model);
  accuracy

  %% 
  % attempt to detect the object in the test image
  disp('Running detector...');
  detector_levels = 2;
  detected_labels = zeros(size(noisySifts, 1), sum((1:detector_levels).^2));
  decision_vals   = zeros(size(noisySifts, 1), sum((1:detector_levels).^2));
  for i=1:size(noisySifts, 1)
    [detected_labels(i, :), decision_vals(i,:)] = detectImage(noisySifts(i).vldsift, model, detector_levels, vocab); 
  end  
  % display number of findings
  size(find(detected_labels))
