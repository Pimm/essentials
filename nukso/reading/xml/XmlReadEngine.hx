package nukso.reading.xml;

/**
 * An XML read engine used by an XML reader.
 * 
 * Objects of this type are usually constructed by XML readers. You only have to implement this interface if you want to
 * change the way XML documents are read.
 */
interface XmlReadEngine {
	/**
	 * The content handler used in this content handler.
	 */
	public var currentContentHandler:ContentHandler;
	/**
	 * The document that is being read.
	 */
	public var document:String;
	/**
	 * The point, in characters, of the document that is to be read next.
	 */
	public var pointer:Int;
	// When compiling to ActionScript 3, defining properties in an interface doesn't work out. Therefore, these get and set
	// methods are defined here.
	#if as3
	public function getCurrentContentHandler():ContentHandler;
	public function getPointer():Int;
	#end
	/**
	 * Reads the next part of the document, and (potentially) sends the content to the passed content handler.
	 */
	public function readNextPart():Void;
	#if as3
	public function setCurrentContentHandler(value:ContentHandler):Void;
	public function setDocument(value:String):Void;
	public function setPointer(value:Int):Void;
	#end
}
