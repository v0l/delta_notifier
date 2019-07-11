typedef DeltaHandler<T> = void Function(T);

abstract class DeltaListenable<T> {
  void addListener(DeltaHandler<T> listener);
  void removeListener(DeltaHandler<T> listener);
}