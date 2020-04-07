# Message Types in On Premise Diagnostics (OPD)

There are four (4) distinct types of messages that can be generated from OPD. Each has
a different appearance and communicate a different type of message.

| Message Type | Sample Text                        | Meaning                                                                                                                                   |
|:-------------:|:------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------|
| ERROR        | <span style="color:red">[-] This is an error message</span>       | This is used to indicate that an error condition has been found. Typically, you will see this when a rule has detected an abnormal state. |
| INFO         | [?] This is an information message | This is used to communicate information to the user. It is not indicative of a failure condition.                                         |
| SUCCESS      | <span style="color:green">[+] This is a success message</span>      | This is used to indicate that a rule/analyzer/scenario has completed successfully.                                                        |
| WARNING      | <span style="background-color:DarkBlue;color:yellow">[!] This is a warning message</span>      | This is used to indicate that an unexpected condition has been encountered with a rule. It *warns* of a potential condition.                |

