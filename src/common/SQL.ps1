################################################################################
# MIT License
#
# Copyright (c) Microsoft Corporation. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Filename: SQL.ps1
# Description: Various SQL query related functions
# Owner: Stefan Goﬂner <stefang@microsoft.com>
# Created On: 10/30/2018 9:04 AM
#
# Last Modified On: 10/30/2018 9:04 AM
#################################################################################
Set-StrictMode -Version Latest

function Get-DataTableFromSQL
(
    [string] $Connstr,
    [string] $Query
)
{
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connstr
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $query

    $dataTable = $null

    # no need for try/catch here. If this fails the rule will fail anyway and we cover the exception there.
    $result = $command.ExecuteReader()
    if ($result.HasRows)
    {
        $dataTable = New-Object System.Data.DataTable
        $dataTable.Load($result)
    }

    $connection.Close()

    return $dataTable
}
