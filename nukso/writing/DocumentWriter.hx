package nukso.writing;

/**
 * A writer that writes or generates documents that has some format, such as XML, JSON or YAML.
 * 
 * You should implement this interface when you need a writer that writes to a specific format.
 */
interface DocumentWriter {
	/**
	 * Writes a document, using the passed addContent method to get the content that is written to the document.
	 */
	public function write(addContent:DocumentBuffer -> Void):String;
}
