package in.natelev.daikondiffvictimpolluter;

import java.util.List;

import daikon.PptTopLevel;

import static in.natelev.daikondiffvictimpolluter.Colors.*;

public class ReducedPpt {
    public String name;
    private List<ReducedInvariant> invariants;

    ReducedPpt(PptTopLevel pptTopLevel, List<ReducedInvariant> invariants) {
        this.name = pptTopLevel.name;
        this.invariants = invariants;
    }

    public List<ReducedInvariant> getInvariants() {
        return invariants;
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append(
                BLUE + "===========================================================================" + RESET + "\n");
        builder.append(YELLOW + name + RESET + "\n");
        for (ReducedInvariant invariant : invariants) {
            builder.append("* " + invariant + "\n");
        }
        return builder.toString();
    }
}