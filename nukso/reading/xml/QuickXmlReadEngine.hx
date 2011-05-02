package nukso.reading.xml;
import nukso.Attributes;
import nukso.HashAttributes;
import nukso.NullAttributes;
import nukso.reading.ContentHandler;
import nukso.tree.Child;
import nukso.tree.Children;
import nukso.tree.Element;
import nukso.tree.NullChildren;

/**
 * An XML read engine that does not validate. It is designed to be safe, rather than safe. It implements the element read
 * settings interface, so it can pass itself to handleElementStart methods.
 * 
 * Objects of this type are usually constructed by XML readers.
 */
class QuickXmlReadEngine implements XmlReadEngine, implements ElementReadSettings {
	/**
	 * A temporary variable used internally.
	 */
	private var characterCode:Int;
	/**
	 * A setter as part of the element read settings.
	 */
	public var contentHandler(never, useAlternativeContentHandler):ContentHandler;
	/**
	 * The content handler used in this content handler.
	 */
	public var currentContentHandler:ContentHandler;
	/**
	 * The document that is being read.
	 */
	public var document:String;
	/**
	 * An empty list of attributes that is used for every element without attributes.
	 */
	private static var emptyAttributes:Attributes;
	/**
	 * The element read settings used for every empty-element tag.
	 */
	private static var emptyElementReadSettings:EmptyElementReadSettings;
	/**
	 * A temporary variable used internally.
	 */
	private var length:Int;
	/**
	 * The point, in characters, of the document that is to be read next.
	 */
	public var pointer:Int;
	/**
	 * Creates a new XML reader.
	 */
	public function new():Void {
		if (null == emptyAttributes) {
			// These objects have no persistent state, and can therefore be re-used safely.
			emptyAttributes = new NullAttributes();
			emptyElementReadSettings = new EmptyElementReadSettings();
		}
	}
	public function convertToTree():Children {
		var treeConvertingContentHandler:TreeConvertingContentHandler = new TreeConvertingContentHandler();
		// Save the previous content handler, so it can be put back.
		var previousContentHandler:ContentHandler = currentContentHandler;
		// Read parts of the document using the tree-converting content handler until the tree is completed.
		currentContentHandler = treeConvertingContentHandler;
		while (treeConvertingContentHandler.working) {
			readNextPart();
		}
		// Put the previous content handler back.
		currentContentHandler = previousContentHandler;
		// Inform the previous content handler of the closed element.
		currentContentHandler.handleElementEnd(treeConvertingContentHandler.closingElementName);
		return treeConvertingContentHandler.result;
	}
	#if !php
	/**
	 * Returns the passed text with the XML character entities decoded.
	 */
	private function decodeText(source:String):String {
		// TODO: Speed up this method, and maybe make it inlined.
		// Find the ampersand.
		var ampersandIndex:Int = source.indexOf("&");
		var semicolonIndex:Int;
		// While there are ampersands in the document, replace the character entity by the character.
		while (-1 != ampersandIndex) {
			// Find the semicolon associated with the ampersand.
			semicolonIndex = source.indexOf(";", ampersandIndex);
			// Replace the character entity by the character.
			switch (source.substr(ampersandIndex + 1, semicolonIndex - ampersandIndex - 1)) {
				case "amp":
				source = source.substr(0, ampersandIndex) + "&" + source.substr(semicolonIndex + 1);
				case "apos":
				source = source.substr(0, ampersandIndex) + "'" + source.substr(semicolonIndex + 1);
				case "gt":
				source = source.substr(0, ampersandIndex) + ">" + source.substr(semicolonIndex + 1);
				case "lt":
				source = source.substr(0, ampersandIndex) + "<" + source.substr(semicolonIndex + 1);
				case "quot":
				source = source.substr(0, ampersandIndex) + "\"" + source.substr(semicolonIndex + 1);
				// If no correct character entity was matched, simply ignore it.
				default:
				source = source.substr(0, ampersandIndex) + source.substr(semicolonIndex + 1);
			}
			ampersandIndex = source.indexOf("&", ampersandIndex + 1);
		}
		return source;
	}
	#end
	/**
	 * Decreases length as long as the character position + length is pointing to is a whitespace.
	 */
	private inline function findLengthWithoutWhitespaces():Void {
		// In AVM2 and JavaScript, use the cca method (the native charCodeAt method). The difference between the native method and
		// the haXe one, is that the haXe one returns null, instead of NaN, if the passed index is out of bounds. Since the passed
		// index will never be out of bounds, there is no reason not to use the faster native method here.
		characterCode = #if (flash9 || js) untyped(document).cca(pointer + length - 1); #else document.charCodeAt(pointer + length - 1); #end
		while (32 == characterCode || (14 > characterCode && 8 < characterCode)) {
			characterCode = #if (flash9 || js) untyped(document).cca(pointer + (--length) - 1); #else document.charCodeAt(pointer + (--length) - 1); #end
		}
	}
	#if as3
	public function getCurrentContentHandler():ContentHandler {
		return currentContentHandler;
	}
	public function getPointer():Int {
		return pointer;
	}
	#end
	/**
	 * Reads the next part of the document, and (potentially) sends the content to the passed content handler.
	 */
	public function readNextPart():Void {
		// If a greater-than character is found, it is some kind of element (rather than plain text).
		if ("<" == document.charAt(pointer)) {
			// Strip off the less-than character.
			switch (document.charAt(++pointer)) {
				// In case the element starts with "</", the element is an end-tag (such as "</book>").
				case "/":
				// Strip off the slash.
				pointer++;
				var nameLength:Int = 0;
				while (">" != document.charAt(pointer + (++nameLength))) {
				}
				// Inform the content handler of the end of the element.
				currentContentHandler.handleElementEnd(document.substr(pointer, nameLength));
				// Strip off the name of the element and the greater-than character.
				pointer += nameLength + 1;
				// In case the element starts with "<!", the element is either a comment, cdata or a DTD (document type definition).
				case "!":
				// Strip off the exclamation mark.
				switch (document.charAt(++pointer)) {
					// In case the element starts with "<![", it is cdata.
					case "[":
					// Increase the pointer by 7, because that's the earliest the string "]]>" can exist.
					pointer += 7;
					var textLength:Int = -1;
					while ("]" != document.charAt(pointer + (++textLength)) || "]" != document.charAt(pointer + textLength + 1) || ">" != document.charAt(pointer + textLength + 2)) {
					}
					// Inform the content handler of the parsed text.
					currentContentHandler.handleText(document.substr(pointer, textLength));
					// Strip off the text and the closer ("]]>").
					pointer += textLength + 3;
					// In case the element starts with "<!-", it is a comment.
					case "-":
					// Increase the pointer by 1, because that's the earliest the double-hyphen ("--") can exist. Note that a
					// double-hyphen at pointer three indicates an empty comment ("<!---->") which is considered correct by the W3C
					// specification of XML.
					pointer++;
					while ("-" != document.charAt(++pointer) || "-" != document.charAt(++pointer)) {
					}
					// This parser doesn't handle comments. Strip off the comment, including the double-hyphen and the greater-than
					// character ("-->"). Note that this line does not verify whether there's actually a greater-than character.
					pointer += 2;
					// In case the element starts with "<!", but not "<![" or "<!-", it is a DTD, or something similar.
					default:
					// This parser doesn't handle DTDs. Strip off the first character in the DTD.
					pointer++;
					// Strip off the rest of the DTD.
					while (">" != document.charAt(pointer++)) {
					}
				}
				// In case the element starts with "<?", it is a prolog.
				case "?":
				pointer += 2;
				while ("?" != document.charAt(++pointer) || ">" != document.charAt(pointer + 1)) {
				}
				// This parser doesn't handle prologs. Strip off the prolog, including the closer "?>".
				pointer += 2;
				// In case the element starts with "<", but not "</", "<!" or "<?", it is a start-tag (such as "<person>") or an
				// empty-element tag (such as "<br />").
				default:
				var nameLength:Int = 1;
				// Note that these lines do not verify whether the first character after the greater-than character is one of the
				// allowed ones. Again, in AVM2 and JavaScript use a native method for speed reasons.
				characterCode = #if (flash9 || js) untyped(document).cca(pointer + 1); #else document.charCodeAt(pointer + 1); #end
				// The first group is lowercase letters, the second group is uppercase characters, the third group is numbers, the
				// hyphen and the period, the last "group" is the underscore.
				while ((96 < characterCode && 123 > characterCode) || (64 < characterCode && 91 > characterCode) || (44 < characterCode && 58 > characterCode && 47 != characterCode) || 95 == characterCode) {
					characterCode = #if (flash9 || js) untyped(document).cca(pointer + (++nameLength)); #else document.charCodeAt(pointer + (++nameLength)); #end
				}
				var name:String = document.substr(pointer, nameLength);
				// Strip off the name.
				pointer += nameLength;
				// Trim any whitespaces after the name (between the name and the attributes, for instance).
				trimWhitespaces();
				// Use the empty attribute list initially. If actual attributes are found, a fresh list will be used.
				var attributes:Attributes = emptyAttributes;
				while (">" != document.charAt(pointer) && "/" != document.charAt(pointer)) {
					var attributeNameLength:Int = 0;
					while ("=" != document.charAt(pointer + (++attributeNameLength))) {
					}
					length = attributeNameLength;
					findLengthWithoutWhitespaces();
					var attributeName:String = document.substr(pointer, length);
					// Strip off the attribute name and the equals character.
					pointer += attributeNameLength + 1;
					// Trim any whitespaces after the attribute name.
					trimWhitespaces();
					// Store the opening quote so that the closing quote can be checked for. Note that this line does not verify
					// whether the opening quote is actually a quote.
					var quote:String = document.charAt(pointer);
					pointer++;
					var attributeValueLength:Int = -1;
					while (quote != document.charAt(pointer + (++attributeValueLength))) {
					}
					if (attributes == emptyAttributes) {
						attributes = new HashAttributes();
					}
					#if as3
					cast(attributes, HashAttributes).set(attributeName, document.substr(pointer, attributeValueLength));
					#else
					untyped(attributes).set(attributeName, document.substr(pointer, attributeValueLength));
					#end
					// Strip off the attribute value;
					pointer += attributeValueLength + 1;
					// Trim any whitespaces after the attribute value.
					trimWhitespaces();
				}
				// If a slash is found, this is an empty-element tag (a tag that both opens and closes an element).
				if ("/" == document.charAt(pointer)) {
					// Strip off the slash and the greater-than character. Note that this line does not verify whether there's
					// actually a greater-than character.
					pointer += 2;
					// Inform the content handler of both the start and the end of the element.
					currentContentHandler.handleElementStart(name, attributes, emptyElementReadSettings);
					currentContentHandler.handleElementEnd(name);
				// If no slash is found, this is a regular start-tag.
				} else {
					// Strip off the greater-than character.
					pointer++;
					// Inform the content handler of the start of the element.s
					currentContentHandler.handleElementStart(name, attributes, this);
				}
			}
			// Trim any whitespaces after the read element.
			trimWhitespaces();
		// If no greater-than character is found, it is plain-text.
		} else {
			var textLength:Int = 0;
			// TODO: Make this while not crash when the document is text-only. Text-only might not be valid XML, but it is
			// extremely common.
			while ("<" != document.charAt(pointer + (++textLength))) {
			}
			// Inform the content handler of the parsed text.
			length = textLength;
			findLengthWithoutWhitespaces();
			// Inform the content handler of the text.
			// In PHP, use the native htmlspecialchars_decode method. TODO: Test this in PHP.
			#if php
			currentContentHandler.handleText(untyped __call__("htmlspecialchars_decode", document.substr(pointer, length)));
			#else
			currentContentHandler.handleText(decodeText(document.substr(pointer, length)));
			#end
			// Strip off the text.
			pointer += textLength;
		}
	}
	public function skip():Void {
		// TODO: At least make this line more efficient by having the null content handler and wrapper in one.
		currentContentHandler = new AlternativeContentHandlerWrapper(new NullContentHandler(), currentContentHandler, this);
	}
	/**
	 * Increases the pointer as long as the character the pointer is pointing to is a whitespace. Returns true.
	 */
	private inline function trimWhitespaces():Void {
		// Again, in AVM2 and JavaScript use a native method for speed reasons.
		characterCode = #if (flash9 || js) untyped(document).cca(pointer); #else document.charCodeAt(pointer); #end
		while (32 == characterCode || (14 > characterCode && 8 < characterCode)) {
			characterCode = #if (flash9 || js) untyped(document).cca(++pointer); #else document.charCodeAt(++pointer); #end
		}
	}
	#if as3
	public function setCurrentContentHandler(value:ContentHandler):Void {
		currentContentHandler = value;
	}
	public function setDocument(value:String):Void {
		document = value;
	}
	public function setPointer(value:Int):Void {
		pointer = value;
	}
	#end
	public function useAlternativeContentHandler(value:ContentHandler):ContentHandler {
		currentContentHandler = new AlternativeContentHandlerWrapper(value, currentContentHandler, this);
		return value;
	}
}
/**
 * A wrapper around an alternative content handler. This wrapper automatically sets the original content handler back at the
 * appropriate time.
 */
class AlternativeContentHandlerWrapper implements ContentHandler {
	// The alternative content handler this wrapper wraps around.
	private var alternativeContentHandler:ContentHandler;
	// The lifetime (in depth levels) of the alternative content handler.
	private var lifetime:Int;
	// The original content handler that will be set back.
	private var originalContentHandler:ContentHandler;
	// A reference to the read engine. This reference is used to set the original content handler back.
	private var readEngine:XmlReadEngine;
	public function new(alternativeContentHandler:ContentHandler, originalContentHandler:ContentHandler, readEngine:XmlReadEngine):Void {
		this.alternativeContentHandler = alternativeContentHandler;
		this.originalContentHandler = originalContentHandler;
		this.readEngine = readEngine;
	}
	public function handleElementEnd(name:String):Void {
		// If the lifetime is now zero, set the original content handler back.
		if (lifetime-- == 0) {
			#if as3
			readEngine.setCurrentContentHandler(originalContentHandler);
			#else
			readEngine.currentContentHandler = originalContentHandler;
			#end
			// Notify the original content handler of the end of the element.
			originalContentHandler.handleElementEnd(name);
		} else {
			// Route the call to the alternative content handler.
			alternativeContentHandler.handleElementEnd(name);
		}
	}
	public function handleElementStart(name:String, attributes:Attributes, elementReadSettings:ElementReadSettings):Void {
		lifetime++;
		// Route the call to the alternative content handler.
		alternativeContentHandler.handleElementStart(name, attributes, elementReadSettings);
	}
	public function handleText(value:String):Void {
		// Route the call to the alternative content handler.
		alternativeContentHandler.handleText(value);
	}
}
class NullContentHandler implements ContentHandler {
	public function new():Void {
	}
	public function handleElementEnd(name:String):Void {
	}
	public function handleElementStart(name:String, attributes:Attributes, elementReadSettings:ElementReadSettings):Void {
	}
	public function handleText(value:String):Void {
	}
}
class TreeConvertingContentHandler implements ContentHandler {
	private var childrenStack:List<ListChildren>;
	public var closingElementName:String;
	public var result:ListChildren;
	public var working:Bool;
	public function new():Void {
		childrenStack = new List();
		childrenStack.push(result = new ListChildren());
		working = true;
	}
	public function handleElementEnd(name:String):Void {
		childrenStack.pop();
		if (childrenStack.isEmpty()) {
			working = false;
			closingElementName = name;
		}
	}
	public function handleElementStart(name:String, attributes:Attributes, elementReadSettings:ElementReadSettings):Void {
		var children:ListChildren = new ListChildren();
		childrenStack.first().addElement(new Element(name, attributes, children));
		childrenStack.push(children);
	}
	public function handleText(value:String):Void {
		childrenStack.first().addText(value);
	}
}
class ListChildren implements Children {
	private var childList:List<Child>;
	private var elementList:List<Element>;
	public var elements(getElements, never):Iterator<Element>;
	public var firstChild(getFirstChild, never):Child;
	public var firstElementChild(getFirstElementChild, never):Element;
	public var firstTextChild(getFirstTextChild, never):String;
	public var lastChild(getLastChild, never):Child;
	public var lastElementChild(getLastElementChild, never):Element;
	public var lastTextChild(getLastTextChild, never):String;
	private var textList:List<String>;
	public var texts(getTexts, never):Iterator<String>;
	public function new():Void {
	}
	public function addElement(value:Element):Void {
		if (null == elementList) {
			elementList = new List();
			if (null == childList) {
				childList = new List();
			}
		}
		elementList.add(value);
		childList.add(Child.element(value));
	}
	public function addText(value:String):Void {
		if (null == textList) {
			textList = new List();
			if (null == childList) {
				childList = new List();
			}
		}
		textList.add(value);
		childList.add(Child.text(value));
	}
	public function iterator():Iterator<Child> {
		if (null == childList) {
			return this;
		} else {
			return childList.iterator();
		}
	}
	private function getElements():Iterator<Element> {
		if (null == elementList) {
			return this;
		} else {
			return elementList.iterator();
		}
	}
	private function getFirstChild():Child {
		if (null == childList) {
			return null;
		} else {
			return childList.first();
		}
	}
	private function getFirstElementChild():Element {
		if (null == elementList) {
			return null;
		} else {
			return elementList.first();
		}
	}
	public function getFirstElementNamed(name:String):Element {
		if (null != elementList) {
			for (candidate in elementList) {
				if (name == candidate.name) {
					return candidate;
				}
			}
		}
		return null;
	}
	private function getFirstTextChild():String {
		if (null == textList) {
			return null;
		} else {
			return textList.first();
		}
	}
	private function getLastChild():Child {
		if (null == childList) {
			return null;
		} else {
			return childList.last();
		}
	}
	private function getLastElementChild():Element {
		if (null == elementList) {
			return null;
		} else {
			return elementList.last();
		}
	}
	private function getLastTextChild():String {
		if (null == textList) {
			return null;
		} else {
			return textList.last();
		}
	}
	private function getTexts():Iterator<String> {
		if (null == textList) {
			return this;
		} else {
			return textList.iterator();
		}
	}
	public function hasNext():Bool {
		return false;
	}
	public function next():Dynamic {
		return null;
	}
	#if debug
	private function toString():String {
		if (null == childList) {
			return "[Children]";
		} else {
			return "[Children " + childList.join(", ") + "]";
		}
	}
	#end
}
/**
 * The element read settings used for empty-element tags. This implementation is super simple, because empty-element tags never
 * contain any child elements.
 */
class EmptyElementReadSettings implements ElementReadSettings {
	public var contentHandler(never, useAlternativeContentHandler):ContentHandler;
	public static var emptyChildren:NullChildren;
	public function new():Void {
		if (null == emptyChildren) {
			emptyChildren = new NullChildren();
		}
	}
	public function convertToTree():Children {
		return emptyChildren;
	}
	public function skip():Void {
	}
	public function useAlternativeContentHandler(value:ContentHandler):ContentHandler {
		return value;
	}
}
