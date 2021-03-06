package lubglb;

import java.lang.annotation.Annotation;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.checkerframework.common.basetype.BaseAnnotatedTypeFactory;
import org.checkerframework.common.basetype.BaseTypeChecker;

import lubglb.quals.A;
import lubglb.quals.B;
import lubglb.quals.C;
import lubglb.quals.D;
import lubglb.quals.E;
import lubglb.quals.F;

public class LubGlbAnnotatedTypeFactory extends BaseAnnotatedTypeFactory {

    public LubGlbAnnotatedTypeFactory(BaseTypeChecker checker) {
        super(checker);
        this.postInit();
    }

    @Override
    protected Set<Class<? extends Annotation>> createSupportedTypeQualifiers() {
        return Collections.unmodifiableSet(
                new HashSet<Class<? extends Annotation>>(
                        Arrays.asList(A.class, B.class, C.class, D.class, E.class, F.class)));
    }

}
