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
        'KeyPressFcn', @key_press, ...
        'Color', [0.1, 0.1, 0.1]);

    fontName = 'Arial';
    fontSize = 10;
    fontWeight = 'bold';
    
    % Nuotin pituuden säädin ja painike (lyhyin = 1/16 piano nuotti, pisin = 1)
    length_values = [0.0625, 0.125, 0.25, 0.5, 0.75, 0.875, 0.9375, 1];
    length_labels = {'1/16', '1/8', '1/4', '1/2', '3/4', '7/8', '15/16', '1'};

    uicontrol('Style', 'text', 'String', 'Note length:', ...
          'Position', [270, 330, 100, 20], ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    uicontrol('Style', 'text', 'String', 's', ...
          'Position', [380, 330, 100, 20], ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    Piano.dur_length = uicontrol('Style', 'popupmenu', ...
    'String', length_labels, ...
    'Value', 4, ... % aloitus on vakio pituus 0.5 (4. arvo)
    'Position', [370, 330, 50, 20], ...
    'Callback', @(src, ~) update_duration(src, length_values));

    
    % nappuloita eri äniaalloille

    bg = uibuttongroup('Title', 'Waveform Select', ...
                      'Position', [0.05, 0.83, 0.5, 0.15], ...  
                   'BackgroundColor', 'black', 'TitlePosition', 'centertop', ...
                   'ForegroundColor', 'white'); 
    
    % piano
    uicontrol(bg, 'Style', 'radiobutton', 'String', 'Piano', ...
              'Position', [10, 40, 100, 30], 'Callback', @(~,~) set_waveform('piano'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % kolmioaalto
    uicontrol(bg, 'Style', 'radiobutton', 'String', 'Triangle', ...
              'Position', [115, 40, 100, 30], 'Callback', @(~,~) set_waveform('triangle'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % neliöaalto
    uicontrol(bg, 'Style', 'radiobutton', 'String', 'Square', ...
              'Position', [220, 40, 100, 30], 'Callback', @(~,~) set_waveform('square'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % saha-aalto
    uicontrol(bg, 'Style', 'radiobutton', 'String', 'Sawtooth', ...
              'Position', [325, 40, 100, 30], 'Callback', @(~,~) set_waveform('sawtooth'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % vibrato
    uicontrol(bg, 'Style', 'radiobutton', 'String', 'Vibrato', ...
              'Position', [430, 40, 100, 30], 'Callback', @(~,~) set_waveform('vibrato'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % siniaalto
    uicontrol(bg, 'Style', 'radiobutton', 'String', 'Sine', ...
              'Position', [535, 40, 100, 30], 'Callback',  @(~,~) set_waveform('sin'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
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

    
   bg1 = uibuttongroup('Title', 'FM Synthesis', ...
                      'Position', [0.05, 0.7, 0.1, 0.1], ...  
                    'BackgroundColor', 'black', 'TitlePosition', 'centertop', ...
                    'ForegroundColor', 'white');

    % FM-synteesi OFF nappula
    Piano.fm_off_button = uicontrol(bg1, 'Style', 'radiobutton', 'String', 'OFF', ...
            'Position', [70, 15, 50, 30], ...  
            'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
            'Value', ~FM.active, ...
            'Callback', @(~,~) resetFM(Piano.mod_slider, Piano.freq_slider), ...
            'BackgroundColor', 'black', 'ForegroundColor', 'white');
    
    % FM-synteesi ON nappula
    Piano.fm_on_button = uicontrol(bg1, 'Style', 'radiobutton', 'String', 'ON', ...
        'Position', [10, 15, 50, 30], ... 
        'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
        'Value', FM.active, ... 
        'Callback', @(src, ~) onFM(), ...  
        'BackgroundColor', 'black', 'ForegroundColor', 'white');

    % oktaavi alas- ja ylöspainikkeet

    uicontrol('Style', 'pushbutton', 'String', 'octave down', ...
              'Position', [80, 330, 100, 30], 'Callback', @octave_down, ...
              'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight);

    uicontrol('Style', 'pushbutton', 'String', 'octave up', ...
              'Position', [80, 370, 100, 30], 'Callback', @octave_up, ...
              'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight);
    
    % Luodaan valkoiset koskettimet
    for i = 1:length(white_key_names)
    Piano.white_keys(i) = uicontrol('Style', 'pushbutton', 'String', white_key_names{i}, ...
        'Position', [(i-1)*50 + 20, 40, 50, 200], ...
        'BackgroundColor', 'white', ...
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
            'BackgroundColor', 'black', 'ForegroundColor', 'white', ...
            'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
            'Callback', @(~,~) play_note(Piano.black_key_frequencies(i), Piano.Fs));
    end

    % Määritetään näppäimistönäppäimet vastaamaan koskettimia
    Piano.white_key_keyboard = {'a', 's', 'd', 'f', 'g', 'h', 'j'};
    Piano.black_key_keyboard = {'q','w', 'e', 'r', 't'};

    piano_synth_gui()

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
    
    % Tarkistetaan, onko näppäin valkoinen tai musta kosketin
    white_key_i = find(strcmp(Piano.white_key_keyboard, key), 1);
    black_key_i = find(strcmp(Piano.black_key_keyboard, key), 1);
    
    % Jos painettiin valkoista kosketinta vastaavaa näppäintä
    if ~isempty(white_key_i)
        play_note(Piano.white_key_frequencies(white_key_i), Piano.Fs);
    end
    
    % Jos painettiin mustaa kosketinta vastaavaa näppäintä
    if ~isempty(black_key_i)
        play_note(Piano.black_key_frequencies(black_key_i), Piano.Fs);
    end
end

% Funktio: ADSR säätimet ja GUI
function piano_synth_gui()
global Piano
global ADSR

    % ADSR plotin pohja
    axADSR = axes('Parent', Piano.f, 'Position', [0.4, 0.55, 0.4, 0.2]); 
    title(axADSR, 'ADSR Envelope');
    xlabel(axADSR, 'Time');
    ylabel(axADSR, 'Amplitude');
    grid(axADSR, 'on');
    
    % ADSR alkuarvot
    ADSR.attack = 0.1;
    ADSR.decay = 0.2;
    ADSR.sustain = 0.7;
    ADSR.release = 0.5;
    
    % Attack säädin
    uicontrol('Style', 'text', 'String', 'Attack:', ...
              'Position', [275, 520, 50, 20], ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    
    Piano.attack_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.attack, 'Position', [350, 520, 100, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ... 
              'Callback', @(src, ~) update_adsr('attack', src.Value));
    
    % Decay säädin
    uicontrol('Style', 'text', 'String', 'Decay:', ...
              'Position', [275, 480, 50, 20], ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    
    Piano.decay_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.decay, 'Position', [350, 480, 100, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ... 
              'Callback', @(src, ~) update_adsr('decay', src.Value));
    
    % Sustain säädin
    uicontrol('Style', 'text', 'String', 'Sustain:', ...
              'Position', [275, 440, 60, 20], ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    
    Piano.sustain_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, ...
              'Value', ADSR.sustain, 'Position', [350, 440, 100, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ...  
              'Callback', @(src, ~) update_adsr('sustain', src.Value));
    
    % Release säädin
    uicontrol('Style', 'text', 'String', 'Release:', ...
              'Position', [275, 400, 60, 20], ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
          'BackgroundColor', [0.1, 0.1, 0.1], 'ForegroundColor', 'white');
    
    Piano.release_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.release, 'Position', [350, 400, 100, 20], ...
              'BackgroundColor', [0.1, 0.5, 0.9], ... 
              'Callback', @(src, ~) update_adsr('release', src.Value));

% Funktio: ADSR päivitys ja kuvaaja
function update_adsr(param, value)
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
    y(t_d) = 1 - (t(t_d) - ADSR.attack) / ADSR.decay; 
    y(t_s) = ADSR.sustain; 
    y(t_r) = ADSR.sustain * (1 - (t(t_r) - (ADSR.attack + ADSR.decay + ADSR.sustain)) / ADSR.release); % Release phase

    % piirretään ADSR-kuvaaja
    plot(axADSR, t, y, 'LineWidth', 2);
    xlabel(axADSR, 'Time', 'Color', 'white'); 
    ylabel(axADSR, 'Amplitude', 'Color', 'white');
    title(axADSR, 'ADSR Envelope', 'Color', 'white'); 
    grid(axADSR, 'on');
    axADSR.XColor = 'white'; 
    axADSR.YColor = 'white'; 
    axADSR.Color = 'black'; 
end 

% Alustetaan ADSR oletusarvot
update_adsr('', 0);

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
