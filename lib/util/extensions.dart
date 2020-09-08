extension ElementOrNull<T> on List<T> {
  T atOrNull(int index) {
    return (index!=null && index>=0 && index<this.length) ? this[index] : null;
  }
}