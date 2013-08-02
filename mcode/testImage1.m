% Create the background
% This example uses a blend of colors from left to right, converted to a TrueColor image
% Use repmat to replicate the pattern in the matrix
% Use the "jet" colormap to specify the color space
bg = ind2rgb(repmat(1:64,64,1),jet(64));

% Create an image and its corresponding transparency data
% This example uses a random set of pixels to create a TrueColor image
im = rand(100,100,3);
% Make the image fade in from left to right by designing its alphadata
% Use repmat to replicate the pattern in the transparency fading
imAlphaData = repmat(0:1/size(im,2):1-1/size(im,2),size(im,1),1);

% Display the images created in subplots
hf = figure('units','normalized','position',[.2 .2 .6 .6]);
ax1 = subplot(2,3,1);
ibg = image(bg);
axis off
title('Background')
ax2 = subplot(2,3,4);
iim = image(im);
axis off
title('Image without transparency yet')

% Now set up axes that overlay the background with the image
% Notice how the image is resized from specifying the spatial
% coordinates to locate it in the axes.
ax3 = subplot(2,3,[2:3, 5:6]);
ibg2 = image(bg);
axis off
hold on
% Overlay the image, and set the transparency previously calculated
iim2 = image(im, 'XData',[30 50],'YData',[10 30]);
set(iim2,'AlphaData',imAlphaData);
title(sprintf('Using transparency while overlaying images:\nresult is multiple image objects.'))