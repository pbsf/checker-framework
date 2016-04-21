// Test case for Issue #668
// https://github.com/typetools/checker-framework/issues/668
// @skip-test

import org.checkerframework.checker.igj.qual.IGJBottom;
import org.checkerframework.checker.igj.qual.ReadOnly;

public class Issue668 {
    public static boolean flag = false;
    @ReadOnly Issue668 field;
    void foo(@IGJBottom Issue668 param) {
        Issue668 myObject = param;
        for (Issue668 otherObject = param; myObject != null; ) {
            myObject = otherObject.field;
            if (flag) {
                otherObject = param;
            } else {
                otherObject = myObject;
            }
        }
    }
}
