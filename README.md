# MATLAB Piano Synthesizer

A MATLAB-based piano synthesizer that leverages digital signal processing to simulate the characteristics of an acoustic piano. This synthesizer supports a variety of waveform synthesis and modulation techniques, including an ADSR envelope generator and FM synthesis. The system includes a graphical user interface (GUI) for intuitive interaction. This project is made for Aalto University's Sound and Speech processing course.

## Features

### Sound Synthesis
The piano synthesizer generates sound waves, controls their spectrum, and applies dynamic modifications to create rich audio output. It employs mathematical functions to model natural acoustic phenomena, such as the hammer striking the piano strings and the strings' vibrations.

### Core Components
1. **Waveform Synthesis**: 
   - Produces sound directly from predefined waveforms. 
   - Includes sine, square, triangle, sawtooth, and vibrato-modulated waveforms.

2. **ADSR Envelope Generator**:
   - Controls the sound's temporal behavior.
   - Enables user customization via an intuitive graphical representation.

3. **Frequency Modulation (FM) Synthesis**:
   - Alters the sound spectrum using a modulating waveform.
   - Adds complexity to the sound by modulating the frequency of the carrier wave with another signal.

4. **Additive Synthesis**:
   - Realistically simulates acoustic piano sounds.
   - Constructs complex tones by combining multiple harmonic components scaled according to piano's harmonic spectrum and dynamics.

### GUI Features
- **Three Octaves**: 
  - The GUI includes three hard-coded octaves for enhanced visual appeal and usability.
  - Users can play the middle octave using specific keys on the computer keyboard.
- **Octave Adjustment**: 
  - Includes control for shifting octaves up or down.
- **Note length Adjustment**: 
  - Includes control for setting the note length in seconds.
- **Reset Button**: 
  - Resets all user inputs and settings to their default state during the program's execution.

### Key Features
- **Waveforms**: Sine, square, triangle, sawtooth, and vibrato modulation.
- **Additive Synthesis**:
  - Simulates piano sounds using harmonics.
  - Constructs waveforms by summing multiple harmonic frequencies.
- **FM Synthesis**:
  - Enhances sound richness with frequency modulation.
  - Implements MATLAB’s `fmod` function for advanced synthesis.

### ADSR Envelope
Simulates the natural decay and dynamics of piano sound, mimicking the interaction between the hammer and strings:
- **Attack**: Time to reach peak amplitude.
- **Decay**: Time to decrease from peak to sustain level.
- **Sustain**: Level maintained until the key is released.
- **Release**: Time for the sound to fade after the key is released.

## How It Works
1. **Waveform Creation**:
   - Generates basic waveforms mathematically and with MATLAB's ready functions.
2. **Additive Synthesis**:
   - Combines harmonic components to simulate complex sounds.
3. **ADSR Envelope**:
   - Applies dynamic shaping to all waveforms, enhancing their tonal richness.
4. **FM Synthesis**:
   - Modifies carrier wave frequency using a modulator signal.

## Installation
1. Clone the repository or download the source code.
2. Open the project in MATLAB 2024a or later.
3. Run the main script to launch the GUI.

## Usage
1. Select a waveform from the GUI.
2. Adjust the ADSR envelope parameters.
3. Enable FM synthesis and configure modulation settings.
4. Use the octave shift controls to explore different tonal ranges.
5. Play notes using the GUI or the middle octave keyboard mapping.
6. Reset settings to defaults using the reset button.
7. Enjoy high-quality synthesized piano sounds.
