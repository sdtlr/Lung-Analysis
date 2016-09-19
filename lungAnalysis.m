function myoutput = lungAnalysis(i)
% Read image into program based on user input.
RGB = imread(i);

% Create smoothing and gaussian filters (different images require different filter types). 
h = fspecial('gaussian');
h3 = fspecial('average');


% Initial noise removal on RGB image using gausian filter.
RGB_gaus = imfilter(RGB,h);

% Convert RGB image to grayscale image.
RGB2Gray = rgb2gray(RGB_gaus);

% Noise removal using median filter in 2 dimensions.
RGB_median = medfilt2(RGB2Gray);

% Further noise removal using the mean filter.
RGB_mean = imfilter(RGB_median,h3); figure, imshow(RGB_mean), title('Image removed of noise (Task 1)');

% Convert smoothed image to a binary image.
BW_mean = im2bw(RGB_mean,0.3); figure, imshow(BW_mean), title('Image removed of noise after conversion to binary (Task 1)');

% Create a disk shaped structuring element, with radius 1.
SE1 = strel('disk',1,0);

% Errode the BW image, using the structure element above.
BW_mean_err = imerode(BW_mean,SE1);
% Dilate the BW image, using the structure element above.
BW_mean_dill = imdilate(BW_mean_err,SE1);

% Invert the BW image.
WB_mean_dill = ~BW_mean_dill;

% Filter any objects from the image that are > 5000 pixels, < 50000 pixels.
BW = bwareafilt(WB_mean_dill,[5000 50000]); figure, imshow(BW), title('Image segmented and displayed on black background (Task 2)');

% Create a new structure element, disk shaped, with radius 2.
SE1_open = strel('disk',2,0);
% Use the imopen function to make the holes in the image larger.
BW = imopen(BW,SE1_open);

% Edge tumor detection.
% Create a new structure element, disk shaped, with radius 18.
SE18 = strel('disk',18,0);

% Close the image to flatten the edges of the lung, using SE18.
BW_closed = imclose(BW,SE18);

% Perform an image subtraction to leave tumors only.
Tumors = BW_closed - BW;

% Create a disk shaped structuring element, with radius 1.
SE1 = strel('disk',1,0);

% Using imopen, remove any very small objects.
Tumors = imopen(Tumors,SE1);

% bwlabel function detects number of tumors, using connected components.
% Each label and total number of objects are stored.
[L,num] = bwlabel(Tumors);

% Label each detected tumor with a red X.
s = regionprops(L, 'Centroid');
figure, imshow(RGB), title('Tumour detection - Original image with overlay (Task 3)');
hold on
for k = 1:numel(s)
    c = s(k).Centroid;
    text(c(1), c(2), 'X', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','Color','red','fontsize',20);
end
hold off

% Display the number of detected tumors to the user.
disp('Number of items in image:');
disp(num);

myoutput = BW;
end

