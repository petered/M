function varargout = exploadGUI4(varargin)
%EXPLOADGUI4 M-file for exploadGUI4.fig
%      EXPLOADGUI4, by itself, creates a new EXPLOADGUI4 or raises the existing
%      singleton*.
%
%      H = EXPLOADGUI4 returns the handle to a new EXPLOADGUI4 or the handle to
%      the existing singleton*.
%
%      EXPLOADGUI4('Property','Value',...) creates a new EXPLOADGUI4 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to exploadGUI4_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      EXPLOADGUI4('CALLBACK') and EXPLOADGUI4('CALLBACK',hObject,...) call the
%      local function named CALLBACK in EXPLOADGUI4.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help exploadGUI4

% Last Modified by GUIDE v2.5 08-Feb-2011 19:00:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @exploadGUI4_OpeningFcn, ...
                   'gui_OutputFcn',  @exploadGUI4_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before exploadGUI4 is made visible.
function exploadGUI4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for exploadGUI4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes exploadGUI4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = exploadGUI4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;



function editSpike_Callback(hObject, eventdata, handles)
% hObject    handle to editSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpike as text
%        str2double(get(hObject,'String')) returns contents of editSpike as a double


% --- Executes during object creation, after setting all properties.
function editSpike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editData_Callback(hObject, eventdata, handles)
% hObject    handle to editData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editData as text
%        str2double(get(hObject,'String')) returns contents of editData as a double


% --- Executes during object creation, after setting all properties.
function editData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushSpikeFind.
function pushSpikeFind_Callback(hObject, eventdata, handles)
% hObject    handle to pushSpikeFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushDataFind.
function pushDataFind_Callback(hObject, eventdata, handles)
% hObject    handle to pushDataFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editCat_Callback(hObject, eventdata, handles)
% hObject    handle to editCat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCat as text
%        str2double(get(hObject,'String')) returns contents of editCat as a double


% --- Executes during object creation, after setting all properties.
function editCat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushGO.
function pushGO_Callback(hObject, eventdata, handles)
% hObject    handle to pushGO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editRoot_Callback(hObject, eventdata, handles)
% hObject    handle to editRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRoot as text
%        str2double(get(hObject,'String')) returns contents of editRoot as a double


% --- Executes during object creation, after setting all properties.
function editRoot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushRoot.
function pushRoot_Callback(hObject, eventdata, handles)
% hObject    handle to pushRoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushSearch.
function pushSearch_Callback(hObject, eventdata, handles)
% hObject    handle to pushSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editEEG_Callback(hObject, eventdata, handles)
% hObject    handle to editEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEEG as text
%        str2double(get(hObject,'String')) returns contents of editEEG as a double


% --- Executes during object creation, after setting all properties.
function editEEG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushEEGFind.
function pushEEGFind_Callback(hObject, eventdata, handles)
% hObject    handle to pushEEGFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editStim_Callback(hObject, eventdata, handles)
% hObject    handle to editStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStim as text
%        str2double(get(hObject,'String')) returns contents of editStim as a double


% --- Executes during object creation, after setting all properties.
function editStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushStimFind.
function pushStimFind_Callback(hObject, eventdata, handles)
% hObject    handle to pushStimFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editStage_Callback(hObject, eventdata, handles)
% hObject    handle to editStage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStage as text
%        str2double(get(hObject,'String')) returns contents of editStage as a double


% --- Executes during object creation, after setting all properties.
function editStage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function popType_Callback(hObject, eventdata, handles)
% hObject    handle to popType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of popType as text
%        str2double(get(hObject,'String')) returns contents of popType as a double


% --- Executes during object creation, after setting all properties.
function popType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listSearch.
function listSearch_Callback(hObject, eventdata, handles)
% hObject    handle to listSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listSearch contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listSearch


% --- Executes during object creation, after setting all properties.
function listSearch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushSpikeAdd.
function pushSpikeAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushSpikeAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushDataAdd.
function pushDataAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushDataAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushEEGAdd.
function pushEEGAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushEEGAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushStimAdd.
function pushStimAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushStimAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushFilter.
function pushFilter_Callback(hObject, eventdata, handles)
% hObject    handle to pushFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushCancel.
function pushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to editVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editVoltage as text
%        str2double(get(hObject,'String')) returns contents of editVoltage as a double


% --- Executes during object creation, after setting all properties.
function editVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushVoltageFind.
function pushVoltageFind_Callback(hObject, eventdata, handles)
% hObject    handle to pushVoltageFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushVoltageAdd.
function pushVoltageAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushVoltageAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushAuto.
function pushAuto_Callback(hObject, eventdata, handles)
% hObject    handle to pushAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editExt_Callback(hObject, eventdata, handles)
% hObject    handle to editExt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editExt as text
%        str2double(get(hObject,'String')) returns contents of editExt as a double


% --- Executes during object creation, after setting all properties.
function editExt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editExt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPhoto_Callback(hObject, eventdata, handles)
% hObject    handle to editPhoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPhoto as text
%        str2double(get(hObject,'String')) returns contents of editPhoto as a double


% --- Executes during object creation, after setting all properties.
function editPhoto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPhoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushPhotoFind.
function pushPhotoFind_Callback(hObject, eventdata, handles)
% hObject    handle to pushPhotoFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushPhotoAdd.
function pushPhotoAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushPhotoAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editNotes_Callback(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNotes as text
%        str2double(get(hObject,'String')) returns contents of editNotes as a double


% --- Executes during object creation, after setting all properties.
function editNotes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPSTH_Callback(hObject, eventdata, handles)
% hObject    handle to editPSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPSTH as text
%        str2double(get(hObject,'String')) returns contents of editPSTH as a double


% --- Executes during object creation, after setting all properties.
function editPSTH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushPSTHFind.
function pushPSTHFind_Callback(hObject, eventdata, handles)
% hObject    handle to pushPSTHFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushPSTHAdd.
function pushPSTHAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushPSTHAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
