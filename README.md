# DICHisto

## Goal

The program helps to adapt white balance between images to get homogeneous gallery. It uses the ActionBar from J.Mutterer 

## How to use

For simplicity the program and icon images are incorporated in the directory of ImageJ. Unzip the file and copy them in the Fiji folder. No file will be overwritten except action_bar_jar if you already have.

Then run the program in [Home Directory]\macros\MICA\PlancheHisto.ijm.

## How to use:
the file *PlancheHisto Manual.pdf* gives more details how to use

### Shortcuts :
<li>[1] : Open. Open an image, if necessary, convert in 3 composite channels</li>
<li>[2] : Reset. Reset each channel to max intensity</li>
<li>[3] : Copy. Copy the relative intensity of (modal/mean) in the range of min& max contrast. if no selection it get the modal gray, if selection it get the mean gray value</li>
<li>[4] : WhitBal. Get the white balance of the relative intensity of (modal/mean) to get each channel at 80% (OptimLum can be adapted) of white. if no selection it get the modal gray, if selection it get the mean gray value</li>
<li>[5] : Paste. Adapt min&max contrast to get the same relative intensity of (modal/mean) per channel</li>
<li>[6] : Apply. Apply the same transformation as necessary for WhitBal. Useful when a reference image is taken in same conditions.</li>
<li>[7] : Scale. Show or hide scale bar.</li>
<li>[8] : Export. Save and RGB image in the same folder as original one withe the extension "WB.tif". The Scale bar is removed before saving.</li>
<li>[0] : Parameter. Let tune the OptimLum paramameter and to scale the image.</li>

## references

- here is a video to introduce it : https://twitter.com/i/status/1409864168749027329

- for details about ActionBar, see:
https://imagejdocu.tudor.lu/doku.php?id=plugin:utilities:action_bar:start#installation

- for information contact sebastien.schaub@imev-mer.fr

