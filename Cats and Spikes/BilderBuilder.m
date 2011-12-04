function varargout = BilderBuilder(varargin)
% BILDERBUILDER MATLAB code for BilderBuilder.fig
%      BILDERBUILDER, by itself, creates a new BILDERBUILDER or raises the existing
%      singleton*.
%
%      H = BILDERBUILDER returns the handle to a new BILDERBUILDER or the handle to
%      the existing singleton*.
%
%      BILDERBUILDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BILDERBUILDER.M with the given input arguments.
%
%      BILDERBUILDER('Property','Value',...) creates a new BILDERBUILDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BilderBuilder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BilderBuilder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BilderBuilder

% Last Modified by GUIDE v2.5 18-Nov-2011 20:37:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BilderBuilder_OpeningFcn, ...
                   'gui_OutputFcn',  @BilderBuilder_OutputFcn, ...
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


% --- Executes just before BilderBuilder is made visible.
function BilderBuilder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BilderBuilder (see VARARGIN)

% Choose default command line output for BilderBuilder
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BilderBuilder wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BilderBuilder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;


% --- Executes on selection change in listStat.
function listStat_Callback(hObject, eventdata, handles)
% hObject    handle to listStat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listStat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listStat


% --- Executes during object creation, after setting all properties.
function listStat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listStat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listGroup.
function listGroup_Callback(hObject, eventdata, handles)
% hObject    handle to listGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listGroup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listGroup


% --- Executes during object creation, after setting all properties.
function listGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listDim.
function listDim_Callback(hObject, eventdata, handles)
% hObject    handle to listDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listDim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listDim


% --- Executes during object creation, after setting all properties.
function listDim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushXon.
function pushXon_Callback(hObject, eventdata, handles)
% hObject    handle to pushXon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushY.
function pushY_Callback(hObject, eventdata, handles)
% hObject    handle to pushY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushZ.
function pushZ_Callback(hObject, eventdata, handles)
% hObject    handle to pushZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushXoff.
function pushXoff_Callback(hObject, eventdata, handles)
% hObject    handle to pushXoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushYon.
function pushYon_Callback(hObject, eventdata, handles)
% hObject    handle to pushYon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushYoff.
function pushYoff_Callback(hObject, eventdata, handles)
% hObject    handle to pushYoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushZon.
function pushZon_Callback(hObject, eventdata, handles)
% hObject    handle to pushZon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushZoff.
function pushZoff_Callback(hObject, eventdata, handles)
% hObject    handle to pushZoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkLabels.
function checkLabels_Callback(hObject, eventdata, handles)
% hObject    handle to checkLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkLabels


% --- Executes on button press in checkComp.
function checkComp_Callback(hObject, eventdata, handles)
% hObject    handle to checkComp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkComp


% --- Executes on button press in pushRelease.
function pushRelease_Callback(hObject, eventdata, handles)
% hObject    handle to pushRelease (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push3D.
function push3D_Callback(hObject, eventdata, handles)
% hObject    handle to push3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
