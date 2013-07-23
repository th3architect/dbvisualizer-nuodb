DbVisualizer Plugin for NuoDB
=============================

[<img src="https://api.travis-ci.org/rbuck/dbvisualizer-nuodb.png?branch=master" alt="Build Status" />](http://travis-ci.org/rbuck/dbvisualizer-nuodb)

# Description

This project provides a plugin for DbVisualizer by providing two things:

- it provides a driver declaration that enables a Wizard to aid in setting up a database connection
- it provides a tailored profile that renders all database objects and performance statistics


# Install Instructions

There are two ways to install NuoDB support, either unzip the compressed file
into the DbVisualizer directory, or manually copy each directory. Each approach
is detailed below.

## Prerequisites

The following are prerequisites:

- NuoDB 1.1.2, or later is installed
- DbVisualizer 9.0.8 is installed (prior versions may be supported but are untested)
- Maven 3 is on your path

## Building a Package

Follow these instructions to build a package:

    git clone https://github.com/rbuck/dbvisualizer-nuodb.git
    cd dbvisualizer-nuodb
    mvn clean install

A simple installer is provided in the dbvisualizer-nuodb-plugin.[tar.gz | zip]
package that will install the plugin and the JDBC jar into DbVisualizer.

## Obtaining a Package

Alternatively, you can download a pre-built package directly from Github:

    wget https://github.com/rbuck/dbvisualizer-nuodb/releases/download/v1.0-prerelease/dbvisualizer-nuodb-plugin.zip

## Using the Package Installer (Mac)

To install this on Mac, assuming the default location of DbVisualizer to be the
following path:

    /Applications/DbVisualizer.app

Then all you need to do is:

    unzip dbvisualizer-nuodb-plugin.zip
    cd dbvisualizer-nuodb-plugin
    ./install.sh

If DbVisualizer is installed elsewhere, you can DBVISUALIZER_HOME to the appropriate
location prior to running the above commands, for example:

    export DBVISUALIZER_HOME=/Applications/DbVisualizer.app/Contents/Resources/app/

n.b. this path includes the path to the internal package contents; the app directory
name changed between Mac releases of DbVisualizer, so this is one reason why this
is set up this way, and secondly, the app directory on Mac is identical to the path
for an install on Linux, so this ought to work for Linux too, I just have not tested
it yet.

## Manual Installation

After obtaining a package and unzipping it per above, follow these instructions
to manually install the plugin if you chose to not use the installer.

### Adding NuoDB JDBC Jars

Assuming you've already installed NuoDB:

    mkdir -p ${DBVISUALIZER_HOME}/jdbc/nuodb/
    cp /opt/nuodb/jar/nuodbjdbc.jar ${DBVISUALIZER_HOME}/jdbc/nuodb/nuodbjdbc.jar

### Adding Auto-Discovery Support

Enabling auto-discovery of the NuoDB JDBC Jar file:

    export DBVISUALIZER_HOME=/Applications/DbVisualizer.app/Contents/java/app
    cp drivers.xml ${DBVISUALIZER_HOME}/resources/

### Adding Profile Support

The DbVisualizer Professional is required in order to enable Profile support.
To add profile support simply perform these commands to enable NuoDB Profiles:

    export DBVISUALIZER_HOME=/Applications/DbVisualizer.app/Contents/java/app
    cp database-mappings.xml ${DBVISUALIZER_HOME}/resources/
    cp profiles/nuodb.xml ${DBVISUALIZER_HOME}/resources/profiles/

# DbVisualizer Setup Instructions

To use the features of this plugin you must currently set the Profile for each
connection; this will change when the DbVisualizer folks add this to their product
and write a Java hook for NuoDB. At that point the following steps will no longer
be necessary. But for now, to enable the NuoDB Profile for the connection you've
established, do the following (requires the Pro version of DbVis):

- Double click on the connection and bring up the connection properties.
- Under "Database Profile" select "Manually Choose"
- From list choose the "nuodb" profile, and press Apply.
- Reconnect the connection to see all the NuoDB specific goodness!
