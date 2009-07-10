package checkers.nullness;

import checkers.basetype.BaseTypeChecker;
import checkers.nullness.quals.*;
import checkers.quals.TypeQualifiers;

/**
 * A typechecker plug-in for the Nullness type system qualifier that finds (and
 * verifies the absence of) null-pointer errors.
 *
 * @see NonNull
 * @see Nullable
 * @see Raw
 * @manual #nullness-checker Nullness Checker
 */
@TypeQualifiers({ Raw.class, NonRaw.class, PolyRaw.class })
public class RawnessSubchecker extends BaseTypeChecker {}
