# Install Instructions

## Dropping the XML Files in Place

Run the following commands:

    export dbvisualizer_home=/Applications/DbVisualizer.app/Contents/java/app
    cp drivers.xml ${dbvisualizer_home}/resources/
    cp database-mappings.xml ${dbvisualizer_home}/resources/
    cp nuodb.xml ${dbvisualizer_home}/resources/profiles/

## Updating the DbVisualizer Jar

*WORK IN PROGRESS*

In order to integrate with DbVisualizer you have to update their Jar file with
the compiled class herein. After compiling this project, perform the following
commands:

    export dbvisualizer_home=/Applications/DbVisualizer.app/Contents/java/app
    cd target/classes
    jar uf ${dbvisualizer_home}/lib/dbvis.jar com/onseven/dbvis/db/nuodb/NuoDBFacade.class

One would hope that would be the end of it, but there is no discovery in DbVis,
you have intrusive declarations such as this in the DatabaseFacade class:

    public static final String SYBASE_IQ_DISPLAY_NAME = "Sybase IQ";
    public static final int SYBASE_ASE = 26;
    public static final String SYBASE_ASE_NAME = "sybase-ase";
    public static final String SYBASE_ASE_DISPLAY_NAME = "Sybase ASE";
    public static final int H2 = 27;
    public static final String H2_NAME = "h2";
    public static final String H2_DISPLAY_NAME = "H2";
    public static final int SQLITE = 28;
    public static final String SQLITE_NAME = "sqlite";
    public static final String SQLITE_DISPLAY_NAME = "SQLite";
    public static final String[][] DATABASE_NAMES = {{"generic", "Generic"}, {"cache", "Cache"}, {"db2-iseries", "DB2 iSeries"}, {"db2", "DB2 LUW"}, {"db2-zos", "DB2 z/OS"}, {"firebird", "Firebird"}, {"frontbase", "FrontBase"}, {"informix", "Informix"}, {"neoview", "HP Neoview"}, {"hsql", "HSQLDB"}, {"h2", "H2"}, {"derby", "JavaDB/Derby"}, {"jdatastore", "JDataStore"}, {"maxdb", "MaxDB"}, {"mimer", "Mimer SQL"}, {"mysql", "MySQL"}, {"netezza", "Netezza"}, {"oracle", "Oracle"}, {"pervasive", "Pervasive"}, {"postgresql", "PostgreSQL"}, {"progress", "Progress"}, {"sqlserver", "SQL Server"}, {"sqlite", "SQLite"}, {"sybase-asa", "Sybase SQL Anywhere"}, {"sybase-ase", "Sybase ASE"}, {"sybase-iq", "Sybase IQ"}};

It would have been nice if they built this list on the fly so that anyone could
simply extend their environment. But alas, it's closed source so I cannot modify
it. Funny, since they have you go through all the effort of declaring a mapping
that you should have to declare it a second time in Java code, huh? No DRY here.

And worse yet, these sorts of abstract methods exist:

    public abstract boolean isOracle();
    public abstract boolean isSQLServer();
    public abstract boolean isSybaseASE();

This project is on hold until we get some help from the DbVis folks. I am going
to go off and add support to an open source tool instead.

