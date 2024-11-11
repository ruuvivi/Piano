function piano

clc;
clear all;
close all;
    global Piano

    % A-nuotin taajuus (Hz) tunnustettu standardi sävelkorkeus
    A = 440;
    
    % Lasketaan nuotteja vastaavat taajuudet
    Piano.note_frequencies = A * 2.^(([-9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2])/12);

    % Näyteenottotaajuus
    Piano.Fs = 44100;
    
    % Nimet koskettimille
    white_key_names = {'C', 'D', 'E', 'F', 'G', 'A', 'B'};
    black_key_names = {'C#', 'D#', 'F#', 'G#', 'A#'};
    
    % Valkoiset koskettimet vastaaviin taajuuksiin
    Piano.white_key_frequencies = [Piano.note_frequencies([1, 3, 5, 6, 8, 10, 12])];
    
    % Mustat koskettimet vastaaviin taajuuksiin
    Piano.black_key_frequencies = [Piano.note_frequencies([2, 4, 7, 9, 11])];
    
    % Luodaan GUI ja määritetään mitä näppäintä koskettaessa mikäkin ääni
    f = figure('Name', 'Piano Syntikka', 'NumberTitle', 'off', ...
        'Position', [300, 300, 800, 400], 'MenuBar', 'none', 'Resize', 'on', ...
        'KeyPressFcn', @key_press);

    % oktaavi alas- ja ylöspainikkeet
    uicontrol('Style', 'pushbutton', 'String', 'Octave Down', ...
              'Position', [5, 5, 100, 30], 'Callback', @octave_down);
    uicontrol('Style', 'pushbutton', 'String', 'Octave Up', ...
              'Position', [110, 5, 100, 30], 'Callback', @octave_up);
    
    % Luodaan valkoiset koskettimet
    for i = 1:length(white_key_names)
        Piano.white_keys(i) = uicontrol('Style', 'pushbutton', 'String', white_key_names{i}, ...
            'Position', [(i-1)*50 + 20, 40, 50, 200], ...
            'BackgroundColor', 'white', ...
            'Callback', @(~,~) play_note(Piano.white_key_frequencies(i), Piano.Fs));
    end
    
    % Paikat mustille koskettimille (valkoisten keskelle)
    black_key_positions = [55, 105, 205, 255, 305];  

    % Luodaan mustat koskettimet
    % Luo mustat koskettimet ja tallenna ne Piano-rakenteeseen
    for i = 1:length(black_key_names)
        Piano.black_keys(i) = uicontrol('Style', 'pushbutton', 'String', black_key_names{i}, ...
            'Position', [black_key_positions(i), 140, 30, 120], ...
            'BackgroundColor', 'black', 'ForegroundColor', 'white', ...
            'Callback', @(~,~) play_note(Piano.black_key_frequencies(i), Piano.Fs));
    end

    % Määritetään näppäimistönäppäimet vastaamaan koskettimia
    Piano.white_key_keyboard = {'a', 's', 'd', 'f', 'g', 'h', 'j'}; % Valkoiset koskettimet
    Piano.black_key_keyboard = {'w', 'e', 't', 'y', 'u'};           % Mustat koskettimet

end

function octave_down(~, ~)
    %Puolittaa jokaisen taajuuden
    global Piano
    Piano.note_frequencies;
    Piano.note_frequencies = 1/2*Piano.note_frequencies;
    update_key_frequencies();
end

function octave_up(~, ~)
    %Tuplaa jokaisen taajuuden
    global Piano
    Piano.note_frequencies;
    Piano.note_frequencies=2*Piano.note_frequencies;
    update_key_frequencies();
end

% Funktio koskettimien taajuuksien päivittämiseen
function update_key_frequencies()
    global Piano
    
    % Päivitetään valkoiset ja mustat kosketintaajuudet
    Piano.white_key_frequencies = Piano.note_frequencies([1, 3, 5, 6, 8, 10, 12]);
    Piano.black_key_frequencies = Piano.note_frequencies([2, 4, 7, 9, 11]);
    
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
        play_note(Piano.white_key_frequencies(white_key_i), Fs);
    end
    
    % Jos painettiin mustaa kosketinta vastaavaa näppäintä
    if ~isempty(black_key_i)
        play_note(Piano.black_key_frequencies(black_key_i), Fs);
    end
end

function play_note(frequency, Fs)

    % Nuotin kesto
    duration = 0.25;
    
    % Aikavektori
    t = 0:1/Fs:duration;

    % Luodaan siniaalto
    y = sin(2 .* pi .* frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t);
    y = y + sin(2 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 2;
    y = y + sin(3 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 4;
    y = y + sin(5 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 16;
    y = y + sin(6 .* 2 .* pi * frequency .* t) .* exp(-0.0004 .* 2 .* pi .* frequency .* t) ./ 32;
    y = y.^3;
    y = fmmod(y,frequency,Fs,1000);
    
    % Soitetaan ääni
    sound(y, Fs);
end