function varargout = listGUI(varargin)
% LISTGUI MATLAB code for listGUI.fig
%      LISTGUI, by itself, creates a new LISTGUI or raises the existing
%      singleton*.
%
%      H = LISTGUI returns the handle to a new LISTGUI or the handle to
%      the existing singleton*.
%
%      LISTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LISTGUI.M with the given input arguments.
%
%      LISTGUI('Property','Value',...) creates a new LISTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before listGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to listGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help listGUI

% Last Modified by GUIDE v2.5 29-Jan-2011 20:11:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @listGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @listGUI_OutputFcn, ...
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

% --- Executes just before listGUI is made visible.
function listGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to listGUI (see VARARGIN)

% Choose default command line output for listGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes listGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = listGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;
end

% --- Executes on selection change in listFiles.
function listFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listFiles
end

% --- Executes during object creation, after setting all properties.
function listFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in pushLoad.
function pushLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


end

% --- Executes on button press in pushAdd.
function pushAdd_Callback(hObject, eventdata, handles)
% hObject    handle to pushAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in pushEdit.
function pushEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pushEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handleends    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in pushRun.
function pushRun_Callback(hObject, eventdata, handles)
% hObject    handle to pushRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in pushSave.
function pushSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
