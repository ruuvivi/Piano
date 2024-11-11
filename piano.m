function piano

    clc;
    clear all;
    close all;
    global Piano

    % A-nuotin taajuus (Hz) tunnustettu standardi sävelkorkeus
    A = 440;
    
    % Lasketaan nuotteja vastaavat taajuudet kahdelle oktaaville
    Piano.note_frequencies = A * 2.^(([-21:2])/12); % Kaksi oktaavia

    % Näyteenottotaajuus
    Piano.Fs = 44100;
    
    % Nimet koskettimille
    white_key_names = {'C / a', 'D', 'E', 'F', 'G', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'A', 'B'};
    black_key_names = {'C# / q', 'D#', 'F#', 'G#', 'A#', 'C#', 'D#', 'F#', 'G#', 'A#'};
    
    
    % Valkoiset koskettimet vastaaviin taajuuksiin
    Piano.white_key_frequencies = Piano.note_frequencies([1, 3, 5, 6, 8, 10, 12, 13, 15, 17, 18, 20, 22, 24]);
    
    % Mustat koskettimet vastaaviin taajuuksiin
    Piano.black_key_frequencies = Piano.note_frequencies([2, 4, 7, 9, 11, 14, 16, 19, 21, 23]);
    
    % Luodaan GUI ja määritetään mitä näppäintä koskettaessa mikäkin ääni
    f = figure('Name', 'Piano Syntikka', 'NumberTitle', 'off', ...
        'Position', [300, 300, 750, 400], 'MenuBar', 'none', 'Resize', 'on', ...
        'KeyPressFcn', @key_press, ...
        'Color', [1, 0.7, 0.8]);

    fontName = 'Harlow Solid Italic';
    fontSize = 10;
    fontWeight = 'normal';

    % oktaavi alas- ja ylöspainikkeet
    uicontrol('Style', 'pushbutton', 'String', 'Octave Down', ...
              'Position', [10, 280, 100, 30], 'Callback', @octave_down, ...
              'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight);

    uicontrol('Style', 'pushbutton', 'String', 'Octave Up', ...
              'Position', [115, 280, 100, 30], 'Callback', @octave_up, ...
              'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight);

    % Vibrato ääniaalto
    uicontrol('Style', 'pushbutton', 'String', 'Vibrato', ...
              'Position', [10, 320, 100, 30], 'Callback', @vibrato, ...
              'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight);
    
    % Normaali ääniaalto
    uicontrol('Style', 'pushbutton', 'String', 'Normal', ...
              'Position', [115, 320, 100, 30], 'Callback', @normal, ...
              'FontName', fontName, 'FontSize', fontSize, 'FontWeight', fontWeight);
    
    % Luodaan valkoiset koskettimet
    for i = 1:length(white_key_names)
        Piano.white_keys(i) = uicontrol('Style', 'pushbutton', 'String', white_key_names{i}, ...
            'Position', [(i-1)*50 + 20, 40, 50, 200], ...
            'BackgroundColor', 'white', ...
            'Callback', @(~,~) play_note(Piano.white_key_frequencies(i), Piano.Fs));
    end
    
    % Paikat mustille koskettimille (valkoisten keskelle)
    black_key_positions = [55, 105, 205, 255, 305, 405, 455, 555, 605, 655];  

    % Luodaan mustat koskettimet ja tallennetaan ne Piano-rakenteeseen
    for i = 1:length(black_key_names)
        Piano.black_keys(i) = uicontrol('Style', 'pushbutton', 'String', black_key_names{i}, ...
            'Position', [black_key_positions(i), 140, 30, 120], ...
            'BackgroundColor', 'black', 'ForegroundColor', 'white', ...
            'Callback', @(~,~) play_note(Piano.black_key_frequencies(i), Piano.Fs));
    end

    % Määritetään näppäimistönäppäimet vastaamaan koskettimia
    Piano.white_key_keyboard = {'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '''', 'z', 'x', 'c'};
    Piano.black_key_keyboard = {'q','w', 'e', 'r', 't', 'y', 'u','i' 'o', 'p'};

end

function octave_down(~, ~)
    %Puolittaa jokaisen taajuuden
    global Piano
    Piano.note_frequencies;
    Piano.note_frequencies = 1/2 * Piano.note_frequencies;
    update_keys();
end

function octave_up(~, ~)
    %Tuplaa jokaisen taajuuden
    global Piano
    Piano.note_frequencies;
    Piano.note_frequencies = 2 * Piano.note_frequencies;
    update_keys();
end

function vibrato(~, ~)
    global Piano
    Piano.note_frequencies;
    Piano.note_frequencies = sin(Piano.note_frequencies()*sin((2*pi*4)*0.001));
    update_keys();
end

function normal(~, ~)
    global Piano
    Piano.note_frequencies;
    A = 440;
    Piano.note_frequencies = A * 2.^(([-21:2])/12); % Kaksi oktaavia
    update_keys();
end

% Funktio koskettimien taajuuksien päivittämiseen
function update_keys()
    global Piano
    
    % Päivitetään valkoiset ja mustat kosketintaajuudet
    Piano.white_key_frequencies = Piano.note_frequencies([1, 3, 5, 6, 8, 10, 12, 13, 15, 17, 18, 20, 22, 24]);
    Piano.black_key_frequencies = Piano.note_frequencies([2, 4, 7, 9, 11, 14, 16, 19, 21, 23]);
    
    % Asetetaan päivitetyt taajuudet valkoisille koskettimille
    for i = 1:length(Piano.white_keys)
        set(Piano.white_keys(i), 'Callback', @(~,~) play_note(Piano.white_key_frequencies(i), Piano.Fs));
    end

    % Asetetaan päivitetyt taajuudet mustille koskettimille
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
    white_key_i = find(strcmp(Piano.white_key_keyboard, key), 1); % compare string
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

    % Nuotin kesto
    duration = 0.5;
    
    % Aikavektori
    t = 0:1/Fs:duration;

    % Luodaan siniaalto (1. versio)
    %y = sin(2 .* pi .* frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t);
    %y = y + sin(2 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 2;
    %y = y + sin(3 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 4;
    %y = y + sin(5 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 16;
    %y = y + sin(6 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 32;
    %y = y.^3;
    %y = fmmod(y,frequency,Fs,1000);

    % FM-synteesi: taajuusmoduloitu signaali: kokeilu 1 ------->

    % Modulaattori- ja kantataajuus (vasaraääni)
    modulator_freq = 200; % Korkea taajuus nopeaa vaimenemista varten
    modulation_index = 2.5;

    modulator = sin(2 * pi * modulator_freq * t);
    y = sin(2 * pi * frequency * t + modulation_index * modulator);

    % Eksponentiaalinen vaimeneminen, joka simuloi vasaran ääntä
    envelope = exp(-4 * t);
    y = y .* envelope;
    
    % FM-synteesi: taajuusmoduloitu signaali: kokeilu 2 (kokeiltu yhdistää
    % 1. versioon) ------->
    %modulator = sin(2 * pi * modulator_freq * t).* exp(-0.0004 .* 2 .* pi .* modulator_freq .* t);
    %y = modulator + sin(2 .* 2 .* pi * modulator_freq .* t) .* exp(-0.0004 .* 2 .* pi .* modulator_freq .* t) ./ 2;
    %y = y + sin(3 .* 2 .* pi * modulator_freq .* t) .* exp(-0.0004 .* 2 .* pi .* modulator_freq .* t) ./ 4;
    %y = y + sin(5 .* 2 .* pi * modulator_freq .* t) .* exp(-0.0004 .* 2 .* pi .* modulator_freq .* t) ./ 16;
    %y = y + sin(6 .* 2 .* pi * modulator_freq .* t) .* exp(-0.0004 .* 2 .* pi .* modulator_freq .* t) ./ 32;
    %y = y.^3;
    %y = sin(2 * pi * frequency * t + modulation_index * modulator);

    % Eksponentiaalinen vaimeneminen - simuloi vasaran ääntä
    %envelope = exp(-4 * t);
    %y = y .* envelope;

    % Soitetaan ääni
    sound(y, Fs);
end

