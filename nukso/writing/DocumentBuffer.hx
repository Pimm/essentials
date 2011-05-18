package nukso.writing;

/**
 * A buffer that contains the content of a document written by a document writer.
 * 
 * Objects of this type are usually constructed by document writers. You only have to implement this interface if you are
 * writing a document writer.
 */
interface DocumentBuffer {
	/**
	 * Adds text to the document.
	 */
	public function addText(value:String):Void;
	/**
	 * Ends the most recently started element. If there are no more elements to end, calling this method might crash your
	 * application.
	 */
	public function endElement():Void;
	/**
	 * Starts a new element in the document with the passed name, and the passed attributes. You don't have to specify any
	 * attributes. If you want to specify attributes, you can use a hash-attributes object.
	 */
	public function startElement(name:String, ?attributes:Attributes):Void;
}
