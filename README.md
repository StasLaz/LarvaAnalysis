# LarvaAnalysis

MATLAB code for the calcium-imaging analysis in:

> **TODO: manuscript title**
> TODO: authors. *TODO: journal* (year). DOI: TODO

The pipeline takes volumetric two-channel (red / green GCaMP) recordings stored in
`.h5` files, follows individual neurons through time, and extracts their raw
fluorescence signals, together with the stimulus temperature recorded during
imaging.

## Repository layout

```
signal_extraction/
    calcium_imaging_Stan.m             Main script: loads an .h5 recording, builds
                                       max-intensity projections, subtracts background,
                                       and launches the tracking app
    Calcium_Stan_Single_Neuron.mlapp   App Designer GUI: neuron tracking, proofreading
                                       and per-neuron signal extraction
```

The signal-processing step (bleaching correction, normalization, figures) will be
added in a later folder.

## Requirements

- MATLAB (developed with R2025b)
- Image Processing Toolbox (`imwarp`, `imshowpair`, `drawcircle`, `imreconstruct`, `bwpropfilt`, ...)
- Curve Fitting Toolbox (`fit` with `'exp2'`, used for the bleaching fit)
- Parallel Computing Toolbox (optional; `parfor` runs serially without it)

Two calibration files are also needed (paths are set inside `calcium_imaging_Stan.m`):

| File | Contents |
|------|----------|
| `background_100Hz.mat` | Background image of the green channel, subtracted from each frame |
| `warp.mat` | Geometric transform (`tform`) that registers the red channel onto the green channel |

## Input data format

Each recording is one HDF5 file containing:

| Location | Contents |
|----------|----------|
| `/<i>/frame` (i = 0 … T−1) | Volume for time point *i*; as read by MATLAB: Z × H × W × C (channel 1 = red, 2 = green) |
| `/time` | Timestamp of each frame |
| `/temperature1_real`, `/temperature2_real` | Temperature readings (°C) per frame |
| Root attributes `T`, `C`, `W`, `H`, `D` | Number of frames, channels, width, height, depth |
| Root attribute `description` | Free-text description of the experiment |

TODO: where the raw data is deposited (e.g., Zenodo/DANDI DOI).

## Usage

`calcium_imaging_Stan.m` is meant to be run **section by section** (Ctrl+Enter
in the MATLAB editor), not as a whole script.

1. Set the paths in the script to your local copies of the data folder,
   `background_100Hz.mat` and `warp.mat`, and add `signal_extraction/` to the MATLAB path.
2. **Read file**: select an `.h5` recording; the temperature trace is plotted.
3. **Convert h5 into max intensity stack**: z-slices `z_start:z_end` (default
   1–20) are collapsed into a maximum-intensity projection for each channel and time point.
4. **Remove background (MAIN)**: run only this section of the three background
   options. The premade background is scaled to the frame's intensity and subtracted
   from the green channel.
5. **Run proof reading**: the red channel is warped onto the green channel and
   the tracking app opens (red on the left, green on the right).
6. In the app, for each neuron:
   - **Track → Tracking**: drag a circle around the neuron on the red image. The
     neuron is tracked automatically through all frames. Use the slider to
     check the result and click on the image to correct its position on any frame.
     **Track → Search / Treshold / LUT** set the search radius, the detection
     threshold and the display range.
   - **Menu → Plot → Total Intensity GCaMP**: compute the green-channel signal
     inside the ROI for every frame.
   - **Save Signal**: append that trace to the `signals` matrix. Use
     **Reference Signal** instead for a non-responding reference neuron.
7. **Build table / Save plot**: writes `<recording>_data.csv` with columns
   `time`, `temperature1`, `temperature2`, `Reference` and `signals_1…n`, and
   saves the figures.

### How the per-neuron signal is computed

For every frame, the signal is the mean of the brightest 10 % of pixels inside
the circular ROI. For ROIs with fewer than 100 pixels, the brightest 50 % are
used instead (`CalculateIntensity` in the app).

## Citation

If you use this code, please cite the paper above. TODO: Zenodo DOI for this code release.

## License

TODO
