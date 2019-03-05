Strip Disclaimer Text
=====================

![This script was last tested in Nuix 7.8](https://img.shields.io/badge/Script%20Tested%20in%20Nuix-7.8-green.svg)

View the GitHub project [here](https://github.com/Nuix/Strip-Disclaimer-Text) or download the latest release [here](https://github.com/Nuix/Strip-Disclaimer-Text/releases).

# Overview

**Written By:** Jason Wells

The intent of this script is to remove reocurring "disclaimer" text (or other common text like a repetitive email footer) from the content text of items.  This script takes the text of a provided text file, finds exact matches in item content text and then replaces those matches in the item's text with specified replacement text.

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

# Process

## Important Notices!

- This script does not make backups of item text before running.  It is recommended that if you wish to backup the item text make a backup of the case or export the item text.
- The newlines of the input, replacement and final result are normalized to all be `\n`.
- Nuix should be started with the argument `-Dfile.encoding=utf8`.  If Nuix is not started with this argument the script may have difficulty matching Unicode characters.  This is a due to a quirk in the way JRuby works.
- The disclaimer text file should be saved with the encoding `UTF-8`, especially if it contains any Unicode characters.


## Input

- **Disclaimer Text File**: The path to a text file that contains the disclaimer text, verbatim, which you wish to replace in the content text of items in your case.
- **Replace With Value**: When checked the script will replace matches with the text value you provide in the **Replacement Value**: text field.  A blank value essentially just removed the matched text from the item.
- **Replacement Value**: When **Replace With Value** is checked, this is the value matches will be replaced with.
- **Replace With File**: When checked matches will be replaced with the text in the file specified in **Replacement Text File**.
- **Replacement Text File**: When **Replace With File** is checked, this is where you specify the text file containing the text which will replace matches.
- **Scope Query**: An optional Nuix query which can be used to further scope down the items modified and checked for modification.  A blank value results in all items in the case being checked for matches (although only items which have a match are modified).
- **Tag Modified**:  If checked, items in which a match is found are tagged with the tag specified in **Tag** when and if the item is found to have a match.
- **Tag**: When **Tag Modified** is checked, this is the tag which will be applied to items which have a match and have their text modified. 

## Items Modified

The script locates items which potentially may have matching text by forming a query looking for all the keywords in your disclaimer text.  For example if you provided a disclaimer text file which contains:

```
This e-mail may contain material that is confidential.
```

And a scope query of:

```
kind:email
```

The script will build a query to locate potential items like the following:

```
(kind:email) AND ("This" AND "e" AND "mail" AND "may" AND "contain" AND "material" AND "that" AND "is" AND "confidential")
```

The terms used to match the disclaimer text are determined by using a Lucene tokenizer to break the disclaimer into the individual terms.  This is to help prevent query syntax errors that may occur on text within the disclaimer text which may be interpretted as invalid Lucene syntax.

Items which hit upon this query are still checked for having an exact match to the disclaimer text before being modified.

**Important:** The find/replace used is strict whitespace and capitalization.  It is expected that the provided disclaimer text is an exact match and will only be replaced in the item's text if an exact match is found.

## Script Processing

While the script is processing a progress dialog will be displayed showing information about the script's current progress and the settings specified.

If you click and confirm aborting the process via the abort button, the script will stop as soon as it reaches a safe point to do such.  Any items which have had their text already modified or have been tagged will **NOT** be rolled back, but no further processing will take place.

# Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the script.

# License

```
Copyright 2019 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```