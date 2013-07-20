# Install Instructions

## Dropping the XML Files in Place

Enabling auto-discovery of the NuoDB JDBC Jar file:

    export dbvisualizer_home=/Applications/DbVisualizer.app/Contents/java/app
    cp drivers.xml ${dbvisualizer_home}/resources/

## Adding Profile Support

To add profile support, you must have a Pro version of DbVisualizer. With that
simply perform these commands to enable NuoDB Profiles:

    export dbvisualizer_home=/Applications/DbVisualizer.app/Contents/java/app
    cp database-mappings.xml ${dbvisualizer_home}/resources/
    cp profiles/nuodb.xml ${dbvisualizer_home}/resources/profiles/

