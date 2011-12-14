#!/bin/bash

spatial_levels=(1,2);
kmeans_clusters=(140);
norm_threshold=(0,4.3);
num_vocab_images=(1500);
jitter_grid_size=(3,5);
jitter_amount=(0.0625);

counter=1;

for lv in $spatial_levels
do

# kmeans number of clusters
for k in $kmean_clusters
do

# norm threshold
for n in $norm_threshold
do

# number of images used for vocab
for v in $num_vocab_images

# jitter grid size
for js in $jitter_grid_size
do

# jitter amount
for ja in $jitter_amount 
do

  echo "running $counter ...";
  echo main($k, $lv, $n, $v, $js, $ja) | matlab -nodisply -nodesktop > output_$lv-$k-$n-$js-$ja-$sw.txt &
  echo 'done!';

done
done
done
done
done
