# DICHisto

## Goal

This set of program let to extract quantitatively multiple histology (pigment) staining from gonad nuclei. The set is in 4 distinct steps which can be adapted indpendently according the needs.

Here are the function per step :

- ***RGBCam (Metamorph) :*** let to acquired RGB image from a monochromatic camera installed on an epifluorescence microscope.
- ***Core (Matlab) :*** let extract histology colored staining to a signal *"Fluorescence-like"* . The program let to distinguish double staining (possibly up to three).
- ***INC2.0 : Interactive Nuclear Contour (ImageJ) :*** a set of ImageJ macros that is designed for interactive whiteboard. The experimenter could draw quickly all nuclei of the godad (a second category has been defined for indiscernible nuclei). Then the program quantifies the statistics per image including the area of +/- KTS per nucleus and in the cytoplasms.
- ***CreateStat (Matlab) :*** : summarizing process to regroup results per nucleus and provide statistical results
 
## How to use

For each program, there is a README.md to give specific requirements if any

## references

- DICHisto has been published in ..., ***Paper in submission, TO BE UPDATED***

- The Matlab parts (Step 1 & 4) are using :
  - bfopen and bfsave functions provided by OME-Bioformats (https://www.openmicroscopy.org/bio-formats/)
  - loadtiff from Yoon-Oh Tak. (https://www.mathworks.com/matlabcentral/fileexchange/35684-multipage-tiff-stack)

- Interactive Nuclear Contour is using :
  - ActionBar from J.Mutterer. for details, see: https://imagejdocu.tudor.lu/doku.php?id=plugin:utilities:action_bar:start#installation

- for information contact sebastien.schaub@imev-mer.fr

- This set of program are 

