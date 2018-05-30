function varargout = Traffic_sign_detection(varargin)
% MAIN_PAGE1 MATLAB code for Traffic_sign_detection.fig
%      MAIN_PAGE1, by itself, creates a new MAIN_PAGE1 or raises the existing
%      singleton*.
%
%      H = MAIN_PAGE1 returns the handle to a new MAIN_PAGE1 or the handle to
%      the existing singleton*.
%
%      MAIN_PAGE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_PAGE1.M with the given input arguments.
%
%      MAIN_PAGE1('Property','Value',...) creates a new MAIN_PAGE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Traffic_sign_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Traffic_sign_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Traffic_sign_detection

% Last Modified by GUIDE v2.5 09-Mar-2018 03:17:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Traffic_sign_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @Traffic_sign_detection_OutputFcn, ...
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


% --- Executes just before Traffic_sign_detection is made visible.
function Traffic_sign_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Traffic_sign_detection (see VARARGIN)

% Choose default command line output for Traffic_sign_detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Traffic_sign_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Traffic_sign_detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SignCar_camera.
function SignCar_camera_Callback(hObject, eventdata, handles)
% hObject    handle to SignCar_camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signAndCar_camera;

% --- Executes on button press in SignCar_video.
function SignCar_video_Callback(hObject, eventdata, handles)
% hObject    handle to SignCar_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signAndCar_video;

% --- Executes on button press in Sign_video.
function Sign_video_Callback(hObject, eventdata, handles)
% hObject    handle to Sign_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sign_video;

% --- Executes on button press in Sign_camera.
function Sign_camera_Callback(hObject, eventdata, handles)
% hObject    handle to Sign_camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sign_camera;
