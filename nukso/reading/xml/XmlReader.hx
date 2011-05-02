package nukso.reading.xml;

/**
 * A reader that reads or "parses" XML documents. This reader is synchronous, and does not validate. Use this reader for small
 * valid XML documents (up to 500 lines), such as configuration files and RSS feeds. Too long XML documents may cause your
 * application to be blocked, while invalid XML documents might cause the reader to crash or freeze completely.
 * 
 * This reader is very primitive: it ignores prologs, DTDs and namespaces. If multiple attributes with the same name exist in
 * one element all but the last one that is mentioned are ignored.
 */
class XmlReader implements DocumentReader {
	private static var readEngine:XmlReadEngine;
	// TODO: Add a "validating" flag. Oh, and a validating XML read engine.
	public function new():Void {
	}
	/**
	 * Reads the passed document, and sends the content to the passed content handler.
	 * 
	 * Calls to this method are currently synchronous: this method always returns after the passed document is entirely read.
	 */
	public function read(document:String, contentHandler:ContentHandler):Void {
		if (null == readEngine) {
			readEngine = new QuickXmlReadEngine();
		}
		#if as3
		readEngine.setDocument(document);
		readEngine.setCurrentContentHandler(contentHandler);
		readEngine.setPointer(0);
		while (readEngine.getPointer() != document.length) {
			readEngine.readNextPart();
		}
		#else
		readEngine.document = document;
		readEngine.currentContentHandler = contentHandler;
		readEngine.pointer = 0;
		while (readEngine.pointer != document.length) {
			readEngine.readNextPart();
		}
		#end
	}
}
