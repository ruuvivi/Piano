% Pääfunktio
function piano
    clc;
    clear all;
    close all;
    global Piano
    
    Piano.waveform = 'piano';

    global FM
    FM.mod_index = 10; % vakio mod indeksi
    FM.mod_frequency = 440; % vakio mod taajuus = sama kuin perustaajuus
    FM.active = false; % FM-modulaatio pois oletuksena

    % A-nuotin taajuus (Hz) tunnustettu standardi sävelkorkeus
    A = 440;
    ToneId = -24:24;
    Piano.Sample = cell(size(ToneId));
    
    % Lasketaan nuotteja vastaavat taajuudet
    Piano.note_frequencies = A * 2.^(ToneId / 12);

    % Näyteenottotaajuus
    Piano.Fs = 44100;

    % Nuotin kesto
    Piano.duration = 0.5;
    
    % Nimet koskettimille
    
    % Kolmen oktaavin valkoisten nuottien nimet
    white_key_names = {'C', 'D', 'E', 'F', 'G', 'A', 'B', ...
                      'C', 'D', 'E', 'F', 'G', 'A', 'B', ...
                      'C', 'D', 'E', 'F', 'G', 'A', 'B'};
    
    % Kolmen oktaavin mustien nuottien nimet
    black_key_names = {'C#', 'D#', 'F#', 'G#', 'A#', ...
                       'C#', 'D#', 'F#', 'G#', 'A#', ...
                       'C#', 'D#', 'F#', 'G#', 'A#'};
        
    % Valkoiset koskettimet vastaaviin taajuuksiin
    Piano.white_key_frequencies = Piano.note_frequencies([1, 3, 5, 6, 8, 10, 12, 13, 15, 17, 18, 20, 22, 24, 25, 27, 29, 30, 32, 34, 36]);
    
    % Mustat koskettimet vastaaviin taajuuksiin
    Piano.black_key_frequencies = Piano.note_frequencies([2, 4, 7, 9, 11, 14, 16, 19, 21, 23, 26, 28, 31, 33, 35]);
    
    % Luodaan GUI ja määritetään mitä näppäintä koskettaessa mikäkin ääni
    Piano.f = figure('Name', 'Piano Syntikka', 'NumberTitle', 'off', ...
        'Position', [300, 300, 750, 400], 'MenuBar', 'none', 'Resize', 'on', ...
        'WindowKeyPressFcn', @key_press, ...
        'Color', [0.1, 0.1, 0.1]);

    fontName = 'Bauhaus 93';
    fontSize = 12;
    fontWeight = 'normal';
    
    % Nuotin pituuden säädin ja painike (lyhyin = 1/16 piano nuotti, pisin = 1)
    Piano.length_values = [0.0625, 0.125, 0.25, 0.5, 0.75, 0.875, 0.9375, 1];
    length_labels = {'1/16', '1/8', '1/4', '1/2', '3/4', '7/8', '15/16', '1'};

    uicontrol('Style', 'text', 'String', 'Note length:', ...
          'Position', [270, 330, 100, 20], ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    uicontrol('Style', 'text', 'String', '(seconds)', ...
          'Position', [410, 330, 100, 20], ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ....
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    Piano.dur_length = uicontrol('Style', 'popupmenu', ...
    'String', length_labels, ...
    'Value', 4, ... % aloitus on vakio pituus 0.5 (4. arvo)
    'Position', [370, 330, 50, 20], ...
    'Callback', @(src, ~) update_duration(src, Piano.length_values));

    
    % Nappuloita eri äniaalloille

    Piano.bg = uibuttongroup('Title', 'Waveform Select', ...
                      'Position', [0.05, 0.83, 0.5, 0.15], ...  
                      'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', fontWeight, ...
                   'BackgroundColor', 'black', 'TitlePosition', 'centertop', ...
                   'ForegroundColor', 'white'); 
    
    % piano
    uicontrol(Piano.bg, 'Style', 'radiobutton', 'String', 'PIANO', ...
              'Position', [10, 40, 100, 30], 'Callback', @(~,~) set_waveform('piano'), ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', fontWeight, ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % kolmioaalto
    uicontrol(Piano.bg, 'Style', 'radiobutton', 'String', 'TRIANGLE', ...
              'Position', [425, 40, 100, 30], 'Callback', @(~,~) set_waveform('triangle'), ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', fontWeight, ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % neliöaalto
    uicontrol(Piano.bg, 'Style', 'radiobutton', 'String', 'SQUARE', ...
              'Position', [190, 40, 100, 30], 'Callback', @(~,~) set_waveform('square'), ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', fontWeight, ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % saha-aalto
    uicontrol(Piano.bg, 'Style', 'radiobutton', 'String', 'SAWTOOTH', ...
              'Position', [295, 40, 100, 30], 'Callback', @(~,~) set_waveform('sawtooth'), ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', fontWeight, ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % vibrato
    uicontrol(Piano.bg, 'Style', 'radiobutton', 'String', 'VIBRATO', ...
              'Position', [535, 40, 100, 30], 'Callback', @(~,~) set_waveform('vibrato'), ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', fontWeight, ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % siniaalto
    uicontrol(Piano.bg, 'Style', 'radiobutton', 'String', 'SINE', ...
              'Position', [110, 40, 60, 30], 'Callback',  @(~,~) set_waveform('sin'), ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', fontWeight, ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');

    % FM-synteesi

    % FM-mod taajuudelle painike
    uicontrol('Style', 'text', 'String', 'Freq:', ...
              'Position', [65, 480, 50, 20], ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    Piano.freq_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 2000, ...
              'Value', FM.mod_frequency, 'Position', [120, 480, 70, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ... 
              'Callback', @(src, ~) update_mod_frequency('freq', src.Value));

    % FM-mod indeksille painike
    uicontrol('Style', 'text', 'String', 'Index:', ...
              'Position', [65, 450, 50, 20], ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    Piano.mod_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 20, ...
              'Value', FM.mod_index, 'Position', [120, 450, 70, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ... 
              'Callback', @(src, ~) update_mod_index('mod', src.Value));

    
   Piano.bg1 = uibuttongroup('Title', 'FM Synthesis', ...
                      'Position', [0.05, 0.7, 0.1, 0.1], ...  
                      'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
                    'BackgroundColor', 'black', 'TitlePosition', 'centertop', ...
                    'ForegroundColor', 'white');

    % FM-synteesi OFF nappula
    Piano.fm_off_button = uicontrol(Piano.bg1, 'Style', 'radiobutton', 'String', 'OFF', ...
            'Position', [70, 15, 50, 30], ...  
            'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
            'Value', ~FM.active, ...
            'Callback', @(~,~) resetFM(Piano.mod_slider, Piano.freq_slider), ...
            'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % FM-synteesi ON nappula
    Piano.fm_on_button = uicontrol(Piano.bg1, 'Style', 'radiobutton', 'String', 'ON', ...
        'Position', [10, 15, 50, 30], ... 
        'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
        'Value', FM.active, ... 
        'Callback', @(src, ~) onFM(), ...  
        'BackgroundColor', 'black', 'ForegroundColor', 'white');

    % oktaavi alas- ja ylöspainikkeet

    uicontrol('Style', 'pushbutton', 'String', 'octave down', ...
              'Position', [70, 330, 110, 30], 'Callback', @octave_down, ...
          'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');

    uicontrol('Style', 'pushbutton', 'String', 'octave up', ...
              'Position', [70, 370, 110, 30], 'Callback', @octave_up, ...
          'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight, ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');

    % reset-painike

    uicontrol('Style', 'pushbutton', 'String', 'RESET', ...
          'Position', [800, 650, 100, 30], 'Callback', @reset_piano, ...
          'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight, ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');

    
    % Luodaan valkoiset koskettimet
    for i = 1:length(white_key_names)
    Piano.white_keys(i) = uicontrol('Style', 'pushbutton', 'String', white_key_names{i}, ...
        'Position', [(i-1)*50 + 20, 40, 50, 200], ...
        'BackgroundColor', 'white', 'ForegroundColor', [1, 1, 1],...
        'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
        'Callback', @(~,~) play_note(Piano.white_key_frequencies(i), Piano.Fs));
    end
    
    % Paikat mustille koskettimille (valkoisten keskelle)
    black_key_positions = [55, 105, 205, 255, 305,...  % Ensimmäinen oktaavi
                           405, 455, 555, 605, 655,...  % Toinen oktaavi
                           755, 805, 905, 955, 1005]; % Kolmas oktaavi

    for i = 1:length(black_key_names)
        Piano.black_keys(i) = uicontrol('Style', 'pushbutton', 'String', black_key_names{i}, ...
            'Position', [black_key_positions(i), 140, 30, 120], ...
            'BackgroundColor', 'black', 'ForegroundColor', [0, 0, 0], ...
            'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
            'Callback', @(~,~) play_note(Piano.black_key_frequencies(i), Piano.Fs));
    end

    % tietokoneen näppäimistön ohjeet

    % valkoiset koskettimet
    letters = {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k'};
    startX = 390; 
    yPosition = 50;  
    width = 10;  
    height = 15;  
    fontSize = 10;  
    
    
    for i = 1:length(letters)
        xPosition = startX + (i - 1) * 50;
        uicontrol('Style', 'text', ...
                  'String', letters{i}, ...
                  'Position', [xPosition, yPosition, width, height], ...
                  'FontName', 'Arial', ...
                  'FontSize', fontSize, ...
                  'FontWeight', 'bold', ...
                  'BackgroundColor', [1, 1, 1], ...
                  'ForegroundColor', [0.7, 0.7, 0.7]);
    end

    % mustat koskettimet
    letters2 = {'w', 'e'};
    startX2 = 415; 
    yPosition2 = 150;  
    
    
    for i = 1:length(letters2)
        xPosition = startX2 + (i - 1) * 50;
        uicontrol('Style', 'text', ...
                  'String', letters2{i}, ...
                  'Position', [xPosition, yPosition2, width, height], ...
                  'FontName', 'Arial', ...
                  'FontSize', fontSize, ...
                  'FontWeight', 'bold', ...
                  'BackgroundColor', [0, 0, 0], ...
                  'ForegroundColor', [0.4, 0.4, 0.4]);
    end

    letters3 = {'t', 'y', 'u'};
    startX3 = 565; 
    
    for i = 1:length(letters3)
        xPosition = startX3 + (i - 1) * 50;
        uicontrol('Style', 'text', ...
                  'String', letters3{i}, ...
                  'Position', [xPosition, yPosition2, width, height], ...
                  'FontName', 'Arial', ...
                  'FontSize', fontSize, ...
                  'FontWeight', 'bold', ...
                  'BackgroundColor', [0, 0, 0], ...
                  'ForegroundColor', [0.4, 0.4, 0.4]);
    end

    % Määritetään näppäimistönäppäimet vastaamaan koskettimia
    Piano.white_key_keyboard = {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k'};
    Piano.black_key_keyboard = {'w', 'e', 't','y', 'u'};

    piano_synth_gui();

end

function reset_piano(~, ~)
    global Piano
    global ADSR
    global FM

    bg = Piano.bg;
    bg1 = Piano.bg1;

    A = 440;
    ToneId = -24:24;

    Piano.note_frequencies = A * 2.^(ToneId / 12);

    ADSR.attack = 0.1;
    ADSR.decay = 0.2;
    ADSR.sustain = 0.7;
    ADSR.release = 0.5;

    set(Piano.attack_slider, 'Value', ADSR.attack);
    set(Piano.decay_slider, 'Value', ADSR.decay);
    set(Piano.sustain_slider, 'Value', ADSR.sustain);
    set(Piano.release_slider, 'Value', ADSR.release);

    update_adsr('', 0);

    set_waveform('piano')
    bg.SelectedObject = bg.Children(6);


    set(Piano.dur_length, 'Value', 4);  
    update_duration(Piano.dur_length, Piano.length_values);
    
    mod_index = 10;
    mod_frequency = 440; 
    set(Piano.mod_slider, 'Value', mod_index);
    set(Piano.freq_slider, 'Value', mod_frequency);
    bg1.SelectedObject = bg1.Children(2);
    FM.active = false;

    update_keys();

end


function octave_down(~, ~)
    %Puolittaa jokaisen taajuuden
    global Piano
    Piano.note_frequencies;
    Piano.note_frequencies = 1/2 * Piano.note_frequencies;
    update_keys();
end

function octave_up(~, ~)
    % Tuplaa jokaisen taajuuden
    global Piano
    Piano.note_frequencies;
    Piano.note_frequencies = 2 * Piano.note_frequencies;
    update_keys();
end

function set_waveform(shape)
    global Piano
    Piano.waveform = shape;
end

function update_mod_index(parameter, value)
    global FM
    switch parameter
        case 'mod'
            FM.mod_index = value;
    end
end

function update_mod_frequency(parameter, value)
    global FM
    switch parameter
        case 'freq'
            FM.mod_frequency = value;
    end
end

% Funktio: FM indeksi ja modulaattori nollataan
function resetFM(mod, freq)
    global FM
    set(freq, 'Value', 0);
    set(mod, 'Value', 0);
    FM.active = false;
end

% Funktio: FM indeksi ja modulaattori päälle
function onFM(~)
global FM
      FM.active = true;  
end



% Funktio: päivitetään nuotin pituus riippuen popup-menun valinnasta
function update_duration(src, length_values)
    global Piano

    %durations = get(src, 'String'); % Lista piuuksista
    selected_value = get(src, 'Value'); % Valittu indeksi
    selected_duration = length_values(selected_value); % Numeeriseksi


    Piano.duration = selected_duration; % päivitetään globaali pituus
   
end

% Funktio koskettimien taajuuksien päivittämiseen
function update_keys()
    global Piano
    
    % Päivitetään valkoiset ja mustat kosketintaajuudet
    Piano.white_key_frequencies = Piano.note_frequencies([1, 3, 5, 6, 8, 10, 12, 13, 15, 17, 18, 20, 22, 24, 25, 27, 29, 30, 32, 34, 36]);
    Piano.black_key_frequencies = Piano.note_frequencies([2, 4, 7, 9, 11, 14, 16, 19, 21, 23, 26, 28, 31, 33, 35]);
    
    % Päivitetyt taajuudet valkoisille koskettimille
    for i = 1:length(Piano.white_keys)
        set(Piano.white_keys(i), 'Callback', @(~,~) play_note(Piano.white_key_frequencies(i), Piano.Fs));
    end

    % Päivitetyt taajuudet mustille koskettimille
    for i = 1:length(Piano.black_keys)
        set(Piano.black_keys(i), 'Callback', @(~,~) play_note(Piano.black_key_frequencies(i), Piano.Fs));
    end
end

% Funktio: mitä näppäintä koskettaessa mikäkin ääni
function key_press(~, event)
    global Piano
    % Tarkista, mikä näppäin on painettu
    key = event.Key;

    % keskioktaavi valkoiset koskettimet
    Piano.white_key_frequencies_2 = Piano.note_frequencies([13, 15, 17, 18, 20, 22, 24, 25]);
    
    % keskioktaavi mustat koskettimet
    Piano.black_key_frequencies_2 = Piano.note_frequencies([14, 16, 19, 21, 23]);
    
    % Tarkistetaan, onko näppäin valkoinen tai musta kosketin
    white_key_i = find(strcmp(Piano.white_key_keyboard, key), 1);
    black_key_i = find(strcmp(Piano.black_key_keyboard, key), 1);
    
    % Jos painettiin valkoista kosketinta vastaavaa näppäintä
    if ~isempty(white_key_i)
        play_note(Piano.white_key_frequencies_2(white_key_i), Piano.Fs);
    end
    
    % Jos painettiin mustaa kosketinta vastaavaa näppäintä
    if ~isempty(black_key_i)
        play_note(Piano.black_key_frequencies_2(black_key_i), Piano.Fs);
    end
end

% Funktio: ADSR säätimet ja GUI
function piano_synth_gui()
global Piano
global ADSR

    
    % ADSR alkuarvot
    ADSR.attack = 0.1;
    ADSR.decay = 0.2;
    ADSR.sustain = 0.7;
    ADSR.release = 0.5;
    
    % Attack säädin
    uicontrol('Style', 'text', 'String', 'Attack:', ...
              'Position', [275, 520, 55, 20], ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    
    Piano.attack_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.attack, 'Position', [350, 520, 100, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ... 
              'Callback', @(src, ~) update_adsr('attack', src.Value));
    
    % Decay säädin
    uicontrol('Style', 'text', 'String', 'Decay:', ...
              'Position', [275, 480, 55, 20], ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    
    Piano.decay_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.decay, 'Position', [350, 480, 100, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ... 
              'Callback', @(src, ~) update_adsr('decay', src.Value));
    
    % Sustain säädin
    uicontrol('Style', 'text', 'String', 'Sustain:', ...
              'Position', [272, 440, 65, 20], ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    
    Piano.sustain_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, ...
              'Value', ADSR.sustain, 'Position', [350, 440, 100, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ...  
              'Callback', @(src, ~) update_adsr('sustain', src.Value));
    
    % Release säädin
    uicontrol('Style', 'text', 'String', 'Release:', ...
              'Position', [275, 400, 65, 20], ...
              'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    
    Piano.release_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.release, 'Position', [350, 400, 100, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ... 
              'Callback', @(src, ~) update_adsr('release', src.Value));
    % Alustetaan ADSR oletusarvot
    update_adsr('', 0);
end

% Funktio: ADSR päivitys ja kuvaaja
function update_adsr(param, value)
global ADSR
global Piano

    
% ADSR plotin pohja
    axADSR = axes('Parent', Piano.f, 'Position', [0.4, 0.55, 0.4, 0.2]); 
    title(axADSR, 'ADSR Envelope');
    xlabel(axADSR, 'Time');
    ylabel(axADSR, 'Amplitude');
    grid(axADSR, 'on');


    switch param
        case 'attack', ADSR.attack = value;
        case 'decay', ADSR.decay = value;
        case 'sustain', ADSR.sustain = value;
        case 'release', ADSR.release = value;
    end

    % Lasketaan ADSR-vaippa
    t = linspace(0, ADSR.attack + ADSR.decay + ADSR.sustain + ADSR.release, 100);
    y = zeros(size(t));
    t_a = t <= ADSR.attack;
    t_d = (t > ADSR.attack) & (t <= ADSR.attack + ADSR.decay);
    t_s = (t > ADSR.attack + ADSR.decay) & (t <= ADSR.attack + ADSR.decay + ADSR.sustain);
    t_r = t > ADSR.attack + ADSR.decay + ADSR.sustain;

    % Vaipan arvot
    y(t_a) = t(t_a) / ADSR.attack; 
    y(t_d) = 1 - (1 - ADSR.sustain) * (t(t_d) - ADSR.attack) / ADSR.decay; 
    y(t_s) = ADSR.sustain; 
    y(t_r) = ADSR.sustain * (1 - (t(t_r) - (ADSR.attack + ADSR.decay + ADSR.sustain)) / ADSR.release); 


    % piirretään ADSR-kuvaaja
    plot(axADSR, t, y, 'LineWidth', 2);
    xlabel(axADSR, 'Time', 'Color', 'white'); 
    ylabel(axADSR, 'Amplitude', 'Color', 'white');
    title(axADSR, 'ADSR Envelope', 'FontName', 'Bauhaus 93', 'FontSize', 12, 'FontWeight', 'normal', 'Color', 'white'); 
    grid(axADSR, 'on');
    axADSR.XColor = 'white'; 
    axADSR.YColor = 'white'; 
    axADSR.Color = 'black'; 

    axADSR.XTickLabel = []; 
    axADSR.YTickLabel = [];  
    
end 





% Funktio: ääniaaltojen päivittäminen, nuotin soitto
function play_note(frequency, Fs)
    global ADSR
    global Piano
    global FM

    % Haetaan ADSR parameterit
    attack_time = ADSR.attack;
    decay_time = ADSR.decay;
    sustain_level = ADSR.sustain;
    release_time = ADSR.release;

    % Haetaan FM parametri
    mod_index = FM.mod_index;

    % Haetaan FM parametri
    mod_frequency = FM.mod_frequency;

    % Nuotin kesto
    duration = Piano.duration;
    
    % Aikavektori
    t = 0:1/Fs:duration;

    % Lasketaan ADSR-vaippapituudet
    total_samples = length(t);
    attack_samples = round(attack_time * Fs);
    decay_samples = round(decay_time * Fs);
    sustain_samples = max(0, total_samples - attack_samples - decay_samples - round(release_time * Fs));
    release_samples = max(0, total_samples - (attack_samples + decay_samples + sustain_samples));
    

    % Luodaan ADSR-vaippa
    adsr_envelope = [
        linspace(0, 1, attack_samples), ...                 % Attack
        linspace(1, sustain_level, decay_samples), ...      % Decay
        sustain_level * ones(1, sustain_samples), ...       % Sustain
        linspace(sustain_level, 0, release_samples) ...     % Release
    ];

    adsr_envelope = adsr_envelope(1:length(t));

    switch Piano.waveform
        case 'piano'
            if FM.active
                % Alla FM-synteesi
                mod = sin(2 * pi * mod_frequency * t);
                y_fm = sin(2 * pi .* frequency .* t + mod_index .* sin(mod .* t));
                
                y = sin(2 * pi .* frequency .* t + mod_index .* sin(mod .* t)) .* exp(-0.0004 .* 2 .* pi .* frequency .* t);
                y = y + sin(2 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 2;
                y = y + sin(3 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 4;
                y = y + sin(5 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 16;
                y = y + sin(6 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 32;

                y = y + y_fm;
                y = y/(max(abs(y)));
            else
                % Alla lisäävä synteesi piano-äänen simuloimiseksi
                y = sin(2 .* pi .* frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t);
                y = y + sin(2 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 2;
                y = y + sin(3 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 4;
                y = y + sin(5 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 16;
                y = y + sin(6 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 32;
                y = y.^3;
                y = fmmod(y,frequency,Fs,1000); % modulaatio
            end
        case 'triangle'
            if FM.active
                % Alla FM-synteesi
                mod = sin(2 * pi * mod_frequency * t);
                y = sawtooth(2 * pi .* frequency .* t + mod_index .* sin(mod .* t), 0.5);
            else
                y = sawtooth(2 * pi * frequency * t, 0.5); % kolmioaalto
            end
        case 'square'
            if FM.active
                % Alla FM-synteesi
                mod = sin(2 * pi * mod_frequency * t);
                y = square(2 * pi .* frequency .* t + mod_index .* sin(mod .* t));
            else
                y = square(2 * pi * frequency * t); % neliöaalto
            end
        case 'sawtooth'
            if FM.active
                % Alla FM-synteesi
                mod = sin(2 * pi * mod_frequency * t);
                y = sawtooth(2 * pi .* frequency .* t + mod_index .* sin(mod .* t));
            else
                y = sawtooth(2 * pi * frequency * t); % saha-aalto
            end
        case 'vibrato'
            vibrato_frequency = 4;         
            vibrato_depth = 0.001;
            vibrato = sin(2 * pi * vibrato_frequency * t) * vibrato_depth;
            a = 2 * pi * frequency * t;
            if FM.active
                % Alla FM-synteesi
                mod = sin(2 * pi * mod_frequency * t);
                y = sin(a + 2 * pi .* frequency .* vibrato + mod_index .* sin(mod .* t));
            else         
                y = sin(a + 2 * pi * frequency* vibrato); 
            end
        case 'sin'
            if FM.active
                % Alla FM-synteesi
                mod = sin(2 * pi * mod_frequency * t);
                y = sin(2 * pi .* frequency .* t + mod_index .* sin(mod .* t));
            else
                y = sin(2 * pi * frequency * t);  
            end
    end

    y = y .* adsr_envelope;

    % Soitetaan ääni
    sound(y, Fs);
end
