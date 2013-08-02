function show_corr_anim(handles)
NFlash = 3;
TPause = 0.5;

a_words = {'bed', 'head', 'ted'};
idx = fsic(a_words, lower(handles.word));
set(0, 'CurrentFigure', handles.hkf);
set(gcf, 'CurrentAxes', handles.hsp(idx));

if idx == 1
    im_trg = handles.skin.bed;
    im_alt = handles.skin.bed_alt;
%     t_word = 'bed';
elseif idx == 2
    im_trg = handles.skin.head;
    im_alt = handles.skin.head_alt;
%     t_word = 'head';
elseif idx == 3
    im_trg = handles.skin.Ted;
    im_alt = handles.skin.Ted2;
%     t_word = 'Ted';
end

if idx == 3
    for i0 = 1 : NFlash
        cla;
        image(im_alt);
        drawnow;
        pause(TPause);
        image(im_trg);
        drawnow;
        pause(TPause);
    end
else
    for i0 = 1 : numel(im_alt)
        cla;
        image(im_alt{i0});
        drawnow;
        pause(TPause);
    end
    cla;
    image(im_trg);
    drawnow;
end

return