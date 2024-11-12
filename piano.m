function piano

    clc;
    clear all;
    close all;
    global Piano
    
    Piano.waveform = 'sine';

    % A-nuotin taajuus (Hz) tunnustettu standardi sävelkorkeus
    A = 440;
    ToneId = -9:2;
    Piano.Sample = cell(size(ToneId));
    
    % Lasketaan nuotteja vastaavat taajuudet kahdelle oktaaville
    Piano.note_frequencies = A * 2.^(ToneId/12); % Kaksi oktaavia

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
    global Piano
    % Nuotin kesto
    duration = 0.5;
    
    % Aikavektori
    t = 0:1/Fs:duration;

    switch Piano.waveform
        case 'sine'
            % Luodaan siniaalto, FM-synteesi, taajuusmodulaatio
            y = sin(2 .* pi .* frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t);
            y = y + sin(2 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 2;
            y = y + sin(3 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 4;
            y = y + sin(5 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 16;
            y = y + sin(6 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 32;
            y = y.^3;
            y = fmmod(y,frequency,Fs,1000); % modulaatio
        case 'triangle'
            y = sawtooth(2 * pi * frequency * t, 0.5); % Triangle wave
        case 'square'
            y = square(2 * pi * frequency * t); % Square wave
        case 'sawtooth'
            y = sawtooth(2 * pi * frequency * t); % Sawtooth wave
    end
    
    % Eksponentiaalinen vaimeneminen, joka simuloi vasaran ääntä
    envelope = exp(-4 * t);
    y = y .* envelope;

    % Soitetaan ääni
    sound(y, Fs);
end


