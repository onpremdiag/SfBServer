# Telemetry Data

Telemetry data is collected with every execution of the OPD package. It is stored, potentially, in two (2) locations:

  1. The local event log (always)
  2. Uploaded to Microsoft for failure trending/analysis (optional)

## The local event log
When OPD is invoked for the first time, it will create a local store in the event log for everything
that it finds during execution. If you open the event viewer (eventvwr.exe) and expand the
*Applications and Services Logs*, you should see an entry for *OPDLog*.

<img src=".\media\EventViewerOPDLog.png" alt="OPD Event log"/>

### Success
All insights, rules, analyzers, and scenario results are recorded in the local event log. These can then be
consumed by external packages (SCOM) for additional alerting/analysis. Here is a typical event log that shows
a successful analyzer operation.

<img src=".\media\SuccessfulAnalyzerEventLog.png" alt="Successful analyzer execution" />

| Field  | Definition  |
|--------|-------------|
| **Name**  | The actual name of the analyzer (rule/scenario) that was executed |
| **Description**  | The textual description of the analyzer (rule/scenario) as it appears in the console application |
| **ID***  | A unique value that identifies the analyzer (rule/scenario)   |
| **Execution ID**  | The global execution ID associated with this execution. All scenario/analyzer/rules that are part of the same run will have the same execution ID. This makes it possible to filter on a specific OPD	session. |
| **Status**  | The final state of the analyzer (rule/scenario)  |
| **Scenario Id**  | A unique value that identifies the scenario that this analyzer is part of  |
| **Analyzer Id**  | A unique value that identifies the analyzer that was executed  |
| **Rule Id**  | A unique value that identifies the rule that was part of this execution  |

### Failure
If a rule/analyzer/scenario fails, an event will be generated that contains information to identify the
specific failure.

<img src=".\media\FailureAnalyzerEventLog.png" alt="Failing analyzer execution" />

## Upload telemetry data to Microsoft *(optional)*
The same information will be uploaded to Microsoft for analysis, trending, troubleshooting. However, no
end user information (machine name, IP address, etc.) will be transmitted to Microsoft. Any insights that 
contain machine/user specific information is *scrubbed* prior to transmission.