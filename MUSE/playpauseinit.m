function output = playpauseinit()
    output = playpause();

function varargout = playpause(varargin)
% PLAYPAUSE MATLAB code for playpause.fig
%      PLAYPAUSE, by itself, creates a new PLAYPAUSE or raises the existing
%      singleton*.
%
%      H = PLAYPAUSE returns the handle to a new PLAYPAUSE or the handle to
%      the existing singleton*.
%
%      PLAYPAUSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAYPAUSE.M with the given input arguments.
%
%      PLAYPAUSE('Property','Value',...) creates a new PLAYPAUSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before playpause_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to playpause_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help playpause

% Last Modified by GUIDE v2.5 25-Mar-2017 14:37:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @playpause_OpeningFcn, ...
                   'gui_OutputFcn',  @playpause_OutputFcn, ...
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

function playpause_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to playpause (see VARARGIN)

% Choose default command line output for playpause
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);