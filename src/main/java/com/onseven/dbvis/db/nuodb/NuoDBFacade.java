package com.onseven.dbvis.db.nuodb;

import com.onseven.dbvis.db.A.G;
import com.onseven.dbvis.db.AbstractFacade;

/**
 * NuoDB Facade for DBVisualizer.
 */
public class NuoDBFacade extends AbstractFacade {
    public NuoDBFacade(G paramG) {
        super(paramG);
    }

    public int getVendor() {
        return 21; // todo: strange, find out what this is all about
    }

    public String getName() {
        return "nuodb";
    }

    public String getDisplayName() {
        return "NuoDB";
    }
}
