#!/bin/bash

spatial_levels=(1);
kmeans_clusters=(140);
norm_threshold=(0);
jitter_grid_size=(3);
jitter_amount=(0.0625);
spatial_weight_drop=(0.5);

counter=1;

for lv in $spatial_levels
do

# kmeans number of clusters
for k in $kmean_clusters
do

# norm threshold
for n in $norm_threshold
do

# jitter grid size
for js in $jitter_grid_size
do

# jitter amount
for ja in $jitter_amount 
do

# spatial weight drop
for sw in $spatial_weight_drop
do
  echo "running $counter ...";
  echo main($lv, $k, $n, $js, $ja, $sw) | matlab -nodisply -nodesktop > output_$lv-$k-$n-$js-$ja-$sw.txt &
  echo 'done!';

done
done
done
done
done
done
