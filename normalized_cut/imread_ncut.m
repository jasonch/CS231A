function I = imread_ncut(Image_file_name,nr,nc);
%  I = imread_ncut(Image_file_name);
%
% Timothee Cour, Stella Yu, Jianbo Shi, 2004.


%% read image 

I = imread(Image_file_name);
[Inr,Inc,nb] = size(I);

if (nb>1),
    I =double(rgb2gray(I));
else
    I = double(I);
end

%resizes while keeping aspect ratio
new_num_rows = 0;
new_num_cols = 0;

r_ratio = Inr / nr;
c_ratio = Inc / nc;

if (r_ratio < c_ratio)
	new_num_rows = Inr / c_ratio;
	new_num_cols = Inc / c_ratio;
else
	new_num_rows = Inr / r_ratio;
	new_num_cols = Inc / r_ratio;
end

I = imresize(I,[new_num_rows, new_num_cols],'bicubic');
