function varargout = VisualizeSegmentation(varargin)
% VISUALIZESEGMENTATION MATLAB code for VisualizeSegmentation.fig
%      VISUALIZESEGMENTATION, by itself, creates a new VISUALIZESEGMENTATION or raises the existing
%      singleton*.
%
%      H = VISUALIZESEGMENTATION returns the handle to a new VISUALIZESEGMENTATION or the handle to
%      the existing singleton*.
%
%      VISUALIZESEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALIZESEGMENTATION.M with the given input arguments.
%
%      VISUALIZESEGMENTATION('Property','Value',...) creates a new VISUALIZESEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VisualizeSegmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VisualizeSegmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VisualizeSegmentation

% Last Modified by GUIDE v2.5 22-Oct-2013 11:12:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VisualizeSegmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @VisualizeSegmentation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before VisualizeSegmentation is made visible.
function VisualizeSegmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VisualizeSegmentation (see VARARGIN)

    % Choose default command line output for VisualizeSegmentation
    handles.output = hObject;
    
    global config;
    
    if( isappdata(0,'vis_seg') )
        vis_seg = getappdata(0,'vis_seg');
        config.cI          =   vis_seg;
        rmappdata(0,'vis_seg');
    else
        msgbox('Some problem arise. Cannot visualize segmentation.');
        return
    end
    
    config.clrOverlay = [0 1 0];
    config.ImageOverlayHandle = 0;
    %colors = bone(20); colors = colors(8:end,:);    bgc = colors(1,:);
    %set(handles.figVisualizeSegmentation , 'units', 'pixels', 'color' , bgc, 'position', ceil(get(0,'screensize') .* [1 1 0.975 0.875]));
    centerfig(handles.figVisualizeSegmentation);
    CustomizeToolBar(handles.figVisualizeSegmentation);
    tmp = get(0,'screensize');
    if tmp(3) > 1200
        defaultFontsize = 8;
    else
        defaultFontsize = 8;
    end
    
%     set(handles.figVisualizeSegmentation,'DefaultUicontrolUnits','normalized',...
%         'DefaultUicontrolFontSize',defaultFontsize);
    leftPos = 0.02;
    
    [handles.imgOpacitySldr,~,~] = ...
        sliderPanel(handles.overlayPanel,...
        {'title','Image Opacity','pos',[leftPos 0.01 0.95 0.205],...
        'units','normalized','fontsize',defaultFontsize},...
        {'min',0,'max',1,'value',1,...
        'sliderstep',[0.01 0.1],...
        'tooltipstring',sprintf('Modify the transparency of the image.\nRight-Click bar to reset to default.')},...
        {'fontsize',defaultFontsize},...
        {'fontsize',defaultFontsize},...
        '%0.2f');
    [handles.overlayOpacitySldr,~,~] = ...
        sliderPanel(handles.overlayPanel,...
        {'title','Overlay Opacity','pos',[leftPos 0.35 0.95 0.205],...
        'units','normalized','fontsize',defaultFontsize},...
        {'min',0,'max',1,'value',0.4,...
        'sliderstep',[0.01 0.1],...
        'tooltipstring',sprintf('Modify the transparency of the overlay.\nRight-Click bar to reset to default.')},...
        {'fontsize',defaultFontsize},...
        {'fontsize',defaultFontsize},...
        '%0.2f');
    
    %{'backgroundcolor',bgc,'fontsize',defaultFontsize},...
%     switch (structInfo.selectedImageIndex)
%         case 1
%             imgToWork = getimage(structInfo.handleRGB);
%             set(handles.rb_RGB,       'value' , 1);
%         case 2
%             imgToWork = getimage(structInfo.handlegrayScale);
%             set(handles.radiobtnGreyscale, 'value' , 1);
%         case 3
%             imgToWork = getimage(structInfo.handlegCH);
%             set(handles.rb_GCH,     'value' , 1);
%         case 4
%             imgToWork = getimage(structInfo.handleAdHq);
%             set(handles.radiobtnAdHq,    'value' , 1);
%         case 5
%             imgToWork = getimage(structInfo.handleImRecon);
%             set(handles.radiobtnImRecon, 'value' , 1);
%     end
    imgToWork = config.cI.img;
    set(handles.figVisualizeSegmentation,'CurrentAxes',handles.axesOverlay);
    config.ImageOverlayHandle = imshow(imgToWork,[],'parent',handles.axesOverlay);
    %expandAxes(handles.axesOverlay);
    
    set (handles.overlayColorButton ,   'cdata',reshape(kron(config.clrOverlay,ones(15,15)),15,15,3));
    set(handles.imgOpacitySldr, 'callback',{@modifyOpacity,2, handles});
    set(handles.overlayOpacitySldr, 'callback',{@modifyOpacity,1, handles});
    
    updateOverlay(config.cI.ves_seg , handles);
    %set(handles.overlayPanel , 'backgroundcolor' , [0.061  0.01  0.081]);
    %set(handles.visualizeImgSelection , 'backgroundcolor' , bgc);
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes VisualizeSegmentation wait for user response (see UIRESUME)
    % uiwait(handles.figVisualizeSegmentation);
end 
% --- Outputs from this function are returned to the command line.
function varargout = VisualizeSegmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on modifyOpacity.
function modifyOpacity(varargin )
    global config;
    handles = varargin{4};    
    parentFigure = handles.figVisualizeSegmentation;
    set(parentFigure,'CurrentAxes',handles.axesOverlay);
    switch varargin{3}
        case 1
            if ~isempty(findall(gcf,'tag','opaqueOverlay'))
                showMaskAsOverlay(get(handles.overlayOpacitySldr,'value'));
            end
        case 2
            set(config.ImageOverlayHandle,...
                'alphadata',get(handles.imgOpacitySldr,'value'));
    end
end

% --- Executes on updateOverlay.
function updateOverlay(varargin)
    % Updates OVERLAY display
    % Takes one input: binary mask to OVERLAY
    % If OVERLAY is empty, mask is cleared; otherwise, it is written
    global config;
    binOverlayImage = varargin{1};
    handles =  varargin{2};
    if isempty(binOverlayImage)
        delete(findall(handles.axesOverlay,'tag','opaqueOverlay'))
    else
        set(handles.figVisualizeSegmentation,'CurrentAxes',handles.axesOverlay);
        opacity = get(handles.overlayOpacitySldr,'value');
        showMaskAsOverlay(opacity,varargin{1},config.clrOverlay);
        %expandAxes(handles.axesOverlay);
    end
end


% --- Executes on button press in overlayColorButton.
function overlayColorButton_Callback(hObject, eventdata, handles)
% hObject    handle to overlayColorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global config;
    %overlayColor = getappdata(handles.overlayColorButton,'overlayColor');
    new_overlayColor = uisetcolor(config.clrOverlay);
    set(handles.overlayColorButton,'cdata',reshape(kron(new_overlayColor,ones(15,15)),15,15,3));
    config.clrOverlay = new_overlayColor;
    %setappdata(handles.overlayColorButton,'overlayColor',overlayColor);
    
    set(handles.figVisualizeSegmentation,'CurrentAxes',handles.axesOverlay);

    if islogical(config.cI.ves_seg)
        updateOverlay(config.cI.ves_seg , handles);
    end
end


% --- Executes on button press in toogleOverlayImages.
function toogleOverlayImages_Callback(hObject, eventdata, handles)
% hObject    handle to toogleOverlayImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.axesOverlay,'children',flipud(get(handles.axesOverlay,'children')));
end


% --- Executes when selected object is changed in visualizeImgSelection.
function visualizeImgSelection_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in visualizeImgSelection 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
    
    global config;
    selectedRadio = get(hObject , 'Tag');
    
    switch (selectedRadio)
        case 'rb_RGB'
            imgToWork = config.cI.img;
        case 'rb_GCH'
            imgToWork = config.cI.img(:,:,2);
    end
    
    childImg = get(handles.axesOverlay,'children');
    delete (childImg);
    set(handles.figVisualizeSegmentation,'CurrentAxes',handles.axesOverlay);
    
    config.ImageOverlayHandle = imshow(imgToWork,[],'parent',handles.axesOverlay);
    
    if islogical(config.cI.ves_seg)
        updateOverlay(config.cI.ves_seg , handles);
    end
    
    
end


% --- Executes on button press in btnClose.
function btnClose_Callback(hObject, eventdata, handles)
% hObject    handle to btnClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    delete(handles.figVisualizeSegmentation);
end

function CustomizeToolBar(currFigure)
    a = findall(currFigure);
    tooltipStings = {'Save Figure', 'Print Figure' , 'Open File' , 'New Figure' , 'Insert Legend' , 'Insert Colorbar' , 'Data Cursor' , 'Rotate 3D' ,'Show Plot Tools' , 'Hide Plot Tools' , 'Link Plot' , 'Show Plot Tools and Dock Figure' , 'Brush/Select Data' , 'Edit Plot'};
    for idx = 1:length(tooltipStings)
        b = findall(a,'ToolTipString', tooltipStings{idx});
        set(b,'Visible','Off');
    end
    
    clear a; clear b;
end
