function testAnim1

hfig = figure('Position', [100, 100, 900, 450], 'Color', 'w');
hdls.hfig = hfig;
hdls.imhs = nan(1, 3);
% Render the target images
for i1 = 1 : 3
    if i1 == 1
        im_trg = double(imread('images/cartoon-bed-1.jpg')) / 255.;
    elseif i1 == 2
        im_trg = double(imread('images/cartoon-head-1.jpg')) / 255.;
    elseif i1 == 3
        im_trg = double(imread('images/cartoon-ted-1.jpg')) / 255.;
    end
    
    hsp = subplot('Position', [0.05 + (i1 - 1) * (0.275 + 0.025), 0.375, 0.275, 0.6]);
    imh = image(im_trg);
    hold on;
    hdls.hsps(i1) = hsp;
    hdls.imhs(i1) = imh;
    
    alphaImg = 1. * ones(size(imh(:, :, 1)));
    
    set(imh, 'AlphaData', alphaImg);
    
    axis square;
    box off;
    set(gca, 'XTick', [], 'XColor', 'w');
    set(gca, 'YTick', [], 'YColor', 'w');
end

% Create the action button
actButton_bed = uicontrol('Style', 'pushbutton', ...
                          'Position', [20 60 100 20], ...
                          'String', 'Animate bed', 'FontSize', 10, ...
                          'Callback', {@actCallback, hdls, 'bed'});
actButton_head = uicontrol('Style', 'pushbutton', ...
                          'Position', [20 40 100 20], ...
                          'String', 'Animate head', 'FontSize', 10, ...
                          'Callback', {@actCallback, hdls, 'head'});
actButton_Ted = uicontrol('Style', 'pushbutton', ...
                          'Position', [20 20 100 20], ...
                          'String', 'Animate Ted', 'FontSize', 10, ...
                          'Callback', {@actCallback, hdls, 'Ted'});


volOKButton = uicontrol('Style', 'pushbutton', ...
                        'Position', [140 60 100 20], ...
                        'String', 'Volume OK', 'FontSize', 10, ...
                        'Callback', {@volDurOK_cbk, hdls, 'vol'});
volTooLoudButton = uicontrol('Style', 'pushbutton', ...
                             'Position', [140 40 100 20], ...
                             'String', 'Volume too loud', 'FontSize', 10, ...
                             'Callback', {@volErr_cbk, hdls, 'loud'});
volTooSoftButton = uicontrol('Style', 'pushbutton', ...
                        	 'Position', [140 20 100 20], ...
                             'String', 'Volume too soft', 'FontSize', 10, ...
                             'Callback', {@volErr_cbk, hdls, 'soft'});

durOKButton = uicontrol('Style', 'pushbutton', ...
                        'Position', [260 60 100 20], ...
                        'String', 'Duration OK', 'FontSize', 10, ...
                        'Callback', {@volDurOK_cbk, hdls, 'dur'});
durLongButton = uicontrol('Style', 'pushbutton', ...
                             'Position', [260 40 100 20], ...
                             'String', 'Duration too long', 'FontSize', 10, ...
                             'Callback', {@durErr_cbk, hdls, 'long'});
durShortButton = uicontrol('Style', 'pushbutton', ...
                        	 'Position', [260 20 100 20], ...
                             'String', 'Duration too short', 'FontSize', 9, ...
                             'Callback', {@durErr_cbk, hdls, 'short'});
return

%%
function actCallback(src, eventData, handles, opt)
dir1 = dir('./images/cartoon-bird-flying-1-*.jpg');
nFrames = numel(dir1);
ima_bird = cell(1, nFrames);

for i1 = 1 : nFrames
    ima_bird{i1} = double(imread(fullfile('images', dir1(i1).name))) / 255.; 
end
set(0, 'CurrentFigure', handles.hfig);

if isequal(opt, 'bed')
%     set(gcf, 'CurrentAxes', handles.hsps(1));
    idx = 1;
elseif isequal(opt, 'head')
%     set(gcf, 'CurrentAxes', handles.hsps(2));
    idx = 2;
elseif isequal(opt, 'Ted')
%     set(gcf, 'CurrentAxes', handles.hsps(3));
    idx = 3;
end

subplot('Position', [0.05 + (idx - 1) * (0.275 + 0.025), 0.375, 0.275, 0.6]);
cla;

im_trg = double(imread(sprintf('images/cartoon-%s-1.jpg', lower(opt)))) / 255.;
imh = image(im_trg);
hold on;
axis square;
box off;
set(gca, 'XTick', [], 'XColor', 'w');
set(gca, 'YTick', [], 'YColor', 'w');

xPrg = 0;
if isequal(opt, 'bed')
    yPrg = -120;
else
    yPrg = -80;
end

frmCnt = 1;
totFrames = 12;
for i0 = 1 : totFrames  
%     for i1 = 1 : nFrames
%     [imHeight, imWidth] = size(ima_bird{frmCnt});

    % subplot('Position', [0.05, 0.6, 0.2, 0.2]);
    imh = image(ima_bird{frmCnt}, 'XData', [10, 140] + xPrg, 'YData', [60, 160] + yPrg);
    xPrg = xPrg + 8;
    yPrg = yPrg + 2;
    hold on;
    axis square;
    box off;
    alphaImg = 0. * ones(size(ima_bird{frmCnt}(:, :, 1)));
    alphaImg(ima_bird{frmCnt}(:, :, 1) < 0.9) = 1.;
    set(imh, 'AlphaData', alphaImg);
%     set(imh, 'AlphaData', 0.75);
    set(gca, 'XTick', [], 'XColor', 'w');
    set(gca, 'YTick', [], 'YColor', 'w');
    drawnow;
    
    frmCnt = frmCnt + 1;
    if (frmCnt > numel(ima_bird))
        frmCnt = 1;
    end

    pause(0.05);
    if ~(i0 == totFrames)
        delete(imh);
    end
%     end
end
return

%%
function volDurOK_cbk(src, eventData, handles, opt)
set(0, 'CurrentFigure', handles.hfig);
if isequal(opt, 'vol')
    im_lsp = double(imread('images/cartoon-speaker_base.jpg')) / 255.;
    hsp_vol = subplot('Position', [0.5, 0.05, 0.15, 0.3]);
elseif isequal(opt, 'dur')
    im_lsp = double(imread('images/cartoon-pencil-ruler-1.jpg')) / 255.;
    hsp_vol = subplot('Position', [0.7, 0.05, 0.15, 0.3]);
end

imh_lsp = image(im_lsp);
hold on;
axis square;
box off;
set(gca, 'XTick', [], 'XColor', 'w');
set(gca, 'YTick', [], 'YColor', 'w');

im_tick_0 = double(imread('images/cartoon-tickmark-1.jpg')) / 255.;

totFrames = 10;

for i1 = 1 : totFrames
    t_ratio = i1 / totFrames;
    im_tick = im_tick_0;
    im_tick = im_tick(:, 1 : round(t_ratio * size(im_tick_0, 2)), :);
    
    alphaImg = 0. * ones(size(im_tick(:, :, 1)));
    alphaImg(im_tick(:, :, 3) < 0.9) = 1.;

    if isequal(opt, 'vol')
        imh_tick = image(im_tick, 'XData', [0, 200 * t_ratio], 'YData', [0, 200]);
    elseif isequal(opt, 'dur')
        imh_tick = image(im_tick, 'XData', [0, 440 * t_ratio], 'YData', [0, 200]);
    end
    set(imh_tick, 'AlphaData', alphaImg);
    
    pause(0.02);
    
    if ~(i1 == totFrames)
        delete(imh_tick);
    end
end

pause(1); 
delete(hsp_vol);
return

%%
function volErr_cbk(src, eventData, handles, opt)
set(0, 'CurrentFigure', handles.hfig);
im_lsp = double(imread('images/cartoon-speaker_base.jpg')) / 255.;
if isequal(opt, 'loud')
    im_lsp_alt = double(imread('images/cartoon-speaker_loud_1.jpg')) / 255.;
else
    im_lsp_alt = double(imread('images/cartoon-speaker_soft_1.jpg')) / 255.;
end

if isequal(opt, 'loud')
    hsp_vol = subplot('Position', [0.5, 0.02, 0.15 * 1.15, 0.3 * 1.15]);
elseif isequal(opt, 'soft')
    hsp_vol = subplot('Position', [0.5, 0.05, 0.15 * 0.6, 0.3 * 0.6]);
end
% set(gca, 'XTick', [], 'XColor', 'w');
% set(gca, 'YTick', [], 'YColor', 'w');

% im_tick_0 = double(imread('images/cartoon-tickmark-1.jpg')) / 255.;

totFrames = 10;

for i1 = 1 : totFrames
%     t_ratio = i1 / totFrames;
%     im_tick = im_tick_0;
%     im_tick = im_tick(:, 1 : round(t_ratio * size(im_tick_0, 2)), :);
    
%     alphaImg = 0. * ones(size(im_tick(:, :, 1)));
%     alphaImg(im_tick(:, :, 3) < 0.9) = 1.;

    if mod(i1, 2) == 1
        imh_lsp = image(im_lsp);
    else
        imh_lsp = image(im_lsp_alt);
    end
    hold on;
    axis square;
    box off;
    set(gca, 'XTick', [], 'XColor', 'w');
    set(gca, 'YTick', [], 'YColor', 'w');

    drawnow;
    pause(0.15);
    if ~(i1 == totFrames)
        delete(imh_lsp);
    end
end

pause(1); 
delete(hsp_vol);
return

%%


%%
function durErr_cbk(src, eventData, handles, opt)
set(0, 'CurrentFigure', handles.hfig);
if isequal(opt, 'long')
    im_pencil_0 = double(imread('images/cartoon-pencil-long.jpg')) / 255.;
elseif isequal(opt, 'short')
    im_pencil_0 = double(imread('images/cartoon-pencil-short.jpg')) / 255.;
end

im_ruler = double(imread('images/cartoon-ruler-1.jpg')) / 255.;

% hsp_vol = subplot('Position', [0.7, 0.05, 0.15, 0.3]);

% imh_lsp = image(im_pencil);
hold on;
% axis square;    
% box off;
% set(gca, 'XTick', [], 'XColor', 'w');
% set(gca, 'YTick', [], 'YColor', 'w');

hsp_vol = subplot('Position', [0.7, 0.10, 0.15, 0.10]);
imh_lsp = image(im_ruler);
hold on;
% axis square;    
box off;
set(gca, 'XTick', [], 'XColor', 'w');
set(gca, 'YTick', [], 'YColor', 'w');

% hsp_vol = subplot('Position', [0.7, 0.15, 0.15, 0.15]);
% imh_lsp = image(im_pencil);
hold on;
% axis square;    
box off;
set(gca, 'XTick', [], 'XColor', 'w');
set(gca, 'YTick', [], 'YColor', 'w');

% im_tick_0 = double(imread('images/cartoon-tickmark-1.jpg')) / 255.;

totFrames = 10;

if isequal(opt, 'short')
    hsp_pen = subplot('Position', [0.7, 0.20, 0.075, 0.15]);
elseif isequal(opt, 'long')
    hsp_pen = subplot('Position', [0.7, 0.20, 0.3, 0.15]);
end
im_pencil_bg = ones(size(im_pencil_0));
image(im_pencil_bg);
hold on;

for i1 = 1 : totFrames
    t_ratio = i1 / totFrames;
    im_pencil = im_pencil_0;
    im_pencil = im_pencil(:, 1 : round(t_ratio * size(im_pencil_0, 2)), :);
    
    alphaImg = 0. * ones(size(im_pencil(:, :, 1)));
    alphaImg(im_pencil(:, :, 3) < 0.9) = 1.;

    if isequal(opt, 'long')
        imh_pencil = image(im_pencil, 'XData', [0, 550 * t_ratio], 'YData', [0, 100]);
    elseif isequal(opt, 'short')
        imh_pencil = image(im_pencil, 'XData', [0, 180 * t_ratio], 'YData', [0, 100]);
    end
    set(imh_pencil, 'AlphaData', alphaImg);
    box off;
    set(gca, 'XTick', [], 'XColor', 'w');
    set(gca, 'YTick', [], 'YColor', 'w');
    
    drawnow;
    pause(0.02);
    
    if ~(i1 == totFrames)
        delete(imh_pencil);
    end
end

pause(1); 
delete(imh_pencil);
delete(imh_lsp);
return