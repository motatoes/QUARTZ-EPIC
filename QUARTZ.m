function varargout = QUARTZ(varargin)
% QUARTZ MATLAB code for QUARTZ.fig
%      QUARTZ, by itself, creates a new QUARTZ or raises the existing
%      singleton*.
%
%      H = QUARTZ returns the handle to a new QUARTZ or the handle to
%      the existing singleton*.
%
%      QUARTZ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUARTZ.M with the given input arguments.
%
%      QUARTZ('Property','Value',...) creates a new QUARTZ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QUARTZ_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QUARTZ_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QUARTZ

% Last Modified by GUIDE v2.5 03-Dec-2013 05:51:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QUARTZ_OpeningFcn, ...
                   'gui_OutputFcn',  @QUARTZ_OutputFcn, ...
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


% --- Executes just before QUARTZ is made visible.
function QUARTZ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to QUARTZ (see VARARGIN)

% Choose default command line output for QUARTZ
    QUARTZ_setup(true);
    handles.output = hObject;
    handles.vessel_data = Vessel_Data;
    centerfig(handles.fig_QUARTZ_MAIN);
    warning('off');
    
    global proc_settings;
    global ui_settings;
    
       
    iniFileName = 'QUARTZ_CONFIG.MAT';
    
    bSavevsSetting = 0;
    %Load up the initial values from the mat file.
	strIniFile = fullfile(cd, '\QUARTZ_settings\' , iniFileName);
	mkdir([cd, '\QUARTZ_settings\']);
    if exist(strIniFile, 'file')
		load(strIniFile);
        %retVal = exist (ui_settings ,'var');
    else
        [ui_settings, proc_settings] = getDefaultSettings();
        bSavevsSetting = 1;
    end
    
    %if(retVal == 0)
    %    [ui_settings, settings] = getDefaultSettings();
    %    bSavevsSetting = 1;
    %end
    
    if(bSavevsSetting)
        save(strIniFile ,'ui_settings' , 'proc_settings');
    end
    %if exist(settings, 'class')
        handles.proc_settings = proc_settings;
    %end
   
    set(handles.txtFolder, 'string', ui_settings.ImageFolder);
	
    %uiwait(msgbox(structMainUI.ImageFolder));
    % Load list of images in the image folder.
    tdata  = LoadImageList();
    set(handles.tbl_ImagesData,'Data',tdata);
    % Select none of the items in the listbox.
	%set(handles.lst_ImageList, 'value', []);
	handles.cI = [];
    if(isempty(handles.cI))
        updateInteractiveModeUI(handles,'off');
    end
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = QUARTZ_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnBrowse.
function btnBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global ui_settings;
    returnValue = uigetdir(ui_settings.ImageFolder,'Select folder');
	% returnValue will be 0 (a double) if they click cancel.
	% returnValue will be the path (a string) if they clicked OK.
    %msgbox(ui_settings.ImageFolder);
	if returnValue ~= 0
		% Assign the value if they didn't click cancel.
		ui_settings.ImageFolder = [returnValue '\'];
		tdata  = LoadImageList();
        
        set(handles.tbl_ImagesData,'Data',tdata);
        set(handles.txtFolder, 'string' ,ui_settings.ImageFolder);
		if(ui_settings.isFovMaskDefaultDir)
            ui_settings.maskFolder = [ui_settings.ImageFolder 'MASK\'];
        end
        guidata(hObject, handles);
		% Save the image folder in our ini file.
		%configValues.lastUsedImageFolder = ui_settings.ImageFolder;
        strIniFile = fullfile([cd, '\QUARTZ_settings\'], ui_settings.iniFileName);
        ui_settings.batchBeginIndex =1;
        %if exist (strIniFile)
        %    load(ui_settings.iniFileName);
        %end
        %configValues.lastUsedImageFolder = ui_settings.ImageFolder;
		save( strIniFile , 'ui_settings' , '-append');
	end


% --- Executes on button press in btnVisualize.
function btnVisualize_Callback(hObject, eventdata, handles)
% hObject    handle to btnVisualize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if( get(handles.rb_vis_seg,'Value') == 1 )
        vis_seg = handles.cI;
        %vis_seg.binaryImage = handles.vessel_data.vessel_data.bw;
        setappdata(0,'vis_seg',vis_seg); 
        VisualizeSegmentation;
    elseif (get(handles.rb_vis_ana,'Value') == 1)
        vdobj.vessel_data = handles.vessel_data;
        vdobj.visualize = 1;
        vdobj.settings = handles.proc_settings.vessel_settings;
        setappdata(0,'vdobj',vdobj); 
        visAnalysis;
    end

% --- Executes on button press in btnProcess.
function btnProcess_Callback(hObject, eventdata, handles)
% hObject    handle to btnProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    prepareProcessing(1, hObject, handles);
    
    
%=====================================================================
% --- Load up the listbox with tif files in folder handles.ui_settings.ImageFolder
function [tab_data] = LoadImageList()   
    global ui_settings;
	
    tab_data = {};
	folder = ui_settings.ImageFolder;
	if ~isempty(ui_settings.ImageFolder) 
		if exist(folder,'dir') == false
			warningMessage = sprintf('Note: the folder used when this program was last run:\n%s\ndoes not exist on this computer.\nPlease run Step 1 to select an image folder.', ui_settings.ImageFolder);
			msgbox(warningMessage);
			return;
		end
	else
		msgboxw('No folder specified as input for function LoadImageList.');
		return;
	end
	% If it gets to here, the folder is good.
	ImageFiles = dir([ui_settings.ImageFolder ui_settings.ext]);
	for Index = 1:length(ImageFiles)
        if(ImageFiles(Index).isdir)
            continue;
        end
        
		imgName = ImageFiles(Index).name;
		[folder, name, extension] = fileparts(imgName);
		extension = upper(extension);
        %disp([num2str(Index-2) ':' name  extension]);
		switch lower(extension)
		case {'.png', '.bmp', '.jpg', '.tif', '.avi'}
			% Allow only PNG, TIF, JPG, or BMP images
			tab_data{end+1,1} = imgName; 
            tab_data{end,2} = 'false';
            tab_data{end,3} = 'false';
            
            tFile = [ui_settings.segPath name '.png'];
            if(exist (tFile , 'file'))
                tab_data{end,2} = 'true';
            end
            tFile = [ui_settings.anaPath name '.mat'];
            if(exist (tFile , 'file'))
                tab_data{end,3} = 'true';
            end
            
		otherwise
		end
	end
	
    return

%=====================================================================

%=====================================================================
% Reads FullImageFileName from disk into the axesImage axes.
function cI = DisplayImage(handles, imgPath)
	% Read in image.
    global ui_settings;
	cI = [];
    try
		cI = readImage(imgPath , '', ui_settings.maskFolder,ui_settings.genFOVruntime );
        anaFile = [ui_settings.segPath cI.StemName '.' ui_settings.segExt];
        if(exist(anaFile,'file') )
            binImg = imread(anaFile);
            if(~islogical(binImg))
                binImg = im2bw(binImg , graythresh(binImg));
            end
            cI.ves_seg = binImg;
            %handles.cI.ves_seg = binImg;
        end
        %imgOriginal  = imread(imgPath);
        %cI.img  = imgOriginal;
        %[folder, name, extension] = fileparts(imgPath);
        %cI.path = [folder '\'];
        %cI.StemName = name;
        %cI.extension = extension;
        %cI.mask = imread([ui_settings.maskFolder  cI.StemName '.png']);

    catch ME
		errorMessage = sprintf('Error opening image file with imread():\n%s\n%s', imgPath , ME.message);
		set(handles.txtStatus, 'String', errorMessage);
		msgbox(errorMessage);
		return;	% Skip the rest of this function
	end
	
    
	try
		% Display image array in a window on the user interface.
		set(handles.axesImage, 'parent',gcf);
        %set(gcf,'CurrentAxes',handles.axesImage);
        handleRGB = imshow(cI.img,[],'parent',handles.axesImage);
       
		% Display a title above the image.
		[folder, basefilename, extension] = fileparts(imgPath);
		extension = lower(extension);
		% Convert any underlines in the name into spaces because otherwise the character after the underline would be a subscript.
		caption = strrep([basefilename extension], '_', ' ');
		% Display the title.
		title(handles.axesImage, caption, 'FontSize', 8);
        
                
        %expandAxes(handles.axesImage);
    catch ME
		errorMessage = sprintf('Error in function DisplayImage.\nError Message:\n%s', ME.message);
		msgbox(errorMessage , 'Warning' , 'warn' , 'modal');
    end
    
	return; % from DisplayImage


% --- Executes when selected cell(s) is changed in tbl_ImagesData.
function tbl_ImagesData_CellSelectionCallback(hObject, eventData, handles)
% hObject    handle to tbl_ImagesData (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
    if( isempty(eventData.Indices) )
        return;
    end
    global ui_settings;
	% Get image name
    selectedItem = eventData.Indices(1);
	% If more than one is selected, bail out.
    if selectedItem < 0 
        return;
    end
    
    tbldata = get(handles.tbl_ImagesData,'Data');
    imgName = tbldata(selectedItem,1);
	imgName = cell2mat(imgName);
    imgPath = [ui_settings.ImageFolder  imgName];	% Prepend folder.
	
	[folder, baseFileName, extension] = fileparts(imgPath);
	switch lower(extension)
	case {'.tif', '.png', '.jpg'}
    	cI = DisplayImage(handles, imgPath);
        handles.cI = cI;
        clear cI;
        if(isempty(handles.cI)==0)
            updateInteractiveModeUI(handles,'on');
        end
        anaFile = [ui_settings.segPath imgName(1:end-3)  ui_settings.segExt];
        if(exist(anaFile,'file') )
            set(handles.rb_vis_seg , 'Enable' , 'on');
            binImg = imread(anaFile);
            if(~islogical(binImg))
                binImg = im2bw(binImg , graythresh(binImg));
            end
            handles.cI.ves_seg = binImg;
        else
            set(handles.rb_vis_seg , 'Enable' , 'off');
        end
        anaFile = [ui_settings.anaPath imgName(1:end-3) ui_settings.anaExt];
        if(exist(anaFile,'file') )
            vd = load(anaFile);
            handles.vessel_data = vd.vessel_data;
            set(handles.rb_vis_ana , 'Enable' , 'on');
        else
            set(handles.rb_vis_ana , 'Enable' , 'off');
            handles.vessel_data = [];%Vessel_Data;
        end
        
        if (strcmp(tbldata(selectedItem,2) ,'false') &&  strcmp(tbldata(selectedItem,3) ,'false' ) )
            set(handles.btnVisualize , 'Enable' , 'off');
        end
        
    otherwise
		msgboxw(['"' extension '"' ' is not supported.']);
		return;
    end
    
	% Update handles structure
    guidata(hObject, handles);
	


% --------------------------------------------------------------------
function Tools_Callback(hObject, eventdata, handles)
% hObject    handle to Tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function directories_Callback(hObject, eventdata, handles)
% hObject    handle to directories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global ui_settings;
    setappdata(0,'ui_settings',ui_settings); 
    f = vessel_segmentation_settings;
    waitfor(f);
    
    if( isappdata(0,'vui_settings') )
        vd = getappdata(0,'vui_settings');
        
        ui_settings.segPath   = vd.segPath;
        ui_settings.anaPath   = vd.anaPath;
        ui_settings.maskFolder = vd.maskFolder;
        ui_settings.segExt = vd.segExt;
        ui_settings.anaExt = vd.anaExt;
        ui_settings.exportMode = vd.exportMode;
        ui_settings.exportDir =  vd.exportDir;
        ui_settings.exportFile =  vd.exportFile;
        ui_settings.saperateFile4EachImage =  vd.saperateFile4EachImage;
        ui_settings.overwriteFile = vd.overwriteFile;
        ui_settings.writeCommulative = vd.writeCommulative;
        ui_settings.isFovMaskDefaultDir =  vd.isFovMaskDefaultDir;
        ui_settings.genFOVruntime =  vd.genFOVruntime;
        if( ui_settings.isFovMaskDefaultDir )
             ui_settings.maskFolder = [ui_settings.ImageFolder , 'MASK\'];
        end
        rmappdata(0,'vui_settings');

        iniFileName = 'QUARTZ_CONFIG.MAT';
        strIniFile = fullfile(cd, '\QUARTZ_settings\' , iniFileName);
        save(strIniFile ,'ui_settings' , '-append');
    end
 
    
    
    

% --------------------------------------------------------------------
function preferences_Callback(hObject, eventdata, handles)
% hObject    handle to preferences (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in lstStatusMsg.
function lstStatusMsg_Callback(hObject, eventdata, handles)
% hObject    handle to lstStatusMsg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstStatusMsg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstStatusMsg


% --- Executes during object creation, after setting all properties.
function lstStatusMsg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstStatusMsg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes on button press in btnBreak.
function btnBreak_Callback(hObject, eventdata, handles)
% hObject    handle to btnBreak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ui_settings;
ui_settings.broken = 1;


% --- Executes on button press in btnClearStatusMsg.
function btnClearStatusMsg_Callback(hObject, eventdata, handles)
% hObject    handle to btnClearStatusMsg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.txtStatus,'String','..');


function [ui_settings , proc_settings] = getDefaultSettings(mode)

    userDir='C:\';
    if(ispc)
        userDir = winqueryreg('HKEY_CURRENT_USER',...
                    ['Software\Microsoft\Windows\CurrentVersion\' ...
                    'Explorer\Shell Folders'],'Personal') ;

        if(isempty(userDir))
             userDir= getenv('USERPROFILE'); 
        end
    else
         userDir= getenv('HOME'); 
    end
    userDir = [userDir '\'];
    
    ui_settings.ImageFolder = userDir;
    ui_settings.maskFolder = [ui_settings.ImageFolder  '\MASK\'];
    ui_settings.iniFileName = 'QUARTZ_CONFIG.MAT';
    ui_settings.anaPath = 'C:\D\QUARTZ\TEST\Ana\';
    ui_settings.segPath = 'C:\D\QUARTZ\TEST\Seg\';
    ui_settings.ext = '*.*';
    ui_settings.anaExt = 'mat';
    ui_settings.segExt = 'png';
    ui_settings.broken = 0;
    ui_settings.mode = '';
    ui_settings.batchBeginIndex = 1;
    ui_settings.bWriteIntemediateImages = false;
    ui_settings.interim_images_path = '';
    
    ui_settings.batBeginIndex = 1;
    ui_settings.batEndIndex   = 73;
    ui_settings.broken = 0;
    ui_settings.bProcessAllFiles = 0;
    
    ui_settings.exportMode = 1;
    ui_settings.exportDir = 'C:\D\QUARTZ\TEST\';
    ui_settings.exportFile = 'testFile';
    ui_settings.saperateFile4EachImage = 0;
    ui_settings.overwriteFile = 1;
    ui_settings.writeCommulative = 0;
    ui_settings.isFovMaskDefaultDir = 1;
    ui_settings.genFOVruntime = 0;
    ui_settings.procMode = 1;
    ui_settings.procOption = 1;
    
    
    args.image_large_size = [1024 , 1024];
    args.image_resize_factor = 1;
    args.mask_option = 'create';
    args.mask_erode  = 1;
    args.iuwt_dark   =  1;
    args.iuwt_inpainting = 0;
    args.iuwt_w_levels  = 0.2;
    args.iuwt_w_thresh = [3,4,5]
    args.iuwt_px_remove = 0.05;
    args.iuwt_px_fill = 0.05;
    args.spline_piece_spacing = 10;
    args.processor_function = 'QUARTZ_algorithm_general'
    args.mask_dark_threshold = 30;
    args.mask_bright_threshold = 255;
    args.mask_largest_region = 1;
    args.centre_spurs = 10;
    args.centre_min_px = 10;
    args.centre_remove_extreme = 1;
    args.centre_clear_branches_dist_transform = 0;
    args.smooth_parallel = 2;
    args.smooth_perpendicular = 0.1;
    args.enforce_connectivity = 1;
    
    
    proc_settings.vessel_settings = Vessel_Settings;
    proc_settings.vessel_settings.show_labels = false;
    proc_settings.vessel_settings.show_optic_disc = true;
    proc_settings.vs_args = args;
    proc_settings.segment = [];
     
    

% --- Executes on button press in btnClose.
function btnClose_Callback(hObject, eventdata, handles)
% hObject    handle to btnClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 try
    allFigs = findall(0,'Type','figure');
    for idx = 1: length(allFigs)
        if( strcmp(get(allFigs(idx) , 'tag' ) , 'figVesselSegmentTool'))
            delete(allFigs(idx));
        elseif( strcmp(get(allFigs(idx) , 'tag' ) , 'figVisualizeSegmentation'))
            delete(allFigs(idx));
        end
    end

    clear allFigs;
    delete(handles.fig_QUARTZ_MAIN);
    
    catch Ex
        
 end
 
function doProcessing(hObject,handles)
    global ui_settings;
    mkdir(ui_settings.anaPath);
    
    handles.proc_settings.vessel_settings.last_path = ui_settings.segPath;
    try           
    if(ui_settings.procMode == 2 ) %Interactive Processing Mode
        imgPath = [handles.cI.path , handles.cI.StemName, handles.cI.ext]; 
        new_line = ['Started     : '  handles.cI.StemName];
        set(handles.txtStatus,'String',new_line);
        pause (0.1);
        % vessel segmentation only
        if(ui_settings.procOption == 1)
            ves_seg = vessel_segmentation(ui_settings, handles.cI);
            handles.cI.ves_seg = ves_seg;
        % vessel analysis only
        elseif (ui_settings.procOption > 1)
            if(ui_settings.procOption == 3)
                ves_seg = vessel_segmentation(ui_settings , handles.cI);
                handles.cI.ves_seg = ves_seg;
            end
            handles.proc_settings.vs_args.cI = handles.cI ;
             % Load VESSEL_DATA from file
            [handles.vessel_data, process_time] = Vessel_Data_IO.load_from_file(imgPath, ...
                                           handles.proc_settings.vs_args, handles.proc_settings.vessel_settings);
            [x_cord , y_cord] = od_localization(handles.cI.img);
            handles.vessel_data.od_location = [x_cord , y_cord];
            %////vess classification
            AVClassification('' , handles.vessel_data);
            %/////vess classification
            
            fileName = [ui_settings.anaPath  handles.cI.StemName '.mat'  ];
            Vessel_Data_IO.save_to_file(fileName, handles.vessel_data);
        end
        cur_msg=cellstr(get(handles.txtStatus,'String'));
        new_line = ['Finished     : '  handles.cI.StemName];
        new_msg = [cur_msg;{new_line}];
        set(handles.txtStatus,'String',new_msg);
    elseif(ui_settings.procMode == 1 ) %Batch Processing Mode
        tbldata = get(handles.tbl_ImagesData,'Data');
        numImages = size(tbldata,1);
        %these should be updates in a callback; not here
        ui_settings.batBeginIndex = str2num(get(handles.edStart , 'String'));
        ui_settings.batEndIndex   = str2num(get(handles.edEnd , 'String'));
        
        if(ui_settings.bProcessAllFiles)
            begIdx = 1 ;
            endIdx = numImages;
        else
            begIdx = ui_settings.batBeginIndex ;
            endIdx = ui_settings.batEndIndex ;
        end
        
        set(handles.txtStatus,'String','. . .');
        for (idx = begIdx:endIdx)

            imgName = tbldata(idx,1);
            imgName = cell2mat(imgName);
            imgPath = [ui_settings.ImageFolder  imgName];

            cI = DisplayImage(handles, imgPath);
            handles.cI = cI;
            
            new_line = ['Started     : ' num2str(idx) '-' cI.StemName];
            if(idx > begIdx)
                cur_msg  = ['Finished  : ' num2str(idx-1) '-' cell2mat(tbldata(idx-1,1))];
            else
                cur_msg=cellstr(get(handles.txtStatus,'String'));
            end
            new_msg = [cur_msg;{new_line}];
            set(handles.txtStatus,'String',new_msg);
            clear cur_msg;
            pause(0.1);
            if (ui_settings.broken  == 1)
                new_line = ['TERMINATED after  completing ' num2str(idx) '-' cI.StemName];
                cur_msg=cellstr(get(handles.txtStatus,'String'));
                new_msg = [cur_msg;{new_line}];
                set(handles.txtStatus,'String',new_msg);
                %ui_settings.batchBeginIndex = idx+1;
                %strIniFile = fullfile(cd, ui_settings.iniFileName);
                %save(strIniFile ,'ui_settings' , '-append');
                ui_settings.broken = 0;
                break;
            end

            if(ui_settings.procOption == 1)
                ves_seg = vessel_segmentation(ui_settings, handles.cI);
                handles.cI.ves_seg = ves_seg;
            elseif (ui_settings.procOption >1)
                if( ui_settings.procOption == 3)
                    ves_seg = vessel_segmentation(ui_settings);
                    handles.cI.ves_seg = ves_seg; 
                end
                handles.proc_settings.vs_args.cI = handles.cI ;
                % Load VESSEL_DATA from file
                [handles.vessel_data, process_time] = Vessel_Data_IO.load_from_file(imgPath, ...
                                           handles.proc_settings.vs_args, handles.proc_settings.vessel_settings);
                
                [x_cord , y_cord] = od_localization(handles.cI.img);
                handles.vessel_data.od_location = [x_cord , y_cord];
                %////vess classification
                AVClassification('' , handles.vessel_data);
                %/////vess classification
                fileName = [ui_settings.anaPath  cI.StemName '.mat'  ];
                Vessel_Data_IO.save_to_file(fileName, handles.vessel_data);
            end
            disp(['DONE : ' num2str(idx) '-' cI.StemName]);
        end
    
    end
    catch Ex
        errorMessage = sprintf('Error in function doProcessing.\nError Message:\n%s', Ex.message);
		msgbox(errorMessage , 'Warning' , 'warn' , 'modal');
        updateProcessingModeUI(handles,'on');
    end
    % Update handles structure
guidata(hObject, handles);
 
function updateInteractiveModeUI(handles, val)
    set(handles.rb_int_proc,'Enable' , val);
    set(handles.rb_vis_seg,'Enable' , val);
    set(handles.rb_vis_ana,'Enable' , val);
    set(handles.btnVisualize,'Enable' , val);

function updateProcessingModeUI(handles, val)
    set(handles.rb_int_proc,'Enable' , val);
    set(handles.rb_bat_proc,'Enable' , val);
    
    set(handles.rb_vseg,'Enable' , val);
    set(handles.rb_vana,'Enable' , val);
    set(handles.rb_vseg_ana,'Enable' , val);
    
    set(handles.rb_vis_seg,'Enable' , val);
    set(handles.rb_vis_ana,'Enable' , val);
    set(handles.btnVisualize,'Enable' , val);
    
    set(handles.btnProcess,'Enable' , val);
    set(handles.btnClearStatusMsg,'Enable' , val);
    set(handles.tbl_ImagesData,'Enable' , val);
    
    set(handles.chkAllFiles,'Enable' , val);
    set(handles.edStart,'Enable' , val);
    set(handles.edEnd,'Enable' , val);
    
    set(handles.btnExport,'Enable' , val);
    set(handles.btnPreprocess,'Enable' , val);
    set(handles.btnBrowse,'Enable' , val);
    


% --- Executes on button press in btnExport.
function btnExport_Callback(hObject, eventdata, handles)
% hObject    handle to btnExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    updateProcessingModeUI(handles,'off');
    set(handles.txtStatus,'String','Start : Exporting vessel analysis');
    pause(0.1);
    global ui_settings;
    path = ui_settings.anaPath;
    D= dir([path '*.mat']);
    expFile = [ui_settings.exportDir '\' ui_settings.exportFile];
    if(ui_settings.overwriteFile == 0)
        c = clock;
        c = fix(c);
        expFile = [expFile '_'  num2str(c(1)) num2str(c(2)) num2str(c(3)) num2str(c(4)) num2str(c(5)) num2str(c(6))];
    end
    
    if(ui_settings.writeCommulative)
        header = {'ImageName', 'OD X' , 'OD Y','Segment ID', 'Prob A' ,'Prob V', 'Num Diameters' , 'Mean Diameter' ,'std Diameter' ,'Min' , 'Max' ,'length', 'Diameter/Length' , 'Tortousity' ,'Centerline CoordinateX','Centerline CoordinateY','Diameter','Local Angle' };
    else
        header1 = {'ImageName', 'OD X' , 'OD Y','Segment ID', 'Prob A' ,'Prob V', 'Num Diameters' , 'Mean Diameter' ,'std Diameter' ,'Min' , 'Max' ,'length', 'Diameter/Length' , 'Tortousity'  };
        header2 = {'ImageName', 'Segment ID','Centerline CoordinateX','Centerline CoordinateY','Diameter','Local Angle' };
    end
for(nIdx = 1:length(D))
    filepath = [path , D(nIdx).name];
    stemName = D(nIdx).name(1:end-4);
    [vessel_data, process_time] = Vessel_Data_IO.load_from_file(filepath, ...
                                            handles.proc_settings.vs_args, handles.proc_settings.vessel_settings);
       
    num_vessels = vessel_data.num_vessels;
    total_diameters = vessel_data.total_diameters;
    
    for(kdx = 1:num_vessels)
        vess = vessel_data.vessel_list(kdx);
        tdx = 1;
        num_diameters = vess.num_diameters;
        %do not write cumulative file
        if(ui_settings.writeCommulative == 0)
            adx = 1;
            if(kdx==1)
                mtW = header2;
                aW = header1; 
            end
            
            aW(kdx+1,adx) = cellstr(stemName);adx = adx+1;
            aW(kdx+1,adx) = num2cell(vessel_data.od_location(1));adx = adx+1;
            aW(kdx+1,adx) = num2cell(vessel_data.od_location(2));adx = adx+1;
            aW(kdx+1,adx) = num2cell(vess.vesID,2); adx = adx+1;
            if(isempty(vess.AV))
                vess.AV = [0,0];
            end
            aW(kdx+1,adx) = num2cell(vess.AV(1));  adx = adx+1;
            aW(kdx+1,adx) = num2cell(vess.AV(2));  adx = adx+1;

            d = vess.diameters(vess.keep_inds);

            aW(kdx+1,adx) = num2cell(numel(d)); adx = adx+1;
            aW(kdx+1,adx) = num2cell(mean(d)); adx = adx+1;
            aW(kdx+1,adx) = num2cell(std(d)); adx = adx+1;
            aW(kdx+1,adx) = num2cell(min(d)); adx = adx+1;
            aW(kdx+1,adx) = num2cell(max(d)); adx = adx+1;
            % Calculate length
            ind1 = find(vess.keep_inds, 1, 'first');
            ind2 = find(vess.keep_inds, 1, 'last');
            len = vess.offset(ind2) - vess.offset(ind1);
            aW(kdx+1,adx) = num2cell(len); adx = adx+1;
            % Calculate diameter / length
            aW(kdx+1,adx) = num2cell(mean(d) / len); adx = adx+1;
            % Calculate tortuosity
            direct_len = sqrt(sum((vess.centre(ind2,:) - vess.centre(ind1,:)).^2)) * vess.scale_value;
            tort = len / direct_len;
            aW(kdx+1,adx) = num2cell(tort); adx = adx+1;
            
            tW(1:num_diameters,tdx) = cellstr(stemName);tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(vess.vesID,2); tdx = tdx+1;
       
        else
            if(kdx==1)
                mtW=header;
            end
            tW(1:num_diameters,tdx) = cellstr(stemName);tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(vessel_data.od_location(1));tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(vessel_data.od_location(2));tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(vess.vesID,2); tdx = tdx+1;

            if(isempty(vess.AV))
                vess.AV = [0,0];
            end
            tW(1:num_diameters,tdx) = num2cell(vess.AV(1));  tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(vess.AV(2));  tdx = tdx+1;

            d = vess.diameters(vess.keep_inds);

            tW(1:num_diameters,tdx) = num2cell(numel(d)); tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(mean(d)); tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(std(d)); tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(min(d)); tdx = tdx+1;
            tW(1:num_diameters,tdx) = num2cell(max(d)); tdx = tdx+1;
            % Calculate length
            ind1 = find(vess.keep_inds, 1, 'first');
            ind2 = find(vess.keep_inds, 1, 'last');
            len = vess.offset(ind2) - vess.offset(ind1);
            data{6,2} = len;
            tW(1:num_diameters,tdx) = num2cell(len); tdx = tdx+1;
            % Calculate diameter / length
            data{7,2} = mean(d) / len;
            tW(1:num_diameters,tdx) = num2cell(mean(d) / len); tdx = tdx+1;
            % Calculate tortuosity
            direct_len = sqrt(sum((vess.centre(ind2,:) - vess.centre(ind1,:)).^2)) * vess.scale_value;
            tort = len / direct_len;
            tW(1:num_diameters,tdx) = num2cell(tort); tdx = tdx+1;
        end
        tW(1:num_diameters,tdx) = num2cell(vess.centre(:,1));tdx = tdx+1;
        tW(1:num_diameters,tdx) = num2cell(vess.centre(:,2));tdx = tdx+1;
        tW(1:num_diameters,tdx) = num2cell(vess.diameters,2);tdx = tdx+1;
        
        ang = vess.der;
        angleInRadians = atan2(ang(:,1),ang(:,2));
        angleInDegrees = (180/pi) * angleInRadians;
        th = angleInDegrees * -1;
        %th = (rad2deg(atan2(ang(:,1),ang(:,2))))*-1;
        tW(1:num_diameters,tdx) = num2cell(th(1:num_diameters)); tdx = tdx+1;
        
        
        mtW = cat(1,mtW , tW);
        clear tW;
%         for (nd = 1:num_diameters)
%             cent_co = [ num2str(vess.centre(nd,1)) , ',' , num2str(vess.centre(nd,2))];
%             tW (nd,2) = vess.centre(nd,1);
%             tW (nd,3) = vess.centre(nd,2);
%             tW (nd,4) = vess.diameters(nd);
%             %tw (nd,4) = [ num2str(vess.angles(nd,1)) , ',' , num2str(vess.angles(nd,2))];
%             tw (nd,5) =  vess.angles(nd,1) ;
%         end
%         
%         mtW = cat(1,mtW , tW);
%         tW = [];
    end
    
    if(ui_settings.exportMode == 1) %do excel
        if ui_settings.saperateFile4EachImage == 1
            if ui_settings.writeCommulative
                fileName = [expFile '_' stemName '.xls'];
                xlswrite(fileName, mtW,  'A1');
            else
                fileName1 =  [expFile '_' stemName '_1.xls'];
                fileName2 =  [expFile '_' stemName '_2.xls'];
                xlswrite(fileName1, aW,  'A1');
                xlswrite(fileName2, mtW,  'A1');
            end
        else
            if ui_settings.writeCommulative
                fileName = [expFile '.xls'];
                xlswrite(fileName, mtW,  stemName, 'A1');
            else
                fileName1 =  [expFile  '_1.xls'];
                fileName2 =  [expFile  '_2.xls'];
                xlswrite(fileName1, aW,  stemName, 'A1');
                xlswrite(fileName2, mtW,  stemName, 'A1');
            end
        end
        
    elseif(ui_settings.exportMode == 2) %do csv
        if ui_settings.saperateFile4EachImage == 1
            flag = 'w';
            if ui_settings.writeCommulative
                fileName = [expFile '_' stemName '.csv'];
            else
                fileName1 =  [expFile '_' stemName '_1.csv'];
                fileName2 =  [expFile '_' stemName '_2.csv'];
            end
        elseif ui_settings.saperateFile4EachImage == 0
            flag = 'a';
            if ui_settings.writeCommulative
                fileName1 = [expFile '.csv'];
            else
                fileName1 = [expFile '_1.csv'];
                fileName2 = [expFile '_2.csv'];
            end
        end
        
        if (ui_settings.writeCommulative == 1)
            fid = fopen(fileName, flag);
            for row=1:size(mtW,1)
                if(row==1)
                    fprintf(fid, '%s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s \n', mtW{row,:});
                else
                    fprintf(fid, '%s , %d , %d , %d , %f , %f , %d , %f , %f , %f , %f , %f , %f , %f , %f , %f , %f , %f \n', mtW{row,:});
                end
            end
            fclose(fid);
        elseif ui_settings.writeCommulative == 0
            fid1 = fopen(fileName1, flag);
            for row=1:size(aW,1)
                if(row==1)
                    fprintf(fid1, '%s , %s , %s , %s , %s , %s , %s , %s , %s , %s , %s  , %s , %s , %s  \n', aW{row,:});
                else
                    fprintf(fid1, '%s , %d , %d , %d , %f , %f , %d , %f , %f , %f , %f  , %f , %f , %f  \n', aW{row,:});
                end
            end
            fclose(fid1);
            fid2 = fopen(fileName2, flag);
            for row=1:size(mtW,1)
                if(row==1)
                    fprintf(fid2, '%s , %s , %s , %s , %s , %s  \n', mtW{row,:});
                else
                    fprintf(fid2, '%s , %d , %f , %f , %f , %f  \n', mtW{row,:});
                end
            end
            fclose(fid2);
        end
        %mtW(1,:) = [];
        %dlmwrite(fileName,mtW,'-append');
        %csvwrite(expFile,cell2mat(mtW));
        
        
    end
    clear mtW;
end

updateProcessingModeUI(handles,'on');
set(handles.txtStatus,'String','Finished : Export vessel analysis');


% --- Executes on button press in btnOpenExcel.
function btnOpenExcel_Callback(hObject, eventdata, handles)
% hObject    handle to btnOpenExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system('climate.xls');



function edStart_Callback(hObject, eventdata, handles)
% hObject    handle to edStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edStart as text
%        str2double(get(hObject,'String')) returns contents of edStart as a double


% --- Executes during object creation, after setting all properties.
function edStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edEnd_Callback(hObject, eventdata, handles)
% hObject    handle to edEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edEnd as text
%        str2double(get(hObject,'String')) returns contents of edEnd as a double


% --- Executes during object creation, after setting all properties.
function edEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkAllFiles.
function chkAllFiles_Callback(hObject, eventdata, handles)
% hObject    handle to chkAllFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkAllFiles
global ui_settings;

ui_settings.bProcessAllFiles =  get(hObject,'Value'); 
if( ui_settings.bProcessAllFiles )

else
    ui_settings.batBeginIndex = get(handles.edStart , 'String');
    ui_settings.batEndIndex   = get(handles.edEnd , 'String');
end


% --- Executes on button press in btnPreprocess.
function btnPreprocess_Callback(hObject, eventdata, handles)
% hObject    handle to btnPreprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prepareProcessing(2 ,hObject, handles);

function doPreProcessing(hObject,handles)
global ui_settings;
    
try 
    processedDir = [ui_settings.ImageFolder '\Processed\'];
    mkdir(processedDir);
    avgMaskSize = 151;
    if(ui_settings.procMode == 2 ) %Interactive Processing Mode
        handles.proc_settings.vs_args.cI = handles.cI ;
        imgPath = [handles.cI.path , handles.cI.StemName, handles.cI.ext]; 
        new_line = ['Started     : '  handles.cI.StemName];
        set(handles.txtStatus,'String',new_line);
        pause (0.1);
        %%%
        R = prehomogenized(handles.cI.img ,1 , avgMaskSize , handles.cI.mask) ;
        G = prehomogenized(handles.cI.img ,2 , avgMaskSize , handles.cI.mask) ;
        B = prehomogenized(handles.cI.img ,3 , avgMaskSize , handles.cI.mask) ; 
        RGB(:,:,1) = R;
        RGB(:,:,2) = G;
        RGB(:,:,3) = B;
        save([processedDir , handles.cI.StemName '.mat'] , 'RGB');

        cur_msg=cellstr(get(handles.txtStatus,'String'));
        new_line = ['Finished     : '  handles.cI.StemName];
        new_msg = [cur_msg;{new_line}];
        set(handles.txtStatus,'String',new_msg);
    elseif(ui_settings.procMode == 1 ) %Batch Processing Mode
        tbldata = get(handles.tbl_ImagesData,'Data');
        numImages = size(tbldata,1);
        %these should be updates in a callback; not here
        ui_settings.batBeginIndex = str2num(get(handles.edStart , 'String'));
        ui_settings.batEndIndex   = str2num(get(handles.edEnd , 'String'));
        
        if(ui_settings.bProcessAllFiles)
            begIdx = 1 ;
            endIdx = numImages;
        else
            begIdx = ui_settings.batBeginIndex ;
            endIdx = ui_settings.batEndIndex ;
        end
        
        set(handles.txtStatus,'String','. . .');
        for (idx = begIdx:endIdx)

            imgName = tbldata(idx,1);
            imgName = cell2mat(imgName);
            imgPath = [ui_settings.ImageFolder  imgName];

            cI = DisplayImage(handles, imgPath);
            handles.cI = cI;
            handles.proc_settings.vs_args.cI = handles.cI ;
            
            new_line = ['Started     : ' num2str(idx) '-' cI.StemName];
            if(idx > begIdx)
                cur_msg  = ['Finished  : ' num2str(idx-1) '-' cell2mat(tbldata(idx-1,1))];
            else
                cur_msg=cellstr(get(handles.txtStatus,'String'));
            end
            new_msg = [cur_msg;{new_line}];
            set(handles.txtStatus,'String',new_msg);
            clear cur_msg;
            pause(0.1);
            if (ui_settings.broken  == 1)
                new_line = ['TERMINATED after  completing ' num2str(idx) '-' cI.StemName];
                cur_msg=cellstr(get(handles.txtStatus,'String'));
                new_msg = [cur_msg;{new_line}];
                set(handles.txtStatus,'String',new_msg);
                %ui_settings.batchBeginIndex = idx+1;
                %strIniFile = fullfile(cd, ui_settings.iniFileName);
                %save(strIniFile ,'ui_settings' , '-append');
                ui_settings.broken = 0;
                break;
            end
            
            R = prehomogenized(cI.img ,1 , avgMaskSize , cI.mask) ;
            G = prehomogenized(cI.img ,2 , avgMaskSize , cI.mask) ;
            B = prehomogenized(cI.img ,3 , avgMaskSize , cI.mask) ; 
            RGB(:,:,1) = R;
            RGB(:,:,2) = G;
            RGB(:,:,3) = B;
            save([processedDir , cI.StemName '.mat'] , 'RGB');
        end
    end
catch Ex
        errorMessage = sprintf('Error in function pre-processing.\nError Message:\n%s', Ex.message);
        msgbox(errorMessage , 'Warning' , 'warn' , 'modal');
        updateProcessingModeUI(handles,'on');
end

function prepareProcessing(mode, hObject, handles)
    global ui_settings
    
    pMode = get(handles.uiProcMode , 'SelectedObject');
    pOption = get(handles.uiProcOption , 'SelectedObject');
    
    if(pOption == handles.rb_vseg)
        procOption = 1;
    elseif (pOption == handles.rb_vana)
        procOption = 2;
    elseif (pOption == handles.rb_vseg_ana)
        procOption = 3;
    end
    
    if(pMode == handles.rb_bat_proc)
        procMode = 1;
    elseif (pMode == handles.rb_int_proc)
        procMode = 2;
    end
    
    ui_settings.procMode = procMode;
    ui_settings.procOption = procOption;
    set(handles.txtStatus,'String','. . .');
    
    updateProcessingModeUI(handles, 'off');
    if(mode==1)
        doProcessing(hObject, handles);
    elseif mode == 2
        doPreProcessing(hObject, handles);
    end
    updateProcessingModeUI(handles, 'on')
    tdata  = LoadImageList();
    set(handles.tbl_ImagesData,'Data',tdata);
