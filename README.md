# ClinicalRecordsManager
author: Antonio Fusco

This software allows for inserting and requesting clinical records from a database through a GUI.

DDL and DML commands for creating tables, triggers, packages and types.

Developed with RAD Studio using Delphi.


Features:

-Logging function: database package opens a TCP connection with the client to send log messages about inserts and logon/logoffs. Said package will also store logs that it was not able to send in a table.

-Dynamic GUI: buttons and elements are created dynamically reading from an .ini file.

-Download/Upload .ini file configs: client will self recover its .ini file in case of corruption or deletion by sending a SQL query to the database for a new .ini configuration or to update the one stored on the database.
