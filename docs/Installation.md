## Installing On Premise Diagnostic (OPD) for Skype for Business Server

The On Premise Diagnostic (OPD) releases are located [here.](https://github.com/onpremdiag/sfbserver/releases)

## Which version should I download?
> Which version do I download?

	- 1.1.yymm.ddrrrr

The release/version number can be interpreted as follows:

	- The first value, 1, indicates the major release value
	- The second digit, either 0 or 1, indicate the type of release
		- 0 indicates that this is a development release
		- 1 indicates that this is a code-signed release
	- The third value, yymm, indicates the year (yy) (last two
	  digits of build year) and the month (mm) that the release was built.
	- The final value, ddrrrr, indicates the day (dd) of the
	  build and the revision/build (rrr) on that day

For the following: 1.1.2003.30001, we know the following:

	- The major release is 1
	- This is a code-signed release (1)
	- It was built in the 3rd month (March) of 2020 (20)
	- It was built on the 30th (30) day of the month and this was the
	  first (0001) build of that day

## Installation of OPD
To download the release, simply follow these steps:

### Downloading

1. Select the release (zip file) that you want to download from GitHub or you can [download the latest release by clicking here](https://github.com/onpremdiag/SfBServer/releases/download/1.7.2112.21001/1.7.2112.21001.zip)

	<img src="./media/selectrelease.png" alt="Select the release to download" />

2. From the download location, right-click on the *properties* of the downloaded zip file
3. In the lower right-hand corner of the dialog, you will see the option to Unblock the zip file. Please check this box and click on *OK*

	<img src="./media/UnblockZip.gif" alt="Unblock the zip file" />

### Copying to destination

Now, you are ready to copy the contents of the file to your installation folder.

1. Open the zip file that contains the On Premise Diagnostic code in a window
2. Open another window to the destination folder that will contain OPD
3. Copy all of the files from the source folder to the destination folder

	<img src="./media/CopyFiles.gif" alt="Copy files from source to destination" />

4. Open a PowerShell command window in the installation folder. OPD requires an administrative instance to execute the scenario properly. One of the first
checks that it will do is to determine if you are running under an administrative context. If not, it will re-start PowerShell
as an administrator (assuming you have privileges to do so).
