<h1>Release notes for build $defname</h1>
<b>Build Number</b>  : $($build.buildnumber)    <br>
<b>Build started</b> : $("{0:dd/MM/yy HH:mm:ss}" -f [datetime]$build.startTime)     <br>
<b>Source Branch</b> : $($build.sourceBranch)  <br>
<h3>Associated work items</h3>
@@WILOOP@@
<li> <b>$($widetail.fields.'System.WorkItemType') $($widetail.id)</b> $($widetail.fields.'System.Title')
@@WILOOP@@
<h3>Associated change sets/commits</h3>
@@CSLOOP@@
<li> <b>ID $($csdetail.changesetid)$($csdetail.commitid)</b> $($csdetail.comment)
<hr>
@@CSLOOP@@