class DbLimitsExceededException implements Exception {
	final Exception cause;

	DbLimitsExceededException(this.cause);
}
