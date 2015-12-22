package java.lang;

import org.checkerframework.checker.lock.qual.GuardedByInaccessible;;

public interface Iterable<T extends @GuardedByInaccessible Object> {
  java.util.Iterator<T> iterator();
}
