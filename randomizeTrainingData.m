
function [permuted_training_data, permuted_label] = randomizeTrainingData(training_data, training_label)

%Label entries correspond to a row of data entries
permute = randperm(size(training_data,1));
permuted_training_data = training_data(permute,:);
permuted_label = training_label(permute,:);

end
