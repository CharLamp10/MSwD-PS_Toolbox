function mswd_ps_main()
    clc
    close all
    % GUI Window
    f = figure('Name', 'MSwD-PS', ...
               'NumberTitle', 'off', ...
               'Position', [600 300 600 400]);  % Enlarged window

    % % --- Add logo image (top-left)
    % ax = axes('Parent', f, 'Units', 'pixels', 'Position', [20 330 60 60]);
    % img = imread('logo.png');  % Replace with your actual logo file
    % imshow(img, 'Parent', ax);
    % axis off;

    % --- Toolbox name (next to logo)
    uicontrol('Style', 'text', ...
              'Parent', f, ...
              'Position', [240 350 400 40], ...
              'String', 'MSWD-PS', ...
              'FontSize', 20, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'left',...
              'ForegroundColor', [0 0 1]);

    % --- Description or main instruction
    uicontrol('Style', 'text', ...
              'Parent', f, ...
              'Position', [150 280 300 30], ...
              'String', 'Select data and run analysis', ...
              'FontSize', 15);

    % --- Run Button
    uicontrol('Style', 'pushbutton', ...
              'Parent', f, ...
              'Position', [200 200 200 40], ...
              'String', 'Select Files & Run', ...
              'FontSize', 12, ...
              'Callback', @run_pipeline);

    % --- Exit Button
    uicontrol('Style', 'pushbutton', ...
              'Parent', f, ...
              'Position', [200 140 200 40], ...
              'String', 'Exit', ...
              'FontSize', 12, ...
              'Callback', @(~,~) close(f));

    % --- Publication Info (bottom)
    uicontrol('Style', 'text', ...
              'Parent', f, ...
              'Position', [50 40 500 50], ...
              'String', 'Based on: "Robust fMRI time-varying functional connectivity analysis using multivariate swarm decomposition", DOI: https://doi.org/10.1016/j.neucom.2025.130404', ...
              'FontSize', 10, ...
              'HorizontalAlignment', 'center');
end

function run_pipeline(~, ~)
    [parentFolder, ~, ~] = fileparts(pwd);
    addpath(genpath(parentFolder))
    % Ask for input directory
    [filenames, pathname] = uigetfile({'*.*', 'All Files'}, 'Select files', 'MultiSelect', 'on');
    if ischar(filenames)
        temp{1,1} = filenames;
        filenames = temp;
    end
    if isnumeric(filenames)
        disp('User canceled file selection.');
        return;
    end
    input_files_orig = {};
    input_files_decomposed = {};
    c1 = 1;
    for i = 1:length(filenames)
        if ~contains(filenames{i}, 'imfs') && ...
           ~contains(filenames{i}, 'brain_states') && ...
           ~contains(filenames{i}, 'TVPS') && ...
           ~contains(filenames{i}, 'rec') && ...
            contains(filenames{i}, '.mat')
            input_files_orig{c1,1} = fullfile(pathname,filenames{i});
            c1 = c1 + 1;
        elseif contains(filenames{i}, 'imfs') && ...
               ~contains(filenames{i}, 'brain_states') && ...
               ~contains(filenames{i}, 'TVPS') && ...
               ~contains(filenames{i}, 'rec') && ...
                contains(filenames{i}, '.mat')
            input_files_decomposed{c1,1} = fullfile(pathname,filenames{i});
            c1 = c1 + 1;
        end
    end
    if length(input_files_orig) == length(filenames)
        disp(['Found ', num2str(length(filenames)), ' files containing fMRI time-series'])
        input_files = input_files_orig;
        cat = "orig";
    elseif length(input_files_decomposed) == length(filenames)
        disp(['Found ', num2str(length(filenames)), ' files containing decomposed fMRI time-series'])
        input_files = input_files_decomposed;
        cat = "decomposed";
    else
        error('Selected files must belong in the same category')
    end

    
    % Ask for output directory
    output_dir = uigetdir(pwd, 'Select output directory');
    if output_dir == 0
        disp('User canceled directory selection.');
        return;
    end
    
    if cat == "orig"
        % Ask for prefix (string)
        prefix = getOutputPrefix_UI();

        % Ask for P_corr_imp parameter (numeric)
        Corr_th = getCorr_th_UI();
    
        % Ask for stdComp parameter (numeric)
        StD_th = getStD_th_UI();
    else
        for i = 1:length(filenames)
            parts = split(filenames{i}, '_');
            prefixs{i} = parts{1};
            for j = 1:length(parts)
                part = parts{j};
                if contains(part, "CORRth")
                    Corr_ths{i} = part;
                elseif contains(part, "STDth")
                    StD_ths{i} = part(1:end-4);
                end
            end
        end
        prefix_unique = unique(prefixs);
        if length(prefix_unique) > 1
            error('You have selected files with different prefix')
        else
            prefix = prefix_unique{1,1};
        end
        Corr_th_unique = unique(Corr_ths);
        if length(Corr_th_unique) > 1
            error('You have selected files with different Corr_th')
        else
            Corr_th = Corr_ths{1,1};
        end
        StD_th_unique = unique(StD_ths);
        if length(StD_th_unique) > 1
            error('You have selected files with different StD_th')
        else
            StD_th = StD_ths{1,1};
        end
    end
    
    % --- Ask user whether to save the decomposed signals or not
    if cat == "orig"
        save_imfs = ask_save_imfs();
    end
    % --- Ask user whether to perform phase synchronization or reconstruct
    % signal or both
    choice1 = ask_analysis_type();
    if strcmp(choice1, 'TVPS') || strcmp(choice1, 'both')
        save_tvps = ask_save_tvps();
        choice2 = ask_estimate_brain_states();
        if choice2 == "Yes"
            choice3 = ask_specify_Nof_states();
            if choice3 == "Specify"
                K = ask_number_of_states();
            else
                K = "estimate";
            end
            save_states = ask_save_states();
        end
    end

    if strcmp(choice1, 'REC') || strcmp(choice1, 'both')
        lambda = getLambda_UI();
    end
    
    %% Decomposition
    if cat == "orig"
        % --- Run MSWD
        for i = 1:length(input_files)
            input_file = input_files{i,1};
            [~, name, ~] = fileparts(input_file);
            names{i} = name;
            disp(['Starting decomposition of ', name])
            try
                imfs = run_MSWD_batch(input_file, Corr_th, StD_th);
                decomposed{i,1} = imfs;
                disp(['Decomposition of ', name,' completed.']);
            catch ME
                errordlg(['Error in MSWD calculation of ', input_file, ' : ' ME.message], 'Error');
                return;
            end
            if save_imfs == "Yes"
                output_file = fullfile(output_dir, [prefix '_' name '_imfs_CORRth', num2str(Corr_th), '_STDth', num2str(StD_th), '.mat']);
                save(output_file, 'imfs');
            end
        end
    else
        for i = 1:length(input_files)
            [~, name, ~] = fileparts(input_files{i});
            parts = split(name, '_');
            name = parts(2:end-3);
            if length(name) == 1
                name = name{1,1};
            else
                name = strjoin(name, '_');
            end
            names{i} = name;
            decomposed{i,1} = load(input_files{i}).imfs;
        end
    end
    
    %% TVPS
    if strcmp(choice1, 'TVPS') || strcmp(choice1, 'both')
        for i = 1:length(decomposed)
            disp(['Starting TVPS of ', names{i}])
            try
                cosdelphi = phase_sync_analysis(decomposed{i,1});
                tvps{i} = cosdelphi;
            catch ME
                errordlg(['Error in TVPS calculation: ' ME.message], 'Error');
            end
            disp(['TVPS of ', names{i},' completed.']);
            if save_tvps == "Yes"
                if cat == "orig"
                    output_file = fullfile(output_dir, [prefix '_' names{i} '_TVPS_CORRth', num2str(Corr_th), '_STDth', num2str(StD_th), '.mat']);
                    save(output_file, 'cosdelphi');
                else
                    output_file = fullfile(output_dir, [prefix '_' names{i} '_TVPS_', Corr_th, '_', StD_th, '.mat']);
                    save(output_file, 'cosdelphi');
                end
            end
        end
        
        if choice2 == "Yes"
            disp('Starting brain state estimation.')
            [state_succession,brain_states, K] = brain_state_estimation(tvps,K);
            disp('Brain state estimation completed')
            if save_states == "Yes"
                if cat == "orig"
                    output_file = fullfile(output_dir, [prefix, '_brain_states_CORRth', num2str(Corr_th), '_STDth', num2str(StD_th), '_K', num2str(K), '.mat']);
                    save(output_file, 'brain_states','state_succession');
                else
                    output_file = fullfile(output_dir, [prefix, '_brain_states_', Corr_th, '_', StD_th, '_K', num2str(K), '.mat']);
                    save(output_file, 'brain_states','state_succession');
                end
            end
            for i = 1:K
                figure;
                state = brain_states(i,:);
                state_new = eye(size(decomposed{1},2), size(decomposed{1},2));
                indx = nchoosek(1:size(decomposed{1},2), 2);
                for n = 1:size(indx,1)
                    state_new(indx(n,1), indx(n,2)) = state(n);
                    state_new(indx(n,2), indx(n,1)) = state(n);
                end
                state_new = state_new(1:end-1, 1:end-1);
                state_new(1:size(state_new,1)+1:end) = 0;  % zero out diagonal
            
                gsplot(state_new);
                set(gca, 'XTick', [], 'YTick', [], 'CLim', [-1 1]);
                axis square;
                colorbar();
                if cat == "orig"
                    output_file = fullfile(output_dir, [prefix, '_brain_state', num2str(i), '_CORRth', num2str(Corr_th), '_STDth', num2str(StD_th), '_K', num2str(K), '.png']);
                    exportgraphics(gcf,output_file,'Resolution',600)
                else
                    output_file = fullfile(output_dir, [prefix, '_brain_state', num2str(i), '_', Corr_th, '_', StD_th, '_K', num2str(K), '.png']);
                    exportgraphics(gcf,output_file,'Resolution',600)
                end
            end
        end
    end 

    %% Reconstruction
    if strcmp(choice1, 'REC') || strcmp(choice1, 'both')
        for i = 1:length(input_files)
            disp(['Starting reconstruction of ', names{i}])
            glob = sum(decomposed{i,1}(:,:,1:end-1),3);
            local = decomposed{i,1}(:,:,end);
            rec = glob.*lambda + local;
            corr = corrcoef(rec);
            if cat == "orig"
                output_file = fullfile(output_dir, [prefix '_' names{i} '_rec_CORRth', num2str(Corr_th), '_STDth', num2str(StD_th), '_lambda' , num2str(lambda),'.mat']);
                save(output_file, 'corr','rec');
            else
                output_file = fullfile(output_dir, [prefix '_' names{i} '_rec_', Corr_th, '_', StD_th, '_lambda' , num2str(lambda),'.mat']);
                save(output_file, 'corr','rec');
            end
            disp(['Reconstruction of ', names{i}, ' completed and output saved'])
        end
    end
    disp('Done.');
end


function prefix = getOutputPrefix_UI()
    % Create UI figure
    fig = uifigure('Name', 'Output prefix', 'Position', [500 500 450 145], ...
                   'WindowStyle', 'modal');

    % Label
    lbl = uilabel(fig, ...
        'Text', 'Enter output prefix (without underscores):', ...
        'Position', [20 110 410 30], ...
        'FontSize', 18);

    % Edit field
    edt = uieditfield(fig, 'text', ...
        'Position', [20 70 410 30], ...
        'FontSize', 18);

    % Submit button
    btn = uibutton(fig, ...
        'Text', 'OK', ...
        'FontSize', 18,...
        'Position', [185 20 80 30], ...
        'ButtonPushedFcn', @(btn,event) uiresume(fig));

    % Wait for user interaction
    uiwait(fig);

    % Get value
    prefix = edt.Value;

    % Handle cancel (if user closes window without clicking OK)
    if isempty(prefix)
        delete(fig);
        error('User canceled prefix input.');
    end

    % Close figure
    delete(fig);
end

function Corr_th = getCorr_th_UI()
    % Create UI figure
    fig = uifigure('Name', 'Parameter Input', 'Position', [500 500 480 145], ...
                   'WindowStyle', 'modal');

    % Label
    lbl = uilabel(fig, ...
        'Text', 'Enter threshold for terminating the algorithm (Corr_th):', ...
        'Position', [20 110 440 30], ...
        'FontSize', 18);

    % Edit field with default value
    edt = uieditfield(fig, 'text', ...
        'Value', '0.02', ...
        'Position', [20 70 440 30], ...
        'FontSize', 18);

    % OK button
    btn = uibutton(fig, ...
        'Text', 'OK', ...
        'FontSize', 18,...
        'Position', [200 20 80 30], ...
        'ButtonPushedFcn', @(btn,event) uiresume(fig));

    % Wait for user to click OK
    uiwait(fig);

    % Read value
    Corr_th = str2double(edt.Value);

    % Handle cancel or invalid input
    if isempty(edt.Value) || isnan(Corr_th)
        delete(fig);
        error('User canceled parameter input or entered invalid value.');
    end

    delete(fig);
end

function StD_th = getStD_th_UI()
    % Create UI figure
    fig = uifigure('Name', 'Parameter Input', 'Position', [500 500 450 145], ...
                   'WindowStyle', 'modal');

    % Label
    lbl = uilabel(fig, ...
        'Text', 'Enter component standard deviation (StD_th):', ...
        'Position', [20 110 410 30], ...
        'FontSize', 18);

    % Edit field with default value
    edt = uieditfield(fig, 'text', ...
        'Value', '0.05', ...
        'Position', [20 70 410 30], ...
        'FontSize', 18);

    % OK button
    btn = uibutton(fig, ...
        'Text', 'OK', ...
        'FontSize', 18,...
        'Position', [185 20 80 30], ...
        'ButtonPushedFcn', @(btn,event) uiresume(fig));

    % Wait for user to click OK
    uiwait(fig);

    % Read value
    StD_th = str2double(edt.Value);

    % Handle cancel or invalid input
    if isempty(edt.Value) || isnan(StD_th)
        delete(fig);
        error('User canceled parameter input or entered invalid value.');
    end

    delete(fig);
end

function save_imfs = ask_save_imfs()
    % Create UI figure
    fig = uifigure('Name', 'Save?', 'Position', [500 500 340 110]);

    % Add label
    uilabel(fig, ...
        'Text', 'Save the decomposed fMRI signals?', ...
        'FontSize', 18, ...
        'Position', [20 70 300 30]);

    % Output holder
    save_imfs = '';

    % Yes button
    uibutton(fig, 'Text', 'Yes', ...
        'Position', [30 30 100 30], ...
        'FontSize', 18,...
        'ButtonPushedFcn', @(btn,event) onChoice('Yes'));

    % No button
    uibutton(fig, 'Text', 'No', ...
        'FontSize', 18,...
        'Position', [210 30 100 30], ...
        'ButtonPushedFcn', @(btn,event) onChoice('No'));

    % Block execution until choice made
    uiwait(fig);

    % Callback function
    function onChoice(choice)
        save_imfs = choice;
        uiresume(fig);
        delete(fig);
    end
end

function choice1 = ask_analysis_type()
    % Create modal figure
    fig = uifigure('Name', 'Select analysis', 'Position', [500 500 540 150], ...
                   'WindowStyle', 'modal');

    % Prompt label
    uilabel(fig, ...
        'Text', ['Run time-varying phase synchronization (TVPS), ' ...
                 'reconstruct the signals using a specific lambda (REC), or both?'], ...
        'Position', [20 90 500 50], ...
        'FontSize', 18, ...
        'HorizontalAlignment', 'left', ...
        'WordWrap', 'on');

    % Output holder
    choice1 = '';

    % TVPS button
    uibutton(fig, 'Text', 'TVPS', ...
        'FontSize', 18,...
        'Position', [30 40 100 30], ...
        'ButtonPushedFcn', @(btn,event) onSelect('TVPS'));

    % REC button
    uibutton(fig, 'Text', 'REC', ...
        'FontSize', 18,...
        'Position', [225 40 100 30], ...
        'ButtonPushedFcn', @(btn,event) onSelect('REC'));

    % both button
    uibutton(fig, 'Text', 'both', ...
        'FontSize', 18,...
        'Position', [410 40 100 30], ...
        'ButtonPushedFcn', @(btn,event) onSelect('both'));

    % Block MATLAB execution until figure is closed
    uiwait(fig);

    % Callback to handle button press
    function onSelect(val)
        choice1 = val;
        uiresume(fig);
        delete(fig);
    end
end

function save_tvps = ask_save_tvps()
    % Create UI figure
    fig = uifigure('Name', 'Save?', 'Position', [500 500 300 110]);

    % Add label
    uilabel(fig, ...
        'Text', 'Save TVPS outputs?', ...
        'FontSize', 18, ...
        'Position', [20 70 260 30]);

    % Output holder
    save_tvps = '';

    % Yes button
    uibutton(fig, 'Text', 'Yes', ...
        'FontSize', 18,...
        'Position', [30 30 100 30], ...
        'ButtonPushedFcn', @(btn,event) onChoice('Yes'));

    % No button
    uibutton(fig, 'Text', 'No', ...
        'FontSize', 18,...
        'Position', [170 30 100 30], ...
        'ButtonPushedFcn', @(btn,event) onChoice('No'));

    % Block execution until choice made
    uiwait(fig);

    % Callback function
    function onChoice(choice)
        save_tvps = choice;
        uiresume(fig);
        delete(fig);
    end
end

function choice2 = ask_estimate_brain_states()
    % Create a modal uifigure
    fig = uifigure('Name', 'Brain states?', ...
                   'Position', [500 500 480 130], ...
                   'WindowStyle', 'modal');

    % Prompt label
    uilabel(fig, ...
        'Text', 'Estimate brain states across all samples using the TVPS data?', ...
        'Position', [20 70 440 40], ...
        'FontSize', 18, ...
        'HorizontalAlignment', 'left', ...
        'WordWrap', 'on');

    % Output variable
    choice2 = '';

    % Yes button
    uibutton(fig, 'Text', 'Yes', ...
        'FontSize', 18,...
        'Position', [100 20 80 30], ...
        'ButtonPushedFcn', @(btn, event) onChoice('Yes'));

    % No button
    uibutton(fig, 'Text', 'No', ...
        'FontSize', 18,...
        'Position', [300 20 80 30], ...
        'ButtonPushedFcn', @(btn, event) onChoice('No'));

    % Wait for user action
    uiwait(fig);

    % Callback for both buttons
    function onChoice(val)
        choice2 = val;
        uiresume(fig);
        delete(fig);
    end
end


function choice3 = ask_specify_Nof_states()
    % Create modal figure
    fig = uifigure('Name', 'Specify states?', ...
                   'Position', [500 500 400 130], ...
                   'WindowStyle', 'modal');

    % Add label
    uilabel(fig, ...
        'Text', 'Specify the number of states (for K-means) or use silhouette for automatic estimation?', ...
        'Position', [20 70 360 40], ...
        'FontSize', 18, ...
        'HorizontalAlignment', 'left', ...
        'WordWrap', 'on');

    % Initialize output
    choice3 = '';

    % Specify button
    uibutton(fig, 'Text', 'Specify', ...
        'FontSize', 18,...
        'Position', [80 20 100 30], ...
        'ButtonPushedFcn', @(btn, event) onChoice('Specify'));

    % Estimate button
    uibutton(fig, 'Text', 'Estimate', ...
        'FontSize', 18,...
        'Position', [220 20 100 30], ...
        'ButtonPushedFcn', @(btn, event) onChoice('Estimate'));

    % Wait for user input
    uiwait(fig);

    % Button callback
    function onChoice(val)
        choice3 = val;
        uiresume(fig);
        delete(fig);
    end
end


function save_states = ask_save_states()
    % Create UI figure
    fig = uifigure('Name', 'Save?', 'Position', [500 500 300 110]);

    % Add label
    uilabel(fig, ...
        'Text', 'Save the obtained brain states?', ...
        'FontSize', 18, ...
        'Position', [20 70 260 30]);

    % Output holder
    save_states = '';

    % Yes button
    uibutton(fig, 'Text', 'Yes', ...
        'FontSize', 18,...
        'Position', [30 30 100 30], ...
        'ButtonPushedFcn', @(btn,event) onChoice('Yes'));

    % No button
    uibutton(fig, 'Text', 'No', ...
        'FontSize', 18,...
        'Position', [170 30 100 30], ...
        'ButtonPushedFcn', @(btn,event) onChoice('No'));

    % Block execution until choice made
    uiwait(fig);

    % Callback function
    function onChoice(choice)
        save_states = choice;
        uiresume(fig);
        delete(fig);
    end
end

function K = ask_number_of_states()
    % Create UI figure
    fig = uifigure('Name', 'Parameter Input', 'Position', [500 500 450 145], ...
                   'WindowStyle', 'modal');

    % Label
    lbl = uilabel(fig, ...
        'Text', 'Enter number of states:', ...
        'Position', [20 110 410 30], ...
        'FontSize', 18);

    % Edit field with default value
    edt = uieditfield(fig, 'text', ...
        'FontSize', 18,...
        'Position', [20 70 410 30], ...
        'FontSize', 14);

    % OK button
    btn = uibutton(fig, ...
        'Text', 'OK', ...
        'FontSize', 18,...
        'Position', [185 20 80 30], ...
        'ButtonPushedFcn', @(btn,event) uiresume(fig));

    % Wait for user to click OK
    uiwait(fig);

    % Read value
    K = str2double(edt.Value);

    % Handle cancel or invalid input
    if isempty(edt.Value) || isnan(K) 
        delete(fig);
        error('User canceled parameter input or entered invalid value.');
    end
    if K <= 1 || round(K) ~= K
        uialert(fig, 'Please enter a valid positive integer greater than 1.', 'Invalid input');
    else
        uiresume(fig);
        delete(fig);
    end

    delete(fig);
end


function lambda = getLambda_UI()
    % Create UI figure
    fig = uifigure('Name', 'Parameter Input', 'Position', [500 500 500 145], ...
                   'WindowStyle', 'modal');

    % Label
    lbl = uilabel(fig, ...
        'Text', 'Enter a value for the reconstruction parameter lambda:', ...
        'Position', [20 110 460 30], ...
        'FontSize', 18);

    % Edit field with default value
    edt = uieditfield(fig, 'text', ...
        'Value', '0.5', ...
        'Position', [20 70 460 30], ...
        'FontSize', 18);

    % OK button
    btn = uibutton(fig, ...
        'Text', 'OK', ...
        'FontSize', 18,...
        'Position', [210 20 80 30], ...
        'ButtonPushedFcn', @(btn,event) uiresume(fig));

    % Wait for user to click OK
    uiwait(fig);

    % Read value
    lambda = str2double(edt.Value);

    % Handle cancel or invalid input
    if isempty(edt.Value) || isnan(lambda)
        delete(fig);
        error('User canceled parameter input or entered invalid value.');
    end

    delete(fig);
end