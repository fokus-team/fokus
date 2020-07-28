class DbQueryFailed implements Exception {
	Object cause;

  DbQueryFailed(this.cause);
}
