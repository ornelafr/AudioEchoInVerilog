# AudioEchoInVerilog
---
This is a project done in Miami University's ECE 287 course
---
# Project Description:
---
The goal of this project is to design a code that would produce an echo effect on the DE2-115 FPGA board. Our strategy revolved around obtaining audio from the line-in MIC port and saving it onto a memory file where we would then manipulate the data into producing an output effect that resembled an echo.

# Background Information:
---
This project requires an understanding of how audio is processed in the DE2-115 so research needs to be done on the pin layouts found in the DE2-115 User Manual as well as the audio chip that is used. The Wolfson MW8731 chip is responsible for the audio manipulation from the female ends of the headphone jacks located on the board. To initiate communication between the audio and the FPGA we require knowledge on I2C and SPI protocols which are found on the Wolfson MW8731 datasheet. This required reading the entire datasheet to understand the communication between the Parent (Master) and Child (Slave) element found in the Wolfson DataSheets. The following figures show how the Child (Slave) mode worked.

![20231215_145006](https://github.com/ornelafr/AudioEchoInVerilog/assets/153780710/d30431dd-302e-4797-b359-819cb61a1ca8)

![20231215_145142](https://github.com/ornelafr/AudioEchoInVerilog/assets/153780710/bd79f143-1250-4004-9471-dd4565d71e12)

 The manual also contains the specific register addresses that allow the audio CODEC to communicate from the Parent to Child and manipulate the corresponding values. 
 Here is an example given by the manual:

![20231215_150107](https://github.com/ornelafr/AudioEchoInVerilog/assets/153780710/f71ff972-ebd6-4ead-bed8-8b4b5ca84fe8)


# Design:
---
The project utilizes a previous project, by Goshik92, that was found from Github that obtains audio input and converts it into a visual representation using the VGA. Since the Audio chip and the video chip share an I2C bus the audio and video chip will not function correctly so we chose to display the echo effect on the VGA first. We began by creating two memories, one records the data coming in from the mic port, and the other stores the echo effect. We chose to store our newly created module, Echo,  under the original top module called FFTVisualizer which instantiates it. We then added on to the FFTVisualizer module to change the input form the mic to the memory file that is processed in our Echo file. The Echo file is calibrated to work with the AUD_BCLK clock where it keeps the first 12 addresses and then repeats this first section for the next 12 addresses and then contains the original 12 addresses the same. This cycle is how we generated the repeating effect of the echo. After this processing we used the AUD_BCLK to time our data output onto the I2SReciever module which would then be sent to the FFTVisualizer to provide the visual output.
![20231215_195304](https://github.com/ornelafr/AudioEchoInVerilog/assets/153780710/b0b9d42b-7699-451d-812a-984b2d95ff96)
![20231215_195348](https://github.com/ornelafr/AudioEchoInVerilog/assets/153780710/e7f8abb3-c43c-448f-8629-a6bdbe185716)

# Results:
---
We did succeed in creating a memory that would store the data input from the mic port, creating a file within the provided code by Goshik92, and a repeating effect out of the visualizer. However, we were not successful in producing a successful verilog code for the Parent-to-Child interaction to produce the output necessary to check if the audio provided a goode echo effect. It was difficult to tell from the visualizer if our echo was successful so it would be necessary to create a working module to check. The output displayed the same shape instead of mimicking real life audio waves. This can be attributed to the FFT file that was a part of the module which used Fourier series transforms to manipulate the data into the VGA. Below is a link to the video that we took from the output our code provided.

https://youtube.com/shorts/g62Ma-kpZf8

# Conclusion:
---
It would have been optimal to have studied each section of the Wolfson manual which provided example scenarios that would have made it easier to organize the module with specific sample rates and output rates. In our case, since the DE2-115 had the device pre-installed we would not have a need to go over the power usage much, this would be more important if we were building the FPGA altogether. Other things on the chip's data sheet were the specific codes for manipulating the decibel range, muting the output, changing the volume, ect. These options would allow for enhancement of the audio quality produced. but would requre extisive research on how analog signals were turned into digital signals. A great starting point to research for a method of producing higher audio quality would be by going over high quality sources that explained how audio echo is made such as in the Time Sequence Analysis in Geophysics book that was used in another Github code that created an echo effect made by a previous student in the ECE287 class named Austyn Larkin. 
https://books.google.com/books?id=k8SSLy-FYagC&pg=PA260&dq=band-pass-filter#v=onepage&q=band-pass-filter&f=false
This book provided great examples on how to manipulate digital data into analog which would help in creating the echo effect that involves repeated signals and lowering the volume for each consecutive repeat to produce a more natural sounding effect.


Goshik92, Fftv. (2018, June 22). Goshik92/FFTVISUALIZER: This project demonstrates DSP capabilities of Terasic DE2-115. GitHub. https://github.com/Goshik92/FFTVisualizer 


Microelectronics, W. (2005, February). W WM8731 / WM8731L - cdn.sparkfun.com. CDN Sparkfun.com. https://cdn.sparkfun.com/datasheets/Dev/Arduino/Shields/WolfsonWM8731.pdf 

Larkin, A. (2018). Reenforcements/VerilogDE2115AudioFilters: Student Project for using audio on the DE2-115 FPGA Development Board. GitHub. https://github.com/Reenforcements/VerilogDE2115AudioFilters 
