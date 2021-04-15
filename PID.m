classdef PID < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        plant                    matlab.ui.control.UIAxes
        SystemParametersPanel    matlab.ui.container.Panel
        SimulateButton           matlab.ui.control.Button
        EEditFieldLabel          matlab.ui.control.Label
        EEditField               matlab.ui.control.NumericEditField
        GEditFieldLabel          matlab.ui.control.Label
        G_a1EditField            matlab.ui.control.NumericEditField
        TEditFieldLabel          matlab.ui.control.Label
        T_a2EditField            matlab.ui.control.NumericEditField
        ToEditFieldLabel         matlab.ui.control.Label
        To_boEditField           matlab.ui.control.NumericEditField
        WoEditFieldLabel         matlab.ui.control.Label
        WoEditField              matlab.ui.control.NumericEditField
        KLabel                   matlab.ui.control.Label
        TiLabel                  matlab.ui.control.Label
        TdLabel                  matlab.ui.control.Label
        k_val                    matlab.ui.control.Label
        ti_val                   matlab.ui.control.Label
        td_val                   matlab.ui.control.Label
        resetButton              matlab.ui.control.Button
        ControllerDropDownLabel  matlab.ui.control.Label
        ControllerDropDown       matlab.ui.control.DropDown
        controller               matlab.ui.control.UIAxes
        system                   matlab.ui.control.UIAxes
        PIDDesignToolLabel       matlab.ui.control.Label
    end

 
    
    methods (Access = private)
        
        %*************************
        % PID Controller functions     
        %************************* 
        
        function pid_init(app)
            % Remove plots
            app.plant.cla();
            app.controller.cla();
            app.system.cla();
            
            % Reset fields for PID 
            app.k_val.Text = '0';
            app.ti_val.Text = '0';
            app.td_val.Text = '0';
            app.GEditFieldLabel.Text = "a1";
            app.G_a1EditField.Value = 0;
            app.TEditFieldLabel.Text = "a2";
            app.T_a2EditField.Value = 0;
            app.ToEditFieldLabel.Text = "bo";
            app.To_boEditField.Value = 0;
            app.EEditFieldLabel.Text = "E";
            app.EEditField.Value = 0;
            app.WoEditFieldLabel.Text = "Wo";
            app.WoEditField.Value = 0;         
            app.WoEditField.Visible = "on";
            app.WoEditFieldLabel.Visible = "on";
            app.EEditField.Visible = "on";
            app.EEditFieldLabel.Visible = "on";
            app.td_val.Visible = "on";
            app.TdLabel.Visible = "on";
                
        end
        
        function pid_plot_planet(app)
            bo = app.To_boEditField.Value;
            a1 = app.G_a1EditField.Value;
            a2 = app.T_a2EditField.Value;
            num = bo;
            den = [a2 a1 bo];
            G = tf(num, den);
            plot(app.plant, step(G));
        end
        
        function pid_plot_controller(app)
            
            bo = app.To_boEditField.Value;
            a1 = app.G_a1EditField.Value;
            a2 = app.T_a2EditField.Value;
            E = app.EEditField.Value;
            Wo = app.WoEditField.Value;
            Ti = a1 - (1 / 2 * E * Wo);
            Td = (a2 / Ti) - (1 / 2 * E * Wo);
            K = (Wo * Ti) / (2 * E * bo);
            N = 2 * E * Wo  * Td;
            s = tf('s');
            num = K * (a2 * s * s + a1 * s + 1);
            den = Ti * s * (1 + Td * s / N);
            
            GF = num / den;
            
            plot(app.controller, step(GF));
            
        end
        
        function pid_plot_system(app)
            % Get input data
            bo = app.To_boEditField.Value;
            a1 = app.G_a1EditField.Value;
            a2 = app.T_a2EditField.Value;
            E = app.EEditField.Value;
            Wo = app.WoEditField.Value;
            Ti = a1 - (1 / 2 * E * Wo);
            Td = (a2 / Ti) - (1 / 2 * E * Wo);
            K = (Wo * Ti) / (2 * E * bo);
            N = 2 * E * Wo  * Td;
            
            % Update K, Ti, Td fields
            K = round(K * 100)/100;
            Ti = round(Ti * 100)/100;
            Td = round(Td * 100)/100;
            app.k_val.Text = num2str(K);
            app.ti_val.Text = num2str(Ti);
            app.td_val.Text = num2str(Td);
            
            % Plot system output
            s = tf('s');   
            num = (K * bo * N) / (Ti * Td);
            den = s * s + (N / Td) * s + (K * bo * N) / (Ti * Td);
            GF = num / den;
            plot(app.system, step(GF));
            
        end
        
        %*************************
        % PI Controller functions     
        %*************************
        
        function pi_init(app)
            % Remove plots
            app.plant.cla();
            app.controller.cla();
            app.system.cla();
            
            % Reset fields for PID 
            app.k_val.Text = '0';
            app.ti_val.Text = '0';
            app.GEditFieldLabel.Text = "G";
            app.G_a1EditField.Value = 0;
            app.TEditFieldLabel.Text = "T";
            app.T_a2EditField.Value = 0;
            app.ToEditFieldLabel.Text = "To";
            app.To_boEditField.Value = 0;    
            app.WoEditField.Visible = "off";
            app.WoEditFieldLabel.Visible = "off";
            app.EEditField.Visible = "off";
            app.EEditFieldLabel.Visible = "off";  
            app.td_val.Visible = "off";
            app.TdLabel.Visible = "off";
        end
        
        function pi_plot_planet(app)
            To = app.To_boEditField.Value;
            G = app.G_a1EditField.Value;
            T = app.T_a2EditField.Value;
            num = G;
            den = [T 1];
            GF = tf(num, den);
            plot(app.plant, step(GF));
        end
        
        function pi_plot_controller(app)
            To = app.To_boEditField.Value;
            G = app.G_a1EditField.Value;
            T = app.T_a2EditField.Value;
            K = T / G * To;
            Ti = T;
            
            s = tf('s');
            GF = K * (1 + 1 / (s * Ti));
            plot(app.controller, step(GF));
            
        end
        
        function pi_plot_system(app)
            % Get input data
            To = app.To_boEditField.Value;
            G = app.G_a1EditField.Value;
            T = app.T_a2EditField.Value;
            K = T / G * To;
            Ti = T;
            
            % Update K, Ti fields
            K = round(K * 100)/100;
            Ti = round(Ti * 100)/100;
            app.k_val.Text = num2str(K);
            app.ti_val.Text = num2str(Ti);
            
            % Plot system output
            s = tf('s');
            HR = K * (1 + 1 / (Ti * s));
            P =  G / (1 + s * T);
            GF = feedback(HR * P, 1);
            plot(app.system, step(GF));
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: SimulateButton
        function simulate_fn(app, event)
            if(app.ControllerDropDown.Value == "PID")
                pid_plot_planet(app);
                pid_plot_controller(app);
                pid_plot_system(app);
                
            elseif (app.ControllerDropDown.Value == "PI")
                pi_plot_planet(app);
                pi_plot_controller(app);
                pi_plot_system(app);
            end
        end

        % Value changed function: ControllerDropDown
        function ControllerdDropDown_fn(app, event)
            value = app.ControllerDropDown.Value;
            if(value == "PID")
                pid_init(app)
            elseif (value == "PI")
                pi_init(app);
            end
        end

        % Button pushed function: resetButton
        function resetButtonPushed(app, ~)
            pi_init(app);
            app.ControllerDropDown.Value = "PI";
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 816 665];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Scrollable = 'on';
            app.UIFigure.WindowState = 'minimized';

            % Create plant
            app.plant = uiaxes(app.UIFigure);
            title(app.plant, 'Plant')
            xlabel(app.plant, 't')
            ylabel(app.plant, 'Y')
            app.plant.Position = [429 291 359 274];

            % Create SystemParametersPanel
            app.SystemParametersPanel = uipanel(app.UIFigure);
            app.SystemParametersPanel.Title = 'System Parameters';
            app.SystemParametersPanel.FontWeight = 'bold';
            app.SystemParametersPanel.Position = [33 311 369 241];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.SystemParametersPanel, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @simulate_fn, true);
            app.SimulateButton.BackgroundColor = [0.2431 0.6588 0.1373];
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Position = [70 22 153 31];
            app.SimulateButton.Text = 'Simulate';

            % Create EEditFieldLabel
            app.EEditFieldLabel = uilabel(app.SystemParametersPanel);
            app.EEditFieldLabel.HorizontalAlignment = 'center';
            app.EEditFieldLabel.Visible = 'off';
            app.EEditFieldLabel.Position = [9 64 63 22];
            app.EEditFieldLabel.Text = 'E';

            % Create EEditField
            app.EEditField = uieditfield(app.SystemParametersPanel, 'numeric');
            app.EEditField.HorizontalAlignment = 'center';
            app.EEditField.Visible = 'off';
            app.EEditField.Position = [87 64 100 22];

            % Create GEditFieldLabel
            app.GEditFieldLabel = uilabel(app.SystemParametersPanel);
            app.GEditFieldLabel.HorizontalAlignment = 'center';
            app.GEditFieldLabel.Position = [8 184 63 22];
            app.GEditFieldLabel.Text = 'G';

            % Create G_a1EditField
            app.G_a1EditField = uieditfield(app.SystemParametersPanel, 'numeric');
            app.G_a1EditField.HorizontalAlignment = 'center';
            app.G_a1EditField.Position = [86 184 100 22];

            % Create TEditFieldLabel
            app.TEditFieldLabel = uilabel(app.SystemParametersPanel);
            app.TEditFieldLabel.HorizontalAlignment = 'center';
            app.TEditFieldLabel.Position = [8 155 63 22];
            app.TEditFieldLabel.Text = 'T';

            % Create T_a2EditField
            app.T_a2EditField = uieditfield(app.SystemParametersPanel, 'numeric');
            app.T_a2EditField.HorizontalAlignment = 'center';
            app.T_a2EditField.Position = [86 155 100 22];

            % Create ToEditFieldLabel
            app.ToEditFieldLabel = uilabel(app.SystemParametersPanel);
            app.ToEditFieldLabel.HorizontalAlignment = 'center';
            app.ToEditFieldLabel.Position = [8 124 63 22];
            app.ToEditFieldLabel.Text = 'To';

            % Create To_boEditField
            app.To_boEditField = uieditfield(app.SystemParametersPanel, 'numeric');
            app.To_boEditField.HorizontalAlignment = 'center';
            app.To_boEditField.Position = [86 124 100 22];

            % Create WoEditFieldLabel
            app.WoEditFieldLabel = uilabel(app.SystemParametersPanel);
            app.WoEditFieldLabel.HorizontalAlignment = 'center';
            app.WoEditFieldLabel.Visible = 'off';
            app.WoEditFieldLabel.Position = [9 93 63 22];
            app.WoEditFieldLabel.Text = 'Wo';

            % Create WoEditField
            app.WoEditField = uieditfield(app.SystemParametersPanel, 'numeric');
            app.WoEditField.HorizontalAlignment = 'center';
            app.WoEditField.Visible = 'off';
            app.WoEditField.Position = [87 93 100 22];

            % Create KLabel
            app.KLabel = uilabel(app.SystemParametersPanel);
            app.KLabel.HorizontalAlignment = 'center';
            app.KLabel.FontWeight = 'bold';
            app.KLabel.Position = [234 184 25 22];
            app.KLabel.Text = 'K =';

            % Create TiLabel
            app.TiLabel = uilabel(app.SystemParametersPanel);
            app.TiLabel.HorizontalAlignment = 'center';
            app.TiLabel.FontWeight = 'bold';
            app.TiLabel.Position = [233.5 134 29 22];
            app.TiLabel.Text = 'Ti =';

            % Create TdLabel
            app.TdLabel = uilabel(app.SystemParametersPanel);
            app.TdLabel.HorizontalAlignment = 'center';
            app.TdLabel.Visible = 'off';
            app.TdLabel.Position = [233.5 85 30 22];
            app.TdLabel.Text = 'Td =';

            % Create k_val
            app.k_val = uilabel(app.SystemParametersPanel);
            app.k_val.HorizontalAlignment = 'center';
            app.k_val.Position = [291 184 25 22];
            app.k_val.Text = '0';

            % Create ti_val
            app.ti_val = uilabel(app.SystemParametersPanel);
            app.ti_val.HorizontalAlignment = 'center';
            app.ti_val.Position = [292 134 25 22];
            app.ti_val.Text = '0';

            % Create td_val
            app.td_val = uilabel(app.SystemParametersPanel);
            app.td_val.HorizontalAlignment = 'center';
            app.td_val.Visible = 'off';
            app.td_val.Position = [291 85 25 22];
            app.td_val.Text = '0';

            % Create resetButton
            app.resetButton = uibutton(app.SystemParametersPanel, 'push');
            app.resetButton.ButtonPushedFcn = createCallbackFcn(app, @resetButtonPushed, true);
            app.resetButton.Position = [243 26 66 23];
            app.resetButton.Text = 'reset';

            % Create ControllerDropDownLabel
            app.ControllerDropDownLabel = uilabel(app.UIFigure);
            app.ControllerDropDownLabel.FontWeight = 'bold';
            app.ControllerDropDownLabel.Position = [42 564 63 22];
            app.ControllerDropDownLabel.Text = 'Controller';

            % Create ControllerDropDown
            app.ControllerDropDown = uidropdown(app.UIFigure);
            app.ControllerDropDown.Items = {'PI', 'PID'};
            app.ControllerDropDown.ValueChangedFcn = createCallbackFcn(app, @ControllerdDropDown_fn, true);
            app.ControllerDropDown.Position = [115 564 288 22];
            app.ControllerDropDown.Value = 'PI';

            % Create controller
            app.controller = uiaxes(app.UIFigure);
            title(app.controller, 'Controller')
            xlabel(app.controller, 't')
            ylabel(app.controller, 'Y')
            app.controller.Position = [33 18 359 274];

            % Create system
            app.system = uiaxes(app.UIFigure);
            title(app.system, 'System')
            xlabel(app.system, 't')
            ylabel(app.system, 'Y')
            app.system.Position = [430 18 359 274];

            % Create PIDDesignToolLabel
            app.PIDDesignToolLabel = uilabel(app.UIFigure);
            app.PIDDesignToolLabel.FontName = 'Arial Black';
            app.PIDDesignToolLabel.FontSize = 36;
            app.PIDDesignToolLabel.FontWeight = 'bold';
            app.PIDDesignToolLabel.FontColor = [0.1412 0.1765 0.2];
            app.PIDDesignToolLabel.Position = [267 608 320 58];
            app.PIDDesignToolLabel.Text = 'PID Design Tool';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PID

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end

