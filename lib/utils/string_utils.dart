class StringUtils {
    static String displayJoin(List<String> parts, String andWord) {
    	String tail = '';
	    if (parts.length >= 2) {
	    	tail = '${parts[parts.length - 2]} $andWord ${parts[parts.length - 1]}';
		    parts = parts.sublist(0, parts.length - 2);
	    }
	    if (parts.length > 0 && tail.isNotEmpty)
	    	tail = ', $tail';
	    return parts.join(', ') + tail;
    }
}
