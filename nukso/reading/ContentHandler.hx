package nukso.reading;
import nukso.tree.Children;

/**
 * A handler that handles the content of a document read by a document reader.
 * 
 * Implementing this interface is common practice when using document readers: you should implement this interface whenever you
 * want to handle the content of a document in a particular manner.
 */
interface ContentHandler {
	/**
	 * Handles the end of an element with the passed name.
	 */
	public function handleElementEnd(name:String):Void;
	/**
	 * Handles the start of an element with the passed name and attributes. Implementations can use the the passed element read
	 * settings to alter the way the document reader reads the document.
	 */
	public function handleElementStart(name:String, attributes:Attributes, elementReadSettings:ElementReadSettings):Void;
	/**
	 * Handles plain text.
	 */
	public function handleText(value:String):Void;
}
/**
 * The read settings for an element. Content handlers may use these objects to alter the way a document reader reads the
 * associated element, and only the associated element.
 *
 * Objects of this type are usually constructed by document readers. You only have to implement this interface if you are
 * writing a document reader.
 */
interface ElementReadSettings {
	/**
	 * The content handler that is used for this specific element. The handleElementStart and handleElementStop methods of the
	 * passed content handler will not be called for the associated element itself. To the original content handler, it will seem
	 * as if the element has no children.
	 */
	public var contentHandler(never, useAlternativeContentHandler):ContentHandler;
	/**
	 * Makes the document reader convert the children of the associated element to a tree structure, similar to the data
	 * structure of the Xml class in haXe. The children of the associated element will no longer be passed to content handler. To
	 * the content handler, it will seem as if the element has no children.
	 * 
	 * Because this method is synchronous in every implementation, calling this method may cause your application to block if the
	 * associated element is too long.
	 */
	public function convertToTree():Children;
	/**
	 * Makes the document reader skip the associated element. The children of the associated element, if any, will be ignored.
	 * To the content handler, it will seem as if the element has no children, and is never closed.
	 */
	public function skip():Void;
	// When compiling to ActionScript 3, explicitly adding these methods is required. If this is not done, they will not end up
	// in the created interface.
	#if as3
	private function useAlternativeContentHandler(value:ContentHandler):ContentHandler;
	#end
}
