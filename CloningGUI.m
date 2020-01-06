function [] = CloningGUI(source, target)
%CLONINGGUI a gui that lets the user control the parameters of the cloning process

figure_handle = figure('MenuBar','none','Name','Seamless Cloning', ...
    'NumberTitle','off','Position',[200,200,800,600]);

handles = guihandles(figure_handle); 

handles.source = source;
handles.target = target;
handles.mask = true(size(source, 1), size(source, 2));
handles.result = target;
handles.offsetx = 0;
handles.offsety = 0;

handles.radio1 = uicontrol('Style','RadioButton','String','Laplace' ...
    ,'Position',[10,570,70,20], 'CallBack', @radio1);

handles.radio2 = uicontrol('Style','RadioButton','String','Shepards', ...
    'Position', [10,540,70,20], 'CallBack', @radio2);

handles.radio3 = uicontrol('Style','RadioButton','String','Custom', ...
    'Position', [10,510,70,20], 'CallBack', @radio3);

uicontrol('Style','PushButton','String','Create Mask', ...
    'Position',[10,480,70,20], 'CallBack', @createMask);

uicontrol('Style','PushButton','String','Set Offset', ...
    'Position',[10,450,70,20], 'CallBack', @getOffset);

handles.offsetx = uicontrol('Style','edit','String','0', ...
    'Position',[10,420,32,20], 'CallBack', @updateOffset);

handles.offsety = uicontrol('Style','edit','String','0', ...
    'Position',[48,420,32,20], 'CallBack', @updateOffset);

uicontrol('Style','PushButton','String','Clone', ...
    'Position',[10,390,70,20], 'CallBack', @clone);

subplot(2,2,1), imshow(handles.source)
subplot(2,2,2), imshow(handles.target)
subplot(2,2,3), imshow(handles.mask)
subplot(2,2,4), imshow(handles.result)
set(handles.radio1,'value',1)

guidata(figure_handle, handles) 

end

% functions that control the cloning method radio buttions
function [] = radio1(hObject, eventdata, handles)
handles = guidata(gcbo);

set(handles.radio2,'value',0)
set(handles.radio3,'value',0)

guidata(gcbo, handles);

end

function [] = radio2(hObject, eventdata, handles)
handles = guidata(gcbo);

set(handles.radio1,'value',0)
set(handles.radio3,'value',0)

guidata(gcbo, handles);

end

function [] = radio3(hObject, eventdata, handles)
handles = guidata(gcbo);

set(handles.radio1,'value',0)
set(handles.radio2,'value',0)

guidata(gcbo, handles);

end

% functions that let the user set the cloning parameters
function [] = createMask(hObject, eventdata, handles)
% CREATEMASK lets the user draw a mask on the source image
handles = guidata(gcbo);

subplot(2,2,1), imshow(handles.source)

h = imfreehand;
mask = h.createMask();

handles.mask = mask;
guidata(gcbo, handles);

subplot(2,2,3), imshow(mask)

end

function [] = getOffset(hObject, eventdata, handles)
% GETOFFSET lets the user choose an offset on the target image
handles = guidata(gcbo);

subplot(2,2,2), imshow(handles.target)

[c, r] = ginput(1);
offset = int32([r c]);

set(handles.offsetx,'string', num2str(offset(1)))
set(handles.offsetx,'value', offset(1))
set(handles.offsety,'string', num2str(offset(2)))
set(handles.offsety,'value', offset(2))

guidata(gcbo, handles);

end

function [] = updateOffset(hObject, eventdata, handles)
% GETOFFSET updates the offset
handles = guidata(gcbo);

set(handles.offsetx,'value', str2num(get(handles.offsetx, 'string')));
set(handles.offsety,'value', str2num(get(handles.offsety, 'string')));

guidata(gcbo, handles);

end

function [] = clone(hObject, eventdata, handles)
% CLONE clones the source image to the target image using the user created
% mask and offset according to the chosen cloning method
handles = guidata(gcbo);
offset = [get(handles.offsetx, 'value'), get(handles.offsety, 'value')];

if get(handles.radio1,'value') == 1
    handles.result = PoissonSeamlessCloning(...
        handles.source, handles.target, handles.mask, offset);
elseif get(handles.radio2,'value') == 1 
    handles.result = ShepardsSeamlessCloning(...
        handles.source, handles.target, handles.mask, offset, @Interpolant);
else
    handles.result = CustomSeamlessCloning(...
        handles.source, handles.target, handles.mask, offset, @SpecialGuidanceB);
end

subplot(2,2,4), imshow(handles.result)
subplot(2,2,1), imshow(handles.source)

figure; imshow(handles.result)

end