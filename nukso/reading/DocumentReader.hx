package nukso.reading;

/**
 * A reader that reads or "parses" a document that has some format, such as XML, JSON or YAML. This document reader does not
 * necessarily create a tree structure. Instead, you have total control over how the data inside the document is handled by
 * providing custom content handlers.
 * 
 * You should implement this interface when you need a reader that reads a specific format.
 */
interface DocumentReader {
	/**
	 * Reads the passed document, and sends the content to the passed content handler.
	 * 
	 * Calls to this method might not be synchronous: this method might return before the passed document is entirely read.
	 * Whether calls to this method are synchronous or asynchronous depends on the implementation.
	 */
	public function read(document:String, contentHandler:ContentHandler):Void;
}
