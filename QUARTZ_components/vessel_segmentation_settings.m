function varargout = vessel_segmentation_settings(varargin)
% VESSEL_SEGMENTATION_SETTINGS MATLAB code for vessel_segmentation_settings.fig
%      VESSEL_SEGMENTATION_SETTINGS, by itself, creates a new VESSEL_SEGMENTATION_SETTINGS or raises the existing
%      singleton*.
%
%      H = VESSEL_SEGMENTATION_SETTINGS returns the handle to a new VESSEL_SEGMENTATION_SETTINGS or the handle to
%      the existing singleton*.
%
%      VESSEL_SEGMENTATION_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VESSEL_SEGMENTATION_SETTINGS.M with the given input arguments.
%
%      VESSEL_SEGMENTATION_SETTINGS('Property','Value',...) creates a new VESSEL_SEGMENTATION_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vessel_segmentation_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vessel_segmentation_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vessel_segmentation_settings

% Last Modified by GUIDE v2.5 02-Dec-2013 17:07:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vessel_segmentation_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @vessel_segmentation_settings_OutputFcn, ...
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


% --- Executes just before vessel_segmentation_settings is made visible.
function vessel_segmentation_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vessel_segmentation_settings (see VARARGIN)

% Choose default command line output for vessel_segmentation_settings
handles.output = hObject;

if( isappdata(0,'ui_settings') )
    vd = getappdata(0,'ui_settings');
    
    handles.ui_settings = vd;
    rmappdata(0,'ui_settings');
end
set(handles.edSegmentedVesselDir ,'String' , vd.segPath);
set(handles.edVesselDataDir ,'String' , vd.anaPath);
set(handles.edFOVMaskDir ,'String' , vd.maskFolder);
set(handles.segFileExt ,'String' , vd.segExt);
set(handles.anaFileExt ,'String' , vd.anaExt);
if(vd.exportMode == 1)
    set(handles.rb_excel_sheet ,'Value' , 1);
elseif(vd.exportMode == 2)
    set(handles.rb_csv_file ,'Value' , 1);
end
set(handles.edExportDir ,'String' , vd.exportDir);
set(handles.edExportFilename ,'String' , vd.exportFile);

set(handles.chk_ex_saperatefile ,'Value' , vd.saperateFile4EachImage);
set(handles.chk_ex_overwrite ,'Value' , vd.overwriteFile);
set(handles.chk_ex_commulative ,'Value' , vd.writeCommulative);
set(handles.chk_FOVMASK_IsDefaultDir ,'Value' , vd.isFovMaskDefaultDir);
set(handles.chk_gen_fov_runtime ,'Value' , vd.genFOVruntime);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vessel_segmentation_settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vessel_segmentation_settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edSegmentedVesselDir_Callback(hObject, eventdata, handles)
% hObject    handle to edSegmentedVesselDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSegmentedVesselDir as text
%        str2double(get(hObject,'String')) returns contents of edSegmentedVesselDir as a double


% --- Executes during object creation, after setting all properties.
function edSegmentedVesselDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSegmentedVesselDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnBrSegPath.
function btnBrSegPath_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrSegPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectDirectory(handles.edSegmentedVesselDir); 

% --- Executes on button press in ckhSaveInterim.
function ckhSaveInterim_Callback(hObject, eventdata, handles)
% hObject    handle to ckhSaveInterim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ckhSaveInterim


% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vd.segPath    = get(handles.edSegmentedVesselDir ,'String' );
vd.anaPath    = get(handles.edVesselDataDir ,'String'  );
vd.maskFolder = get(handles.edFOVMaskDir ,'String' );
vd.segExt     = get(handles.segFileExt ,'String' );
vd.anaExt     = get(handles.anaFileExt ,'String' );

if(get(handles.rb_excel_sheet ,'Value' ) == 1)
    vd.exportMode = 1;
elseif( get(handles.rb_csv_file ,'Value' ) == 1)
    vd.exportMode = 2;
end

vd.exportDir  = get(handles.edExportDir ,'String' );
vd.exportFile = get(handles.edExportFilename ,'String'  );

vd.saperateFile4EachImage   = get(handles.chk_ex_saperatefile ,'Value' );
vd.overwriteFile = get(handles.chk_ex_overwrite ,'Value' );
vd.writeCommulative = get(handles.chk_ex_commulative ,'Value' );
vd.isFovMaskDefaultDir      = get(handles.chk_FOVMASK_IsDefaultDir ,'Value' );
vd.genFOVruntime   = get(handles.chk_gen_fov_runtime ,'Value'  );
setappdata(0,'vui_settings',vd); 


delete(gcf);

% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);


function edFOVMaskDir_Callback(hObject, eventdata, handles)
% hObject    handle to edFOVMaskDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edFOVMaskDir as text
%        str2double(get(hObject,'String')) returns contents of edFOVMaskDir as a double


% --- Executes during object creation, after setting all properties.
function edFOVMaskDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edFOVMaskDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnBrMaskPath.
function btnBrMaskPath_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrMaskPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectDirectory(handles.edFOVMaskDir);



function edVesselDataDir_Callback(hObject, eventdata, handles)
% hObject    handle to edVesselDataDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edVesselDataDir as text
%        str2double(get(hObject,'String')) returns contents of edVesselDataDir as a double


% --- Executes during object creation, after setting all properties.
function edVesselDataDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edVesselDataDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnBrVesselDataPath.
function btnBrVesselDataPath_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrVesselDataPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectDirectory(handles.edVesselDataDir);

% --- Executes on button press in chk_FOVMASK_IsDefaultDir.
function chk_FOVMASK_IsDefaultDir_Callback(hObject, eventdata, handles)
% hObject    handle to chk_FOVMASK_IsDefaultDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_FOVMASK_IsDefaultDir



function edExportDir_Callback(hObject, eventdata, handles)
% hObject    handle to edExportDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edExportDir as text
%        str2double(get(hObject,'String')) returns contents of edExportDir as a double


% --- Executes during object creation, after setting all properties.
function edExportDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edExportDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edExportFilename_Callback(hObject, eventdata, handles)
% hObject    handle to edExportFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edExportFilename as text
%        str2double(get(hObject,'String')) returns contents of edExportFilename as a double


% --- Executes during object creation, after setting all properties.
function edExportFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edExportFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnBrExportDir.
function btnBrExportDir_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrExportDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectDirectory(handles.edExportDir); 

% --- Executes on button press in chk_ex_saperatefile.
function chk_ex_saperatefile_Callback(hObject, eventdata, handles)
% hObject    handle to chk_ex_saperatefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_ex_saperatefile


% --- Executes on button press in chk_gen_fov_runtime.
function chk_gen_fov_runtime_Callback(hObject, eventdata, handles)
% hObject    handle to chk_gen_fov_runtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_gen_fov_runtime


% --- Executes on selection change in anaFileExt.
function anaFileExt_Callback(hObject, eventdata, handles)
% hObject    handle to anaFileExt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns anaFileExt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from anaFileExt


% --- Executes during object creation, after setting all properties.
function anaFileExt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anaFileExt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in segFileExt.
function segFileExt_Callback(hObject, eventdata, handles)
% hObject    handle to segFileExt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns segFileExt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from segFileExt


% --- Executes during object creation, after setting all properties.
function segFileExt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segFileExt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function selectDirectory(uiCtrl)
    startWith = get( uiCtrl , 'String' );    
    returnValue = uigetdir(startWith,'Select folder');
   
	if returnValue ~= 0
        set(uiCtrl , 'String' , returnValue ); 
    end
    


% --- Executes on button press in chk_ex_overwrite.
function chk_ex_overwrite_Callback(hObject, eventdata, handles)
% hObject    handle to chk_ex_overwrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_ex_overwrite


% --- Executes on button press in chk_ex_commulative.
function chk_ex_commulative_Callback(hObject, eventdata, handles)
% hObject    handle to chk_ex_commulative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_ex_commulative
