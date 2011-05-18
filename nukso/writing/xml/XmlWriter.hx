package nukso.writing.xml;

/**
 * A writer that writes or generates a XML documents.
 */
class XmlWriter {
	private var indent:Bool;
	public function new(indent:Bool = true):Void {
		this.indent = indent;
	}
	public function write(addContent:DocumentBuffer -> Void):String {
		var buffer:SingleLineXmlBuffer = new SingleLineXmlBuffer();
		addContent(buffer);
		// While there are still started (open) elements, close them.
		while (false == buffer.nameStack.isEmpty()) {
			buffer.endElement();
		}
		return buffer.result;
	}
}
interface XmlBuffer implements DocumentBuffer {
	/**
	 * The stack of names of started (open) elements.
	 */
	public var nameStack:List<String>;
	/**
	 * The resulting document.
	 */
	public var result:String;
}
class SingleLineXmlBuffer implements XmlBuffer {
	private var greaterThanCharacterMissing:Bool;
	public var nameStack:List<String>;
	public var result:String;
	public function new():Void {
		nameStack = new List();
		result = "";
	}
	public function addText(value:String):Void {
		// If a greater than character (from the element start) is missing, add it now.
		if (greaterThanCharacterMissing) {
			result += ">";
			greaterThanCharacterMissing = false;
		}
		result += value;
	}
	public function endElement():Void {
		// If no greater-than character has been placed since the element start, this element is empty. Complete it as an
		// empty-element tag, instead.
		if (greaterThanCharacterMissing) {
			result += " />";
			nameStack.pop();
			greaterThanCharacterMissing = false;
		// If this element is not empty, add an element end tag to the resulting document.
		} else {
			result += "</" + nameStack.pop() + ">";
		}
	}
	public function startElement(name:String, ?attributes:Attributes):Void {
		// If a greater than character (from the previous element start) is missing, add it now.
		if (greaterThanCharacterMissing) {
			result += ">";
		}
		// If attributes are passed, add an element start tag with the passed attributes.
		if (null != attributes) {
			result += "<" + name;
			for (attributeName in attributes.names) {
				result += " " + attributeName + "=\"" + attributes.get(attributeName) + "\"";
			}
		// If no attributes are passed, add a simple element start tag.
		} else {
			result += "<" + name;
		}
		nameStack.push(name);
		greaterThanCharacterMissing = true;
	}
}
class IndentingXmlBuffer implements XmlBuffer {
	public var nameStack:List<String>;
	public var result:String;
	public function new():Void {
		nameStack = new List();
		result = "";
	}
	public function addText(value:String):Void {
		result += value;
	}
	public function endElement():Void {
		// Add an element end tag to the resulting document.
		result += "</" + nameStack.pop() + ">";
	}
	public function startElement(name:String, ?attributes:Attributes):Void {
		// If attributes are passed, add an element start tag with the passed attributes.
		if (null != attributes) {
			result += "<" + name;
			for (attributeName in attributes.names) {
				result += " " + attributeName + "='" + attributes.get(attributeName) + "'";
			}
			result += ">";
		// If no attributes are passed, add a simple element start tag.
		} else {
			result += "<" + name + ">";
		}
		nameStack.push(name);
	}
}
