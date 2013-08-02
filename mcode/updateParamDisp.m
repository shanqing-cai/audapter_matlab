function updateParamDisp(p, hgui)
set(hgui.edit_param_rmsThresh, 'String', sprintf('%.6f', p.rmsThresh));
set(hgui.edit_param_nLPC, 'String', sprintf('%.1f', p.nLPC));
set(hgui.edit_param_fn1, 'String', sprintf('%.1f', p.fn1));
set(hgui.edit_param_fn2, 'String', sprintf('%.1f', p.fn2));
set(hgui.edit_param_aFact, 'String', sprintf('%.1f', p.aFact));
set(hgui.edit_param_bFact, 'String', sprintf('%.1f', p.bFact));
set(hgui.edit_param_gFact, 'String', sprintf('%.1f', p.gFact));
set(hgui.edit_param_bCepsLift, 'String', sprintf('%d', p.bCepsLift));
set(hgui.edit_param_cepsWinWidth, 'String', sprintf('%d', p.cepsWinWidth));

load(hgui.uiConfigFN);
set(hgui.rb_showWordHint, 'Value', uiConfig.showWordHint);
set(hgui.rb_showWarningHint, 'Value', uiConfig.showWarningHint);
set(hgui.rb_showInfoOnlyErr, 'Value', uiConfig.showInfoOnlyErr);
set(hgui.rb_showCorrCount, 'Value', uiConfig.showCorrCount);
set(hgui.rb_showCorrAnim, 'Value', uiConfig.bShowCorrAnim);

% The timing mode popup menu
listItems = get(hgui.pm_timingMode, 'String');
set_onset = [];
set_term = [];
for i1 = 1 : numel(listItems)
    t_item = listItems{i1};
    if uiConfig.trialStartWithAnim == 1
        if ~isempty(strfind(t_item, 'with anim'))
            set_onset(end + 1) = i1;
        end
    else
        if ~isempty(strfind(t_item, 'after anim'))
            set_onset(end + 1) = i1;
        end
    end
    
    if uiConfig.trialPresetDur == 1
        if ~isempty(strfind(t_item, 'preset dur'))
            set_term(end + 1) = i1;
        end
    else
        if ~isempty(strfind(t_item, 'manual term'))
            set_term(end + 1) = i1;
        end
    end
    
end
idx = intersect(set_onset, set_term);
set(hgui.pm_timingMode, 'Value', idx);

% The prompt mode popup menu
listItems = get(hgui.pm_promptMode, 'String');
if isequal(uiConfig.promptMode, 'v')
    idx = fsic(listItems, 'Visual only');
elseif isequal(uiConfig.promptMode, 'a')
    idx = fsic(listItems, 'Auditory only');
elseif isequal(uiConfig.promptMode, 'av')
    idx = fsic(listItems, 'Auditory + visual');
end
set(hgui.pm_promptMode, 'Value', idx);

% Prompt volume
set(hgui.sld_promptVol, 'Value', uiConfig.promptVol);
set(hgui.text_promptVol, 'String', sprintf('%.1f dB', uiConfig.promptVol));
return