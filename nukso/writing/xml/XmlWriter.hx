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
