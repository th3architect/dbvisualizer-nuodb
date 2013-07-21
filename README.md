
# Install Instructions

There are two ways to install NuoDB support, either unzip the compressed file
into the DbVisualizer directory, or manually copy each directory. Each approach
is detailed below.

## Unzip

After performing a maven install command on the project, an archive will be
generated and is available in the target directory. With that archive, perform
the following operations:

    export dbvisualizer_home=/Applications/DbVisualizer.app/Contents/java/app
    tar -C ${dbvisualizer_home} xzvf dbvisualizer-nuodb-zip.tar.gz

## Manual Copying

### Adding Auto-Discovery Support

Enabling auto-discovery of the NuoDB JDBC Jar file:

    export dbvisualizer_home=/Applications/DbVisualizer.app/Contents/java/app
    cp drivers.xml ${dbvisualizer_home}/resources/

### Adding Profile Support

The DbVisualizer Professional is required in order to enable Profile support.
To add profile support simply perform these commands to enable NuoDB Profiles:

    export dbvisualizer_home=/Applications/DbVisualizer.app/Contents/java/app
    cp database-mappings.xml ${dbvisualizer_home}/resources/
    cp profiles/nuodb.xml ${dbvisualizer_home}/resources/profiles/

