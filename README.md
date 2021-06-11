# APCSFinalProject
https://docs.google.com/document/d/12vMIEBgRI5vZeqyWZfRLKQuXoBFMkojwSN4oXDotTow/edit?usp=sharing

Compile/Run instructions:
Open Brightroom.pde in APCSFinalProject/Lightroom/Brightroom.
Run the processing file.
Drag the sliders from left to right to increase the magnitude of the specified effect.
Drag with your mouse on the output image preview from one point to another, and press space to crop. Press c to cancel.
Click on any of the 18 buttons to activate them. Presets will apply prespecified effects to the image.

1. Brightroom
2. Jun Kubo
3. My goal for this project is to create a working Lightroom clone. You’ll be able to select a photo and apply adjustments to the image. Lightroom is known for being a nondestructive editing program, meaning that the original image is not altered in any way; the adjustments are stored as a set of instructions that are applied upon export. I intend to copy a lot of the way Lightroom works, including it’s non-destructiveness.

Development Log:
- Created a skeleton of the initial code, based on an earlier classwork where we applied kernels to images.
- Added a slider, successfully tied it to the magnitude of an "emboss" kernel, resulting in the slider controlling how embossed the image is, from a scale of -1 to 1. Likely will be changed to a scale from 0 to 1 for emboss in the future, because -1 embossed looks similar to 1 embossed. The -1 to 1 scale will be useful for other kernels.
- Added brightness, sharpness, saturation, hue, resize, blur, highlights, shadows, and contrast sliders, with toggle buttons.
- Added reset, save, undo, and export control buttons. Added vivid, cinematic, film, and sketch preset buttons.
- Added crop using mouse position on output preview, using space to crop and c to cancel.
