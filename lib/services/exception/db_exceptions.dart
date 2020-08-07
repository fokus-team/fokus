class DbQueryFailed implements Exception {
	Object cause;

	DbQueryFailed(this.cause);
}

class NoDbConnection implements Exception {
	Object cause;

	NoDbConnection(this.cause);
}

