#!/usr/bin/env python
"""Synthesis_Parser.py: Parses out warning messages from Xilinx synthesis"""

__author__      = "Parker Jacobs"
__date__        = "January 17, 2011"
__modified__    = "February 14,2011"
__project__     = "Senior Design Project: CODEC Deux"
__college__     = "Mississippi State University"
__version__     = "Built in Python 2.7"

import sys
import string

def OutFile_Data(Name_Of_Outfile, Some_Variable):
    "This parses data from a list and inserts it into another"
    for letter in Some_Variable:
        if " " in letter:
            Name_Of_Outfile = Name_Of_Outfile + '_'
        else:
            Name_Of_Outfile = Name_Of_Outfile + letter
    return Name_Of_Outfile

def Line_Break(Output_File, iterations):
    "This prints out a divider line within the Output File"
    for i in range(iterations):
        print >>Output_File, "=================================================="

#Input the name of the synthesis report to parse
File_Name = raw_input("Enter a file name: ")

#Try/Except block attempts to open specified file name.
try:
    Input_File = open(File_Name, "r")
except:
    print "File not found:", File_Name
    exit()

#Get information for the output file
Module = raw_input("Name of Module: ")
Author = raw_input("Name of Author: ")

lines = []                  #lines is an array that stores the lines detailing a warning.
Size_Mismatch_List = []     #Size_Mismatch_List stores the size mismatch warnings
Warning_Messages = []       #Warning_Messages stores the details specific to a module
Synthesizing_Unit_List = [] #Synthesizing_Unit_List stores each module that has Warnings
Output_File_Name = ""       #Name of the Output File generated at the end of the code.

#Flags
Synthesizing_Unit_Flag = 0
Warning_Flag = 0

#Number_Of_Warnings is a variable that tracks the number of warningss found.
Number_Of_Warnings = 0

Empty_List = []
The_Module = ""

for line in Input_File:
    if "WARNING:Xst:2725" in line:
        Number_Of_Warnings = Number_Of_Warnings + 1
        Size_Mismatch_List.append(line)
    elif "Synthesizing Unit" in line:
        if Synthesizing_Unit_Flag == 1 and Warning_Flag == 1:
            Synthesizing_Unit_List.append(Warning_Messages)
        elif Synthesizing_Unit_Flag == 1 and Warning_Flag == 0:
            if len(Empty_List) > 0:
                Empty_List.pop()
        Warning_Messages = []
        Warning_Messages.append(line)
        Synthesizing_Unit_Flag = 1
        Warning_Flag = 0
        for i in line:
            if i is "<":
                The_Module = ""
            elif i is ">":
                Empty_List.append(The_Module)
                The_Module = ""
            else:
                The_Module = The_Module + i

    if Synthesizing_Unit_Flag == 1:
        if "WARNING:Xst:737" in line:
            Warning_Messages.append(line)            
            Warning_Flag = 1
            Number_Of_Warnings = Number_Of_Warnings + 1
        elif "WARNING:Xst:653" in line:
            Warning_Messages.append(line)            
            Warning_Flag = 1
            Number_Of_Warnings = Number_Of_Warnings + 1             
    lines.append(line)

if Synthesizing_Unit_Flag == 1 and Warning_Flag == 0:
    if len(Empty_List) > 0:
        Empty_List.pop()

for line in Empty_List:
    print line
    The_Module = line.rstrip()
    if The_Module == "Weight_Az":
        print "I left off here. Soon to parse verilog modules"


Number_Of_Latches = len(Synthesizing_Unit_List)
Number_Of_Lines = len(lines)
Warning_Percent = float(Number_Of_Warnings) / float(Number_Of_Lines) * 100.0

#Create the Output File
Output_File_Name = OutFile_Data(Output_File_Name, Module)
Output_File_Name = Output_File_Name + '_'
Output_File_Name = OutFile_Data(Output_File_Name, Author)
Output_File_Name = Output_File_Name + '.OUT'

Output_File = open(Output_File_Name, 'w')

print >>Output_File, 'Latch and Mismatch Report'
print >>Output_File, 'Report Generated From: ' + File_Name
Line_Break(Output_File, 1)
print >>Output_File, 'Name of Author: ' + Author
print >>Output_File, 'Name of Module: ' + Module
Line_Break(Output_File, 1)
print >>Output_File, ''

for iter in Size_Mismatch_List:
    print >>Output_File, iter

print >>Output_File, ''


for i in Synthesizing_Unit_List:
    Line_Break(Output_File, 3)
    print >>Output_File, ''
    for j in i:
        print >>Output_File, j

Line_Break(Output_File, 2)
print >>Output_File, ''

#Print the File Statistics
print >>Output_File, 'Number of Modules with Latches = %d' % Number_Of_Latches
print >>Output_File, 'Number of Lines in Synthesis Report = %d' % Number_Of_Lines
print >>Output_File, 'Number of Parsed Warnings = %d' % Number_Of_Warnings
print >>Output_File, 'Warnings to Lines Percentage = %f%%' % Warning_Percent

Output_File.close()
Input_File.close()
