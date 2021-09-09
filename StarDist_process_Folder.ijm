/*
 * Macro template to process multiple images in a folder
 * Todd Fallesen, CALM Facility, Jan 2021.
 * Run multiple slices through 2D StarDist using the Versatile pre-trained network, default from the plugin.
 * 
 * To Run: 
 * 1.) Split your image stack into channels. Save the DAPI channel into a folder as single images. In FIJI this would be File-->Save As-->Image Sequence.
 * 2.) Run this code. select the directory where the DAPI channel single images are, and select the the output folder you would like to put the StarDist result images into
 * 3.) StarDist result images will be labelled "DAPI_stardist_" + filename of original file. This is useful for sorting in CellProfiler. This can be changed in the processFile function block, under the variable "save_file"
 */

//Pop up a dialog box asking for the directory where the DAPI files are located.
#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix


print("\\Clear");
processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	open(input+File.separator + file);
	filename_short = File.nameWithoutExtension;
	save_file = "DAPI_stardist_"+filename_short + ".tif";
	save_path = output + File.separator + save_file;
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'"+file+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.5', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	selectWindow("Label Image");
	print("Saving to in reality: " + save_path);
	save(save_path);
	print("Saving to: " + output);
	run("Close All");
}
