function freq = show_gcsd_gui(data, fs)
    % data: matrix [time x regions]
    % fs: sampling frequency (Hz)
    % freq: user-defined frequency of interest (Hz)

    % Compute GCSD (placeholder)
    for i = 1:size(data,3)
        [pxx(:,i), f] = gcpsd_new(data(:,:,i), fs);
    end

    % Create figure
    f_gui = figure('Name', 'GCSD Viewer', ...
                   'NumberTitle', 'off', ...
                   'Position', [300 300 800 400], ...
                   'WindowStyle', 'modal');  % modal to block until closed

    % Left side: GCSD plot
    ax = axes('Parent', f_gui, 'Units', 'pixels', 'Position', [50 80 350 280]);
    plot(ax, f, pxx);
    datacursormode on;
    title(ax, 'Generalized Cross Spectral Density');
    xlabel(ax, 'Frequency (Hz)');
    ylabel(ax, 'Power');

    % Right side: Frequency input
    uicontrol('Parent', f_gui, 'Style', 'text', ...
              'Position', [460 250 250 30], ...
              'String', 'Enter frequency of interest (Hz):', ...
              'FontSize', 11, ...
              'HorizontalAlignment', 'left');

    freq_input = uicontrol('Parent', f_gui, 'Style', 'edit', ...
                           'Position', [460 210 200 30], ...
                           'FontSize', 11);

    % Submit button
    uicontrol('Parent', f_gui, 'Style', 'pushbutton', ...
              'Position', [460 160 200 30], ...
              'String', 'Submit', ...
              'Callback', @on_submit);

    % Wait for user to click Submit
    uiwait(f_gui);

    % Return value captured from edit box
    freq = str2double(get(freq_input, 'String'));
    close(f_gui);

    % Nested callback
    function on_submit(~, ~)
        val = str2double(get(freq_input, 'String'));
        if isnan(val)
            errordlg('Please enter a valid number.', 'Invalid input');
        else
            uiresume(f_gui);
        end
    end
end
