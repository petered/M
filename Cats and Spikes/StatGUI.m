function varargout = StatGUI(varargin)
% STATGUI MATLAB code for StatGUI.fig
%      STATGUI, by itself, creates a new STATGUI or raises the existing
%      singleton*.
%
%      H = STATGUI returns the handle to a new STATGUI or the handle to
%      the existing singleton*.
%
%      STATGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATGUI.M with the given input arguments.
%
%      STATGUI('Property','Value',...) creates a new STATGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StatGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StatGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StatGUI

% Last Modified by GUIDE v2.5 15-Nov-2011 16:29:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StatGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @StatGUI_OutputFcn, ...
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


% --- Executes just before StatGUI is made visible.
function StatGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StatGUI (see VARARGIN)

% Choose default command line output for StatGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StatGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StatGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles;


% --- Executes on selection change in popStat.
function popStat_Callback(hObject, eventdata, handles)
% hObject    handle to popStat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popStat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popStat


% --- Executes during object creation, after setting all properties.
function popStat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popStat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushStat.
function pushStat_Callback(hObject, eventdata, handles)
% hObject    handle to pushStat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on selection change in popExp.
function popExp_Callback(hObject, eventdata, handles)
% hObject    handle to popExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popExp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popExp


% --- Executes during object creation, after setting all properties.
function popExp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushExp.
function pushExp_Callback(hObject, eventdata, handles)
% hObject    handle to pushExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listExp.
function listExp_Callback(hObject, eventdata, handles)
% hObject    handle to listExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listExp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listExp


% --- Executes during object creation, after setting all properties.
function listExp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popGroup.
function popGroup_Callback(hObject, eventdata, handles)
% hObject    handle to popGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popGroup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popGroup


% --- Executes during object creation, after setting all properties.
function popGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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


% --- Executes on button press in pushGroup.
function pushGroup_Callback(hObject, eventdata, handles)
% hObject    handle to pushGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushViewTable.
function pushViewTable_Callback(hObject, eventdata, handles)
% hObject    handle to pushViewTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushViewGraphs.
function pushViewGraphs_Callback(hObject, eventdata, handles)
% hObject    handle to pushViewGraphs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushHelp.
function pushHelp_Callback(hObject, eventdata, handles)
% hObject    handle to pushHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushViewGraph.
function pushViewGraph_Callback(hObject, eventdata, handles)
% hObject    handle to pushViewGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushMake.
function pushMake_Callback(hObject, eventdata, handles)
% hObject    handle to pushMake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
