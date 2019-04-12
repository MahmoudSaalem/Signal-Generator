classdef SignalGenerator_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        GeneralSignalGenerator          matlab.ui.Figure
        SignalSpecificationsPanel       matlab.ui.container.Panel
        EnterBreakpointsButton          matlab.ui.control.Button
        NextButton                      matlab.ui.control.Button
        EndofTimeScaleEditFieldLabel    matlab.ui.control.Label
        EndofTimeScaleEditField         matlab.ui.control.NumericEditField
        StartofTimeScaleEditFieldLabel  matlab.ui.control.Label
        StartofTimeScaleEditField       matlab.ui.control.NumericEditField
        SignalperRegionPanel            matlab.ui.container.Panel
        fromtoLabel                     matlab.ui.control.Label
        ImpulsePanel                    matlab.ui.container.Panel
        AmplitudeEditFieldLabel         matlab.ui.control.Label
        ImpulseAmplitudeEditField       matlab.ui.control.NumericEditField
        DCPanel                         matlab.ui.container.Panel
        AmplitudeEditField_2Label       matlab.ui.control.Label
        DCAmplitudeEditField            matlab.ui.control.NumericEditField
        RampPanel                       matlab.ui.container.Panel
        InterceptEditFieldLabel         matlab.ui.control.Label
        InterceptEditField              matlab.ui.control.NumericEditField
        SlopeEditFieldLabel             matlab.ui.control.Label
        SlopeEditField                  matlab.ui.control.NumericEditField
        SignalTypeDropDownLabel         matlab.ui.control.Label
        SignalTypeDropDown              matlab.ui.control.DropDown
        SinusoidalPanel                 matlab.ui.container.Panel
        AmplitudeEditField_4Label       matlab.ui.control.Label
        SinusoidalAmplitudeEditField    matlab.ui.control.NumericEditField
        FrequencyHzEditFieldLabel       matlab.ui.control.Label
        FrequencyHzEditField            matlab.ui.control.NumericEditField
        DCShiftEditFieldLabel           matlab.ui.control.Label
        SinDCShiftEditField             matlab.ui.control.NumericEditField
        PhaseShiftRadianLabel           matlab.ui.control.Label
        PhaseShiftRadianEditField       matlab.ui.control.NumericEditField
        NextDoneButton                  matlab.ui.control.Button
        ExponentialPanel                matlab.ui.container.Panel
        AmplitudeEditField_3Label       matlab.ui.control.Label
        ExponentialAmplitudeEditField   matlab.ui.control.NumericEditField
        ExponentEditFieldLabel          matlab.ui.control.Label
        ExponentEditField               matlab.ui.control.NumericEditField
        DCShiftEditField_2Label         matlab.ui.control.Label
        ExpDCShiftEditField             matlab.ui.control.NumericEditField
        ThetaEditFieldLabel             matlab.ui.control.Label
        ThetaEditField                  matlab.ui.control.NumericEditField
        BackButton                      matlab.ui.control.Button
        warningLabel                    matlab.ui.control.Label
        LTIChannelPanel                 matlab.ui.container.Panel
        SamplingFrequencyEditFieldLabel  matlab.ui.control.Label
        SamplingFrequencyEditField      matlab.ui.control.NumericEditField
        mtButton                        matlab.ui.control.Button
        htButton                        matlab.ui.control.Button
        ConvoluteButton                 matlab.ui.control.Button
        NoiseEditFieldLabel             matlab.ui.control.Label
        NoiseEditField                  matlab.ui.control.NumericEditField
    end

    
    methods (Access = private)
        
        % GUI related functions
        function hideAll(app)
            % Hiding all the signals' panels
            app.ImpulsePanel.Visible = false;
            app.DCPanel.Visible = false;
            app.RampPanel.Visible = false;
            app.ExponentialPanel.Visible = false;
            app.SinusoidalPanel.Visible = false;
        end
        
        function resetPanel(app)
            % Showing the default signal panel
            hideAll(app);
            app.ImpulsePanel.Visible = true;
            % Default option for the drop down menu
            app.SignalTypeDropDown.Value = "Impulse Signal";
            % Setting the values to all the edit fields to zero
            app.StartofTimeScaleEditField.Value = 0;
            app.EndofTimeScaleEditField.Value = 6;
            app.ImpulseAmplitudeEditField.Value = 0;
            app.DCAmplitudeEditField.Value = 0;
            app.SlopeEditField.Value = 0;
            app.InterceptEditField.Value = 0;
            app.ExponentialAmplitudeEditField.Value = 0;
            app.ExponentEditField.Value = 0;
            app.SinusoidalAmplitudeEditField.Value = 0;
            app.FrequencyHzEditField.Value = 0;
            app.PhaseShiftRadianEditField.Value = 0;
            app.SinDCShiftEditField.Value = 0;
        end
        
        function updateFromTo(app)
            % The from to label that determines what time interval
            % is the user entering
            
            % Getting the value required depending on the interval being entered
            timeStart = getTimeInterval(app);
            timeStart = timeStart(end - getCounter(app));
            timeEnd = getTimeInterval(app);
            timeEnd = timeEnd(end - getCounter(app) + 1);
            % Updating the label
            app.fromtoLabel.Text = "From "+num2str(timeStart)+" to "+num2str(timeEnd);
        end
        
        % Saving the inputs of the signal for each time interval
        % and concatenating the small signals to the main signal to be plotted
        function saveInputs(app)
            % Getting the current time interval
            timeStart = getTimeInterval(app);
            timeStart = timeStart(end - getCounter(app)); % start of the current interval
            timeEnd = getTimeInterval(app);
            timeEnd = timeEnd(end - getCounter(app) + 1); % end of the current interval
            n = (timeEnd - timeStart) * getSamplingFrequency(app); % number of samples depending on the sampling frequency
            tVal = linspace(timeStart, timeEnd, n); % time variable for the current interval
            
            % Switch case on the signal entered to set its variables
            signalType = app.SignalTypeDropDown.Value;
            bool = getBoolSignal(app);
            if(bool)
                concatTimeSignal(app, tVal);
            else
                concatTimeResponse(app, tVal);
            end
            
            switch(signalType)
                case "Impulse Signal"
                    setAmplitude(app, app.ImpulseAmplitudeEditField.Value);
                    % Impulse signal is all zeros except at the breakpoint
                    signal = zeros(1, length(tVal));
                    signal(1) = getAmplitude(app);
                    % Concatenating the signal to the right signal
                    if(bool)
                        concatSignal(app, signal);
                    else
                        concatResponse(app, signal);
                    end
                case "DC Signal"
                    setAmplitude(app, app.DCAmplitudeEditField.Value);
                    % DC signal is of constant amplitude
                    signal = getAmplitude(app)*ones(1, length(tVal));
                    if(bool)
                        concatSignal(app, signal);
                    else
                        concatResponse(app, signal);
                    end
                case "Ramp Signal"
                    setSlope(app, app.SlopeEditField.Value);
                    setIntercept(app, app.InterceptEditField.Value);
                    % Ramp signal = slope * time + intercept (y = mx + c)
                    signal = getSlope(app) * tVal + getIntercept(app);
                    if(bool)
                        concatSignal(app, signal);
                    else
                        concatResponse(app, signal);
                    end
                case "Exponential Signal"
                    setAmplitude(app, app.ExponentialAmplitudeEditField.Value);
                    setExponent(app, app.ExponentEditField.Value);
                    setTheta(app, app.ThetaEditField.Value);
                    setExpDCShift(app, app.ExpDCShiftEditField.Value);
                    % Exponential signal = amplitude * e^(exponent * time + time shift) + DC shift
                    signal = getAmplitude(app) * exp(getExponent(app) * tVal + getTheta(app)) + getExpDCShift(app);
                    if(bool)
                        concatSignal(app, signal);
                    else
                        concatResponse(app, signal);
                    end
                case "Sinusoidal Signal"
                    setAmplitude(app, app.SinusoidalAmplitudeEditField.Value);
                    setFrequency(app, app.FrequencyHzEditField.Value);
                    setPhaseShift(app, app.PhaseShiftRadianEditField.Value);
                    setSinDCShift(app, app.SinDCShiftEditField.Value);
                    % Sinusoidal signal = amplitude * sin(2 * pi * frequency * time + phase shift) + DC shift
                    signal = getAmplitude(app) * sin(2*pi*getFrequency(app)*tVal + getPhaseShift(app)) + getSinDCShift(app);
                    if(bool)
                        concatSignal(app, signal);
                    else
                        concatResponse(app, signal);
                    end
            end
        end
        
        % Start and end time validation
        function results = validateTime(app)
            start_t = app.StartofTimeScaleEditField.Value;
            end_t = app.EndofTimeScaleEditField.Value;
            if(start_t >= end_t)
                bool = false;
            else
                bool = true;
            end
            results = bool;
        end
        
        function [convolutedSignal, convolutedTime] = convolute(app, signal, timeSignal, response, timeResponse)
            timeStart = timeSignal(1) + timeResponse(1);
            timeEnd = timeSignal(end) + timeResponse(end);
            samplingFrequency = getSamplingFrequency(app);
            convolutedTime = linspace(timeStart, timeEnd, (timeEnd - timeStart) * samplingFrequency);
            y = conv(signal, response);
            y = y / samplingFrequency;
            
            y(end+1) = 0;
            
            noise = getNoise(app) * randn(1, length(y));
            convolutedSignal = y + noise;
        end
        
        function plotTime(~, signal, timeSignal, ttl, i)
            subplot(2, 3, i)
            % Generate the plot
            plot(timeSignal, signal, 'LineWidth', 1)
            title(ttl)
            xlabel('Time')
            ylabel('Amplitude')
            axis 'auto x'
            axis 'auto y'
            grid on
        end
        
        function plotFrequency(app, sig, ttl, i)
            subplot(2, 3, i) % subplot at the bottom half of the figure
            Fs = getSamplingFrequency(app); % Sampling frequency
            signal = sig;
            nfft = 1024; % Length of FFT
            % Take fft, padding with zeros
            X = fft(signal,nfft);
            % FFT is symmetric, we need half of it only
            X = X(1:nfft/2);
            % Take the magnitude of fft
            mx = abs(X);
            % Frequency vector
            f = (0:nfft/2-1)*Fs/nfft;
            % Mirror the plot to obtain double sided spectrum
            f = [-fliplr(f) f];
            mx = [fliplr(mx) mx];
            % Generate the plot
            plot(f, mx, 'LineWidth', 1)
            
            % n = linspace(-Fs/2, Fs/2, length(time));
            % y = fftshift(fft(signal/Fs));
            % ymag = abs(y);
            % plot(n, ymag, 'LineWidth', 1);
            title(ttl)
            xlabel('Frequency (Hz)')
            ylabel('Amplitude')
            axis 'auto signal'
            axis 'auto y'
            grid on
        end
        
        % Breakpoints validation
        function results = validateBreakpoints(app, val)
            if(isempty(val))
                results = true;
                return
            end
            start_t = app.StartofTimeScaleEditField.Value;
            end_t = app.EndofTimeScaleEditField.Value;
            if(start_t>val(1) || end_t<val(end))
                bool = false;
            else
                bool = true;
            end
            results = bool;
        end
        
        % Displaying warnings
        function displayWarning(~, msg)
            opts = struct('WindowStyle','modal',...
                'Interpreter','tex');
            waitfor(warndlg(msg,...
                'Warning', opts));
        end
        
        % Global Variables
        % For the functions to see the data entered by the user
        
        % breakpoints
        function setBreakpoints(~, val)
            global breakpoints;
            breakpoints = val;
        end
        function results = getBreakpoints(~)
            global breakpoints;
            results = breakpoints;
        end
        % timeInterval
        function setTimeInterval(~, val)
            global timeInterval;
            timeInterval = val;
        end
        function results = getTimeInterval(~)
            global timeInterval;
            results = timeInterval;
        end
        % counter
        function setCounter(~, val)
            global counter;
            counter = val;
        end
        function results = getCounter(~)
            global counter;
            results = counter;
        end
        function results = decrementCounter(app)
            setCounter(app, getCounter(app)-1);
            results = getCounter(app);
        end
        % samplingFrequency
        function setSamplingFrequency(~, val)
            global samplingFrequency;
            samplingFrequency = val;
        end
        function results = getSamplingFrequency(~)
            global samplingFrequency;
            results = samplingFrequency;
        end
        % noise
        function setNoise(~, val)
            global noise;
            noise = val;
        end
        function results = getNoise(~)
            global noise;
            results = noise;
        end
        % amplitude
        function setAmplitude(~, val)
            global amplitude;
            amplitude = val;
        end
        function results = getAmplitude(~)
            global amplitude;
            results = amplitude;
        end
        % slope
        function setSlope(~, val)
            global slope;
            slope = val;
        end
        function results = getSlope(~)
            global slope;
            results = slope;
        end
        % intercept
        function setIntercept(~, val)
            global intercept;
            intercept = val;
        end
        function results = getIntercept(~)
            global intercept;
            results = intercept;
        end
        % exponent
        function setExponent(~, val)
            global exponent;
            exponent = val;
        end
        function results = getExponent(~)
            global exponent;
            results = exponent;
        end
        % theta
        function setTheta(~, val)
            global theta;
            theta = val;
        end
        function results = getTheta(~)
            global theta;
            results = theta;
        end
        % expDCShift
        function setExpDCShift(~, val)
            global expDCShift;
            expDCShift = val;
        end
        function results = getExpDCShift(~)
            global expDCShift;
            results = expDCShift;
        end
        % phaseShift
        function setPhaseShift(~, val)
            global phaseShift;
            phaseShift = val;
        end
        function results = getPhaseShift(~)
            global phaseShift;
            results = phaseShift;
        end
        % sinDCShift
        function setSinDCShift(~, val)
            global sinDCShift;
            sinDCShift = val;
        end
        function results = getSinDCShift(~)
            global sinDCShift;
            results = sinDCShift;
        end
        % frequency
        function setFrequency(~, val)
            global frequency;
            frequency = val;
        end
        function results = getFrequency(~)
            global frequency;
            results = frequency;
        end
        % timeSignal
        function setTimeSignal(~, val)
            global timeSignal;
            timeSignal = val;
        end
        function results = getTimeSignal(~)
            global timeSignal;
            results = timeSignal;
        end
        function concatTimeSignal(app, val)
            time = getTimeSignal(app);
            setTimeSignal(app, [time val]);
        end
        % signal
        function setSignal(~, val)
            global signal;
            signal = val;
        end
        function results = getSignal(~)
            global signal;
            results = signal;
        end
        function concatSignal(app, val)
            signal = getSignal(app);
            setSignal(app, [signal val]);
        end
        % timeResponse
        function setTimeResponse(~, val)
            global timeResponse;
            timeResponse = val;
        end
        function results = getTimeResponse(~)
            global timeResponse;
            results = timeResponse;
        end
        function concatTimeResponse(app, val)
            time = getTimeResponse(app);
            setTimeResponse(app, [time val]);
        end
        % response
        function setResponse(~, val)
            global response;
            response = val;
        end
        function results = getResponse(~)
            global response;
            results = response;
        end
        function concatResponse(app, val)
            signal = getResponse(app);
            setResponse(app, [signal val]);
        end
        % Button boolean, m(t) true, h(t) false
        function setBoolSignal(~, val)
            global boolSignal;
            boolSignal = val;
        end
        function results = getBoolSignal(~)
            global boolSignal;
            results = boolSignal;
        end
        
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(~)
            % Cleaning the workspace
            clc;
            clear;
            close all;
        end

        % Button pushed function: NextButton
        function NextButtonPushed(app, ~)
            % Showing the next panel
            app.SignalSpecificationsPanel.Visible = false;
            app.SignalperRegionPanel.Visible = true;
            
            % Saving the values from the main panel
            timeStart = app.StartofTimeScaleEditField.Value;
            timeEnd = app.EndofTimeScaleEditField.Value;
            breakingPoints = getBreakpoints(app);
            
            % Calculating the time interval
            timeInterval = [timeStart breakingPoints timeEnd];
            timeInterval = sort(timeInterval);
            
            % Setting the global variables
            setTimeInterval(app, timeInterval);
            setCounter(app, length(timeInterval)-1);
            
            resetPanel(app);
            
            % GUI related
            % To change the next button text to plot on the last signal before plotting
            if(getCounter(app) == 1)
                app.NextDoneButton.Text = "Done";
            else
                app.NextDoneButton.Text = "Next";
            end
            updateFromTo(app);
        end

        % Value changed function: SignalTypeDropDown
        function SignalTypeDropDownValueChanged(app, ~)
            % Displaying the correct signal panel upon selecting it
            value = app.SignalTypeDropDown.Value;
            hideAll(app);
            switch(value)
                case "Impulse Signal"
                    app.ImpulsePanel.Visible = true;
                case "DC Signal"
                    app.DCPanel.Visible = true;
                case "Ramp Signal"
                    app.RampPanel.Visible = true;
                case "Exponential Signal"
                    app.ExponentialPanel.Visible = true;
                case "Sinusoidal Signal"
                    app.SinusoidalPanel.Visible = true;
            end
        end

        % Button pushed function: EnterBreakpointsButton
        function EnterBreakpointsButtonPushed(app, ~)
            % Getting the breakpoints values
            answer = inputdlg('Enter space-separated numbers:',...
                'Breaking Points', [1 50]);
            % Setting focus on the application
            figure(app.GeneralSignalGenerator);
            if(~isempty(answer))
                user_val = str2num(answer{1}); %#ok<*ST2NM>
                user_val = sort(user_val);
                
                % Setting the breakpoints global variable
                bool = validateBreakpoints(app, user_val);
                if(bool)
                    setBreakpoints(app, user_val);
                else
                    displayWarning(app, 'Breakpoints must be inside the time interval entered.');
                end
                
                if((isempty(user_val) && ~isempty(answer{1})) || ~isreal(user_val))
                    setBreakpoints(app, []); % to keep it clean in case imaginary number entered
                    displayWarning(app, 'Please enter numbers only.');
                end
            end
            % Setting focus on the application
            figure(app.GeneralSignalGenerator);
        end

        % Button pushed function: NextDoneButton
        function NextDoneButtonPushed(app, ~)
            saveInputs(app);
            counter = getCounter(app);
            global m;
            global h;
            if(counter <= 1)
                app.SignalSpecificationsPanel.Visible = false;
                app.SignalperRegionPanel.Visible = false;
                app.LTIChannelPanel.Visible = true;
                setBreakpoints(app, []);
                if(~isempty(h) && ~isempty(m) && m && h)
                    app.ConvoluteButton.Enable = true;
                    m = false;
                    h = false;
                end
            else
                decrementCounter(app);
                updateFromTo(app);
                resetPanel(app);
                if(getCounter(app) == 1)
                    app.NextDoneButton.Text = "Done";
                else
                    app.NextDoneButton.Text = "Next";
                end
            end
        end

        % Button pushed function: BackButton
        function BackButtonPushed(app, ~)
            % Displaying the previous panel (main panel)
            app.SignalSpecificationsPanel.Visible = true;
            app.SignalperRegionPanel.Visible = false;
        end

        % Value changed function: EndofTimeScaleEditField, 
        % StartofTimeScaleEditField
        function StartofTimeScaleEditFieldValueChanged(app, ~)
            bool = validateTime(app) && validateBreakpoints(app, getBreakpoints(app));
            app.NextButton.Enable = bool;
            app.warningLabel.Visible = ~bool;
        end

        % Button pushed function: ConvoluteButton
        function ConvoluteButtonPushed(app, ~)
            % Setting the global variables
            setSamplingFrequency(app, app.SamplingFrequencyEditField.Value);
            setNoise(app, app.NoiseEditField.Value);
            
            % Plot all the required signals
            % Enlarging the Figure 1 form
            fig = figure(1);
            pos = get(fig,'position');
            set(fig,'position',[pos(1:2)/4 pos(3:4)*2]);
            
            setBreakpoints(app, []);
            
            % Getting the values from the global variables
            timeSignal = getTimeSignal(app);
            signal = getSignal(app);
            
            timeResponse = getTimeResponse(app);
            response = getResponse(app);
            
            [convolutedSignal, convolutedTime] = convolute(app, signal, timeSignal, response, timeResponse);
            
            if(response(1) == 0) % Because deconve can't have the first coeffecient as zero
                response(1) = 1e-6;
            end
            signal = getSamplingFrequency(app) * deconv(convolutedSignal, response);
            signal(end) = [];
            
            % Time Domain
            plotTime(app, signal, timeSignal, 'Message', 1);
            plotTime(app, response, timeResponse, 'Response', 2);
            plotTime(app, convolutedSignal, convolutedTime, 'Convolution', 3);
            
            % Frequency Domain
            plotFrequency(app, signal, 'Message', 4);
            plotFrequency(app, response, 'Response', 5);
            plotFrequency(app, convolutedSignal, 'Convolution', 6);
            
            % Closing the app form upon plotting
            delete(app.GeneralSignalGenerator);
        end

        % Button pushed function: mtButton
        function mtButtonPushed(app, ~)
            % Setting the right boolean to action
            setBoolSignal(app, true);
            
            % Setting the panel
            app.LTIChannelPanel.Visible = false;
            app.SignalSpecificationsPanel.Visible = true;
            
            % Setting the panel title
            app.SignalSpecificationsPanel.Title = "Message";
            
            fs = app.SamplingFrequencyEditField.Value;
            setSamplingFrequency(app, fs);
            app.SamplingFrequencyEditField.Enable = false;
            
            setTimeSignal(app, []);
            setSignal(app, []);
            
            setBreakpoints(app, []);
            
            global m;
            m = true;
        end

        % Button pushed function: htButton
        function htButtonPushed(app, ~)
            % Setting the right boolean to action
            setBoolSignal(app, false);
            
            % Setting the panel
            app.LTIChannelPanel.Visible = false;
            app.SignalSpecificationsPanel.Visible = true;
            
            % Setting the panel title
            app.SignalSpecificationsPanel.Title = "Response";
            
            fs = app.SamplingFrequencyEditField.Value;
            setSamplingFrequency(app, fs);
            app.SamplingFrequencyEditField.Enable = false;
            
            setTimeResponse(app, []);
            setResponse(app, []);
            
            setBreakpoints(app, []);
            
            global h;
            h = true;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create GeneralSignalGenerator
            app.GeneralSignalGenerator = uifigure;
            app.GeneralSignalGenerator.Position = [800 500 370 280];
            app.GeneralSignalGenerator.Name = 'General Signal Generator';
            app.GeneralSignalGenerator.Resize = 'off';

            % Create SignalSpecificationsPanel
            app.SignalSpecificationsPanel = uipanel(app.GeneralSignalGenerator);
            app.SignalSpecificationsPanel.Title = 'Signal Specifications';
            app.SignalSpecificationsPanel.Visible = 'off';
            app.SignalSpecificationsPanel.Position = [10 40 350 220];

            % Create EnterBreakpointsButton
            app.EnterBreakpointsButton = uibutton(app.SignalSpecificationsPanel, 'push');
            app.EnterBreakpointsButton.ButtonPushedFcn = createCallbackFcn(app, @EnterBreakpointsButtonPushed, true);
            app.EnterBreakpointsButton.Position = [28 51 150 22];
            app.EnterBreakpointsButton.Text = 'Enter Breakpoints';

            % Create NextButton
            app.NextButton = uibutton(app.SignalSpecificationsPanel, 'push');
            app.NextButton.ButtonPushedFcn = createCallbackFcn(app, @NextButtonPushed, true);
            app.NextButton.Position = [223 51 100 22];
            app.NextButton.Text = 'Next';

            % Create EndofTimeScaleEditFieldLabel
            app.EndofTimeScaleEditFieldLabel = uilabel(app.SignalSpecificationsPanel);
            app.EndofTimeScaleEditFieldLabel.HorizontalAlignment = 'right';
            app.EndofTimeScaleEditFieldLabel.Position = [28 99 103 22];
            app.EndofTimeScaleEditFieldLabel.Text = 'End of Time Scale';

            % Create EndofTimeScaleEditField
            app.EndofTimeScaleEditField = uieditfield(app.SignalSpecificationsPanel, 'numeric');
            app.EndofTimeScaleEditField.ValueChangedFcn = createCallbackFcn(app, @StartofTimeScaleEditFieldValueChanged, true);
            app.EndofTimeScaleEditField.Position = [177 99 146 22];
            app.EndofTimeScaleEditField.Value = 6;

            % Create StartofTimeScaleEditFieldLabel
            app.StartofTimeScaleEditFieldLabel = uilabel(app.SignalSpecificationsPanel);
            app.StartofTimeScaleEditFieldLabel.HorizontalAlignment = 'right';
            app.StartofTimeScaleEditFieldLabel.Position = [28 147 108 22];
            app.StartofTimeScaleEditFieldLabel.Text = 'Start of Time Scale';

            % Create StartofTimeScaleEditField
            app.StartofTimeScaleEditField = uieditfield(app.SignalSpecificationsPanel, 'numeric');
            app.StartofTimeScaleEditField.ValueChangedFcn = createCallbackFcn(app, @StartofTimeScaleEditFieldValueChanged, true);
            app.StartofTimeScaleEditField.Position = [177 147 146 22];

            % Create SignalperRegionPanel
            app.SignalperRegionPanel = uipanel(app.GeneralSignalGenerator);
            app.SignalperRegionPanel.Title = 'Signal per Region';
            app.SignalperRegionPanel.Visible = 'off';
            app.SignalperRegionPanel.Position = [11 21 350 250];

            % Create fromtoLabel
            app.fromtoLabel = uilabel(app.SignalperRegionPanel);
            app.fromtoLabel.Position = [11 198 110 22];
            app.fromtoLabel.Text = 'from to';

            % Create ImpulsePanel
            app.ImpulsePanel = uipanel(app.SignalperRegionPanel);
            app.ImpulsePanel.Title = 'Impulse';
            app.ImpulsePanel.Position = [31 100 300 60];

            % Create AmplitudeEditFieldLabel
            app.AmplitudeEditFieldLabel = uilabel(app.ImpulsePanel);
            app.AmplitudeEditFieldLabel.HorizontalAlignment = 'right';
            app.AmplitudeEditFieldLabel.Position = [9 8 60 22];
            app.AmplitudeEditFieldLabel.Text = 'Amplitude';

            % Create ImpulseAmplitudeEditField
            app.ImpulseAmplitudeEditField = uieditfield(app.ImpulsePanel, 'numeric');
            app.ImpulseAmplitudeEditField.Limits = [0 Inf];
            app.ImpulseAmplitudeEditField.Position = [129 8 160 22];

            % Create DCPanel
            app.DCPanel = uipanel(app.SignalperRegionPanel);
            app.DCPanel.Title = 'DC';
            app.DCPanel.Visible = 'off';
            app.DCPanel.Position = [31 100 300 60];

            % Create AmplitudeEditField_2Label
            app.AmplitudeEditField_2Label = uilabel(app.DCPanel);
            app.AmplitudeEditField_2Label.HorizontalAlignment = 'right';
            app.AmplitudeEditField_2Label.Position = [9 8 60 22];
            app.AmplitudeEditField_2Label.Text = 'Amplitude';

            % Create DCAmplitudeEditField
            app.DCAmplitudeEditField = uieditfield(app.DCPanel, 'numeric');
            app.DCAmplitudeEditField.Position = [129 8 160 22];

            % Create RampPanel
            app.RampPanel = uipanel(app.SignalperRegionPanel);
            app.RampPanel.Title = 'Ramp';
            app.RampPanel.Visible = 'off';
            app.RampPanel.Position = [31 72 300 88];

            % Create InterceptEditFieldLabel
            app.InterceptEditFieldLabel = uilabel(app.RampPanel);
            app.InterceptEditFieldLabel.HorizontalAlignment = 'right';
            app.InterceptEditFieldLabel.Position = [9 8 53 22];
            app.InterceptEditFieldLabel.Text = 'Intercept';

            % Create InterceptEditField
            app.InterceptEditField = uieditfield(app.RampPanel, 'numeric');
            app.InterceptEditField.Position = [129 8 160 22];

            % Create SlopeEditFieldLabel
            app.SlopeEditFieldLabel = uilabel(app.RampPanel);
            app.SlopeEditFieldLabel.HorizontalAlignment = 'right';
            app.SlopeEditFieldLabel.Position = [11 38 36 22];
            app.SlopeEditFieldLabel.Text = 'Slope';

            % Create SlopeEditField
            app.SlopeEditField = uieditfield(app.RampPanel, 'numeric');
            app.SlopeEditField.Position = [129 36 160 22];

            % Create SignalTypeDropDownLabel
            app.SignalTypeDropDownLabel = uilabel(app.SignalperRegionPanel);
            app.SignalTypeDropDownLabel.HorizontalAlignment = 'right';
            app.SignalTypeDropDownLabel.Position = [30 168 67 22];
            app.SignalTypeDropDownLabel.Text = 'Signal Type';

            % Create SignalTypeDropDown
            app.SignalTypeDropDown = uidropdown(app.SignalperRegionPanel);
            app.SignalTypeDropDown.Items = {'Impulse Signal', 'DC Signal', 'Ramp Signal', 'Exponential Signal', 'Sinusoidal Signal'};
            app.SignalTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SignalTypeDropDownValueChanged, true);
            app.SignalTypeDropDown.Position = [120 168 210 22];
            app.SignalTypeDropDown.Value = 'Impulse Signal';

            % Create SinusoidalPanel
            app.SinusoidalPanel = uipanel(app.SignalperRegionPanel);
            app.SinusoidalPanel.Title = 'Sinusoidal';
            app.SinusoidalPanel.Visible = 'off';
            app.SinusoidalPanel.Position = [31 11 300 149];

            % Create AmplitudeEditField_4Label
            app.AmplitudeEditField_4Label = uilabel(app.SinusoidalPanel);
            app.AmplitudeEditField_4Label.HorizontalAlignment = 'right';
            app.AmplitudeEditField_4Label.Position = [11 98 60 22];
            app.AmplitudeEditField_4Label.Text = 'Amplitude';

            % Create SinusoidalAmplitudeEditField
            app.SinusoidalAmplitudeEditField = uieditfield(app.SinusoidalPanel, 'numeric');
            app.SinusoidalAmplitudeEditField.Position = [129 98 160 22];

            % Create FrequencyHzEditFieldLabel
            app.FrequencyHzEditFieldLabel = uilabel(app.SinusoidalPanel);
            app.FrequencyHzEditFieldLabel.HorizontalAlignment = 'right';
            app.FrequencyHzEditFieldLabel.Position = [11 62 62 28];
            app.FrequencyHzEditFieldLabel.Text = {'Frequency'; '(Hz)'};

            % Create FrequencyHzEditField
            app.FrequencyHzEditField = uieditfield(app.SinusoidalPanel, 'numeric');
            app.FrequencyHzEditField.Position = [129 68 160 22];

            % Create DCShiftEditFieldLabel
            app.DCShiftEditFieldLabel = uilabel(app.SinusoidalPanel);
            app.DCShiftEditFieldLabel.HorizontalAlignment = 'right';
            app.DCShiftEditFieldLabel.Position = [11 8 50 22];
            app.DCShiftEditFieldLabel.Text = 'DC Shift';

            % Create SinDCShiftEditField
            app.SinDCShiftEditField = uieditfield(app.SinusoidalPanel, 'numeric');
            app.SinDCShiftEditField.Position = [129 8 160 22];

            % Create PhaseShiftRadianLabel
            app.PhaseShiftRadianLabel = uilabel(app.SinusoidalPanel);
            app.PhaseShiftRadianLabel.HorizontalAlignment = 'right';
            app.PhaseShiftRadianLabel.Position = [11 32 67 28];
            app.PhaseShiftRadianLabel.Text = {'Phase Shift'; '(Radian)'};

            % Create PhaseShiftRadianEditField
            app.PhaseShiftRadianEditField = uieditfield(app.SinusoidalPanel, 'numeric');
            app.PhaseShiftRadianEditField.Position = [129 38 160 22];

            % Create NextDoneButton
            app.NextDoneButton = uibutton(app.SignalperRegionPanel, 'push');
            app.NextDoneButton.ButtonPushedFcn = createCallbackFcn(app, @NextDoneButtonPushed, true);
            app.NextDoneButton.Position = [231 198 100 22];
            app.NextDoneButton.Text = 'Next';

            % Create ExponentialPanel
            app.ExponentialPanel = uipanel(app.SignalperRegionPanel);
            app.ExponentialPanel.Title = 'Exponential';
            app.ExponentialPanel.Visible = 'off';
            app.ExponentialPanel.Position = [31 11 300 149];

            % Create AmplitudeEditField_3Label
            app.AmplitudeEditField_3Label = uilabel(app.ExponentialPanel);
            app.AmplitudeEditField_3Label.HorizontalAlignment = 'right';
            app.AmplitudeEditField_3Label.Position = [12 97 60 22];
            app.AmplitudeEditField_3Label.Text = 'Amplitude';

            % Create ExponentialAmplitudeEditField
            app.ExponentialAmplitudeEditField = uieditfield(app.ExponentialPanel, 'numeric');
            app.ExponentialAmplitudeEditField.Position = [129 98 160 22];

            % Create ExponentEditFieldLabel
            app.ExponentEditFieldLabel = uilabel(app.ExponentialPanel);
            app.ExponentEditFieldLabel.HorizontalAlignment = 'right';
            app.ExponentEditFieldLabel.Position = [12 67 57 22];
            app.ExponentEditFieldLabel.Text = 'Exponent';

            % Create ExponentEditField
            app.ExponentEditField = uieditfield(app.ExponentialPanel, 'numeric');
            app.ExponentEditField.Position = [129 68 160 22];

            % Create DCShiftEditField_2Label
            app.DCShiftEditField_2Label = uilabel(app.ExponentialPanel);
            app.DCShiftEditField_2Label.HorizontalAlignment = 'right';
            app.DCShiftEditField_2Label.Position = [12 7 50 22];
            app.DCShiftEditField_2Label.Text = 'DC Shift';

            % Create ExpDCShiftEditField
            app.ExpDCShiftEditField = uieditfield(app.ExponentialPanel, 'numeric');
            app.ExpDCShiftEditField.Position = [129 8 160 22];

            % Create ThetaEditFieldLabel
            app.ThetaEditFieldLabel = uilabel(app.ExponentialPanel);
            app.ThetaEditFieldLabel.HorizontalAlignment = 'right';
            app.ThetaEditFieldLabel.Position = [12 37 36 22];
            app.ThetaEditFieldLabel.Text = 'Theta';

            % Create ThetaEditField
            app.ThetaEditField = uieditfield(app.ExponentialPanel, 'numeric');
            app.ThetaEditField.Position = [129 38 160 22];

            % Create BackButton
            app.BackButton = uibutton(app.SignalperRegionPanel, 'push');
            app.BackButton.ButtonPushedFcn = createCallbackFcn(app, @BackButtonPushed, true);
            app.BackButton.Position = [129 198 100 22];
            app.BackButton.Text = 'Back';

            % Create warningLabel
            app.warningLabel = uilabel(app.GeneralSignalGenerator);
            app.warningLabel.HorizontalAlignment = 'right';
            app.warningLabel.FontColor = [1 0 0];
            app.warningLabel.Visible = 'off';
            app.warningLabel.Position = [101 18 260 22];
            app.warningLabel.Text = 'Warning! Check the time interval then proceed.';

            % Create LTIChannelPanel
            app.LTIChannelPanel = uipanel(app.GeneralSignalGenerator);
            app.LTIChannelPanel.Title = 'LTI Channel';
            app.LTIChannelPanel.Position = [11 11 350 250];

            % Create SamplingFrequencyEditFieldLabel
            app.SamplingFrequencyEditFieldLabel = uilabel(app.LTIChannelPanel);
            app.SamplingFrequencyEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingFrequencyEditFieldLabel.Position = [31 188 116 22];
            app.SamplingFrequencyEditFieldLabel.Text = 'Sampling Frequency';

            % Create SamplingFrequencyEditField
            app.SamplingFrequencyEditField = uieditfield(app.LTIChannelPanel, 'numeric');
            app.SamplingFrequencyEditField.Limits = [0 Inf];
            app.SamplingFrequencyEditField.Position = [180 188 146 22];
            app.SamplingFrequencyEditField.Value = 100;

            % Create mtButton
            app.mtButton = uibutton(app.LTIChannelPanel, 'push');
            app.mtButton.ButtonPushedFcn = createCallbackFcn(app, @mtButtonPushed, true);
            app.mtButton.Position = [125 103 100 22];
            app.mtButton.Text = 'm(t)';

            % Create htButton
            app.htButton = uibutton(app.LTIChannelPanel, 'push');
            app.htButton.ButtonPushedFcn = createCallbackFcn(app, @htButtonPushed, true);
            app.htButton.Position = [125 63 100 22];
            app.htButton.Text = 'h(t)';

            % Create ConvoluteButton
            app.ConvoluteButton = uibutton(app.LTIChannelPanel, 'push');
            app.ConvoluteButton.ButtonPushedFcn = createCallbackFcn(app, @ConvoluteButtonPushed, true);
            app.ConvoluteButton.Enable = 'off';
            app.ConvoluteButton.Position = [126 23 100 22];
            app.ConvoluteButton.Text = 'Convolute';

            % Create NoiseEditFieldLabel
            app.NoiseEditFieldLabel = uilabel(app.LTIChannelPanel);
            app.NoiseEditFieldLabel.HorizontalAlignment = 'right';
            app.NoiseEditFieldLabel.Position = [31 150 36 22];
            app.NoiseEditFieldLabel.Text = 'Noise';

            % Create NoiseEditField
            app.NoiseEditField = uieditfield(app.LTIChannelPanel, 'numeric');
            app.NoiseEditField.Position = [180 150 146 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = SignalGenerator_exported

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.GeneralSignalGenerator)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.GeneralSignalGenerator)
        end
    end
end