
function [permuted_training_data, permuted_label] = randomizeTrainingData(training_data, training_label)

%Label entries correspond to a row of data entries
permuted_training_data = training_data(randperm(size(training_data,1)),:);
permuted_label = training_label(randperm(size(training_label,1)),:);

end
