//July, 2021,Todd Fallesen, CALM Facility,Crick
//Idea of this script is to do a median filter on all image slices to even out the image a bit for better detection in cellprofiler.
//

//The script will launch a dialog box where you pick the input directory. All the median filtered images will be saved back to the same folder (makes it easier to load into CellProfiler).
//The modified images will have "Contrast_med_filter_enhanced_" appended to their filename at the beginning of the filename. This can be changed by changing the string in the variable "save_file"

//If the images don't start with c1, c2, or c4, the image prefix can be changed in prefix_1, prefix_2, prefix_3. If there are more or less channels, edit the prefix's and the really long if statement.

#@ File (label = "Input directory", style = "directory") input

print("\\Clear");

//Set all the prefixes by hardcode, and run the same on all
suffix = ".tif";
prefix_1 = "c1";
prefix_2 = "c2";
prefix_3 = "c4";

processFolder(input);



// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if( (list[i].contains(prefix_1) && endsWith(list[i], suffix)) || (list[i].contains(prefix_2) && endsWith(list[i], suffix)) || (list[i].contains(prefix_3) && endsWith(list[i], suffix))    )
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	print("Processing: " + input + File.separator + file);
	open(input+File.separator + file);
	filename_short = File.nameWithoutExtension;
	save_file = "Contrast_med_filter_enhanced_" + filename_short + ".tif";
	save_path = input + File.separator + save_file;
	rename("original");
	run("Median...", "radius=2");
	print("Saving to in reality: " + save_path);
	save(save_path);
	print("Saving to: " + save_path);
	run("Close All");
}
