function piano

clc;
clear all;
close all;

    % A-nuotin taajuus (Hz) tunnustettu standardi sävelkorkeus
    A = 440;
    
    % Lasketaan nuotteja vastaavat taajuudet
    note_frequencies = A * 2.^(([-9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2])/12);

    % Näyteenottotaajuus
    Fs = 44100;
    
    % Nimet koskettimille
    white_key_names = {'C', 'D', 'E', 'F', 'G', 'A', 'B'};
    black_key_names = {'C#', 'D#', 'F#', 'G#', 'A#'};
    
    % Valkoiset koskettimet vastaaviin taajuuksiin
    white_key_frequencies = [note_frequencies([1, 3, 5, 6, 8, 10, 12])];
    
    % Mustat koskettimet vastaaviin taajuuksiin
    black_key_frequencies = [note_frequencies([2, 4, 7, 9, 11])];
    
    % Valkoisten koskettimien mitat
    white_key_width = 50;
    white_key_height = 200;

    % Mustien koskettimien mitat
    black_key_width = 30;
    black_key_height = 120;
    
    % Luodaan GUI ja määritetään mitä näppäintä koskettaessa mikäkin ääni
    f = figure('Name', 'Piano Syntikka', 'NumberTitle', 'off', ...
        'Position', [300, 300, 800, 400], 'MenuBar', 'none', 'Resize', 'on', ...
        'KeyPressFcn', @key_press);
    
    % Luodaan valkoiset koskettimet
    for i = 1:length(white_key_names)
        uicontrol('Style', 'pushbutton', 'String', white_key_names{i}, ...
            'Position', [(i-1)*white_key_width + 20, 40, white_key_width, white_key_height], ...
            'BackgroundColor', 'black', 'Callback', @(~,~) play_note(white_key_frequencies(i), Fs));
    end
    
    % Paikat mustille koskettimille (valkoisten keskelle)
    black_key_positions = [55, 105, 205, 255, 305];  

    % Luodaan mustat koskettimet
    for i = 1:length(black_key_names)
        uicontrol('Style', 'pushbutton', 'String', black_key_names{i}, ...
            'Position', [black_key_positions(i), 140, black_key_width, black_key_height], ...
            'BackgroundColor', 'white', 'ForegroundColor', 'white', ...
            'Callback', @(~,~) play_note(black_key_frequencies(i), Fs));
    end

    % Määritetään näppäimistönäppäimet vastaamaan koskettimia
    white_key_keyboard = {'a', 's', 'd', 'f', 'g', 'h', 'j'}; % Valkoiset koskettimet
    black_key_keyboard = {'w', 'e', 't', 'y', 'u'};           % Mustat koskettimet

    % Funktio: mitä näppäintä koskettaessa mikäkin ääni
    function key_press(~, event)
        % Tarkista, mikä näppäin on painettu
        key = event.Key;
        
        % Tarkistetaan, onko näppäin valkoinen tai musta kosketin
        white_key_i = find(strcmp(white_key_keyboard, key), 1); % compare string
        black_key_i = find(strcmp(black_key_keyboard, key), 1);
        
        % Jos painettiin valkoista kosketinta vastaavaa näppäintä
        if ~isempty(white_key_i)
            play_note(white_key_frequencies(white_key_i), Fs);
        end
        
        % Jos painettiin mustaa kosketinta vastaavaa näppäintä
        if ~isempty(black_key_i)
            play_note(black_key_frequencies(black_key_i), Fs);
        end
    end
end

function play_note(frequency, Fs)

    % Nuotin kesto
    duration = 0.25;
    
    % Aikavektori
    t = 0:1/Fs:duration;

    % Luodaan siniaalto
    y = 0.5 * sin(2 * pi * frequency * t);
    
    % Soitetaan ääni
    sound(y, Fs);

    function octave_down
%Puolittaa jokaisen taajuuden
note_frequencies=1/2*note_frequencies;
end

function octave_up
%Tuplaa jokaisen taajuuden
note_frequencies=2*note_frequencies;
end
