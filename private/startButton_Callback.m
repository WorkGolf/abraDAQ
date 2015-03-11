% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check which test
if get(handles.monitor,'Value') == 1 % if monitor
    dataOut = startMonitor(hObject, eventdata, handles);
    
elseif get(handles.dataLogg,'Value') == 1 % if standard test
    dataOut = startLogg(hObject, eventdata, handles);
    
elseif get(handles.impactTest,'Value') == 1 % if impactTest
    dataOut = startImpact(hObject, eventdata, handles);
    
elseif get(handles.periodic,'Value') == 1 % if impactTest
    dataOut = startPeriodic(hObject, eventdata, handles);
    
elseif get(handles.steppedSine,'Value') == 1 % if impactTest
    dataOut = startSteppedSine(hObject, eventdata, handles);
    
elseif handles.multisine.Value == 1 % if impactTest
    dataOut = startMultisine(hObject, eventdata, handles);
    
end

% Check if report is to be generated
if get(handles.autoReport,'Value') && ~get(handles.monitor,'Value')
    %try
        for i = 1%:length(dataOut.Data)
            dataIn = dataOut.Data{i};
            dataIn.UserData = dataOut.Metadata;
            viblab_report(dataIn)
        end
    %catch
        %errordlg('Something wrong with the report generation.')
    %end
end