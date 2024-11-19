function piano

    clc;
    clear all;
    close all;
    global Piano
    
    Piano.waveform = 'sine';

    % ADSR parameterit
    global ADSR
    ADSR.attack = 0.1;   % vakio attack aika
    ADSR.decay = 0.1;    % vakio decay aika
    ADSR.sustain = 0.7;  % vakio sustain taso
    ADSR.release = 0.2;  % vakio release aika

    global FM
    FM.mod_index = 10; % vakio mod indeksi

    % A-nuotin taajuus (Hz) tunnustettu standardi sävelkorkeus
    A = 440;
    ToneId = -9:2;
    Piano.Sample = cell(size(ToneId));
    
    % Lasketaan nuotteja vastaavat taajuudet
    Piano.note_frequencies = A * 2.^(ToneId/12);

    % Näyteenottotaajuus
    Piano.Fs = 44100;
    
    % Nimet koskettimille
    white_key_names = {'C', 'D', 'E', 'F', 'G', 'A', 'B'};
    black_key_names = {'C#', 'D#', 'F#', 'G#', 'A#'};
    
    
    % Valkoiset koskettimet vastaaviin taajuuksiin
    Piano.white_key_frequencies = Piano.note_frequencies([1, 3, 5, 6, 8, 10, 12]);
    
    % Mustat koskettimet vastaaviin taajuuksiin
    Piano.black_key_frequencies = Piano.note_frequencies([2, 4, 7, 9, 11]);
    
    % Luodaan GUI ja määritetään mitä näppäintä koskettaessa mikäkin ääni
    f = figure('Name', 'Piano Syntikka', 'NumberTitle', 'off', ...
        'Position', [300, 300, 750, 400], 'MenuBar', 'none', 'Resize', 'on', ...
        'KeyPressFcn', @key_press, ...
        'Color', [0, 0.3, 0]);

    fontName = 'Matura MT Script Capitals';
    fontSize = 12;
    fontWeight = 'normal';

    % FM-mod indeksille painike
    uicontrol('Style', 'text', 'String', 'Mod:', ...
              'Position', [500, 240, 50, 20], 'BackgroundColor', 'white');
    Piano.mod_slider = uicontrol('Style', 'slider', 'Min', 1, 'Max', 20, ...
              'Value', FM.mod_index, 'Position', [600, 240, 100, 20], ...
              'Callback', @(src, ~) update_mod_index('mod', src.Value));

    % ADSR-painikkeet
    uicontrol('Style', 'text', 'String', 'Attack:', ...
              'Position', [500, 200, 50, 20], 'BackgroundColor', 'white');
    Piano.attack_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.attack, 'Position', [600, 200, 100, 20], ...
              'Callback', @(src, ~) update_adsr('attack', src.Value));
    
    uicontrol('Style', 'text', 'String', 'Decay:', ...
              'Position', [500, 160, 50, 20], 'BackgroundColor', 'white');
    Piano.decay_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.decay, 'Position', [600, 160, 100, 20], ...
              'Callback', @(src, ~) update_adsr('decay', src.Value));
    
    uicontrol('Style', 'text', 'String', 'Sustain:', ...
              'Position', [500, 120, 50, 20], 'BackgroundColor', 'white');
    Piano.sustain_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 1, ...
              'Value', ADSR.sustain, 'Position', [600, 120, 100, 20], ...
              'Callback', @(src, ~) update_adsr('sustain', src.Value));
    
    uicontrol('Style', 'text', 'String', 'Release:', ...
              'Position', [500, 80, 50, 20], 'BackgroundColor', 'white');
    Piano.release_slider = uicontrol('Style', 'slider', 'Min', 0.01, 'Max', 1, ...
              'Value', ADSR.release, 'Position', [600, 80, 100, 20], ...
              'Callback', @(src, ~) update_adsr('release', src.Value));

    % oktaavi alas- ja ylöspainikkeet
    uicontrol('Style', 'pushbutton', 'String', 'octave down', ...
              'Position', [10, 280, 100, 30], 'Callback', @octave_down, ...
              'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight);

    uicontrol('Style', 'pushbutton', 'String', 'octave up', ...
              'Position', [115, 280, 100, 30], 'Callback', @octave_up, ...
              'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight);
    
    % nappuloita eri äniaalloille

    % Normaali Piano
    uicontrol('Style', 'pushbutton', 'String', 'Piano', ...
              'Position', [10, 360, 100, 30], 'Callback', @(~,~) set_waveform('sine'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');
    
    % kolmioaalto
    uicontrol('Style', 'pushbutton', 'String', 'Triangle Wave', ...
              'Position', [115, 360, 100, 30], 'Callback', @(~,~) set_waveform('triangle'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');
    
    % neliöaalto
    uicontrol('Style', 'pushbutton', 'String', 'Square Wave', ...
              'Position', [220, 360, 100, 30], 'Callback', @(~,~) set_waveform('square'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');

     % vibrato
    uicontrol('Style', 'pushbutton', 'String', 'Vibrato', ...
              'Position', [325, 360, 100, 30], 'Callback', @(~,~) set_waveform('vibrato'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');

    % fm-synteesi
    uicontrol('Style', 'pushbutton', 'String', 'FM-synthesis', ...
              'Position', [430, 360, 100, 30], 'Callback', @(~,~) set_waveform('fm'), ...
              'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Luodaan valkoiset koskettimet
    for i = 1:length(white_key_names)
        Piano.white_keys(i) = uicontrol('Style', 'pushbutton', 'String', white_key_names{i}, ...
            'Position', [(i-1)*50 + 20, 40, 50, 200], ...
            'BackgroundColor', 'white', ...
            'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold', ...
            'Callback', @(~,~) play_note(Piano.white_key_frequencies(i), Piano.Fs));
    end
    
    % Paikat mustille koskettimille (valkoisten keskelle)
    black_key_positions = [55, 105, 205, 255, 305];  

    % Luodaan mustat koskettimet ja tallennetaan ne Piano-rakenteeseen
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

function update_adsr(parameter, value)
    global ADSR
    switch parameter
        case 'attack'
            ADSR.attack = value;
        case 'decay'
            ADSR.decay = value;
        case 'sustain'
            ADSR.sustain = value;
        case 'release'
            ADSR.release = value;
    end
end

function update_mod_index(parameter, value)
    global FM
    switch parameter
        case 'mod'
            FM.mod_index = value;
    end
end

% Funktio koskettimien taajuuksien päivittämiseen
function update_keys()
    global Piano
    
    % Päivitetään valkoiset ja mustat kosketintaajuudet
    Piano.white_key_frequencies = Piano.note_frequencies([1, 3, 5, 6, 8, 10, 12]);
    Piano.black_key_frequencies = Piano.note_frequencies([2, 4, 7, 9, 11]);
    
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

    % Nuotin kesto
    duration = 0.5;
    
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


    % Vibrato säädöt
    vibrato_frequency = 4;         
    vibrato_depth = 0.001;         

    vibrato = sin(2 * pi * vibrato_frequency * t) * vibrato_depth;
    a = 2 * pi * frequency * t;

    envelope = exp(-4 * t); % exponentiaalinen vaimenenminen jäljittämään pianon ääntä

    switch Piano.waveform
        case 'sine'
            % Alla additiivinen synteesi piano-äänen simuloimiseksi
            % Luodaan siniaalto, FM-synteesi, taajuusmodulaatio
            y = sin(2 .* pi .* frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t);
            y = y + sin(2 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 2;
            y = y + sin(3 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 4;
            y = y + sin(5 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 16;
            y = y + sin(6 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 32;
            y = y.^3;
            y = fmmod(y,frequency,Fs,1000); % modulaatio
            y = y .* envelope;
        case 'triangle'
            y = sawtooth(2 * pi * frequency * t); % Triangle wave
        case 'square'
            y = square(2 * pi * frequency * t); % Square wave
        case 'sawtooth'
            y = sawtooth(2 * pi * frequency * t); % Sawtooth wave
        case 'vibrato'
            y = sin(a + 2 * pi * frequency * vibrato);
        case 'fm'
            % Alla FM-synteesi
            mod_freq = frequency; % Modulaattoritaajuus
            %mod_freq:
            % Pienet arvot (esim. 10–50 Hz) tuottavat hitaampaa muuntelua ja pulssimaisia efektiä
            %Suuret arvot (100–300 Hz) lisäävät rikkaampia harmonisia
            %komponentteja sekä "metallisia ääniä"

            % Modulaatioindeksi = kuinka voimakkaasti modulaattori vaikuttaa
            % pienet arvot = hienovaraista muuntelua esim 2
            % suuret arvot = monimutkaisempia ja aggressiivisempia ääniä
            % esim 10
            % Modulaattorioskillaatio
            mod = sin(2 * pi * mod_freq * t);
        
            % FM-synteesi: hetkellinen taajuus jota ohjaa modulaattori
            %inst_phase = sin(2 * pi * frequency * t + mod_index * mod);
            inst_phase = sin(2 * pi .* mod_index .* mod .* t);
            
            y = inst_phase .* envelope;

    end

    y = y .* adsr_envelope;

    % Soitetaan ääni
    sound(y, Fs);
end