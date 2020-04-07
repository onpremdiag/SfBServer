## Installing On Premise Diagnostic (OPD) for SharePoint

The On Premise Diagnostic (OPD) releases are located [here.](https://github.com/onpremdiag/SharePoint/releases)
<img src="./media/releaserepo.png" alt="Releases" height="563" width="585"/>

## Which version should I download?
> Which version do I download?
You will notice that there are two (2) versions for each release

	- 2.0.yymm.ddrrrr
	- 2.1.yymm.ddrrrr

The release/version number can be interpreted as follows:

	- The first value, 2, indicates the major release value
	- The second digit, either 0 or 1, indicate the type of release
		- 0 indicates that this is a development release
		- 1 indicates that this is a code-signed release
	- The third value, yymm, indicates the year (yy) (last two 
	  digits of build year) and the month (mm) that the release was built.
	- The final value, ddrrrr, indicates the day (dd) of the 
	  build and the revision/build (rrr) on that day

For the following: 2.1.1908.01002, we know the following:

	- The major release is 2
	- This is a code-signed release (1)
	- It was built in the 8th month (August) of 2019 (19)
	- It was built on the 1st (1) day of the month and this was the 
	  second (2) build of that day
 
## Installation of OPD
To download the release, simply follow these steps:

### Downloading

1. Select the release (zip file) that you want to download from GitHub

	<img src="./media/selectrelease.png" alt="Select the release to download" />

2. From the download location, right-click on the *properties* of the downloaded zip file
3. In the lower right-hand corner of the dialog, you will see the option to Unblock the zip file. Please check this box and click on *OK* 

	<img src="./media/unblockzip.png" alt="Unblock the zip file" />

### Copying to destination

Now, you are ready to copy the contents of the file to your installation folder.

1. Open the zip file that contains the On Premise Diagnostic code in a window
2. Open another window to the destination folder that will contain OPD
3. Copy all of the files from the source folder to the destination folder

	<img src="./media/copyfiles.png" alt="Copy files from source to destination" />

4. Open a PowerShell command window. OPD requires an administrative instance to execute the scenario properly. One of the first
checks that it will do is to determine if you are running under an administrative context. If not, it will re-start PowerShell
as an administrator (assuming you have privileges to do so).
