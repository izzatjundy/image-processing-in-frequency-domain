# Image Processing in the Frequency Domain

A MATLAB GUI for exploring frequency-domain image filtering and restoration, developed for IF4073 Digital Image Processing Assignment 2. The app covers Parts B–F: low-pass filtering, high-pass filtering, frequency-domain brightness enhancement, periodic-noise restoration, and motion-blur restoration.

## Requirements

- MATLAB with support for `uifigure` and App Designer UI components. The app was checked with MATLAB R2026a.
- Signal Processing Toolbox or Symbolic Math Toolbox to run Part F, which uses MATLAB's `sinc` function to construct the motion-blur transfer function.
- Image Processing Toolbox is optional. The app uses `imshow` when available and falls back to MATLAB image display functions otherwise.

No third-party packages are required.

## Run the app

1. Open MATLAB and set the Current Folder to the repository root.
2. Run:

   ```matlab
   addpath(genpath('src'));
   app = FrequencyProcessingApp();
   ```

The app also adds the `src` folders to the MATLAB path when it starts. Keep the repository's `data` directory beside `src` so the image dialogs can open the bundled test images by default.

## Using the GUI

### Parts B, C, and D — Frequency Filtering

1. Select **Low-Pass Filtering**, **High-Pass Filtering**, or **Brightness Enhancement**.
2. Select a filter variant and adjust its parameter sliders.
3. Click **Load Image** and choose a test image. The initial folder follows the selected part under `data/`.
4. Click **Run** to display the input, result, input and result spectra, and filter mask.

Available methods:

- **B:** Ideal, Gaussian, and Butterworth low-pass filters.
- **C:** Ideal, Gaussian, and Butterworth high-pass filters.
- **D:** Frequency-domain emphasis for brightness enhancement.

For Part C, the displayed result uses the absolute value of the real inverse-transform response, converted to `uint8` without dynamic rescaling. This shows positive and negative edge responses as bright edges on a black background. The result spectrum is computed from the input spectrum multiplied by the selected high-pass mask.

### Part E — Periodic-Noise Restoration

1. Load a degraded image from `data/E_periodic_noise_restoration/input/`.
2. Inspect the centered log-magnitude spectrum. Use **Inspect Spikes** to review candidate noise peaks, or click the spectrum to inspect coordinates.
3. Select an Ideal, Gaussian, or Butterworth bandreject filter, or choose notch reject and manage its notch points.
4. Adjust the parameters and click **Run**. The app displays the before/after spectra, mask, and restored image.

### Part F — Motion-Blur Restoration

1. Load a degraded image from `data/F_motion_blur_restoration/input/`. Optionally load its reference image.
2. Set the motion parameters (length, angle, and exposure time). Length and angle update the corresponding motion components.
3. Set the inverse-filter radius cutoff and Wiener K (NSR), then click **Run**.
4. Review the degradation transfer function/PSF and both inverse-filter and Wiener results.

The motion parameters for the bundled images are listed in [data/F_motion_blur_restoration/README.md](data/F_motion_blur_restoration/README.md).

### Exporting a view

Click **Export View** on the active tab, choose an output folder, and the app saves a PNG snapshot of the GUI.

## Repository layout

```text
data/
  B_smoothing_blurring_frequency/
  C_high_pass_filtering_frequency/
  D_brightness_frequency/
  E_periodic_noise_restoration/
  F_motion_blur_restoration/
src/
  FrequencyProcessingApp.m
  b/       Part B low-pass filters
  c/       Part C high-pass filters
  d/       Part D brightness filter
  e/       Part E bandreject and notch-reject filters
  f/       Part F motion-blur model and restorers
  core/    Shared frequency processing, registries, and display helpers
ngetes/    Assignment PDFs and local development artifacts
```

## Implementation notes

The filter masks and restoration methods are implemented in the project source. The app uses centered frequency grids, applies the selected transfer function to the shifted Fourier spectrum, then uses the inverse Fourier transform to produce the spatial result. Color images are processed channel by channel.

The GUI loads one selected image at a time. For assignment testing, select and run every image in the corresponding `data/<part>/input/` folder. Compare against the provided `reference/` images where available; Part C's supplied data has no reference folder.
